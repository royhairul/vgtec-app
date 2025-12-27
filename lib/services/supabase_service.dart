import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/detection_result.dart';

/// Service untuk sync data ke Supabase
class SupabaseService {
  static final SupabaseService instance = SupabaseService._();
  SupabaseService._();

  SupabaseClient? _client;
  bool _isInitialized = false;

  /// Initialize Supabase (panggil di main.dart)
  Future<void> initialize(String url, String anonKey) async {
    if (_isInitialized) return;

    try {
      await Supabase.initialize(url: url, anonKey: anonKey);
      _client = Supabase.instance.client;
      _isInitialized = true;
      print('✅ Supabase initialized');
    } catch (e) {
      print('❌ Supabase initialization failed: $e');
      // Jangan throw error, biar app tetap jalan offline
    }
  }

  /// Check if connected to internet & Supabase
  bool get isAvailable => _isInitialized && _client != null;

  /// Upload detection ke Supabase
  Future<bool> uploadDetection(DetectionResult detection) async {
    if (!isAvailable) {
      print('⚠️ Supabase not available, skipping upload');
      return false;
    }

    try {
      final response = await _client!
          .from('detections')
          .insert(detection.toMap())
          .select();

      print('✅ Detection uploaded to Supabase');
      return true;
      return false;
    } catch (e) {
      print('❌ Error uploading detection: $e');
      return false;
    }
  }

  /// Upload multiple detections (batch)
  Future<int> uploadDetections(List<DetectionResult> detections) async {
    if (!isAvailable || detections.isEmpty) return 0;

    int successCount = 0;
    for (final detection in detections) {
      final success = await uploadDetection(detection);
      if (success) successCount++;
    }

    print('✅ Uploaded $successCount/${detections.length} detections');
    return successCount;
  }

  /// Get all detections from Supabase
  Future<List<DetectionResult>> getDetections({int limit = 100}) async {
    if (!isAvailable) return [];

    try {
      final response = await _client!
          .from('detections')
          .select()
          .order('timestamp', ascending: false)
          .limit(limit);

      final List<DetectionResult> detections = [];
      for (final item in response) {
        detections.add(DetectionResult.fromMap(item));
      }

      return detections;
    } catch (e) {
      print('❌ Error fetching detections: $e');
      return [];
    }
  }

  /// Stream detections (real-time)
  Stream<List<DetectionResult>>? streamDetections() {
    if (!isAvailable) return null;

    return _client!
        .from('detections')
        .stream(primaryKey: ['id'])
        .order('timestamp', ascending: false)
        .limit(50)
        .map((data) {
          return data.map((item) => DetectionResult.fromMap(item)).toList();
        });
  }

  /// Delete detection
  Future<bool> deleteDetection(int id) async {
    if (!isAvailable) return false;

    try {
      await _client!.from('detections').delete().eq('id', id);
      print('✅ Detection deleted from Supabase');
      return true;
    } catch (e) {
      print('❌ Error deleting detection: $e');
      return false;
    }
  }
}
