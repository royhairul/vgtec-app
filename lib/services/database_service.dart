// import 'dart:io';
// import 'package:drift/drift.dart';
// import 'package:drift_flutter/drift_flutter.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as p;
// import '../models/detection_result.dart' as model;

// part 'database_service.g.dart';

// /// Table untuk deteksi kerusakan jalan
// class Detections extends Table {
//   IntColumn get id => integer().autoIncrement()();
//   TextColumn get damageClass => text().named('class')();
//   RealColumn get confidence => real()();
//   RealColumn get latitude => real()();
//   RealColumn get longitude => real()();
//   TextColumn get imagePath => text()();
//   DateTimeColumn get timestamp => dateTime()();
//   BoolColumn get synced => boolean().withDefault(const Constant(false))();
// }

// @DriftDatabase(tables: [Detections])
// class AppDatabase extends _$AppDatabase {
//   AppDatabase() : super(_openConnection());

//   @override
//   int get schemaVersion => 1;

//   /// Get all detections
//   Future<List<Detection>> getAllDetections() async {
//     return await select(detections).get();
//   }

//   /// Get detections dengan filter
//   Future<List<Detection>> getDetectionsByClass(String damageClass) async {
//     return await (select(
//       detections,
//     )..where((tbl) => tbl.damageClass.equals(damageClass))).get();
//   }

//   /// Get unsynced detections (untuk sync ke Supabase)
//   Future<List<Detection>> getUnsyncedDetections() async {
//     return await (select(
//       detections,
//     )..where((tbl) => tbl.synced.equals(false))).get();
//   }

//   /// Insert detection
//   Future<int> insertDetection(DetectionsCompanion detection) async {
//     return await into(detections).insert(detection);
//   }

//   /// Update detection
//   Future<bool> updateDetection(Detection detection) async {
//     return await update(detections).replace(detection);
//   }

//   /// Delete detection
//   Future<int> deleteDetection(int id) async {
//     return await (delete(detections)..where((tbl) => tbl.id.equals(id))).go();
//   }

//   /// Mark as synced
//   Future<void> markAsSynced(int id) async {
//     await (update(detections)..where((tbl) => tbl.id.equals(id))).write(
//       const DetectionsCompanion(synced: Value(true)),
//     );
//   }

//   /// Get detection count by class
//   Future<Map<String, int>> getDetectionCounts() async {
//     final allDetections = await getAllDetections();
//     final counts = <String, int>{};

//     for (final detection in allDetections) {
//       counts[detection.damageClass] = (counts[detection.damageClass] ?? 0) + 1;
//     }

//     return counts;
//   }

//   /// Delete all detections (for testing)
//   Future<int> deleteAllDetections() async {
//     return await delete(detections).go();
//   }
// }

// /// Connection configuration
// LazyDatabase _openConnection() {
//   return LazyDatabase(() async {
//     final dbFolder = await getApplicationDocumentsDirectory();
//     final file = File(p.join(dbFolder.path, 'road_damage.db'));

//     print('📂 Database path: ${file.path}');

//     return driftDatabase(name: file.path);
//   });
// }

// /// Extension untuk convert antara model dan database
// extension DetectionConversion on Detection {
//   model.DetectionResult toModel() {
//     return model.DetectionResult(
//       id: id,
//       damageClass: damageClass,
//       confidence: confidence,
//       latitude: latitude,
//       longitude: longitude,
//       imagePath: imagePath,
//       timestamp: timestamp,
//       synced: synced,
//     );
//   }
// }

// extension DetectionResultConversion on model.DetectionResult {
//   DetectionsCompanion toCompanion() {
//     return DetectionsCompanion(
//       id: id != null ? Value(id!) : const Value.absent(),
//       damageClass: Value(damageClass),
//       confidence: Value(confidence),
//       latitude: Value(latitude),
//       longitude: Value(longitude),
//       imagePath: Value(imagePath),
//       timestamp: Value(timestamp),
//       synced: Value(synced),
//     );
//   }
// }

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/detection_result.dart' as model;
import '../services/supabase_service.dart';

part 'database_service.g.dart';

/// ================================================================
/// TABLE DEFINISI
/// ================================================================
class Detections extends Table {
  // id sekarang autoIncrement (biar tidak perlu diisi manual)
  IntColumn get id => integer().autoIncrement()();

  // gunakan nama kolom database 'class' agar tetap konsisten dengan model
  TextColumn get damageClass => text().named('class')();

  RealColumn get confidence => real()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get imagePath => text()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  RealColumn get widthCm => real().nullable()();
  RealColumn get depthCm => real().nullable()();
}

