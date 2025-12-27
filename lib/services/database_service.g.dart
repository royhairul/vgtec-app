// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_service.dart';

// ignore_for_file: type=lint
class $DetectionsTable extends Detections
    with TableInfo<$DetectionsTable, Detection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DetectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _damageClassMeta = const VerificationMeta(
    'damageClass',
  );
  @override
  late final GeneratedColumn<String> damageClass = GeneratedColumn<String>(
    'class',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _widthCmMeta = const VerificationMeta(
    'widthCm',
  );
  @override
  late final GeneratedColumn<double> widthCm = GeneratedColumn<double>(
    'width_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _depthCmMeta = const VerificationMeta(
    'depthCm',
  );
  @override
  late final GeneratedColumn<double> depthCm = GeneratedColumn<double>(
    'depth_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    damageClass,
    confidence,
    latitude,
    longitude,
    imagePath,
    timestamp,
    synced,
    widthCm,
    depthCm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'detections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Detection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('class')) {
      context.handle(
        _damageClassMeta,
        damageClass.isAcceptableOrUnknown(data['class']!, _damageClassMeta),
      );
    } else if (isInserting) {
      context.missing(_damageClassMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('width_cm')) {
      context.handle(
        _widthCmMeta,
        widthCm.isAcceptableOrUnknown(data['width_cm']!, _widthCmMeta),
      );
    }
    if (data.containsKey('depth_cm')) {
      context.handle(
        _depthCmMeta,
        depthCm.isAcceptableOrUnknown(data['depth_cm']!, _depthCmMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Detection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Detection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      damageClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      widthCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}width_cm'],
      ),
      depthCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}depth_cm'],
      ),
    );
  }

  @override
  $DetectionsTable createAlias(String alias) {
    return $DetectionsTable(attachedDatabase, alias);
  }
}

