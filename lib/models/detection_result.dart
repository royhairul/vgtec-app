/// Model untuk hasil deteksi kerusakan jalan
class DetectionResult {
  final String damageClass; // amblas, bergelombang, berlubang, retak_buaya
  final double confidence;
  final double latitude;
  final double longitude;
  final String imagePath;
  final DateTime timestamp;
  final bool synced;
  final int? id;
  final double? widthCm; // estimated width in cm
  final double? depthCm; // estimated depth in cm

  DetectionResult({
    required this.damageClass,
    required this.confidence,
    required this.latitude,
    required this.longitude,
    required this.imagePath,
    required this.timestamp,
    this.synced = false,
    this.id,
    this.widthCm,
    this.depthCm,
  });

  /// Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'class': damageClass,
      'confidence': confidence,
      'latitude': latitude,
      'longitude': longitude,
      'image_path': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'synced': synced ? 1 : 0,
      'width_cm': widthCm,
      'depth_cm': depthCm,
    };
  }

  /// Create from Map (dari database)
  factory DetectionResult.fromMap(Map<String, dynamic> map) {
    return DetectionResult(
      id: map['id'] as int?,
      damageClass: map['class'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      imagePath: map['image_path'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      synced: (map['synced'] as int) == 1,
      widthCm: map['width_cm'] != null
          ? (map['width_cm'] as num).toDouble()
          : null,
      depthCm: map['depth_cm'] != null
          ? (map['depth_cm'] as num).toDouble()
          : null,
    );
  }

  /// Copy with untuk update field tertentu
  DetectionResult copyWith({
    int? id,
    String? damageClass,
    double? confidence,
    double? latitude,
    double? longitude,
    String? imagePath,
    DateTime? timestamp,
    bool? synced,
    double? widthCm,
    double? depthCm,
  }) {
    return DetectionResult(
      id: id ?? this.id,
      damageClass: damageClass ?? this.damageClass,
      confidence: confidence ?? this.confidence,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imagePath: imagePath ?? this.imagePath,
      timestamp: timestamp ?? this.timestamp,
      synced: synced ?? this.synced,
      widthCm: widthCm ?? this.widthCm,
      depthCm: depthCm ?? this.depthCm,
    );
  }
}

/// Kelas damage yang didukung
class RoadDamageClass {
  static const String amblas = 'amblas';
  static const String bergelombang = 'bergelombang';
  static const String berlubang = 'berlubang';
  static const String retakBuaya = 'retak_buaya';

  static const List<String> all = [amblas, bergelombang, berlubang, retakBuaya];

  /// Mapping index ke class name (sesuai model TFLite)
  static String fromIndex(int index) {
    switch (index) {
      case 0:
        return amblas;
      case 1:
        return bergelombang;
      case 2:
        return berlubang;
      case 3:
        return retakBuaya;
      default:
        return 'unknown';
    }
  }

  /// Get display name (untuk UI)
  static String getDisplayName(String className) {
    switch (className) {
      case amblas:
        return 'Amblas';
      case bergelombang:
        return 'Bergelombang';
      case berlubang:
        return 'Berlubang';
      case retakBuaya:
        return 'Retak Buaya';
      default:
        return 'Unknown';
    }
  }
}
