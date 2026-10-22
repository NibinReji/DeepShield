import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'analysisresult.dart';

enum MediaType { image, video }

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  final ImagePicker _picker = ImagePicker();

  XFile? _selectedFile;
  MediaType _mediaType = MediaType.image;

  static const Color _green = Color(0xFF216B5C);
  static const Color _lightGreen = Color(0xFFE4F1EE);
  static const Color _textColor = Color(0xFF18201F);
  static const Color _mutedColor = Color(0xFF737C79);

  Future<void> _pickImage() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (file == null || !mounted) return;

      setState(() {
        _selectedFile = file;
        _mediaType = MediaType.image;
      });
    } catch (e) {
      _showMessage('Could not select image: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final file = await _picker.pickVideo(source: ImageSource.gallery);

      if (file == null || !mounted) return;

      setState(() {
        _selectedFile = file;
        _mediaType = MediaType.video;
      });
    } catch (e) {
      _showMessage('Could not select video: $e');
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _analyzeMedia() async {
    final file = _selectedFile;

    if (file == null) {
      _showMessage('Please select an image first.');
      return;
    }

    if (_mediaType == MediaType.video) {
      _showMessage(
        'Video analysis is not available yet. Please select an image.',
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AnalysisResultScreen(imageFile: file)),
    );
  }

  String _fileSize() {
    final file = _selectedFile;
    if (file == null) return '';

    try {
      final bytes = File(file.path).lengthSync();

      if (bytes < 1024) return '$bytes B';

      if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} KB';
      }

      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: _textColor),
        ),
        title: const Text(
          'Analyze Media',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Check your media',
                style: TextStyle(
                  fontSize: 28,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Upload an image or video to check for potentially '
                'AI-generated or manipulated content.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: _mutedColor,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Select media type',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF27302E),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _mediaTypeButton(
                      icon: Icons.image_outlined,
                      title: 'Image',
                      selected: _mediaType == MediaType.image,
                      onTap: _pickImage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _mediaTypeButton(
                      icon: Icons.videocam_outlined,
                      title: 'Video',
                      selected: _mediaType == MediaType.video,
                      onTap: _pickVideo,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _selectedFile == null ? _buildUploadBox() : _buildSelectedMedia(),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'Images: JPG, PNG, JPEG  •  Video preview only',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Color(0xFF8A9290)),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _analyzeMedia,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.analytics_outlined),
                      SizedBox(width: 9),
                      Text(
                        'Analyze Media',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mediaTypeButton({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 85,
        decoration: BoxDecoration(
          color: selected ? _lightGreen : const Color(0xFFF7F9F8),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? _green : const Color(0xFFE0E8E5),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 27,
              color: selected ? _green : const Color(0xFF687370),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? _green : const Color(0xFF4D5754),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBox() {
    final isImage = _mediaType == MediaType.image;

    return GestureDetector(
      onTap: isImage ? _pickImage : _pickVideo,
      child: Container(
        width: double.infinity,
        height: 270,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7F6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFDCE5E2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 65,
              width: 65,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: _lightGreen,
              ),
              child: Icon(
                isImage
                    ? Icons.add_photo_alternate_outlined
                    : Icons.video_library_outlined,
                size: 30,
                color: _green,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isImage ? 'Upload an image' : 'Upload a video',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF27302E),
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Tap to choose from your device',
              style: TextStyle(fontSize: 13, color: Color(0xFF7A8380)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
              decoration: BoxDecoration(
                color: _lightGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Choose File',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedMedia() {
    final file = _selectedFile!;
    final isImage = _mediaType == MediaType.image;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E8E5)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: SizedBox(
              height: 280,
              width: double.infinity,
              child: isImage
                  ? Image.file(
                      File(file.path),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 60,
                          color: Color(0xFF60706C),
                        ),
                      ),
                    )
                  : Container(
                      color: const Color(0xFFE8EFED),
                      child: const Center(
                        child: Icon(
                          Icons.videocam_outlined,
                          size: 70,
                          color: Color(0xFF60706C),
                        ),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _lightGreen,
                  ),
                  child: Icon(
                    isImage ? Icons.image_outlined : Icons.videocam_outlined,
                    color: _green,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF27302E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _fileSize(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: _mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _removeFile,
                  icon: const Icon(Icons.close),
                  color: _mutedColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
