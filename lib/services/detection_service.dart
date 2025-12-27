import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/detection_result.dart' as model;
import 'database_service.dart';

// Preprocessing enums (top-level)
enum NormalizationMode { float01, float255, minus1to1 }

enum ChannelOrder { rgb, bgr }

/// Service untuk deteksi kerusakan jalan menggunakan TFLite model (YOLOv8)
class DetectionService {
  // TFLite interpreter fields
  Interpreter? _interpreter;
  bool _isInitialized = false;
  // Calibration constants for depth estimation
  final double _assumedDamageDepthCm = 10.0;
  final double _assumedDamageWidthCm = 50.0;
  // Detection threshold (objectness) — lower for debugging if needed
  double _detectionThreshold = 0.05;
  static final DetectionService instance = DetectionService._();
  DetectionService._();

  /// Initialize TFLite model
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('🔄 Loading TFLite detection model (YOLOv8)...');

      // Check if asset exists first
      final assetPath = 'assets/models/yolov11n_int8.tflite';
      print('📁 Checking asset path: $assetPath');

      // Try loading with minimal options first for int8 quantized model
      final options = InterpreterOptions()
        ..threads =
            1 // Start with single thread
        ..useNnApiForAndroid = false; // Disable NNAPI initially

      print('🚀 Creating interpreter...');
      _interpreter = await Interpreter.fromAsset(assetPath, options: options);

      print('📊 Getting input/output details...');
      final inputShape = _interpreter!.getInputTensors().first.shape;
      final outputShape = _interpreter!.getOutputTensors().first.shape;
      print('✅ Model loaded - Input: $inputShape, Output: $outputShape');

