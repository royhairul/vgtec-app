import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../main.dart';
import '../models/detection_result.dart';
import '../services/detection_service.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../widgets/map_location_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImagePreviewScreen extends StatefulWidget {
  final String imagePath;

  const ImagePreviewScreen({super.key, required this.imagePath});

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  List<Map<String, dynamic>>? _detectionResults;
  bool _isDetecting = false;
  String? _errorMessage;
  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();
    // Lock to portrait mode for better image viewing
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _loadImage();
  }

  @override
  void dispose() {
    // Restore all orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> _loadImage() async {
    try {
      final file = File(widget.imagePath);

      // Check file size first (limit to 10MB)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('File terlalu besar. Maksimal 10MB.');
      }

      // Check if file exists and is readable
      if (!await file.exists()) {
        throw Exception('File tidak ditemukan.');
      }

      // Simple validation - just check if we can read the file
      // Don't decode to memory immediately to avoid OOM
      setState(() {
        _imageLoaded = true;
        _errorMessage = null;
      });
    } catch (e) {
      print('❌ Image load error: $e');
      setState(() {
        _errorMessage = 'Gagal memuat gambar: $e';
        _imageLoaded = false;
      });
    }
  }

  Future<ui.Image> _getImageInfo() async {
    try {
      final bytes = await File(widget.imagePath).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (e) {
      print('❌ Failed to get image info: $e');
      // Return dummy image info if failed
      throw Exception('Gagal mendapatkan info gambar');
    }
  }

  Future<void> _detectDamage() async {
    setState(() {
      _isDetecting = true;
      _errorMessage = null;
    });

    try {
      final detectionService = Provider.of<DetectionService>(
        context,
        listen: false,
      );

      // Add timeout for detection process
      final results = await detectionService
          .detectFromImage(File(widget.imagePath))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception(
              'Deteksi timeout. Coba gambar yang lebih kecil.',
            ),
          );

      setState(() {
        _detectionResults = results;
        _isDetecting = false;
      });
    } catch (e) {
      print('❌ Detection failed: $e');
      setState(() {
        _errorMessage = 'Gagal mendeteksi: $e';
        _isDetecting = false;
      });
    }
  }

  Future<void> _saveDetection() async {
    if (_detectionResults == null || _detectionResults!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada deteksi untuk disimpan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final locationService = Provider.of<LocationService>(
        context,
        listen: false,
      );

      // Get current location first with timeout
      final position = await locationService.getCurrentPosition().timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );

      // Show map picker dialog with default location if GPS fails
      final selectedLocation = await showDialog<LatLng>(
        context: context,
        builder: (context) => MapLocationPicker(
          initialLatitude: position?.latitude ?? -6.2088, // Default: Jakarta
          initialLongitude: position?.longitude ?? 106.8456,
        ),
      );

      // If user cancelled, return
      if (selectedLocation == null) {
        return;
      }

      // Show loading
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Menyimpan hasil deteksi...'),
                ],
              ),
            ),
          ),
        ),
      );

      final database = Provider.of<AppDatabase>(context, listen: false);

      // Create directory if not exists
      final appDir = await getApplicationDocumentsDirectory();
      final detectionsDir = Directory('${appDir.path}/detections');
      if (!await detectionsDir.exists()) {
        await detectionsDir.create(recursive: true);
      }

      // Copy image to app directory
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(widget.imagePath)}';
      final savedImage = await File(
        widget.imagePath,
      ).copy('${detectionsDir.path}/$fileName');

      // Save all detections to database with selected location
      int savedCount = 0;
      for (var result in _detectionResults!) {
        final detectionData = Detection(
          id: 0, // Auto-increment
          damageClass: result['class'] as String,
          confidence: (result['confidence'] as num).toDouble(),
          latitude: selectedLocation.latitude,
          longitude: selectedLocation.longitude,
          imagePath: savedImage.path,
          timestamp: DateTime.now(),
          synced: false,
          widthCm: result['width_cm'] != null
              ? (result['width_cm'] as num).toDouble()
              : null,
          depthCm: result['depth_cm'] != null
              ? (result['depth_cm'] as num).toDouble()
              : null,
        );
        await database.insertDetection(detectionData.toCompanion(false));
        savedCount++;
      }

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        Navigator.of(context).pop(); // Go back to camera screen

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$savedCount deteksi berhasil disimpan'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Close loading dialog if open
        Navigator.of(context, rootNavigator: true).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.background
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Preview Gambar'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_detectionResults == null && !_isDetecting)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              tooltip: 'Ulangi',
            ),
        ],
      ),
      body: Column(
        children: [
          // Image Preview with Bounding Boxes
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : AppColors.surfaceLightGray,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              margin: const EdgeInsets.only(bottom: 8),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                child: Center(
                  child: _imageLoaded
                      ? InteractiveViewer(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                File(widget.imagePath),
                                fit: BoxFit.contain,
                              ),
                              if (_detectionResults != null &&
                                  _detectionResults!.isNotEmpty)
                                FutureBuilder<ui.Image>(
                                  future: _getImageInfo(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      final image = snapshot.data!;
                                      return CustomPaint(
                                        painter: BoundingBoxPainter(
                                          detections: _detectionResults!,
                                          imageWidth: image.width.toDouble(),
                                          imageHeight: image.height.toDouble(),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                            ],
                          ),
                        )
                      : Center(
                          child: CircularProgressIndicator(
                            color: isDark ? Colors.white : AppColors.primary,
                          ),
                        ),
                ),
              ),
            ),
          ),

          // Detection Results or Actions
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : AppColors.surfaceWhite,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Error Message
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Detection Results - Summary Only
                    if (_detectionResults != null) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? (_detectionResults!.isEmpty
                                    ? AppColors.success.withOpacity(0.15)
                                    : AppColors.warning.withOpacity(0.15))
                              : (_detectionResults!.isEmpty
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.warning.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _detectionResults!.isEmpty
                                ? AppColors.success.withOpacity(0.5)
                                : AppColors.warning.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _detectionResults!.isEmpty
                                    ? AppColors.success.withOpacity(0.2)
                                    : AppColors.warning.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _detectionResults!.isEmpty
                                    ? Icons.check_circle_rounded
                                    : Icons.warning_amber_rounded,
                                color: _detectionResults!.isEmpty
                                    ? AppColors.success
                                    : AppColors.warning,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _detectionResults!.isEmpty
                                        ? 'Tidak ada kerusakan'
                                        : '${_detectionResults!.length} kerusakan terdeteksi',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textDark,
                                    ),
                                  ),
                                  if (_detectionResults!.isNotEmpty)
                                    Text(
                                      'Lihat kotak berwarna di gambar',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? AppColors.textSecondary
                                            : AppColors.textGray,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Action Buttons
                    if (_detectionResults == null && !_isDetecting)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _detectDamage,
                          icon: const Icon(Icons.search, size: 24),
                          label: const Text(
                            'Cek Kerusakan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),

                    if (_isDetecting)
                      SizedBox(
                        height: 56,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 3,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Mendeteksi kerusakan...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (_detectionResults != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.refresh),
                                label: const Text(
                                  'Ulangi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: _saveDetection,
                                icon: const Icon(Icons.save, size: 24),
                                label: const Text(
                                  'Simpan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter to draw bounding boxes on detected road damage
class BoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> detections;
  final double imageWidth;
  final double imageHeight;

  BoundingBoxPainter({
    required this.detections,
    required this.imageWidth,
    required this.imageHeight,
  });

  Color _getColorForClass(String damageClass) {
    switch (damageClass) {
      case RoadDamageClass.amblas:
        return Colors.red;
      case RoadDamageClass.bergelombang:
        return Colors.orange;
      case RoadDamageClass.berlubang:
        return Colors.blue;
      case RoadDamageClass.retakBuaya:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate the actual displayed image size considering aspect ratio
    final imageAspectRatio = imageWidth / imageHeight;
    final canvasAspectRatio = size.width / size.height;

    double displayWidth;
    double displayHeight;
    double offsetX = 0;
    double offsetY = 0;

    if (canvasAspectRatio > imageAspectRatio) {
      // Canvas is wider - image is limited by height
      displayHeight = size.height;
      displayWidth = displayHeight * imageAspectRatio;
      offsetX = (size.width - displayWidth) / 2;
    } else {
      // Canvas is taller - image is limited by width
      displayWidth = size.width;
      displayHeight = displayWidth / imageAspectRatio;
      offsetY = (size.height - displayHeight) / 2;
    }

    // Debug: Print first time
    if (detections.isNotEmpty) {
      print('🎨 BoundingBoxPainter Debug:');
      print(
        '   Image size: ${imageWidth.toInt()}x${imageHeight.toInt()} (aspect: ${imageAspectRatio.toStringAsFixed(2)})',
      );
      print(
        '   Canvas size: ${size.width.toInt()}x${size.height.toInt()} (aspect: ${canvasAspectRatio.toStringAsFixed(2)})',
      );
      print(
        '   Display size: ${displayWidth.toInt()}x${displayHeight.toInt()}',
      );
      print('   Offset: (${offsetX.toInt()}, ${offsetY.toInt()})');
    }

    for (var detection in detections) {
      final bbox = detection['boundingBox'] as Map<String, dynamic>;
      final damageClass = detection['class'] as String;
      final confidence = (detection['confidence'] as num).toDouble();

      // Get normalized coordinates (0-1)
      final left = (bbox['left'] as num).toDouble();
      final top = (bbox['top'] as num).toDouble();
      final width = (bbox['width'] as num).toDouble();
      final height = (bbox['height'] as num).toDouble();

      // Convert to pixel coordinates on ACTUAL displayed image
      final rect = Rect.fromLTWH(
        offsetX + (left * displayWidth),
        offsetY + (top * displayHeight),
        width * displayWidth,
        height * displayHeight,
      );

      final color = _getColorForClass(damageClass);

      // Draw bounding box
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawRect(rect, paint);

      // Draw semi-transparent background for box
      final fillPaint = Paint()
        ..color = color.withOpacity(0.15)
        ..style = PaintingStyle.fill;

      canvas.drawRect(rect, fillPaint);

      // Draw label background
      final labelText = RoadDamageClass.getDisplayName(damageClass);
      final textPainter = TextPainter(
        text: TextSpan(
          text: labelText,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.8),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Position label above the box (or inside if too close to top)
      final labelY = rect.top > textPainter.height + 8
          ? rect.top - textPainter.height - 4
          : rect.top + 4;

      // Draw label background
      final labelBgRect = Rect.fromLTWH(
        rect.left,
        labelY,
        textPainter.width + 8,
        textPainter.height + 4,
      );

      final labelBgPaint = Paint()
        ..color = color.withOpacity(0.9)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(labelBgRect, const Radius.circular(4)),
        labelBgPaint,
      );

      // Draw label text
      textPainter.paint(canvas, Offset(rect.left + 4, labelY + 2));
    }
  }

  @override
  bool shouldRepaint(BoundingBoxPainter oldDelegate) {
    return detections != oldDelegate.detections;
  }
}