class Detection extends DataClass implements Insertable<Detection> {
  final int id;
  final String damageClass;
  final double confidence;
  final double latitude;
  final double longitude;
  final String imagePath;
  final DateTime timestamp;
  final bool synced;
  final double? widthCm;
  final double? depthCm;
  const Detection({
    required this.id,
    required this.damageClass,
    required this.confidence,
    required this.latitude,
    required this.longitude,
    required this.imagePath,
    required this.timestamp,
    required this.synced,
    this.widthCm,
    this.depthCm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['class'] = Variable<String>(damageClass);
    map['confidence'] = Variable<double>(confidence);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['image_path'] = Variable<String>(imagePath);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['synced'] = Variable<bool>(synced);
    if (!nullToAbsent || widthCm != null) {
      map['width_cm'] = Variable<double>(widthCm);
    }
    if (!nullToAbsent || depthCm != null) {
      map['depth_cm'] = Variable<double>(depthCm);
    }
    return map;
  }

  DetectionsCompanion toCompanion(bool nullToAbsent) {
    return DetectionsCompanion(
      id: Value(id),
      damageClass: Value(damageClass),
      confidence: Value(confidence),
      latitude: Value(latitude),
      longitude: Value(longitude),
      imagePath: Value(imagePath),
      timestamp: Value(timestamp),
      synced: Value(synced),
      widthCm: widthCm == null && nullToAbsent
          ? const Value.absent()
          : Value(widthCm),
      depthCm: depthCm == null && nullToAbsent
          ? const Value.absent()
          : Value(depthCm),
    );
  }

  factory Detection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Detection(
      id: serializer.fromJson<int>(json['id']),
      damageClass: serializer.fromJson<String>(json['damageClass']),
      confidence: serializer.fromJson<double>(json['confidence']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      synced: serializer.fromJson<bool>(json['synced']),
      widthCm: serializer.fromJson<double?>(json['widthCm']),
      depthCm: serializer.fromJson<double?>(json['depthCm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'damageClass': serializer.toJson<String>(damageClass),
      'confidence': serializer.toJson<double>(confidence),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'imagePath': serializer.toJson<String>(imagePath),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'synced': serializer.toJson<bool>(synced),
      'widthCm': serializer.toJson<double?>(widthCm),
      'depthCm': serializer.toJson<double?>(depthCm),
    };
  }

  Detection copyWith({
    int? id,
    String? damageClass,
    double? confidence,
    double? latitude,
    double? longitude,
    String? imagePath,
    DateTime? timestamp,
    bool? synced,
    Value<double?> widthCm = const Value.absent(),
    Value<double?> depthCm = const Value.absent(),
  }) => Detection(
    id: id ?? this.id,
    damageClass: damageClass ?? this.damageClass,
    confidence: confidence ?? this.confidence,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    imagePath: imagePath ?? this.imagePath,
    timestamp: timestamp ?? this.timestamp,
    synced: synced ?? this.synced,
    widthCm: widthCm.present ? widthCm.value : this.widthCm,
    depthCm: depthCm.present ? depthCm.value : this.depthCm,
  );
  Detection copyWithCompanion(DetectionsCompanion data) {
    return Detection(
      id: data.id.present ? data.id.value : this.id,
      damageClass: data.damageClass.present
          ? data.damageClass.value
          : this.damageClass,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      synced: data.synced.present ? data.synced.value : this.synced,
      widthCm: data.widthCm.present ? data.widthCm.value : this.widthCm,
      depthCm: data.depthCm.present ? data.depthCm.value : this.depthCm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Detection(')
          ..write('id: $id, ')
          ..write('damageClass: $damageClass, ')
          ..write('confidence: $confidence, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('imagePath: $imagePath, ')
          ..write('timestamp: $timestamp, ')
          ..write('synced: $synced, ')
          ..write('widthCm: $widthCm, ')
          ..write('depthCm: $depthCm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    damageClass,
    confidence,
    latitude,
    longitude,
    imagePath,
    timestamp,
    synced,
    widthCm,
    depthCm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Detection &&
          other.id == this.id &&
          other.damageClass == this.damageClass &&
          other.confidence == this.confidence &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.imagePath == this.imagePath &&
          other.timestamp == this.timestamp &&
          other.synced == this.synced &&
          other.widthCm == this.widthCm &&
          other.depthCm == this.depthCm);
}

class DetectionsCompanion extends UpdateCompanion<Detection> {
  final Value<int> id;
  final Value<String> damageClass;
  final Value<double> confidence;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> imagePath;
  final Value<DateTime> timestamp;
  final Value<bool> synced;
  final Value<double?> widthCm;
  final Value<double?> depthCm;
  const DetectionsCompanion({
    this.id = const Value.absent(),
    this.damageClass = const Value.absent(),
    this.confidence = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.synced = const Value.absent(),
    this.widthCm = const Value.absent(),
    this.depthCm = const Value.absent(),
  });
  DetectionsCompanion.insert({
    this.id = const Value.absent(),
    required String damageClass,
    required double confidence,
    required double latitude,
    required double longitude,
    required String imagePath,
    required DateTime timestamp,
    this.synced = const Value.absent(),
    this.widthCm = const Value.absent(),
    this.depthCm = const Value.absent(),
  }) : damageClass = Value(damageClass),
       confidence = Value(confidence),
       latitude = Value(latitude),
       longitude = Value(longitude),
       imagePath = Value(imagePath),
       timestamp = Value(timestamp);
  static Insertable<Detection> custom({
    Expression<int>? id,
    Expression<String>? damageClass,
    Expression<double>? confidence,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? imagePath,
    Expression<DateTime>? timestamp,
    Expression<bool>? synced,
    Expression<double>? widthCm,
    Expression<double>? depthCm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (damageClass != null) 'class': damageClass,
      if (confidence != null) 'confidence': confidence,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (imagePath != null) 'image_path': imagePath,
      if (timestamp != null) 'timestamp': timestamp,
      if (synced != null) 'synced': synced,
      if (widthCm != null) 'width_cm': widthCm,
      if (depthCm != null) 'depth_cm': depthCm,
    });
  }

  DetectionsCompanion copyWith({
    Value<int>? id,
    Value<String>? damageClass,
    Value<double>? confidence,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String>? imagePath,
    Value<DateTime>? timestamp,
    Value<bool>? synced,
    Value<double?>? widthCm,
    Value<double?>? depthCm,
  }) {
    return DetectionsCompanion(
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

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (damageClass.present) {
      map['class'] = Variable<String>(damageClass.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (widthCm.present) {
      map['width_cm'] = Variable<double>(widthCm.value);
    }
    if (depthCm.present) {
      map['depth_cm'] = Variable<double>(depthCm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DetectionsCompanion(')
          ..write('id: $id, ')
          ..write('damageClass: $damageClass, ')
          ..write('confidence: $confidence, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('imagePath: $imagePath, ')
          ..write('timestamp: $timestamp, ')
          ..write('synced: $synced, ')
          ..write('widthCm: $widthCm, ')
          ..write('depthCm: $depthCm')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DetectionsTable detections = $DetectionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [detections];
}

typedef $$DetectionsTableCreateCompanionBuilder =
    DetectionsCompanion Function({
      Value<int> id,
      required String damageClass,
      required double confidence,
      required double latitude,
      required double longitude,
      required String imagePath,
      required DateTime timestamp,
      Value<bool> synced,
      Value<double?> widthCm,
      Value<double?> depthCm,
    });
typedef $$DetectionsTableUpdateCompanionBuilder =
    DetectionsCompanion Function({
      Value<int> id,
      Value<String> damageClass,
      Value<double> confidence,
      Value<double> latitude,
      Value<double> longitude,
      Value<String> imagePath,
      Value<DateTime> timestamp,
      Value<bool> synced,
      Value<double?> widthCm,
      Value<double?> depthCm,
    });

class $$DetectionsTableFilterComposer
    extends Composer<_$AppDatabase, $DetectionsTable> {
  $$DetectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get damageClass => $composableBuilder(
    column: $table.damageClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get widthCm => $composableBuilder(
    column: $table.widthCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get depthCm => $composableBuilder(
    column: $table.depthCm,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DetectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DetectionsTable> {
  $$DetectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get damageClass => $composableBuilder(
    column: $table.damageClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get widthCm => $composableBuilder(
    column: $table.widthCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get depthCm => $composableBuilder(
    column: $table.depthCm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DetectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DetectionsTable> {
  $$DetectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get damageClass => $composableBuilder(
    column: $table.damageClass,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<double> get widthCm =>
      $composableBuilder(column: $table.widthCm, builder: (column) => column);

  GeneratedColumn<double> get depthCm =>
      $composableBuilder(column: $table.depthCm, builder: (column) => column);
}

class $$DetectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DetectionsTable,
          Detection,
          $$DetectionsTableFilterComposer,
          $$DetectionsTableOrderingComposer,
          $$DetectionsTableAnnotationComposer,
          $$DetectionsTableCreateCompanionBuilder,
          $$DetectionsTableUpdateCompanionBuilder,
          (
            Detection,
            BaseReferences<_$AppDatabase, $DetectionsTable, Detection>,
          ),
          Detection,
          PrefetchHooks Function()
        > {
  $$DetectionsTableTableManager(_$AppDatabase db, $DetectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DetectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DetectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DetectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> damageClass = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<double?> widthCm = const Value.absent(),
                Value<double?> depthCm = const Value.absent(),
              }) => DetectionsCompanion(
                id: id,
                damageClass: damageClass,
                confidence: confidence,
                latitude: latitude,
                longitude: longitude,
                imagePath: imagePath,
                timestamp: timestamp,
                synced: synced,
                widthCm: widthCm,
                depthCm: depthCm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String damageClass,
                required double confidence,
                required double latitude,
                required double longitude,
                required String imagePath,
                required DateTime timestamp,
                Value<bool> synced = const Value.absent(),
                Value<double?> widthCm = const Value.absent(),
                Value<double?> depthCm = const Value.absent(),
              }) => DetectionsCompanion.insert(
                id: id,
                damageClass: damageClass,
                confidence: confidence,
                latitude: latitude,
                longitude: longitude,
                imagePath: imagePath,
                timestamp: timestamp,
                synced: synced,
                widthCm: widthCm,
                depthCm: depthCm,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DetectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DetectionsTable,
      Detection,
      $$DetectionsTableFilterComposer,
      $$DetectionsTableOrderingComposer,
      $$DetectionsTableAnnotationComposer,
      $$DetectionsTableCreateCompanionBuilder,
      $$DetectionsTableUpdateCompanionBuilder,
      (Detection, BaseReferences<_$AppDatabase, $DetectionsTable, Detection>),
      Detection,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DetectionsTableTableManager get detections =>
      $$DetectionsTableTableManager(_db, _db.detections);
}