      _isInitialized = true;
      print('✅ Detection model loaded successfully');
    } catch (e, stackTrace) {
      print('❌ Error loading TFLite model: $e');
      print('📋 Stack trace: $stackTrace');
      print('🔍 Error type: ${e.runtimeType}');

      // Don't rethrow - allow app to continue without model
      print(
        '⚠️ Continuing without model - detection features will be unavailable',
      );
      _isInitialized = true; // Mark as initialized to prevent retry
    }
  }

  /// Dispose model
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
    print('🗑️ TFLite models disposed');
  }

  /// Deteksi dari image file
  Future<List<Map<String, dynamic>>> detectFromImage(File imageFile) async {
    if (!_isInitialized) {
      await initialize();
    }
    if (_interpreter == null) {
      print('❌ Model not loaded - detection unavailable');
      throw Exception(
        'Detection model not available. Please check model file and try again.',
      );
    }
    print('🔍 Running detection on ${imageFile.path}');
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      print('❌ Failed to decode image');
      return <Map<String, dynamic>>[];
    }
    // Resize input image (YOLOv8 expects 640x640)
    final yoloInputImage = img.copyResize(image, width: 640, height: 640);
    final input = _prepareInput4D(yoloInputImage, 640, _interpreter!);

    // YOLOv8 Output: [1, 8, 8400]
    var output = List.generate(
      1,
      (_) => List.generate(8, (_) => List.filled(8400, 0.0)),
    );

    final stopwatch = Stopwatch()..start();
    _interpreter!.run(input, output);
    stopwatch.stop();
    print('✅ Detection complete (${stopwatch.elapsedMilliseconds}ms)');

    // Parse YOLO output
    final preds = output[0]; // [8, 8400]
    final detections = <Map<String, dynamic>>[];

    for (int i = 0; i < 8400; i++) {
      final conf = preds[4][i];
      if (conf < _detectionThreshold) continue;

      final x = preds[0][i];
      final y = preds[1][i];
      final w = preds[2][i];
      final h = preds[3][i];

      // Get class with highest confidence
      final clsScores = preds.sublist(5).map((c) => c[i]).toList();
      final clsIdx = clsScores.indexOf(
        clsScores.reduce((a, b) => a > b ? a : b),
      );
      final clsConf = clsScores[clsIdx];

      // Convert to pixel coordinates
      final left = ((x - w / 2) * image.width)
          .clamp(0, image.width - 1)
          .toInt();
      final top = ((y - h / 2) * image.height)
          .clamp(0, image.height - 1)
          .toInt();
      final width = (w * image.width).clamp(1, image.width - left).toInt();
      final height = (h * image.height).clamp(1, image.height - top).toInt();

      // Skip very small ROIs
      if (width < 20 || height < 20) continue;

      // Simplified size estimation
      double estWidthCm = width * 0.1;
      double estDepthCm = height * 0.05;

      detections.add({
        'class': model.RoadDamageClass.fromIndex(clsIdx),
        'confidence': conf,
        'classifier_label': model.RoadDamageClass.fromIndex(clsIdx),
        'classifier_confidence': clsConf,
        'boundingBox': {
          'left': left / image.width,
          'top': top / image.height,
          'width': width / image.width,
          'height': height / image.height,
        },
        'width_cm': estWidthCm,
        'depth_cm': estDepthCm,
      });
    }

    print('📊 Raw detections: ${detections.length}');
    final nmsDetections = _applyNMS(detections, iouThreshold: 0.45);
    print('✅ Final detections after NMS: ${nmsDetections.length}');
    return nmsDetections;
  }

  /// Convert image to Float32List for TFLite input
  Float32List _imageToFloat32List(
    img.Image image,
    int size, {
    NormalizationMode? normMode,
    ChannelOrder? chOrder,
  }) {
    final converted = Float32List(size * size * 3);
    int pixelIndex = 0;
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        final pixel = image.getPixel(j, i);
        final r = pixel.r.toDouble();
        final g = pixel.g.toDouble();
        final b = pixel.b.toDouble();

        // Normalize to 0-1 (default for most models)
        converted[pixelIndex++] = (r / 255.0);
        converted[pixelIndex++] = (g / 255.0);
        converted[pixelIndex++] = (b / 255.0);
      }
    }
    return converted;
  }

  /// Prepare input shaped [1,H,W,3] for interpreter
  dynamic _prepareInput4D(
    img.Image image,
    int size,
    Interpreter interpreter, {
    NormalizationMode? normMode,
    ChannelOrder? chOrder,
  }) {
    final flat = _imageToFloat32List(
      image,
      size,
      normMode: normMode,
      chOrder: chOrder,
    );

    // Default: float input -> nested double list
    final out = List.generate(
      1,
      (_) => List.generate(
        size,
        (_) => List.generate(size, (_) => List.filled(3, 0.0)),
      ),
    );
    int idx = 0;
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        out[0][i][j][0] = flat[idx++];
        out[0][i][j][1] = flat[idx++];
        out[0][i][j][2] = flat[idx++];
      }
    }
    return out;
  }

  /// Non-Maximum Suppression (NMS)
  List<Map<String, dynamic>> _applyNMS(
    List<Map<String, dynamic>> detections, {
    double iouThreshold = 0.5,
  }) {
    if (detections.isEmpty) return [];
    detections.sort(
      (a, b) =>
          (b['confidence'] as double).compareTo(a['confidence'] as double),
    );
    final selected = <Map<String, dynamic>>[];
    final suppressed = List.filled(detections.length, false);

    for (int i = 0; i < detections.length; i++) {
      if (suppressed[i]) continue;
      selected.add(detections[i]);
      final boxA = detections[i]['boundingBox'] as Map<String, dynamic>;

      for (int j = i + 1; j < detections.length; j++) {
        if (suppressed[j]) continue;
        final boxB = detections[j]['boundingBox'] as Map<String, dynamic>;
        final iou = _calculateIOU(boxA, boxB);
        if (iou > iouThreshold) suppressed[j] = true;
      }
    }
    return selected;
  }

  double _calculateIOU(Map<String, dynamic> boxA, Map<String, dynamic> boxB) {
    final leftA = boxA['left'] as double, topA = boxA['top'] as double;
    final widthA = boxA['width'] as double, heightA = boxA['height'] as double;
    final leftB = boxB['left'] as double, topB = boxB['top'] as double;
    final widthB = boxB['width'] as double, heightB = boxB['height'] as double;

    final xLeft = leftA > leftB ? leftA : leftB;
    final yTop = topA > topB ? topA : topB;
    final xRight = (leftA + widthA) < (leftB + widthB)
        ? (leftA + widthA)
        : (leftB + widthB);
    final yBottom = (topA + heightA) < (topB + heightB)
        ? (topA + heightA)
        : (topB + heightB);

    if (xRight < xLeft || yBottom < yTop) return 0.0;
    final intersectionArea = (xRight - xLeft) * (yBottom - yTop);
    final boxAArea = widthA * heightA;
    final boxBArea = widthB * heightB;
    final unionArea = boxAArea + boxBArea - intersectionArea;
    return intersectionArea / unionArea;
  }

  bool get isReady => _isInitialized && _interpreter != null;
}