/// ================================================================
/// DATABASE
/// ================================================================
@DriftDatabase(tables: [Detections])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  /// Get all detections
  Future<List<Detection>> getAllDetections() async {
    return await select(detections).get();
  }

  /// Get detections berdasarkan class kerusakan
  Future<List<Detection>> getDetectionsByClass(String damageClass) async {
    return await (select(
      detections,
    )..where((tbl) => tbl.damageClass.equals(damageClass))).get();
  }

  /// Get unsynced detections (untuk sinkronisasi Supabase)
  Future<List<Detection>> getUnsyncedDetections() async {
    return await (select(
      detections,
    )..where((tbl) => tbl.synced.equals(false))).get();
  }

  /// Insert detection (tanpa id manual)
  Future<int> insertDetection(DetectionsCompanion detection) async {
    try {
      // Pastikan id tidak diisi (autoIncrement akan handle)
      final clean = detection.copyWith(id: const Value.absent());
      final insertedId = await into(detections).insert(clean);
      print(
        '💾 Inserted detection id=$insertedId class=${detection.damageClass.value}',
      );
      return insertedId;
    } catch (e) {
      print('❌ Insert detection error: $e');
      rethrow;
    }
  }

  /// Update detection (replace by id)
  Future<bool> updateDetection(Detection detection) async {
    return await update(detections).replace(detection);
  }

  /// Delete detection by id
  Future<int> deleteDetection(int id) async {
    return await (delete(detections)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Tandai detection sudah tersinkronisasi
  Future<void> markAsSynced(int id) async {
    await (update(detections)..where((tbl) => tbl.id.equals(id))).write(
      const DetectionsCompanion(synced: Value(true)),
    );
  }

  /// Statistik jumlah per class
  Future<Map<String, int>> getDetectionCounts() async {
    final allDetections = await getAllDetections();
    final counts = <String, int>{};
    for (final detection in allDetections) {
      counts[detection.damageClass] = (counts[detection.damageClass] ?? 0) + 1;
    }
    return counts;
  }

  /// Hapus semua deteksi (reset)
  Future<int> deleteAllDetections() async {
    return await delete(detections).go();
  }

  /// ================================================================
  /// SYNC TO SUPABASE (pakai SupabaseService)
  /// ================================================================
  Future<void> syncUnsyncedToSupabase() async {
    print('☁️ [SYNC] Checking unsynced detections...');
    final supabase = SupabaseService.instance;

    // Pastikan Supabase sudah siap
    if (!supabase.isAvailable) {
      print('⚠️ Supabase belum diinisialisasi atau offline.');
      return;
    }

    // Ambil data yang belum tersinkronisasi
    final unsynced = await getUnsyncedDetections();
    if (unsynced.isEmpty) {
      print('✅ Tidak ada data yang perlu disinkronkan.');
      return;
    }

    print('📦 Mengirim ${unsynced.length} data ke Supabase...');

    int success = 0;
    for (final det in unsynced) {
      try {
        // Convert model dari database ke model app
        final modelDet = det.toModel();
        final uploaded = await supabase.uploadDetection(modelDet);
        if (uploaded) {
          await markAsSynced(det.id);
          success++;
        }
      } catch (e) {
        print('⚠️ Gagal sync id=${det.id}: $e');
      }
    }

    print(
      '📊 [SYNC] Selesai — berhasil: $success, gagal: ${unsynced.length - success}',
    );
  }
}

/// ================================================================
/// DATABASE CONNECTION CONFIG
/// ================================================================
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'road_damage.db'));

    print('📂 Database path: ${file.path}');
    return driftDatabase(name: file.path);
  });
}

/// ================================================================
/// MODEL ↔️ DATABASE CONVERSION
/// ================================================================
extension DetectionConversion on Detection {
  model.DetectionResult toModel() {
    return model.DetectionResult(
      id: id,
      damageClass: damageClass,
      confidence: confidence,
      latitude: latitude,
      longitude: longitude,
      imagePath: imagePath,
      timestamp: timestamp,
      synced: synced,
    );
  }
}

extension DetectionResultConversion on model.DetectionResult {
  DetectionsCompanion toCompanion() {
    return DetectionsCompanion(
      // ❗ jangan isi id, biarkan autoIncrement handle
      id: const Value.absent(),
      damageClass: Value(damageClass),
      confidence: Value(confidence),
      latitude: Value(latitude),
      longitude: Value(longitude),
      imagePath: Value(imagePath),
      timestamp: Value(timestamp),
      synced: Value(synced),
    );
  }
}
