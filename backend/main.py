
from pathlib import Path
import io

import timm
import torch
import torch.nn as nn

from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware

from PIL import Image, UnidentifiedImageError
from torchvision import transforms


# -------------------- Configuration --------------------

BASE_DIR = Path(__file__).resolve().parent

MODEL_PATH = (
    BASE_DIR / "models" / "deepshield_efficientnet_b3_mhsa_best.pth"
)

DEVICE = torch.device(
    "cuda" if torch.cuda.is_available() else "cpu"
)

IMAGE_SIZE = 300

CLASS_NAMES = ["FAKE", "REAL"]

SUPPORTED_FORMATS = {"JPEG", "PNG"}


# -------------------- FastAPI Application --------------------

app = FastAPI(
    title="DeepShield Image Detection API",
    description="Deepfake image detection using EfficientNet-B3 and MHSA",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restrict before production deployment
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


# -------------------- Image Preprocessing --------------------

preprocess = transforms.Compose([
    transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),
    transforms.ToTensor(),
    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225],
    ),
])


# -------------------- MHSA Architecture --------------------

class MHSA(nn.Module):
    def __init__(self, channels, heads=4):
        super().__init__()

        self.norm = nn.LayerNorm(channels)

        self.attention = nn.MultiheadAttention(
            embed_dim=channels,
            num_heads=heads,
            batch_first=True,
        )

        self.scale = nn.Parameter(torch.tensor(0.1))

    def forward(self, x):
        batch, channels, height, width = x.shape

        # Convert spatial feature maps into attention tokens.
        tokens = x.flatten(2).transpose(1, 2)

        normalized = self.norm(tokens)

        attended, _ = self.attention(
            normalized,
            normalized,
            normalized,
            need_weights=False,
        )

        # Residual attention connection.
        tokens = tokens + self.scale * attended

        return tokens.transpose(1, 2).reshape(
            batch,
            channels,
            height,
            width,
        )


class DeepShieldMHSA(nn.Module):
    def __init__(self):
        super().__init__()

        self.backbone = timm.create_model(
            "efficientnet_b3",
            pretrained=False,
            num_classes=0,
        )

        channels = self.backbone.num_features

        self.mhsa = MHSA(
            channels,
            heads=4,
        )

        self.pool = nn.AdaptiveAvgPool2d(1)

        self.classifier = nn.Linear(
            channels,
            2,
        )

    def forward(self, x):
        features = self.backbone.forward_features(x)

        features = self.mhsa(features)

        features = self.pool(features).flatten(1)

        return self.classifier(features)


# -------------------- Load Trained Model --------------------

model = None
model_load_error = None

try:
    if not MODEL_PATH.is_file():
        raise FileNotFoundError(
            f"Model checkpoint not found: {MODEL_PATH}"
        )

    checkpoint = torch.load(
        MODEL_PATH,
        map_location="cpu",
        weights_only=False,
    )

    # Support wrapped checkpoints and raw state dictionaries.
    if (
        isinstance(checkpoint, dict)
        and "model_state_dict" in checkpoint
    ):
        weights = checkpoint["model_state_dict"]

    elif isinstance(checkpoint, dict):
        weights = checkpoint

    else:
        raise ValueError("Unsupported checkpoint format.")

    candidate = DeepShieldMHSA()

    candidate.load_state_dict(
        weights,
        strict=True,
    )

    candidate.to(DEVICE)
    candidate.eval()

    model = candidate

    print(
        f"DeepShield MHSA model loaded successfully on {DEVICE}."
    )

except Exception as exc:
    model_load_error = str(exc)

    print(
        f"Model loading failed: {model_load_error}"
    )


# -------------------- API Endpoints --------------------

@app.get("/")
def home():
    return {
        "app": "DeepShield",
        "model": "EfficientNet-B3 + 4-head MHSA",
        "model_loaded": model is not None,
        "device": str(DEVICE),
    }


@app.get("/health")
def health():
    return {
        "status": "ready" if model is not None else "model_error",
        "model_loaded": model is not None,
        "error": model_load_error,
    }


# -------------------- Image Prediction --------------------

@app.post("/predict")
async def predict(file: UploadFile = File(...)):

    if model is None:
        raise HTTPException(
            status_code=503,
            detail=f"Model unavailable: {model_load_error}",
        )

    try:
        # Read uploaded file.
        contents = await file.read()

        if not contents:
            raise HTTPException(
                status_code=400,
                detail="The uploaded file is empty.",
            )

        # Validate the actual image contents instead of relying
        # on the MIME type supplied by the mobile device.
        try:
            with Image.open(io.BytesIO(contents)) as uploaded_image:

                image_format = uploaded_image.format

                if image_format not in SUPPORTED_FORMATS:
                    raise HTTPException(
                        status_code=415,
                        detail=(
                            "Unsupported image format. "
                            "Please upload a JPG, JPEG or PNG image."
                        ),
                    )

                uploaded_image.verify()

        except UnidentifiedImageError:
            raise HTTPException(
                status_code=400,
                detail="The uploaded file is not a valid image.",
            )

        except OSError:
            raise HTTPException(
                status_code=400,
                detail="The image is damaged or cannot be opened.",
            )

        # Reopen the validated image and convert it to RGB.
        with Image.open(io.BytesIO(contents)) as uploaded_image:
            image = uploaded_image.convert("RGB")

        # Apply the same preprocessing used by the model.
        tensor = preprocess(image).unsqueeze(0).to(DEVICE)

        # Run inference.
        with torch.inference_mode():
            logits = model(tensor)

            probabilities = torch.softmax(
                logits,
                dim=1,
            )[0]

        predicted_index = int(
            probabilities.argmax().item()
        )

        label = CLASS_NAMES[predicted_index]

        confidence = float(
            probabilities[predicted_index].item()
        )

        fake_probability = float(
            probabilities[0].item()
        )

        real_probability = float(
            probabilities[1].item()
        )

        return {
            "filename": file.filename,
            "prediction": label,
            "confidence": round(confidence, 6),
            "probabilities": {
                "fake": round(fake_probability, 6),
                "real": round(real_probability, 6),
            },
        }

    except HTTPException:
        raise

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=f"Image analysis failed: {exc}",
        )

    finally:
        await file.close()
