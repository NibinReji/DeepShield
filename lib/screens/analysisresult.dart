import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AnalysisResultScreen extends StatefulWidget {
  final XFile imageFile;

  const AnalysisResultScreen({super.key, required this.imageFile});

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen>
    with SingleTickerProviderStateMixin {
  static const Color green = Color(0xFF216B5C);
  static const Color lightGreen = Color(0xFFE4F1EE);
  static const Color textColor = Color(0xFF18201F);
  static const Color mutedColor = Color(0xFF737C79);
  static const Color fakeColor = Color(0xFFB42318);

  // Physical Android phone connects using your laptop's LAN IP.
  static const String apiUrl = 'http://192.168.1.34:8000/predict';

  bool isLoading = true;
  String? errorMessage;
  String? prediction;
  double? confidence;
  double? fakeProbability;
  double? realProbability;

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _analyzeImage();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _analyzeImage() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
      prediction = null;
      confidence = null;
      fakeProbability = null;
      realProbability = null;
    });

    try {
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          widget.imageFile.path,
          filename: widget.imageFile.name,
        ),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 120),
      );

      final response = await http.Response.fromStream(streamedResponse);

      dynamic data;

      try {
        data = jsonDecode(response.body);
      } catch (_) {
        throw Exception('The server returned an invalid response.');
      }

      if (response.statusCode != 200) {
        final detail = data is Map ? data['detail']?.toString() : null;

        throw Exception(detail ?? 'Server error: ${response.statusCode}');
      }

      if (data is! Map) {
        throw Exception('Unexpected response from the server.');
      }

      final receivedPrediction = data['prediction']?.toString().toUpperCase();
      final receivedConfidence = data['confidence'];

      if (receivedPrediction != 'REAL' && receivedPrediction != 'FAKE') {
        throw Exception('The server returned an invalid prediction.');
      }

      if (receivedConfidence is! num ||
          !receivedConfidence.toDouble().isFinite ||
          receivedConfidence < 0 ||
          receivedConfidence > 1) {
        throw Exception('The server returned an invalid confidence.');
      }

      double? fake;
      double? real;

      final probabilities = data['probabilities'];

      if (probabilities is Map) {
        final fakeValue = probabilities['fake'];
        final realValue = probabilities['real'];

        if (fakeValue is num) fake = fakeValue.toDouble();
        if (realValue is num) real = realValue.toDouble();
      }

      if (!mounted) return;

      setState(() {
        prediction = receivedPrediction;
        confidence = receivedConfidence.toDouble();
        fakeProbability = fake;
        realProbability = real;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      String message;

      if (error is SocketException) {
        message =
            'Cannot connect to the server. Check that FastAPI is running, '
            'your phone and laptop use the same Wi-Fi, and Windows Firewall '
            'allows the connection.';
      } else if (error is http.ClientException) {
        message = 'Network error. Check the server connection.';
      } else {
        message = error.toString().replaceFirst('Exception: ', '');
      }

      setState(() {
        errorMessage = message;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReal = prediction == 'REAL';
    final resultColor = isReal ? green : fakeColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: textColor),
        ),
        title: const Text(
          'Analysis Result',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isLoading
              ? _buildLoading()
              : errorMessage != null
              ? _buildError()
              : _buildResult(resultColor, isReal),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      key: const ValueKey('loading'),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _animationController,
              child: Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.document_scanner_outlined,
                  size: 55,
                  color: green,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Analyzing your image',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please wait while DeepShield processes your image.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.5, color: mutedColor),
            ),
            const SizedBox(height: 30),
            const SizedBox(
              width: 220,
              child: LinearProgressIndicator(
                color: green,
                backgroundColor: lightGreen,
                minHeight: 6,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Checking image features...',
              style: TextStyle(fontSize: 13, color: mutedColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      key: const ValueKey('error'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: fakeColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                size: 45,
                color: fakeColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Analysis Failed',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: mutedColor,
              ),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _analyzeImage,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(Color resultColor, bool isReal) {
    return SingleChildScrollView(
      key: const ValueKey('result'),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Analysis complete',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Here is the prediction returned by your model.',
            style: TextStyle(fontSize: 14, height: 1.5, color: mutedColor),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.file(
              File(widget.imageFile.path),
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 160,
                color: lightGreen,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  size: 50,
                  color: green,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: resultColor.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: resultColor.withValues(alpha: 0.25)),
            ),
            child: Column(
              children: [
                Icon(
                  isReal
                      ? Icons.verified_outlined
                      : Icons.warning_amber_rounded,
                  size: 62,
                  color: resultColor,
                ),
                const SizedBox(height: 12),
                Text(
                  prediction ?? 'UNKNOWN',
                  style: TextStyle(
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                    color: resultColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isReal ? 'Predicted as real' : 'Predicted as fake',
                  style: const TextStyle(fontSize: 14, color: mutedColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _buildConfidenceCard(resultColor),
          if (fakeProbability != null && realProbability != null) ...[
            const SizedBox(height: 16),
            _buildProbabilityCard(
              'FAKE probability',
              fakeProbability!,
              fakeColor,
            ),
            const SizedBox(height: 12),
            _buildProbabilityCard('REAL probability', realProbability!, green),
          ],
          const SizedBox(height: 22),
          Text(
            widget.imageFile.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: mutedColor),
          ),
          const SizedBox(height: 12),
          const Text(
            'This result is a model prediction, not a guarantee '
            'that the image is authentic or manipulated.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, height: 1.5, color: mutedColor),
          ),
          const SizedBox(height: 26),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Analyze Another Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceCard(Color color) {
    final value = confidence ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Model confidence',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              Text(
                '${(value * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 8,
              color: color,
              backgroundColor: const Color(0xFFE0E6E4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProbabilityCard(String label, double value, Color color) {
    final percentage = value.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8ECEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(1)}%',
                style: TextStyle(fontWeight: FontWeight.w800, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 7,
              color: color,
              backgroundColor: const Color(0xFFE0E6E4),
            ),
          ),
        ],
      ),
    );
  }
}
