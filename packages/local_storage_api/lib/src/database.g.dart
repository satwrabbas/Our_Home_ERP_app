// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ClientsTable extends Clients with TableInfo<$ClientsTable, Client> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 2,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nationalIdMeta = const VerificationMeta(
    'nationalId',
  );
  @override
  late final GeneratedColumn<String> nationalId = GeneratedColumn<String>(
    'national_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phone,
    nationalId,
    userId,
    createdAt,
    updatedAt,
    isDeleted,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Client> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('national_id')) {
      context.handle(
        _nationalIdMeta,
        nationalId.isAcceptableOrUnknown(data['national_id']!, _nationalIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Client map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Client(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      nationalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}national_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $ClientsTable createAlias(String alias) {
    return $ClientsTable(attachedDatabase, alias);
  }
}

class Client extends DataClass implements Insertable<Client> {
  final String id;
  final String name;
  final String phone;
  final String? nationalId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isSynced;
  const Client({
    required this.id,
    required this.name,
    required this.phone,
    this.nationalId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || nationalId != null) {
      map['national_id'] = Variable<String>(nationalId);
    }
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  ClientsCompanion toCompanion(bool nullToAbsent) {
    return ClientsCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      nationalId: nationalId == null && nullToAbsent
          ? const Value.absent()
          : Value(nationalId),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isSynced: Value(isSynced),
    );
  }

  factory Client.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Client(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      nationalId: serializer.fromJson<String?>(json['nationalId']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'nationalId': serializer.toJson<String?>(nationalId),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Client copyWith({
    String? id,
    String? name,
    String? phone,
    Value<String?> nationalId = const Value.absent(),
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isSynced,
  }) => Client(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    nationalId: nationalId.present ? nationalId.value : this.nationalId,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isSynced: isSynced ?? this.isSynced,
  );
  Client copyWithCompanion(ClientsCompanion data) {
    return Client(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      nationalId: data.nationalId.present
          ? data.nationalId.value
          : this.nationalId,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Client(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('nationalId: $nationalId, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    phone,
    nationalId,
    userId,
    createdAt,
    updatedAt,
    isDeleted,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Client &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.nationalId == this.nationalId &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isSynced == this.isSynced);
}

class ClientsCompanion extends UpdateCompanion<Client> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<String?> nationalId;
  final Value<String> userId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const ClientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String phone,
    this.nationalId = const Value.absent(),
    required String userId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       phone = Value(phone),
       userId = Value(userId);
  static Insertable<Client> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? nationalId,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (nationalId != null) 'national_id': nationalId,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? phone,
    Value<String?>? nationalId,
    Value<String>? userId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return ClientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (nationalId.present) {
      map['national_id'] = Variable<String>(nationalId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('nationalId: $nationalId, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContractsTable extends Contracts
    with TableInfo<$ContractsTable, Contract> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContractsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clients (id)',
    ),
  );
  static const VerificationMeta _contractTypeMeta = const VerificationMeta(
    'contractType',
  );
  @override
  late final GeneratedColumn<String> contractType = GeneratedColumn<String>(
    'contract_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('لاحق التخصص'),
  );
  static const VerificationMeta _apartmentDetailsMeta = const VerificationMeta(
    'apartmentDetails',
  );
  @override
  late final GeneratedColumn<String> apartmentDetails = GeneratedColumn<String>(
    'apartment_details',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalAreaMeta = const VerificationMeta(
    'totalArea',
  );
  @override
  late final GeneratedColumn<double> totalArea = GeneratedColumn<double>(
    'total_area',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseMeterPriceAtSigningMeta =
      const VerificationMeta('baseMeterPriceAtSigning');
  @override
  late final GeneratedColumn<double> baseMeterPriceAtSigning =
      GeneratedColumn<double>(
        'base_meter_price_at_signing',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _installmentsCountMeta = const VerificationMeta(
    'installmentsCount',
  );
  @override
  late final GeneratedColumn<int> installmentsCount = GeneratedColumn<int>(
    'installments_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(48),
  );
  static const VerificationMeta _coefficientsMeta = const VerificationMeta(
    'coefficients',
  );
  @override
  late final GeneratedColumn<String> coefficients = GeneratedColumn<String>(
    'coefficients',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contractDateMeta = const VerificationMeta(
    'contractDate',
  );
  @override
  late final GeneratedColumn<DateTime> contractDate = GeneratedColumn<DateTime>(
    'contract_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    contractType,
    apartmentDetails,
    totalArea,
    baseMeterPriceAtSigning,
    installmentsCount,
    coefficients,
    userId,
    contractDate,
    isCompleted,
    createdAt,
    updatedAt,
    isDeleted,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contracts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Contract> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('contract_type')) {
      context.handle(
        _contractTypeMeta,
        contractType.isAcceptableOrUnknown(
          data['contract_type']!,
          _contractTypeMeta,
        ),
      );
    }
    if (data.containsKey('apartment_details')) {
      context.handle(
        _apartmentDetailsMeta,
        apartmentDetails.isAcceptableOrUnknown(
          data['apartment_details']!,
          _apartmentDetailsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_apartmentDetailsMeta);
    }
    if (data.containsKey('total_area')) {
      context.handle(
        _totalAreaMeta,
        totalArea.isAcceptableOrUnknown(data['total_area']!, _totalAreaMeta),
      );
    } else if (isInserting) {
      context.missing(_totalAreaMeta);
    }
    if (data.containsKey('base_meter_price_at_signing')) {
      context.handle(
        _baseMeterPriceAtSigningMeta,
        baseMeterPriceAtSigning.isAcceptableOrUnknown(
          data['base_meter_price_at_signing']!,
          _baseMeterPriceAtSigningMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseMeterPriceAtSigningMeta);
    }
    if (data.containsKey('installments_count')) {
      context.handle(
        _installmentsCountMeta,
        installmentsCount.isAcceptableOrUnknown(
          data['installments_count']!,
          _installmentsCountMeta,
        ),
      );
    }
    if (data.containsKey('coefficients')) {
      context.handle(
        _coefficientsMeta,
        coefficients.isAcceptableOrUnknown(
          data['coefficients']!,
          _coefficientsMeta,
        ),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('contract_date')) {
      context.handle(
        _contractDateMeta,
        contractDate.isAcceptableOrUnknown(
          data['contract_date']!,
          _contractDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contractDateMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Contract map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contract(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      contractType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contract_type'],
      )!,
      apartmentDetails: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apartment_details'],
      )!,
      totalArea: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_area'],
      )!,
      baseMeterPriceAtSigning: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}base_meter_price_at_signing'],
      )!,
      installmentsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installments_count'],
      )!,
      coefficients: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coefficients'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      contractDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}contract_date'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $ContractsTable createAlias(String alias) {
    return $ContractsTable(attachedDatabase, alias);
  }
}

class Contract extends DataClass implements Insertable<Contract> {
  final String id;
  final String clientId;
  final String contractType;
  final String apartmentDetails;
  final double totalArea;
  final double baseMeterPriceAtSigning;
  final int installmentsCount;
  final String coefficients;
  final String userId;
  final DateTime contractDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isSynced;
  const Contract({
    required this.id,
    required this.clientId,
    required this.contractType,
    required this.apartmentDetails,
    required this.totalArea,
    required this.baseMeterPriceAtSigning,
    required this.installmentsCount,
    required this.coefficients,
    required this.userId,
    required this.contractDate,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    map['contract_type'] = Variable<String>(contractType);
    map['apartment_details'] = Variable<String>(apartmentDetails);
    map['total_area'] = Variable<double>(totalArea);
    map['base_meter_price_at_signing'] = Variable<double>(
      baseMeterPriceAtSigning,
    );
    map['installments_count'] = Variable<int>(installmentsCount);
    map['coefficients'] = Variable<String>(coefficients);
    map['user_id'] = Variable<String>(userId);
    map['contract_date'] = Variable<DateTime>(contractDate);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  ContractsCompanion toCompanion(bool nullToAbsent) {
    return ContractsCompanion(
      id: Value(id),
      clientId: Value(clientId),
      contractType: Value(contractType),
      apartmentDetails: Value(apartmentDetails),
      totalArea: Value(totalArea),
      baseMeterPriceAtSigning: Value(baseMeterPriceAtSigning),
      installmentsCount: Value(installmentsCount),
      coefficients: Value(coefficients),
      userId: Value(userId),
      contractDate: Value(contractDate),
      isCompleted: Value(isCompleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isSynced: Value(isSynced),
    );
  }

  factory Contract.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contract(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      contractType: serializer.fromJson<String>(json['contractType']),
      apartmentDetails: serializer.fromJson<String>(json['apartmentDetails']),
      totalArea: serializer.fromJson<double>(json['totalArea']),
      baseMeterPriceAtSigning: serializer.fromJson<double>(
        json['baseMeterPriceAtSigning'],
      ),
      installmentsCount: serializer.fromJson<int>(json['installmentsCount']),
      coefficients: serializer.fromJson<String>(json['coefficients']),
      userId: serializer.fromJson<String>(json['userId']),
      contractDate: serializer.fromJson<DateTime>(json['contractDate']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'contractType': serializer.toJson<String>(contractType),
      'apartmentDetails': serializer.toJson<String>(apartmentDetails),
      'totalArea': serializer.toJson<double>(totalArea),
      'baseMeterPriceAtSigning': serializer.toJson<double>(
        baseMeterPriceAtSigning,
      ),
      'installmentsCount': serializer.toJson<int>(installmentsCount),
      'coefficients': serializer.toJson<String>(coefficients),
      'userId': serializer.toJson<String>(userId),
      'contractDate': serializer.toJson<DateTime>(contractDate),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Contract copyWith({
    String? id,
    String? clientId,
    String? contractType,
    String? apartmentDetails,
    double? totalArea,
    double? baseMeterPriceAtSigning,
    int? installmentsCount,
    String? coefficients,
    String? userId,
    DateTime? contractDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isSynced,
  }) => Contract(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    contractType: contractType ?? this.contractType,
    apartmentDetails: apartmentDetails ?? this.apartmentDetails,
    totalArea: totalArea ?? this.totalArea,
    baseMeterPriceAtSigning:
        baseMeterPriceAtSigning ?? this.baseMeterPriceAtSigning,
    installmentsCount: installmentsCount ?? this.installmentsCount,
    coefficients: coefficients ?? this.coefficients,
    userId: userId ?? this.userId,
    contractDate: contractDate ?? this.contractDate,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isSynced: isSynced ?? this.isSynced,
  );
  Contract copyWithCompanion(ContractsCompanion data) {
    return Contract(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      contractType: data.contractType.present
          ? data.contractType.value
          : this.contractType,
      apartmentDetails: data.apartmentDetails.present
          ? data.apartmentDetails.value
          : this.apartmentDetails,
      totalArea: data.totalArea.present ? data.totalArea.value : this.totalArea,
      baseMeterPriceAtSigning: data.baseMeterPriceAtSigning.present
          ? data.baseMeterPriceAtSigning.value
          : this.baseMeterPriceAtSigning,
      installmentsCount: data.installmentsCount.present
          ? data.installmentsCount.value
          : this.installmentsCount,
      coefficients: data.coefficients.present
          ? data.coefficients.value
          : this.coefficients,
      userId: data.userId.present ? data.userId.value : this.userId,
      contractDate: data.contractDate.present
          ? data.contractDate.value
          : this.contractDate,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Contract(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('contractType: $contractType, ')
          ..write('apartmentDetails: $apartmentDetails, ')
          ..write('totalArea: $totalArea, ')
          ..write('baseMeterPriceAtSigning: $baseMeterPriceAtSigning, ')
          ..write('installmentsCount: $installmentsCount, ')
          ..write('coefficients: $coefficients, ')
          ..write('userId: $userId, ')
          ..write('contractDate: $contractDate, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    contractType,
    apartmentDetails,
    totalArea,
    baseMeterPriceAtSigning,
    installmentsCount,
    coefficients,
    userId,
    contractDate,
    isCompleted,
    createdAt,
    updatedAt,
    isDeleted,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contract &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.contractType == this.contractType &&
          other.apartmentDetails == this.apartmentDetails &&
          other.totalArea == this.totalArea &&
          other.baseMeterPriceAtSigning == this.baseMeterPriceAtSigning &&
          other.installmentsCount == this.installmentsCount &&
          other.coefficients == this.coefficients &&
          other.userId == this.userId &&
          other.contractDate == this.contractDate &&
          other.isCompleted == this.isCompleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isSynced == this.isSynced);
}

class ContractsCompanion extends UpdateCompanion<Contract> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<String> contractType;
  final Value<String> apartmentDetails;
  final Value<double> totalArea;
  final Value<double> baseMeterPriceAtSigning;
  final Value<int> installmentsCount;
  final Value<String> coefficients;
  final Value<String> userId;
  final Value<DateTime> contractDate;
  final Value<bool> isCompleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const ContractsCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.contractType = const Value.absent(),
    this.apartmentDetails = const Value.absent(),
    this.totalArea = const Value.absent(),
    this.baseMeterPriceAtSigning = const Value.absent(),
    this.installmentsCount = const Value.absent(),
    this.coefficients = const Value.absent(),
    this.userId = const Value.absent(),
    this.contractDate = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContractsCompanion.insert({
    this.id = const Value.absent(),
    required String clientId,
    this.contractType = const Value.absent(),
    required String apartmentDetails,
    required double totalArea,
    required double baseMeterPriceAtSigning,
    this.installmentsCount = const Value.absent(),
    this.coefficients = const Value.absent(),
    required String userId,
    required DateTime contractDate,
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       apartmentDetails = Value(apartmentDetails),
       totalArea = Value(totalArea),
       baseMeterPriceAtSigning = Value(baseMeterPriceAtSigning),
       userId = Value(userId),
       contractDate = Value(contractDate);
  static Insertable<Contract> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<String>? contractType,
    Expression<String>? apartmentDetails,
    Expression<double>? totalArea,
    Expression<double>? baseMeterPriceAtSigning,
    Expression<int>? installmentsCount,
    Expression<String>? coefficients,
    Expression<String>? userId,
    Expression<DateTime>? contractDate,
    Expression<bool>? isCompleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (contractType != null) 'contract_type': contractType,
      if (apartmentDetails != null) 'apartment_details': apartmentDetails,
      if (totalArea != null) 'total_area': totalArea,
      if (baseMeterPriceAtSigning != null)
        'base_meter_price_at_signing': baseMeterPriceAtSigning,
      if (installmentsCount != null) 'installments_count': installmentsCount,
      if (coefficients != null) 'coefficients': coefficients,
      if (userId != null) 'user_id': userId,
      if (contractDate != null) 'contract_date': contractDate,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContractsCompanion copyWith({
    Value<String>? id,
    Value<String>? clientId,
    Value<String>? contractType,
    Value<String>? apartmentDetails,
    Value<double>? totalArea,
    Value<double>? baseMeterPriceAtSigning,
    Value<int>? installmentsCount,
    Value<String>? coefficients,
    Value<String>? userId,
    Value<DateTime>? contractDate,
    Value<bool>? isCompleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return ContractsCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      contractType: contractType ?? this.contractType,
      apartmentDetails: apartmentDetails ?? this.apartmentDetails,
      totalArea: totalArea ?? this.totalArea,
      baseMeterPriceAtSigning:
          baseMeterPriceAtSigning ?? this.baseMeterPriceAtSigning,
      installmentsCount: installmentsCount ?? this.installmentsCount,
      coefficients: coefficients ?? this.coefficients,
      userId: userId ?? this.userId,
      contractDate: contractDate ?? this.contractDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (contractType.present) {
      map['contract_type'] = Variable<String>(contractType.value);
    }
    if (apartmentDetails.present) {
      map['apartment_details'] = Variable<String>(apartmentDetails.value);
    }
    if (totalArea.present) {
      map['total_area'] = Variable<double>(totalArea.value);
    }
    if (baseMeterPriceAtSigning.present) {
      map['base_meter_price_at_signing'] = Variable<double>(
        baseMeterPriceAtSigning.value,
      );
    }
    if (installmentsCount.present) {
      map['installments_count'] = Variable<int>(installmentsCount.value);
    }
    if (coefficients.present) {
      map['coefficients'] = Variable<String>(coefficients.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (contractDate.present) {
      map['contract_date'] = Variable<DateTime>(contractDate.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContractsCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('contractType: $contractType, ')
          ..write('apartmentDetails: $apartmentDetails, ')
          ..write('totalArea: $totalArea, ')
          ..write('baseMeterPriceAtSigning: $baseMeterPriceAtSigning, ')
          ..write('installmentsCount: $installmentsCount, ')
          ..write('coefficients: $coefficients, ')
          ..write('userId: $userId, ')
          ..write('contractDate: $contractDate, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MaterialPricesHistoryTable extends MaterialPricesHistory
    with TableInfo<$MaterialPricesHistoryTable, MaterialPricesHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaterialPricesHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _effectiveDateMeta = const VerificationMeta(
    'effectiveDate',
  );
  @override
  late final GeneratedColumn<DateTime> effectiveDate =
      GeneratedColumn<DateTime>(
        'effective_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _ironPriceMeta = const VerificationMeta(
    'ironPrice',
  );
  @override
  late final GeneratedColumn<double> ironPrice = GeneratedColumn<double>(
    'iron_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cementPriceMeta = const VerificationMeta(
    'cementPrice',
  );
  @override
  late final GeneratedColumn<double> cementPrice = GeneratedColumn<double>(
    'cement_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _block15PriceMeta = const VerificationMeta(
    'block15Price',
  );
  @override
  late final GeneratedColumn<double> block15Price = GeneratedColumn<double>(
    'block15_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formworkAndPouringWagesMeta =
      const VerificationMeta('formworkAndPouringWages');
  @override
  late final GeneratedColumn<double> formworkAndPouringWages =
      GeneratedColumn<double>(
        'formwork_and_pouring_wages',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _aggregateMaterialsPriceMeta =
      const VerificationMeta('aggregateMaterialsPrice');
  @override
  late final GeneratedColumn<double> aggregateMaterialsPrice =
      GeneratedColumn<double>(
        'aggregate_materials_price',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _ordinaryWorkerWageMeta =
      const VerificationMeta('ordinaryWorkerWage');
  @override
  late final GeneratedColumn<double> ordinaryWorkerWage =
      GeneratedColumn<double>(
        'ordinary_worker_wage',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    effectiveDate,
    ironPrice,
    cementPrice,
    block15Price,
    formworkAndPouringWages,
    aggregateMaterialsPrice,
    ordinaryWorkerWage,
    userId,
    createdAt,
    isDeleted,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'material_prices_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaterialPricesHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('effective_date')) {
      context.handle(
        _effectiveDateMeta,
        effectiveDate.isAcceptableOrUnknown(
          data['effective_date']!,
          _effectiveDateMeta,
        ),
      );
    }
    if (data.containsKey('iron_price')) {
      context.handle(
        _ironPriceMeta,
        ironPrice.isAcceptableOrUnknown(data['iron_price']!, _ironPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_ironPriceMeta);
    }
    if (data.containsKey('cement_price')) {
      context.handle(
        _cementPriceMeta,
        cementPrice.isAcceptableOrUnknown(
          data['cement_price']!,
          _cementPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cementPriceMeta);
    }
    if (data.containsKey('block15_price')) {
      context.handle(
        _block15PriceMeta,
        block15Price.isAcceptableOrUnknown(
          data['block15_price']!,
          _block15PriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_block15PriceMeta);
    }
    if (data.containsKey('formwork_and_pouring_wages')) {
      context.handle(
        _formworkAndPouringWagesMeta,
        formworkAndPouringWages.isAcceptableOrUnknown(
          data['formwork_and_pouring_wages']!,
          _formworkAndPouringWagesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_formworkAndPouringWagesMeta);
    }
    if (data.containsKey('aggregate_materials_price')) {
      context.handle(
        _aggregateMaterialsPriceMeta,
        aggregateMaterialsPrice.isAcceptableOrUnknown(
          data['aggregate_materials_price']!,
          _aggregateMaterialsPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggregateMaterialsPriceMeta);
    }
    if (data.containsKey('ordinary_worker_wage')) {
      context.handle(
        _ordinaryWorkerWageMeta,
        ordinaryWorkerWage.isAcceptableOrUnknown(
          data['ordinary_worker_wage']!,
          _ordinaryWorkerWageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ordinaryWorkerWageMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MaterialPricesHistoryData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaterialPricesHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      effectiveDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}effective_date'],
      )!,
      ironPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}iron_price'],
      )!,
      cementPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cement_price'],
      )!,
      block15Price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}block15_price'],
      )!,
      formworkAndPouringWages: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}formwork_and_pouring_wages'],
      )!,
      aggregateMaterialsPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}aggregate_materials_price'],
      )!,
      ordinaryWorkerWage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ordinary_worker_wage'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $MaterialPricesHistoryTable createAlias(String alias) {
    return $MaterialPricesHistoryTable(attachedDatabase, alias);
  }
}

class MaterialPricesHistoryData extends DataClass
    implements Insertable<MaterialPricesHistoryData> {
  final String id;
  final DateTime effectiveDate;
  final double ironPrice;
  final double cementPrice;
  final double block15Price;
  final double formworkAndPouringWages;
  final double aggregateMaterialsPrice;
  final double ordinaryWorkerWage;
  final String userId;
  final DateTime createdAt;
  final bool isDeleted;
  final bool isSynced;
  const MaterialPricesHistoryData({
    required this.id,
    required this.effectiveDate,
    required this.ironPrice,
    required this.cementPrice,
    required this.block15Price,
    required this.formworkAndPouringWages,
    required this.aggregateMaterialsPrice,
    required this.ordinaryWorkerWage,
    required this.userId,
    required this.createdAt,
    required this.isDeleted,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['effective_date'] = Variable<DateTime>(effectiveDate);
    map['iron_price'] = Variable<double>(ironPrice);
    map['cement_price'] = Variable<double>(cementPrice);
    map['block15_price'] = Variable<double>(block15Price);
    map['formwork_and_pouring_wages'] = Variable<double>(
      formworkAndPouringWages,
    );
    map['aggregate_materials_price'] = Variable<double>(
      aggregateMaterialsPrice,
    );
    map['ordinary_worker_wage'] = Variable<double>(ordinaryWorkerWage);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  MaterialPricesHistoryCompanion toCompanion(bool nullToAbsent) {
    return MaterialPricesHistoryCompanion(
      id: Value(id),
      effectiveDate: Value(effectiveDate),
      ironPrice: Value(ironPrice),
      cementPrice: Value(cementPrice),
      block15Price: Value(block15Price),
      formworkAndPouringWages: Value(formworkAndPouringWages),
      aggregateMaterialsPrice: Value(aggregateMaterialsPrice),
      ordinaryWorkerWage: Value(ordinaryWorkerWage),
      userId: Value(userId),
      createdAt: Value(createdAt),
      isDeleted: Value(isDeleted),
      isSynced: Value(isSynced),
    );
  }

  factory MaterialPricesHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaterialPricesHistoryData(
      id: serializer.fromJson<String>(json['id']),
      effectiveDate: serializer.fromJson<DateTime>(json['effectiveDate']),
      ironPrice: serializer.fromJson<double>(json['ironPrice']),
      cementPrice: serializer.fromJson<double>(json['cementPrice']),
      block15Price: serializer.fromJson<double>(json['block15Price']),
      formworkAndPouringWages: serializer.fromJson<double>(
        json['formworkAndPouringWages'],
      ),
      aggregateMaterialsPrice: serializer.fromJson<double>(
        json['aggregateMaterialsPrice'],
      ),
      ordinaryWorkerWage: serializer.fromJson<double>(
        json['ordinaryWorkerWage'],
      ),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'effectiveDate': serializer.toJson<DateTime>(effectiveDate),
      'ironPrice': serializer.toJson<double>(ironPrice),
      'cementPrice': serializer.toJson<double>(cementPrice),
      'block15Price': serializer.toJson<double>(block15Price),
      'formworkAndPouringWages': serializer.toJson<double>(
        formworkAndPouringWages,
      ),
      'aggregateMaterialsPrice': serializer.toJson<double>(
        aggregateMaterialsPrice,
      ),
      'ordinaryWorkerWage': serializer.toJson<double>(ordinaryWorkerWage),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  MaterialPricesHistoryData copyWith({
    String? id,
    DateTime? effectiveDate,
    double? ironPrice,
    double? cementPrice,
    double? block15Price,
    double? formworkAndPouringWages,
    double? aggregateMaterialsPrice,
    double? ordinaryWorkerWage,
    String? userId,
    DateTime? createdAt,
    bool? isDeleted,
    bool? isSynced,
  }) => MaterialPricesHistoryData(
    id: id ?? this.id,
    effectiveDate: effectiveDate ?? this.effectiveDate,
    ironPrice: ironPrice ?? this.ironPrice,
    cementPrice: cementPrice ?? this.cementPrice,
    block15Price: block15Price ?? this.block15Price,
    formworkAndPouringWages:
        formworkAndPouringWages ?? this.formworkAndPouringWages,
    aggregateMaterialsPrice:
        aggregateMaterialsPrice ?? this.aggregateMaterialsPrice,
    ordinaryWorkerWage: ordinaryWorkerWage ?? this.ordinaryWorkerWage,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isSynced: isSynced ?? this.isSynced,
  );
  MaterialPricesHistoryData copyWithCompanion(
    MaterialPricesHistoryCompanion data,
  ) {
    return MaterialPricesHistoryData(
      id: data.id.present ? data.id.value : this.id,
      effectiveDate: data.effectiveDate.present
          ? data.effectiveDate.value
          : this.effectiveDate,
      ironPrice: data.ironPrice.present ? data.ironPrice.value : this.ironPrice,
      cementPrice: data.cementPrice.present
          ? data.cementPrice.value
          : this.cementPrice,
      block15Price: data.block15Price.present
          ? data.block15Price.value
          : this.block15Price,
      formworkAndPouringWages: data.formworkAndPouringWages.present
          ? data.formworkAndPouringWages.value
          : this.formworkAndPouringWages,
      aggregateMaterialsPrice: data.aggregateMaterialsPrice.present
          ? data.aggregateMaterialsPrice.value
          : this.aggregateMaterialsPrice,
      ordinaryWorkerWage: data.ordinaryWorkerWage.present
          ? data.ordinaryWorkerWage.value
          : this.ordinaryWorkerWage,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaterialPricesHistoryData(')
          ..write('id: $id, ')
          ..write('effectiveDate: $effectiveDate, ')
          ..write('ironPrice: $ironPrice, ')
          ..write('cementPrice: $cementPrice, ')
          ..write('block15Price: $block15Price, ')
          ..write('formworkAndPouringWages: $formworkAndPouringWages, ')
          ..write('aggregateMaterialsPrice: $aggregateMaterialsPrice, ')
          ..write('ordinaryWorkerWage: $ordinaryWorkerWage, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    effectiveDate,
    ironPrice,
    cementPrice,
    block15Price,
    formworkAndPouringWages,
    aggregateMaterialsPrice,
    ordinaryWorkerWage,
    userId,
    createdAt,
    isDeleted,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaterialPricesHistoryData &&
          other.id == this.id &&
          other.effectiveDate == this.effectiveDate &&
          other.ironPrice == this.ironPrice &&
          other.cementPrice == this.cementPrice &&
          other.block15Price == this.block15Price &&
          other.formworkAndPouringWages == this.formworkAndPouringWages &&
          other.aggregateMaterialsPrice == this.aggregateMaterialsPrice &&
          other.ordinaryWorkerWage == this.ordinaryWorkerWage &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.isDeleted == this.isDeleted &&
          other.isSynced == this.isSynced);
}

class MaterialPricesHistoryCompanion
    extends UpdateCompanion<MaterialPricesHistoryData> {
  final Value<String> id;
  final Value<DateTime> effectiveDate;
  final Value<double> ironPrice;
  final Value<double> cementPrice;
  final Value<double> block15Price;
  final Value<double> formworkAndPouringWages;
  final Value<double> aggregateMaterialsPrice;
  final Value<double> ordinaryWorkerWage;
  final Value<String> userId;
  final Value<DateTime> createdAt;
  final Value<bool> isDeleted;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const MaterialPricesHistoryCompanion({
    this.id = const Value.absent(),
    this.effectiveDate = const Value.absent(),
    this.ironPrice = const Value.absent(),
    this.cementPrice = const Value.absent(),
    this.block15Price = const Value.absent(),
    this.formworkAndPouringWages = const Value.absent(),
    this.aggregateMaterialsPrice = const Value.absent(),
    this.ordinaryWorkerWage = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MaterialPricesHistoryCompanion.insert({
    this.id = const Value.absent(),
    this.effectiveDate = const Value.absent(),
    required double ironPrice,
    required double cementPrice,
    required double block15Price,
    required double formworkAndPouringWages,
    required double aggregateMaterialsPrice,
    required double ordinaryWorkerWage,
    required String userId,
    this.createdAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ironPrice = Value(ironPrice),
       cementPrice = Value(cementPrice),
       block15Price = Value(block15Price),
       formworkAndPouringWages = Value(formworkAndPouringWages),
       aggregateMaterialsPrice = Value(aggregateMaterialsPrice),
       ordinaryWorkerWage = Value(ordinaryWorkerWage),
       userId = Value(userId);
  static Insertable<MaterialPricesHistoryData> custom({
    Expression<String>? id,
    Expression<DateTime>? effectiveDate,
    Expression<double>? ironPrice,
    Expression<double>? cementPrice,
    Expression<double>? block15Price,
    Expression<double>? formworkAndPouringWages,
    Expression<double>? aggregateMaterialsPrice,
    Expression<double>? ordinaryWorkerWage,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (effectiveDate != null) 'effective_date': effectiveDate,
      if (ironPrice != null) 'iron_price': ironPrice,
      if (cementPrice != null) 'cement_price': cementPrice,
      if (block15Price != null) 'block15_price': block15Price,
      if (formworkAndPouringWages != null)
        'formwork_and_pouring_wages': formworkAndPouringWages,
      if (aggregateMaterialsPrice != null)
        'aggregate_materials_price': aggregateMaterialsPrice,
      if (ordinaryWorkerWage != null)
        'ordinary_worker_wage': ordinaryWorkerWage,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MaterialPricesHistoryCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? effectiveDate,
    Value<double>? ironPrice,
    Value<double>? cementPrice,
    Value<double>? block15Price,
    Value<double>? formworkAndPouringWages,
    Value<double>? aggregateMaterialsPrice,
    Value<double>? ordinaryWorkerWage,
    Value<String>? userId,
    Value<DateTime>? createdAt,
    Value<bool>? isDeleted,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return MaterialPricesHistoryCompanion(
      id: id ?? this.id,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      ironPrice: ironPrice ?? this.ironPrice,
      cementPrice: cementPrice ?? this.cementPrice,
      block15Price: block15Price ?? this.block15Price,
      formworkAndPouringWages:
          formworkAndPouringWages ?? this.formworkAndPouringWages,
      aggregateMaterialsPrice:
          aggregateMaterialsPrice ?? this.aggregateMaterialsPrice,
      ordinaryWorkerWage: ordinaryWorkerWage ?? this.ordinaryWorkerWage,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (effectiveDate.present) {
      map['effective_date'] = Variable<DateTime>(effectiveDate.value);
    }
    if (ironPrice.present) {
      map['iron_price'] = Variable<double>(ironPrice.value);
    }
    if (cementPrice.present) {
      map['cement_price'] = Variable<double>(cementPrice.value);
    }
    if (block15Price.present) {
      map['block15_price'] = Variable<double>(block15Price.value);
    }
    if (formworkAndPouringWages.present) {
      map['formwork_and_pouring_wages'] = Variable<double>(
        formworkAndPouringWages.value,
      );
    }
    if (aggregateMaterialsPrice.present) {
      map['aggregate_materials_price'] = Variable<double>(
        aggregateMaterialsPrice.value,
      );
    }
    if (ordinaryWorkerWage.present) {
      map['ordinary_worker_wage'] = Variable<double>(ordinaryWorkerWage.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaterialPricesHistoryCompanion(')
          ..write('id: $id, ')
          ..write('effectiveDate: $effectiveDate, ')
          ..write('ironPrice: $ironPrice, ')
          ..write('cementPrice: $cementPrice, ')
          ..write('block15Price: $block15Price, ')
          ..write('formworkAndPouringWages: $formworkAndPouringWages, ')
          ..write('aggregateMaterialsPrice: $aggregateMaterialsPrice, ')
          ..write('ordinaryWorkerWage: $ordinaryWorkerWage, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InstallmentsScheduleTable extends InstallmentsSchedule
    with TableInfo<$InstallmentsScheduleTable, InstallmentsScheduleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstallmentsScheduleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _contractIdMeta = const VerificationMeta(
    'contractId',
  );
  @override
  late final GeneratedColumn<String> contractId = GeneratedColumn<String>(
    'contract_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contracts (id)',
    ),
  );
  static const VerificationMeta _installmentNumberMeta = const VerificationMeta(
    'installmentNumber',
  );
  @override
  late final GeneratedColumn<int> installmentNumber = GeneratedColumn<int>(
    'installment_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contractId,
    installmentNumber,
    dueDate,
    status,
    userId,
    createdAt,
    updatedAt,
    isDeleted,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'installments_schedule';
  @override
  VerificationContext validateIntegrity(
    Insertable<InstallmentsScheduleData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contract_id')) {
      context.handle(
        _contractIdMeta,
        contractId.isAcceptableOrUnknown(data['contract_id']!, _contractIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contractIdMeta);
    }
    if (data.containsKey('installment_number')) {
      context.handle(
        _installmentNumberMeta,
        installmentNumber.isAcceptableOrUnknown(
          data['installment_number']!,
          _installmentNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installmentNumberMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InstallmentsScheduleData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstallmentsScheduleData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      contractId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contract_id'],
      )!,
      installmentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installment_number'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $InstallmentsScheduleTable createAlias(String alias) {
    return $InstallmentsScheduleTable(attachedDatabase, alias);
  }
}

class InstallmentsScheduleData extends DataClass
    implements Insertable<InstallmentsScheduleData> {
  final String id;
  final String contractId;
  final int installmentNumber;
  final DateTime dueDate;
  final String status;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isSynced;
  const InstallmentsScheduleData({
    required this.id,
    required this.contractId,
    required this.installmentNumber,
    required this.dueDate,
    required this.status,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['contract_id'] = Variable<String>(contractId);
    map['installment_number'] = Variable<int>(installmentNumber);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['status'] = Variable<String>(status);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  InstallmentsScheduleCompanion toCompanion(bool nullToAbsent) {
    return InstallmentsScheduleCompanion(
      id: Value(id),
      contractId: Value(contractId),
      installmentNumber: Value(installmentNumber),
      dueDate: Value(dueDate),
      status: Value(status),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isSynced: Value(isSynced),
    );
  }

  factory InstallmentsScheduleData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstallmentsScheduleData(
      id: serializer.fromJson<String>(json['id']),
      contractId: serializer.fromJson<String>(json['contractId']),
      installmentNumber: serializer.fromJson<int>(json['installmentNumber']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      status: serializer.fromJson<String>(json['status']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'contractId': serializer.toJson<String>(contractId),
      'installmentNumber': serializer.toJson<int>(installmentNumber),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'status': serializer.toJson<String>(status),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  InstallmentsScheduleData copyWith({
    String? id,
    String? contractId,
    int? installmentNumber,
    DateTime? dueDate,
    String? status,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isSynced,
  }) => InstallmentsScheduleData(
    id: id ?? this.id,
    contractId: contractId ?? this.contractId,
    installmentNumber: installmentNumber ?? this.installmentNumber,
    dueDate: dueDate ?? this.dueDate,
    status: status ?? this.status,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isSynced: isSynced ?? this.isSynced,
  );
  InstallmentsScheduleData copyWithCompanion(
    InstallmentsScheduleCompanion data,
  ) {
    return InstallmentsScheduleData(
      id: data.id.present ? data.id.value : this.id,
      contractId: data.contractId.present
          ? data.contractId.value
          : this.contractId,
      installmentNumber: data.installmentNumber.present
          ? data.installmentNumber.value
          : this.installmentNumber,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      status: data.status.present ? data.status.value : this.status,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstallmentsScheduleData(')
          ..write('id: $id, ')
          ..write('contractId: $contractId, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contractId,
    installmentNumber,
    dueDate,
    status,
    userId,
    createdAt,
    updatedAt,
    isDeleted,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstallmentsScheduleData &&
          other.id == this.id &&
          other.contractId == this.contractId &&
          other.installmentNumber == this.installmentNumber &&
          other.dueDate == this.dueDate &&
          other.status == this.status &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isSynced == this.isSynced);
}

class InstallmentsScheduleCompanion
    extends UpdateCompanion<InstallmentsScheduleData> {
  final Value<String> id;
  final Value<String> contractId;
  final Value<int> installmentNumber;
  final Value<DateTime> dueDate;
  final Value<String> status;
  final Value<String> userId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const InstallmentsScheduleCompanion({
    this.id = const Value.absent(),
    this.contractId = const Value.absent(),
    this.installmentNumber = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstallmentsScheduleCompanion.insert({
    this.id = const Value.absent(),
    required String contractId,
    required int installmentNumber,
    required DateTime dueDate,
    this.status = const Value.absent(),
    required String userId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : contractId = Value(contractId),
       installmentNumber = Value(installmentNumber),
       dueDate = Value(dueDate),
       userId = Value(userId);
  static Insertable<InstallmentsScheduleData> custom({
    Expression<String>? id,
    Expression<String>? contractId,
    Expression<int>? installmentNumber,
    Expression<DateTime>? dueDate,
    Expression<String>? status,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contractId != null) 'contract_id': contractId,
      if (installmentNumber != null) 'installment_number': installmentNumber,
      if (dueDate != null) 'due_date': dueDate,
      if (status != null) 'status': status,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstallmentsScheduleCompanion copyWith({
    Value<String>? id,
    Value<String>? contractId,
    Value<int>? installmentNumber,
    Value<DateTime>? dueDate,
    Value<String>? status,
    Value<String>? userId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return InstallmentsScheduleCompanion(
      id: id ?? this.id,
      contractId: contractId ?? this.contractId,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (contractId.present) {
      map['contract_id'] = Variable<String>(contractId.value);
    }
    if (installmentNumber.present) {
      map['installment_number'] = Variable<int>(installmentNumber.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstallmentsScheduleCompanion(')
          ..write('id: $id, ')
          ..write('contractId: $contractId, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsLedgerTable extends PaymentsLedger
    with TableInfo<$PaymentsLedgerTable, PaymentsLedgerData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsLedgerTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v4(),
  );
  static const VerificationMeta _contractIdMeta = const VerificationMeta(
    'contractId',
  );
  @override
  late final GeneratedColumn<String> contractId = GeneratedColumn<String>(
    'contract_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contracts (id)',
    ),
  );
  static const VerificationMeta _scheduleIdMeta = const VerificationMeta(
    'scheduleId',
  );
  @override
  late final GeneratedColumn<String> scheduleId = GeneratedColumn<String>(
    'schedule_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES installments_schedule (id)',
    ),
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
    'payment_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaidMeta = const VerificationMeta(
    'amountPaid',
  );
  @override
  late final GeneratedColumn<double> amountPaid = GeneratedColumn<double>(
    'amount_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meterPriceAtPaymentMeta =
      const VerificationMeta('meterPriceAtPayment');
  @override
  late final GeneratedColumn<double> meterPriceAtPayment =
      GeneratedColumn<double>(
        'meter_price_at_payment',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _convertedMetersMeta = const VerificationMeta(
    'convertedMeters',
  );
  @override
  late final GeneratedColumn<double> convertedMeters = GeneratedColumn<double>(
    'converted_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feesMeta = const VerificationMeta('fees');
  @override
  late final GeneratedColumn<double> fees = GeneratedColumn<double>(
    'fees',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isWhatsAppSentMeta = const VerificationMeta(
    'isWhatsAppSent',
  );
  @override
  late final GeneratedColumn<bool> isWhatsAppSent = GeneratedColumn<bool>(
    'is_whats_app_sent',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_whats_app_sent" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contractId,
    scheduleId,
    paymentDate,
    amountPaid,
    meterPriceAtPayment,
    convertedMeters,
    fees,
    isWhatsAppSent,
    userId,
    createdAt,
    updatedAt,
    isDeleted,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments_ledger';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentsLedgerData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contract_id')) {
      context.handle(
        _contractIdMeta,
        contractId.isAcceptableOrUnknown(data['contract_id']!, _contractIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contractIdMeta);
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
        _scheduleIdMeta,
        scheduleId.isAcceptableOrUnknown(data['schedule_id']!, _scheduleIdMeta),
      );
    }
    if (data.containsKey('payment_date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['payment_date']!,
          _paymentDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentDateMeta);
    }
    if (data.containsKey('amount_paid')) {
      context.handle(
        _amountPaidMeta,
        amountPaid.isAcceptableOrUnknown(data['amount_paid']!, _amountPaidMeta),
      );
    } else if (isInserting) {
      context.missing(_amountPaidMeta);
    }
    if (data.containsKey('meter_price_at_payment')) {
      context.handle(
        _meterPriceAtPaymentMeta,
        meterPriceAtPayment.isAcceptableOrUnknown(
          data['meter_price_at_payment']!,
          _meterPriceAtPaymentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_meterPriceAtPaymentMeta);
    }
    if (data.containsKey('converted_meters')) {
      context.handle(
        _convertedMetersMeta,
        convertedMeters.isAcceptableOrUnknown(
          data['converted_meters']!,
          _convertedMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_convertedMetersMeta);
    }
    if (data.containsKey('fees')) {
      context.handle(
        _feesMeta,
        fees.isAcceptableOrUnknown(data['fees']!, _feesMeta),
      );
    }
    if (data.containsKey('is_whats_app_sent')) {
      context.handle(
        _isWhatsAppSentMeta,
        isWhatsAppSent.isAcceptableOrUnknown(
          data['is_whats_app_sent']!,
          _isWhatsAppSentMeta,
        ),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentsLedgerData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentsLedgerData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      contractId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contract_id'],
      )!,
      scheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_id'],
      ),
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_date'],
      )!,
      amountPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_paid'],
      )!,
      meterPriceAtPayment: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}meter_price_at_payment'],
      )!,
      convertedMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}converted_meters'],
      )!,
      fees: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fees'],
      )!,
      isWhatsAppSent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_whats_app_sent'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $PaymentsLedgerTable createAlias(String alias) {
    return $PaymentsLedgerTable(attachedDatabase, alias);
  }
}

class PaymentsLedgerData extends DataClass
    implements Insertable<PaymentsLedgerData> {
  final String id;
  final String contractId;
  final String? scheduleId;
  final DateTime paymentDate;
  final double amountPaid;
  final double meterPriceAtPayment;
  final double convertedMeters;
  final double fees;
  final bool isWhatsAppSent;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isSynced;
  const PaymentsLedgerData({
    required this.id,
    required this.contractId,
    this.scheduleId,
    required this.paymentDate,
    required this.amountPaid,
    required this.meterPriceAtPayment,
    required this.convertedMeters,
    required this.fees,
    required this.isWhatsAppSent,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['contract_id'] = Variable<String>(contractId);
    if (!nullToAbsent || scheduleId != null) {
      map['schedule_id'] = Variable<String>(scheduleId);
    }
    map['payment_date'] = Variable<DateTime>(paymentDate);
    map['amount_paid'] = Variable<double>(amountPaid);
    map['meter_price_at_payment'] = Variable<double>(meterPriceAtPayment);
    map['converted_meters'] = Variable<double>(convertedMeters);
    map['fees'] = Variable<double>(fees);
    map['is_whats_app_sent'] = Variable<bool>(isWhatsAppSent);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  PaymentsLedgerCompanion toCompanion(bool nullToAbsent) {
    return PaymentsLedgerCompanion(
      id: Value(id),
      contractId: Value(contractId),
      scheduleId: scheduleId == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduleId),
      paymentDate: Value(paymentDate),
      amountPaid: Value(amountPaid),
      meterPriceAtPayment: Value(meterPriceAtPayment),
      convertedMeters: Value(convertedMeters),
      fees: Value(fees),
      isWhatsAppSent: Value(isWhatsAppSent),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isSynced: Value(isSynced),
    );
  }

  factory PaymentsLedgerData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentsLedgerData(
      id: serializer.fromJson<String>(json['id']),
      contractId: serializer.fromJson<String>(json['contractId']),
      scheduleId: serializer.fromJson<String?>(json['scheduleId']),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      amountPaid: serializer.fromJson<double>(json['amountPaid']),
      meterPriceAtPayment: serializer.fromJson<double>(
        json['meterPriceAtPayment'],
      ),
      convertedMeters: serializer.fromJson<double>(json['convertedMeters']),
      fees: serializer.fromJson<double>(json['fees']),
      isWhatsAppSent: serializer.fromJson<bool>(json['isWhatsAppSent']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'contractId': serializer.toJson<String>(contractId),
      'scheduleId': serializer.toJson<String?>(scheduleId),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'amountPaid': serializer.toJson<double>(amountPaid),
      'meterPriceAtPayment': serializer.toJson<double>(meterPriceAtPayment),
      'convertedMeters': serializer.toJson<double>(convertedMeters),
      'fees': serializer.toJson<double>(fees),
      'isWhatsAppSent': serializer.toJson<bool>(isWhatsAppSent),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  PaymentsLedgerData copyWith({
    String? id,
    String? contractId,
    Value<String?> scheduleId = const Value.absent(),
    DateTime? paymentDate,
    double? amountPaid,
    double? meterPriceAtPayment,
    double? convertedMeters,
    double? fees,
    bool? isWhatsAppSent,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isSynced,
  }) => PaymentsLedgerData(
    id: id ?? this.id,
    contractId: contractId ?? this.contractId,
    scheduleId: scheduleId.present ? scheduleId.value : this.scheduleId,
    paymentDate: paymentDate ?? this.paymentDate,
    amountPaid: amountPaid ?? this.amountPaid,
    meterPriceAtPayment: meterPriceAtPayment ?? this.meterPriceAtPayment,
    convertedMeters: convertedMeters ?? this.convertedMeters,
    fees: fees ?? this.fees,
    isWhatsAppSent: isWhatsAppSent ?? this.isWhatsAppSent,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isSynced: isSynced ?? this.isSynced,
  );
  PaymentsLedgerData copyWithCompanion(PaymentsLedgerCompanion data) {
    return PaymentsLedgerData(
      id: data.id.present ? data.id.value : this.id,
      contractId: data.contractId.present
          ? data.contractId.value
          : this.contractId,
      scheduleId: data.scheduleId.present
          ? data.scheduleId.value
          : this.scheduleId,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      amountPaid: data.amountPaid.present
          ? data.amountPaid.value
          : this.amountPaid,
      meterPriceAtPayment: data.meterPriceAtPayment.present
          ? data.meterPriceAtPayment.value
          : this.meterPriceAtPayment,
      convertedMeters: data.convertedMeters.present
          ? data.convertedMeters.value
          : this.convertedMeters,
      fees: data.fees.present ? data.fees.value : this.fees,
      isWhatsAppSent: data.isWhatsAppSent.present
          ? data.isWhatsAppSent.value
          : this.isWhatsAppSent,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsLedgerData(')
          ..write('id: $id, ')
          ..write('contractId: $contractId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('meterPriceAtPayment: $meterPriceAtPayment, ')
          ..write('convertedMeters: $convertedMeters, ')
          ..write('fees: $fees, ')
          ..write('isWhatsAppSent: $isWhatsAppSent, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contractId,
    scheduleId,
    paymentDate,
    amountPaid,
    meterPriceAtPayment,
    convertedMeters,
    fees,
    isWhatsAppSent,
    userId,
    createdAt,
    updatedAt,
    isDeleted,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentsLedgerData &&
          other.id == this.id &&
          other.contractId == this.contractId &&
          other.scheduleId == this.scheduleId &&
          other.paymentDate == this.paymentDate &&
          other.amountPaid == this.amountPaid &&
          other.meterPriceAtPayment == this.meterPriceAtPayment &&
          other.convertedMeters == this.convertedMeters &&
          other.fees == this.fees &&
          other.isWhatsAppSent == this.isWhatsAppSent &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isSynced == this.isSynced);
}

class PaymentsLedgerCompanion extends UpdateCompanion<PaymentsLedgerData> {
  final Value<String> id;
  final Value<String> contractId;
  final Value<String?> scheduleId;
  final Value<DateTime> paymentDate;
  final Value<double> amountPaid;
  final Value<double> meterPriceAtPayment;
  final Value<double> convertedMeters;
  final Value<double> fees;
  final Value<bool> isWhatsAppSent;
  final Value<String> userId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const PaymentsLedgerCompanion({
    this.id = const Value.absent(),
    this.contractId = const Value.absent(),
    this.scheduleId = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.meterPriceAtPayment = const Value.absent(),
    this.convertedMeters = const Value.absent(),
    this.fees = const Value.absent(),
    this.isWhatsAppSent = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsLedgerCompanion.insert({
    this.id = const Value.absent(),
    required String contractId,
    this.scheduleId = const Value.absent(),
    required DateTime paymentDate,
    required double amountPaid,
    required double meterPriceAtPayment,
    required double convertedMeters,
    this.fees = const Value.absent(),
    this.isWhatsAppSent = const Value.absent(),
    required String userId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : contractId = Value(contractId),
       paymentDate = Value(paymentDate),
       amountPaid = Value(amountPaid),
       meterPriceAtPayment = Value(meterPriceAtPayment),
       convertedMeters = Value(convertedMeters),
       userId = Value(userId);
  static Insertable<PaymentsLedgerData> custom({
    Expression<String>? id,
    Expression<String>? contractId,
    Expression<String>? scheduleId,
    Expression<DateTime>? paymentDate,
    Expression<double>? amountPaid,
    Expression<double>? meterPriceAtPayment,
    Expression<double>? convertedMeters,
    Expression<double>? fees,
    Expression<bool>? isWhatsAppSent,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contractId != null) 'contract_id': contractId,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (amountPaid != null) 'amount_paid': amountPaid,
      if (meterPriceAtPayment != null)
        'meter_price_at_payment': meterPriceAtPayment,
      if (convertedMeters != null) 'converted_meters': convertedMeters,
      if (fees != null) 'fees': fees,
      if (isWhatsAppSent != null) 'is_whats_app_sent': isWhatsAppSent,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsLedgerCompanion copyWith({
    Value<String>? id,
    Value<String>? contractId,
    Value<String?>? scheduleId,
    Value<DateTime>? paymentDate,
    Value<double>? amountPaid,
    Value<double>? meterPriceAtPayment,
    Value<double>? convertedMeters,
    Value<double>? fees,
    Value<bool>? isWhatsAppSent,
    Value<String>? userId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return PaymentsLedgerCompanion(
      id: id ?? this.id,
      contractId: contractId ?? this.contractId,
      scheduleId: scheduleId ?? this.scheduleId,
      paymentDate: paymentDate ?? this.paymentDate,
      amountPaid: amountPaid ?? this.amountPaid,
      meterPriceAtPayment: meterPriceAtPayment ?? this.meterPriceAtPayment,
      convertedMeters: convertedMeters ?? this.convertedMeters,
      fees: fees ?? this.fees,
      isWhatsAppSent: isWhatsAppSent ?? this.isWhatsAppSent,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (contractId.present) {
      map['contract_id'] = Variable<String>(contractId.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = Variable<String>(scheduleId.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (amountPaid.present) {
      map['amount_paid'] = Variable<double>(amountPaid.value);
    }
    if (meterPriceAtPayment.present) {
      map['meter_price_at_payment'] = Variable<double>(
        meterPriceAtPayment.value,
      );
    }
    if (convertedMeters.present) {
      map['converted_meters'] = Variable<double>(convertedMeters.value);
    }
    if (fees.present) {
      map['fees'] = Variable<double>(fees.value);
    }
    if (isWhatsAppSent.present) {
      map['is_whats_app_sent'] = Variable<bool>(isWhatsAppSent.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsLedgerCompanion(')
          ..write('id: $id, ')
          ..write('contractId: $contractId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('meterPriceAtPayment: $meterPriceAtPayment, ')
          ..write('convertedMeters: $convertedMeters, ')
          ..write('fees: $fees, ')
          ..write('isWhatsAppSent: $isWhatsAppSent, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClientsTable clients = $ClientsTable(this);
  late final $ContractsTable contracts = $ContractsTable(this);
  late final $MaterialPricesHistoryTable materialPricesHistory =
      $MaterialPricesHistoryTable(this);
  late final $InstallmentsScheduleTable installmentsSchedule =
      $InstallmentsScheduleTable(this);
  late final $PaymentsLedgerTable paymentsLedger = $PaymentsLedgerTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    clients,
    contracts,
    materialPricesHistory,
    installmentsSchedule,
    paymentsLedger,
  ];
}

typedef $$ClientsTableCreateCompanionBuilder =
    ClientsCompanion Function({
      Value<String> id,
      required String name,
      required String phone,
      Value<String?> nationalId,
      required String userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$ClientsTableUpdateCompanionBuilder =
    ClientsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> phone,
      Value<String?> nationalId,
      Value<String> userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });

final class $$ClientsTableReferences
    extends BaseReferences<_$AppDatabase, $ClientsTable, Client> {
  $$ClientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ContractsTable, List<Contract>>
  _contractsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.contracts,
    aliasName: $_aliasNameGenerator(db.clients.id, db.contracts.clientId),
  );

  $$ContractsTableProcessedTableManager get contractsRefs {
    final manager = $$ContractsTableTableManager(
      $_db,
      $_db.contracts,
    ).filter((f) => f.clientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_contractsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClientsTableFilterComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> contractsRefs(
    Expression<bool> Function($$ContractsTableFilterComposer f) f,
  ) {
    final $$ContractsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contracts,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContractsTableFilterComposer(
            $db: $db,
            $table: $db.contracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  Expression<T> contractsRefs<T extends Object>(
    Expression<T> Function($$ContractsTableAnnotationComposer a) f,
  ) {
    final $$ContractsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contracts,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContractsTableAnnotationComposer(
            $db: $db,
            $table: $db.contracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientsTable,
          Client,
          $$ClientsTableFilterComposer,
          $$ClientsTableOrderingComposer,
          $$ClientsTableAnnotationComposer,
          $$ClientsTableCreateCompanionBuilder,
          $$ClientsTableUpdateCompanionBuilder,
          (Client, $$ClientsTableReferences),
          Client,
          PrefetchHooks Function({bool contractsRefs})
        > {
  $$ClientsTableTableManager(_$AppDatabase db, $ClientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String?> nationalId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientsCompanion(
                id: id,
                name: name,
                phone: phone,
                nationalId: nationalId,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                required String phone,
                Value<String?> nationalId = const Value.absent(),
                required String userId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientsCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                nationalId: nationalId,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ClientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contractsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (contractsRefs) db.contracts],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (contractsRefs)
                    await $_getPrefetchedData<Client, $ClientsTable, Contract>(
                      currentTable: table,
                      referencedTable: $$ClientsTableReferences
                          ._contractsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ClientsTableReferences(db, table, p0).contractsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.clientId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ClientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientsTable,
      Client,
      $$ClientsTableFilterComposer,
      $$ClientsTableOrderingComposer,
      $$ClientsTableAnnotationComposer,
      $$ClientsTableCreateCompanionBuilder,
      $$ClientsTableUpdateCompanionBuilder,
      (Client, $$ClientsTableReferences),
      Client,
      PrefetchHooks Function({bool contractsRefs})
    >;
typedef $$ContractsTableCreateCompanionBuilder =
    ContractsCompanion Function({
      Value<String> id,
      required String clientId,
      Value<String> contractType,
      required String apartmentDetails,
      required double totalArea,
      required double baseMeterPriceAtSigning,
      Value<int> installmentsCount,
      Value<String> coefficients,
      required String userId,
      required DateTime contractDate,
      Value<bool> isCompleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$ContractsTableUpdateCompanionBuilder =
    ContractsCompanion Function({
      Value<String> id,
      Value<String> clientId,
      Value<String> contractType,
      Value<String> apartmentDetails,
      Value<double> totalArea,
      Value<double> baseMeterPriceAtSigning,
      Value<int> installmentsCount,
      Value<String> coefficients,
      Value<String> userId,
      Value<DateTime> contractDate,
      Value<bool> isCompleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });

final class $$ContractsTableReferences
    extends BaseReferences<_$AppDatabase, $ContractsTable, Contract> {
  $$ContractsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientsTable _clientIdTable(_$AppDatabase db) => db.clients
      .createAlias($_aliasNameGenerator(db.contracts.clientId, db.clients.id));

  $$ClientsTableProcessedTableManager get clientId {
    final $_column = $_itemColumn<String>('client_id')!;

    final manager = $$ClientsTableTableManager(
      $_db,
      $_db.clients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $InstallmentsScheduleTable,
    List<InstallmentsScheduleData>
  >
  _installmentsScheduleRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.installmentsSchedule,
        aliasName: $_aliasNameGenerator(
          db.contracts.id,
          db.installmentsSchedule.contractId,
        ),
      );

  $$InstallmentsScheduleTableProcessedTableManager
  get installmentsScheduleRefs {
    final manager = $$InstallmentsScheduleTableTableManager(
      $_db,
      $_db.installmentsSchedule,
    ).filter((f) => f.contractId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _installmentsScheduleRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaymentsLedgerTable, List<PaymentsLedgerData>>
  _paymentsLedgerRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.paymentsLedger,
    aliasName: $_aliasNameGenerator(
      db.contracts.id,
      db.paymentsLedger.contractId,
    ),
  );

  $$PaymentsLedgerTableProcessedTableManager get paymentsLedgerRefs {
    final manager = $$PaymentsLedgerTableTableManager(
      $_db,
      $_db.paymentsLedger,
    ).filter((f) => f.contractId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsLedgerRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ContractsTableFilterComposer
    extends Composer<_$AppDatabase, $ContractsTable> {
  $$ContractsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contractType => $composableBuilder(
    column: $table.contractType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apartmentDetails => $composableBuilder(
    column: $table.apartmentDetails,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalArea => $composableBuilder(
    column: $table.totalArea,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get baseMeterPriceAtSigning => $composableBuilder(
    column: $table.baseMeterPriceAtSigning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installmentsCount => $composableBuilder(
    column: $table.installmentsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coefficients => $composableBuilder(
    column: $table.coefficients,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get contractDate => $composableBuilder(
    column: $table.contractDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientsTableFilterComposer get clientId {
    final $$ClientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableFilterComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> installmentsScheduleRefs(
    Expression<bool> Function($$InstallmentsScheduleTableFilterComposer f) f,
  ) {
    final $$InstallmentsScheduleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.installmentsSchedule,
      getReferencedColumn: (t) => t.contractId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstallmentsScheduleTableFilterComposer(
            $db: $db,
            $table: $db.installmentsSchedule,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentsLedgerRefs(
    Expression<bool> Function($$PaymentsLedgerTableFilterComposer f) f,
  ) {
    final $$PaymentsLedgerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentsLedger,
      getReferencedColumn: (t) => t.contractId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsLedgerTableFilterComposer(
            $db: $db,
            $table: $db.paymentsLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContractsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContractsTable> {
  $$ContractsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contractType => $composableBuilder(
    column: $table.contractType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apartmentDetails => $composableBuilder(
    column: $table.apartmentDetails,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalArea => $composableBuilder(
    column: $table.totalArea,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get baseMeterPriceAtSigning => $composableBuilder(
    column: $table.baseMeterPriceAtSigning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installmentsCount => $composableBuilder(
    column: $table.installmentsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coefficients => $composableBuilder(
    column: $table.coefficients,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get contractDate => $composableBuilder(
    column: $table.contractDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientsTableOrderingComposer get clientId {
    final $$ClientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableOrderingComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContractsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContractsTable> {
  $$ContractsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contractType => $composableBuilder(
    column: $table.contractType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get apartmentDetails => $composableBuilder(
    column: $table.apartmentDetails,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalArea =>
      $composableBuilder(column: $table.totalArea, builder: (column) => column);

  GeneratedColumn<double> get baseMeterPriceAtSigning => $composableBuilder(
    column: $table.baseMeterPriceAtSigning,
    builder: (column) => column,
  );

  GeneratedColumn<int> get installmentsCount => $composableBuilder(
    column: $table.installmentsCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coefficients => $composableBuilder(
    column: $table.coefficients,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get contractDate => $composableBuilder(
    column: $table.contractDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $$ClientsTableAnnotationComposer get clientId {
    final $$ClientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableAnnotationComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> installmentsScheduleRefs<T extends Object>(
    Expression<T> Function($$InstallmentsScheduleTableAnnotationComposer a) f,
  ) {
    final $$InstallmentsScheduleTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.installmentsSchedule,
          getReferencedColumn: (t) => t.contractId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InstallmentsScheduleTableAnnotationComposer(
                $db: $db,
                $table: $db.installmentsSchedule,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> paymentsLedgerRefs<T extends Object>(
    Expression<T> Function($$PaymentsLedgerTableAnnotationComposer a) f,
  ) {
    final $$PaymentsLedgerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentsLedger,
      getReferencedColumn: (t) => t.contractId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsLedgerTableAnnotationComposer(
            $db: $db,
            $table: $db.paymentsLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContractsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContractsTable,
          Contract,
          $$ContractsTableFilterComposer,
          $$ContractsTableOrderingComposer,
          $$ContractsTableAnnotationComposer,
          $$ContractsTableCreateCompanionBuilder,
          $$ContractsTableUpdateCompanionBuilder,
          (Contract, $$ContractsTableReferences),
          Contract,
          PrefetchHooks Function({
            bool clientId,
            bool installmentsScheduleRefs,
            bool paymentsLedgerRefs,
          })
        > {
  $$ContractsTableTableManager(_$AppDatabase db, $ContractsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContractsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContractsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContractsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String> contractType = const Value.absent(),
                Value<String> apartmentDetails = const Value.absent(),
                Value<double> totalArea = const Value.absent(),
                Value<double> baseMeterPriceAtSigning = const Value.absent(),
                Value<int> installmentsCount = const Value.absent(),
                Value<String> coefficients = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> contractDate = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContractsCompanion(
                id: id,
                clientId: clientId,
                contractType: contractType,
                apartmentDetails: apartmentDetails,
                totalArea: totalArea,
                baseMeterPriceAtSigning: baseMeterPriceAtSigning,
                installmentsCount: installmentsCount,
                coefficients: coefficients,
                userId: userId,
                contractDate: contractDate,
                isCompleted: isCompleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String clientId,
                Value<String> contractType = const Value.absent(),
                required String apartmentDetails,
                required double totalArea,
                required double baseMeterPriceAtSigning,
                Value<int> installmentsCount = const Value.absent(),
                Value<String> coefficients = const Value.absent(),
                required String userId,
                required DateTime contractDate,
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContractsCompanion.insert(
                id: id,
                clientId: clientId,
                contractType: contractType,
                apartmentDetails: apartmentDetails,
                totalArea: totalArea,
                baseMeterPriceAtSigning: baseMeterPriceAtSigning,
                installmentsCount: installmentsCount,
                coefficients: coefficients,
                userId: userId,
                contractDate: contractDate,
                isCompleted: isCompleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ContractsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                clientId = false,
                installmentsScheduleRefs = false,
                paymentsLedgerRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (installmentsScheduleRefs) db.installmentsSchedule,
                    if (paymentsLedgerRefs) db.paymentsLedger,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (clientId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.clientId,
                                    referencedTable: $$ContractsTableReferences
                                        ._clientIdTable(db),
                                    referencedColumn: $$ContractsTableReferences
                                        ._clientIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (installmentsScheduleRefs)
                        await $_getPrefetchedData<
                          Contract,
                          $ContractsTable,
                          InstallmentsScheduleData
                        >(
                          currentTable: table,
                          referencedTable: $$ContractsTableReferences
                              ._installmentsScheduleRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContractsTableReferences(
                                db,
                                table,
                                p0,
                              ).installmentsScheduleRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.contractId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (paymentsLedgerRefs)
                        await $_getPrefetchedData<
                          Contract,
                          $ContractsTable,
                          PaymentsLedgerData
                        >(
                          currentTable: table,
                          referencedTable: $$ContractsTableReferences
                              ._paymentsLedgerRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContractsTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsLedgerRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.contractId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ContractsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContractsTable,
      Contract,
      $$ContractsTableFilterComposer,
      $$ContractsTableOrderingComposer,
      $$ContractsTableAnnotationComposer,
      $$ContractsTableCreateCompanionBuilder,
      $$ContractsTableUpdateCompanionBuilder,
      (Contract, $$ContractsTableReferences),
      Contract,
      PrefetchHooks Function({
        bool clientId,
        bool installmentsScheduleRefs,
        bool paymentsLedgerRefs,
      })
    >;
typedef $$MaterialPricesHistoryTableCreateCompanionBuilder =
    MaterialPricesHistoryCompanion Function({
      Value<String> id,
      Value<DateTime> effectiveDate,
      required double ironPrice,
      required double cementPrice,
      required double block15Price,
      required double formworkAndPouringWages,
      required double aggregateMaterialsPrice,
      required double ordinaryWorkerWage,
      required String userId,
      Value<DateTime> createdAt,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$MaterialPricesHistoryTableUpdateCompanionBuilder =
    MaterialPricesHistoryCompanion Function({
      Value<String> id,
      Value<DateTime> effectiveDate,
      Value<double> ironPrice,
      Value<double> cementPrice,
      Value<double> block15Price,
      Value<double> formworkAndPouringWages,
      Value<double> aggregateMaterialsPrice,
      Value<double> ordinaryWorkerWage,
      Value<String> userId,
      Value<DateTime> createdAt,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });

class $$MaterialPricesHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $MaterialPricesHistoryTable> {
  $$MaterialPricesHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ironPrice => $composableBuilder(
    column: $table.ironPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cementPrice => $composableBuilder(
    column: $table.cementPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get block15Price => $composableBuilder(
    column: $table.block15Price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get formworkAndPouringWages => $composableBuilder(
    column: $table.formworkAndPouringWages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get aggregateMaterialsPrice => $composableBuilder(
    column: $table.aggregateMaterialsPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ordinaryWorkerWage => $composableBuilder(
    column: $table.ordinaryWorkerWage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MaterialPricesHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $MaterialPricesHistoryTable> {
  $$MaterialPricesHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ironPrice => $composableBuilder(
    column: $table.ironPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cementPrice => $composableBuilder(
    column: $table.cementPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get block15Price => $composableBuilder(
    column: $table.block15Price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get formworkAndPouringWages => $composableBuilder(
    column: $table.formworkAndPouringWages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get aggregateMaterialsPrice => $composableBuilder(
    column: $table.aggregateMaterialsPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ordinaryWorkerWage => $composableBuilder(
    column: $table.ordinaryWorkerWage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MaterialPricesHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaterialPricesHistoryTable> {
  $$MaterialPricesHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ironPrice =>
      $composableBuilder(column: $table.ironPrice, builder: (column) => column);

  GeneratedColumn<double> get cementPrice => $composableBuilder(
    column: $table.cementPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get block15Price => $composableBuilder(
    column: $table.block15Price,
    builder: (column) => column,
  );

  GeneratedColumn<double> get formworkAndPouringWages => $composableBuilder(
    column: $table.formworkAndPouringWages,
    builder: (column) => column,
  );

  GeneratedColumn<double> get aggregateMaterialsPrice => $composableBuilder(
    column: $table.aggregateMaterialsPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ordinaryWorkerWage => $composableBuilder(
    column: $table.ordinaryWorkerWage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$MaterialPricesHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaterialPricesHistoryTable,
          MaterialPricesHistoryData,
          $$MaterialPricesHistoryTableFilterComposer,
          $$MaterialPricesHistoryTableOrderingComposer,
          $$MaterialPricesHistoryTableAnnotationComposer,
          $$MaterialPricesHistoryTableCreateCompanionBuilder,
          $$MaterialPricesHistoryTableUpdateCompanionBuilder,
          (
            MaterialPricesHistoryData,
            BaseReferences<
              _$AppDatabase,
              $MaterialPricesHistoryTable,
              MaterialPricesHistoryData
            >,
          ),
          MaterialPricesHistoryData,
          PrefetchHooks Function()
        > {
  $$MaterialPricesHistoryTableTableManager(
    _$AppDatabase db,
    $MaterialPricesHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaterialPricesHistoryTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MaterialPricesHistoryTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MaterialPricesHistoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> effectiveDate = const Value.absent(),
                Value<double> ironPrice = const Value.absent(),
                Value<double> cementPrice = const Value.absent(),
                Value<double> block15Price = const Value.absent(),
                Value<double> formworkAndPouringWages = const Value.absent(),
                Value<double> aggregateMaterialsPrice = const Value.absent(),
                Value<double> ordinaryWorkerWage = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaterialPricesHistoryCompanion(
                id: id,
                effectiveDate: effectiveDate,
                ironPrice: ironPrice,
                cementPrice: cementPrice,
                block15Price: block15Price,
                formworkAndPouringWages: formworkAndPouringWages,
                aggregateMaterialsPrice: aggregateMaterialsPrice,
                ordinaryWorkerWage: ordinaryWorkerWage,
                userId: userId,
                createdAt: createdAt,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> effectiveDate = const Value.absent(),
                required double ironPrice,
                required double cementPrice,
                required double block15Price,
                required double formworkAndPouringWages,
                required double aggregateMaterialsPrice,
                required double ordinaryWorkerWage,
                required String userId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaterialPricesHistoryCompanion.insert(
                id: id,
                effectiveDate: effectiveDate,
                ironPrice: ironPrice,
                cementPrice: cementPrice,
                block15Price: block15Price,
                formworkAndPouringWages: formworkAndPouringWages,
                aggregateMaterialsPrice: aggregateMaterialsPrice,
                ordinaryWorkerWage: ordinaryWorkerWage,
                userId: userId,
                createdAt: createdAt,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MaterialPricesHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaterialPricesHistoryTable,
      MaterialPricesHistoryData,
      $$MaterialPricesHistoryTableFilterComposer,
      $$MaterialPricesHistoryTableOrderingComposer,
      $$MaterialPricesHistoryTableAnnotationComposer,
      $$MaterialPricesHistoryTableCreateCompanionBuilder,
      $$MaterialPricesHistoryTableUpdateCompanionBuilder,
      (
        MaterialPricesHistoryData,
        BaseReferences<
          _$AppDatabase,
          $MaterialPricesHistoryTable,
          MaterialPricesHistoryData
        >,
      ),
      MaterialPricesHistoryData,
      PrefetchHooks Function()
    >;
typedef $$InstallmentsScheduleTableCreateCompanionBuilder =
    InstallmentsScheduleCompanion Function({
      Value<String> id,
      required String contractId,
      required int installmentNumber,
      required DateTime dueDate,
      Value<String> status,
      required String userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$InstallmentsScheduleTableUpdateCompanionBuilder =
    InstallmentsScheduleCompanion Function({
      Value<String> id,
      Value<String> contractId,
      Value<int> installmentNumber,
      Value<DateTime> dueDate,
      Value<String> status,
      Value<String> userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });

final class $$InstallmentsScheduleTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InstallmentsScheduleTable,
          InstallmentsScheduleData
        > {
  $$InstallmentsScheduleTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ContractsTable _contractIdTable(_$AppDatabase db) =>
      db.contracts.createAlias(
        $_aliasNameGenerator(
          db.installmentsSchedule.contractId,
          db.contracts.id,
        ),
      );

  $$ContractsTableProcessedTableManager get contractId {
    final $_column = $_itemColumn<String>('contract_id')!;

    final manager = $$ContractsTableTableManager(
      $_db,
      $_db.contracts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contractIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PaymentsLedgerTable, List<PaymentsLedgerData>>
  _paymentsLedgerRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.paymentsLedger,
    aliasName: $_aliasNameGenerator(
      db.installmentsSchedule.id,
      db.paymentsLedger.scheduleId,
    ),
  );

  $$PaymentsLedgerTableProcessedTableManager get paymentsLedgerRefs {
    final manager = $$PaymentsLedgerTableTableManager(
      $_db,
      $_db.paymentsLedger,
    ).filter((f) => f.scheduleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsLedgerRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InstallmentsScheduleTableFilterComposer
    extends Composer<_$AppDatabase, $InstallmentsScheduleTable> {
  $$InstallmentsScheduleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  $$ContractsTableFilterComposer get contractId {
    final $$ContractsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contractId,
      referencedTable: $db.contracts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContractsTableFilterComposer(
            $db: $db,
            $table: $db.contracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paymentsLedgerRefs(
    Expression<bool> Function($$PaymentsLedgerTableFilterComposer f) f,
  ) {
    final $$PaymentsLedgerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentsLedger,
      getReferencedColumn: (t) => t.scheduleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsLedgerTableFilterComposer(
            $db: $db,
            $table: $db.paymentsLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InstallmentsScheduleTableOrderingComposer
    extends Composer<_$AppDatabase, $InstallmentsScheduleTable> {
  $$InstallmentsScheduleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContractsTableOrderingComposer get contractId {
    final $$ContractsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contractId,
      referencedTable: $db.contracts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContractsTableOrderingComposer(
            $db: $db,
            $table: $db.contracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InstallmentsScheduleTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstallmentsScheduleTable> {
  $$InstallmentsScheduleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $$ContractsTableAnnotationComposer get contractId {
    final $$ContractsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contractId,
      referencedTable: $db.contracts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContractsTableAnnotationComposer(
            $db: $db,
            $table: $db.contracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paymentsLedgerRefs<T extends Object>(
    Expression<T> Function($$PaymentsLedgerTableAnnotationComposer a) f,
  ) {
    final $$PaymentsLedgerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentsLedger,
      getReferencedColumn: (t) => t.scheduleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsLedgerTableAnnotationComposer(
            $db: $db,
            $table: $db.paymentsLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InstallmentsScheduleTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstallmentsScheduleTable,
          InstallmentsScheduleData,
          $$InstallmentsScheduleTableFilterComposer,
          $$InstallmentsScheduleTableOrderingComposer,
          $$InstallmentsScheduleTableAnnotationComposer,
          $$InstallmentsScheduleTableCreateCompanionBuilder,
          $$InstallmentsScheduleTableUpdateCompanionBuilder,
          (InstallmentsScheduleData, $$InstallmentsScheduleTableReferences),
          InstallmentsScheduleData,
          PrefetchHooks Function({bool contractId, bool paymentsLedgerRefs})
        > {
  $$InstallmentsScheduleTableTableManager(
    _$AppDatabase db,
    $InstallmentsScheduleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstallmentsScheduleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstallmentsScheduleTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InstallmentsScheduleTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> contractId = const Value.absent(),
                Value<int> installmentNumber = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstallmentsScheduleCompanion(
                id: id,
                contractId: contractId,
                installmentNumber: installmentNumber,
                dueDate: dueDate,
                status: status,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String contractId,
                required int installmentNumber,
                required DateTime dueDate,
                Value<String> status = const Value.absent(),
                required String userId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstallmentsScheduleCompanion.insert(
                id: id,
                contractId: contractId,
                installmentNumber: installmentNumber,
                dueDate: dueDate,
                status: status,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InstallmentsScheduleTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({contractId = false, paymentsLedgerRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paymentsLedgerRefs) db.paymentsLedger,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (contractId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.contractId,
                                    referencedTable:
                                        $$InstallmentsScheduleTableReferences
                                            ._contractIdTable(db),
                                    referencedColumn:
                                        $$InstallmentsScheduleTableReferences
                                            ._contractIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paymentsLedgerRefs)
                        await $_getPrefetchedData<
                          InstallmentsScheduleData,
                          $InstallmentsScheduleTable,
                          PaymentsLedgerData
                        >(
                          currentTable: table,
                          referencedTable: $$InstallmentsScheduleTableReferences
                              ._paymentsLedgerRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InstallmentsScheduleTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsLedgerRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.scheduleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$InstallmentsScheduleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstallmentsScheduleTable,
      InstallmentsScheduleData,
      $$InstallmentsScheduleTableFilterComposer,
      $$InstallmentsScheduleTableOrderingComposer,
      $$InstallmentsScheduleTableAnnotationComposer,
      $$InstallmentsScheduleTableCreateCompanionBuilder,
      $$InstallmentsScheduleTableUpdateCompanionBuilder,
      (InstallmentsScheduleData, $$InstallmentsScheduleTableReferences),
      InstallmentsScheduleData,
      PrefetchHooks Function({bool contractId, bool paymentsLedgerRefs})
    >;
typedef $$PaymentsLedgerTableCreateCompanionBuilder =
    PaymentsLedgerCompanion Function({
      Value<String> id,
      required String contractId,
      Value<String?> scheduleId,
      required DateTime paymentDate,
      required double amountPaid,
      required double meterPriceAtPayment,
      required double convertedMeters,
      Value<double> fees,
      Value<bool> isWhatsAppSent,
      required String userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$PaymentsLedgerTableUpdateCompanionBuilder =
    PaymentsLedgerCompanion Function({
      Value<String> id,
      Value<String> contractId,
      Value<String?> scheduleId,
      Value<DateTime> paymentDate,
      Value<double> amountPaid,
      Value<double> meterPriceAtPayment,
      Value<double> convertedMeters,
      Value<double> fees,
      Value<bool> isWhatsAppSent,
      Value<String> userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });

final class $$PaymentsLedgerTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PaymentsLedgerTable,
          PaymentsLedgerData
        > {
  $$PaymentsLedgerTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ContractsTable _contractIdTable(_$AppDatabase db) =>
      db.contracts.createAlias(
        $_aliasNameGenerator(db.paymentsLedger.contractId, db.contracts.id),
      );

  $$ContractsTableProcessedTableManager get contractId {
    final $_column = $_itemColumn<String>('contract_id')!;

    final manager = $$ContractsTableTableManager(
      $_db,
      $_db.contracts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contractIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InstallmentsScheduleTable _scheduleIdTable(_$AppDatabase db) =>
      db.installmentsSchedule.createAlias(
        $_aliasNameGenerator(
          db.paymentsLedger.scheduleId,
          db.installmentsSchedule.id,
        ),
      );

  $$InstallmentsScheduleTableProcessedTableManager? get scheduleId {
    final $_column = $_itemColumn<String>('schedule_id');
    if ($_column == null) return null;
    final manager = $$InstallmentsScheduleTableTableManager(
      $_db,
      $_db.installmentsSchedule,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scheduleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentsLedgerTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsLedgerTable> {
  $$PaymentsLedgerTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get meterPriceAtPayment => $composableBuilder(
    column: $table.meterPriceAtPayment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get convertedMeters => $composableBuilder(
    column: $table.convertedMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fees => $composableBuilder(
    column: $table.fees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWhatsAppSent => $composableBuilder(
    column: $table.isWhatsAppSent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  $$ContractsTableFilterComposer get contractId {
    final $$ContractsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contractId,
      referencedTable: $db.contracts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContractsTableFilterComposer(
            $db: $db,
            $table: $db.contracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InstallmentsScheduleTableFilterComposer get scheduleId {
    final $$InstallmentsScheduleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleId,
      referencedTable: $db.installmentsSchedule,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstallmentsScheduleTableFilterComposer(
            $db: $db,
            $table: $db.installmentsSchedule,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsLedgerTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsLedgerTable> {
  $$PaymentsLedgerTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get meterPriceAtPayment => $composableBuilder(
    column: $table.meterPriceAtPayment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get convertedMeters => $composableBuilder(
    column: $table.convertedMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fees => $composableBuilder(
    column: $table.fees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWhatsAppSent => $composableBuilder(
    column: $table.isWhatsAppSent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContractsTableOrderingComposer get contractId {
    final $$ContractsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contractId,
      referencedTable: $db.contracts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContractsTableOrderingComposer(
            $db: $db,
            $table: $db.contracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InstallmentsScheduleTableOrderingComposer get scheduleId {
    final $$InstallmentsScheduleTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.scheduleId,
          referencedTable: $db.installmentsSchedule,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InstallmentsScheduleTableOrderingComposer(
                $db: $db,
                $table: $db.installmentsSchedule,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$PaymentsLedgerTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsLedgerTable> {
  $$PaymentsLedgerTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => column,
  );

  GeneratedColumn<double> get meterPriceAtPayment => $composableBuilder(
    column: $table.meterPriceAtPayment,
    builder: (column) => column,
  );

  GeneratedColumn<double> get convertedMeters => $composableBuilder(
    column: $table.convertedMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fees =>
      $composableBuilder(column: $table.fees, builder: (column) => column);

  GeneratedColumn<bool> get isWhatsAppSent => $composableBuilder(
    column: $table.isWhatsAppSent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $$ContractsTableAnnotationComposer get contractId {
    final $$ContractsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contractId,
      referencedTable: $db.contracts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContractsTableAnnotationComposer(
            $db: $db,
            $table: $db.contracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InstallmentsScheduleTableAnnotationComposer get scheduleId {
    final $$InstallmentsScheduleTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.scheduleId,
          referencedTable: $db.installmentsSchedule,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InstallmentsScheduleTableAnnotationComposer(
                $db: $db,
                $table: $db.installmentsSchedule,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$PaymentsLedgerTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsLedgerTable,
          PaymentsLedgerData,
          $$PaymentsLedgerTableFilterComposer,
          $$PaymentsLedgerTableOrderingComposer,
          $$PaymentsLedgerTableAnnotationComposer,
          $$PaymentsLedgerTableCreateCompanionBuilder,
          $$PaymentsLedgerTableUpdateCompanionBuilder,
          (PaymentsLedgerData, $$PaymentsLedgerTableReferences),
          PaymentsLedgerData,
          PrefetchHooks Function({bool contractId, bool scheduleId})
        > {
  $$PaymentsLedgerTableTableManager(
    _$AppDatabase db,
    $PaymentsLedgerTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsLedgerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsLedgerTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsLedgerTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> contractId = const Value.absent(),
                Value<String?> scheduleId = const Value.absent(),
                Value<DateTime> paymentDate = const Value.absent(),
                Value<double> amountPaid = const Value.absent(),
                Value<double> meterPriceAtPayment = const Value.absent(),
                Value<double> convertedMeters = const Value.absent(),
                Value<double> fees = const Value.absent(),
                Value<bool> isWhatsAppSent = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsLedgerCompanion(
                id: id,
                contractId: contractId,
                scheduleId: scheduleId,
                paymentDate: paymentDate,
                amountPaid: amountPaid,
                meterPriceAtPayment: meterPriceAtPayment,
                convertedMeters: convertedMeters,
                fees: fees,
                isWhatsAppSent: isWhatsAppSent,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String contractId,
                Value<String?> scheduleId = const Value.absent(),
                required DateTime paymentDate,
                required double amountPaid,
                required double meterPriceAtPayment,
                required double convertedMeters,
                Value<double> fees = const Value.absent(),
                Value<bool> isWhatsAppSent = const Value.absent(),
                required String userId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsLedgerCompanion.insert(
                id: id,
                contractId: contractId,
                scheduleId: scheduleId,
                paymentDate: paymentDate,
                amountPaid: amountPaid,
                meterPriceAtPayment: meterPriceAtPayment,
                convertedMeters: convertedMeters,
                fees: fees,
                isWhatsAppSent: isWhatsAppSent,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentsLedgerTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contractId = false, scheduleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (contractId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.contractId,
                                referencedTable: $$PaymentsLedgerTableReferences
                                    ._contractIdTable(db),
                                referencedColumn:
                                    $$PaymentsLedgerTableReferences
                                        ._contractIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (scheduleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.scheduleId,
                                referencedTable: $$PaymentsLedgerTableReferences
                                    ._scheduleIdTable(db),
                                referencedColumn:
                                    $$PaymentsLedgerTableReferences
                                        ._scheduleIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PaymentsLedgerTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsLedgerTable,
      PaymentsLedgerData,
      $$PaymentsLedgerTableFilterComposer,
      $$PaymentsLedgerTableOrderingComposer,
      $$PaymentsLedgerTableAnnotationComposer,
      $$PaymentsLedgerTableCreateCompanionBuilder,
      $$PaymentsLedgerTableUpdateCompanionBuilder,
      (PaymentsLedgerData, $$PaymentsLedgerTableReferences),
      PaymentsLedgerData,
      PrefetchHooks Function({bool contractId, bool scheduleId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClientsTableTableManager get clients =>
      $$ClientsTableTableManager(_db, _db.clients);
  $$ContractsTableTableManager get contracts =>
      $$ContractsTableTableManager(_db, _db.contracts);
  $$MaterialPricesHistoryTableTableManager get materialPricesHistory =>
      $$MaterialPricesHistoryTableTableManager(_db, _db.materialPricesHistory);
  $$InstallmentsScheduleTableTableManager get installmentsSchedule =>
      $$InstallmentsScheduleTableTableManager(_db, _db.installmentsSchedule);
  $$PaymentsLedgerTableTableManager get paymentsLedger =>
      $$PaymentsLedgerTableTableManager(_db, _db.paymentsLedger);
}
