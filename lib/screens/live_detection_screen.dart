import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../services/detection_service.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../models/detection_result.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LiveDetectionScreen extends StatefulWidget {
  const LiveDetectionScreen({super.key});

  @override
  State<LiveDetectionScreen> createState() => _LiveDetectionScreenState();
}

class _LiveDetectionScreenState extends State<LiveDetectionScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isDetecting = false;
  bool _isInitialized = false;
  List<Map<String, dynamic>> _currentDetections = [];
  Timer? _detectionTimer;
  late DetectionService _detectionService;

  @override
  void initState() {
    super.initState();
    // Lock orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Hide system UI for fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializeCamera();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _detectionService = context.read<DetectionService>();
  }

  Future<void> _initializeCamera() async {
    try {
      print('📷 Initializing camera...');
      _cameras = await availableCameras();
      print('📷 Available cameras: ${_cameras?.length ?? 0}');

      if (_cameras == null || _cameras!.isEmpty) {
        print('❌ No cameras available');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak ada kamera tersedia'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      print('📷 Using camera: ${_cameras!.first.name}');
      _controller = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      print('📷 Initializing controller...');
      await _controller!.initialize();

      // FORCE portrait orientation for camera
      await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);

      print('✅ Camera initialized successfully (portrait locked)');

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e, stackTrace) {
      print('❌ Camera initialization error: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing camera: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _startLiveDetection() {
    if (_isDetecting ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      print(
        '⚠️ Cannot start detection: detecting=$_isDetecting, controller=${_controller != null}, initialized=${_controller?.value.isInitialized}',
      );
      return;
    }

    print('▶️ Starting live detection...');
    setState(() => _isDetecting = true);

    // Run detection every 2 seconds
    _detectionTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!_isDetecting || !mounted) {
        timer.cancel();
        return;
      }

      try {
        // Capture image
        print('📸 Capturing image...');
        final image = await _controller!.takePicture();
        print('✅ Image captured: ${image.path}');

        // Ensure detection service is initialized
        print('⚙️ Initializing detection service...');
        await _detectionService.initialize();

        // Run detection
        print('🔍 Running detection...');
        final results = await _detectionService.detectFromImage(
          File(image.path),
        );

        if (mounted) {
          setState(() {
            _currentDetections = results;
          });
        }

        // Delete temporary image
        await File(image.path).delete();
      } catch (e) {
        print('❌ Detection error: $e');
      }
    });
  }

  void _stopLiveDetection() {
    setState(() {
      _isDetecting = false;
      _currentDetections.clear();
    });
    _detectionTimer?.cancel();
  }

  Future<void> _captureAndSave() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      // Stop live detection temporarily
      final wasDetecting = _isDetecting;
      if (_isDetecting) {
        _stopLiveDetection();
      }

      // Capture image
      final image = await _controller!.takePicture();

      // Show loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      // Ensure detection service is initialized
      await _detectionService.initialize();

      // Run detection
      final results = await _detectionService.detectFromImage(File(image.path));

      // Get location
      final locationService = context.read<LocationService>();
      final position = await locationService.getCurrentPosition();

      // Save image permanently
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = File(path.join(appDir.path, fileName));
      await File(image.path).copy(savedImage.path);

      // Save to database
      final database = context.read<AppDatabase>();

      if (results.isNotEmpty) {
        for (var detection in results) {
          final result = DetectionResult(
            damageClass: detection['class'] as String,
            confidence: detection['confidence'] as double,
            latitude: position?.latitude ?? 0.0,
            longitude: position?.longitude ?? 0.0,
            imagePath: savedImage.path,
            timestamp: DateTime.now(),
            synced: false,
            widthCm: detection['width_cm'] != null
                ? (detection['width_cm'] as num).toDouble()
                : null,
            depthCm: detection['depth_cm'] != null
                ? (detection['depth_cm'] as num).toDouble()
                : null,
          );
          await database.insertDetection(result.toCompanion());
        }
      }

      // Close loading
      if (mounted) {
        Navigator.of(context).pop();

        // Show success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              results.isEmpty
                  ? 'Foto disimpan (tidak ada kerusakan terdeteksi)'
                  : 'Berhasil menyimpan ${results.length} deteksi',
            ),
            backgroundColor: results.isEmpty ? Colors.orange : Colors.green,
          ),
        );

        // Resume live detection if it was active
        if (wasDetecting) {
          _startLiveDetection();
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    _controller?.dispose();
    // Restore system UI and orientation
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: !_isInitialized
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Memuat kamera...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                // Camera Preview - Fullscreen dengan aspect ratio yang benar
                _buildCameraPreview(size),

                // Dark overlay untuk top (solid color)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 120,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ),
                ),

                // Dark overlay untuk bottom (solid color)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 180,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),

                // Top controls
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            iconSize: 28,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        // Title
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Live Detection',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        // Play/Pause button
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isDetecting
                                ? Colors.red.withOpacity(0.9)
                                : Colors.black.withOpacity(0.5),
                            boxShadow: [
                              BoxShadow(
                                color: _isDetecting
                                    ? Colors.red.withOpacity(0.5)
                                    : Colors.black.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              _isDetecting ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            iconSize: 28,
                            onPressed: _isDetecting
                                ? _stopLiveDetection
                                : _startLiveDetection,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Detection results overlay (tengah atas)
                if (_currentDetections.isNotEmpty)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 80,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Kerusakan Terdeteksi',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_currentDetections.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ..._currentDetections.take(3).map((detection) {
                            final className = detection['class'] as String;
                            final confidence =
                                detection['confidence'] as double;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.5),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      RoadDamageClass.getDisplayName(className),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${(confidence * 100).toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          if (_currentDetections.length > 3)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Center(
                                child: Text(
                                  '+${_currentDetections.length - 3} lainnya',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                // Bottom controls - Instagram/TikTok style
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Status indicator
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _isDetecting
                                  ? Colors.red
                                  : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: _isDetecting
                                      ? Colors.red.withOpacity(0.5)
                                      : Colors.black.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: _isDetecting
                                        ? [
                                            BoxShadow(
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _isDetecting ? 'LIVE' : 'PAUSED',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Capture button - TikTok style
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.white,
                              shape: const CircleBorder(),
                              child: InkWell(
                                onTap: _captureAndSave,
                                customBorder: const CircleBorder(),
                                child: const Center(
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 32,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap untuk simpan',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCameraPreview(Size size) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    // Hitung scale untuk fullscreen
    final scale = size.aspectRatio * _controller!.value.aspectRatio;

    // Jika scale < 1, berarti kamera lebih tinggi, gunakan horizontal fill
    // Jika scale > 1, berarti kamera lebih lebar, gunakan vertical fill
    if (scale < 1) {
      return Center(
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: CameraPreview(_controller!),
        ),
      );
    } else {
      return Transform.scale(
        scale: scale,
        child: Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: CameraPreview(_controller!),
          ),
        ),
      );
    }
  }
}
