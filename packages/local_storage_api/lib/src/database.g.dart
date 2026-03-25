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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phone,
    nationalId,
    createdAt,
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
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
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
        DriftSqlType.int,
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
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ClientsTable createAlias(String alias) {
    return $ClientsTable(attachedDatabase, alias);
  }
}

class Client extends DataClass implements Insertable<Client> {
  final int id;
  final String name;
  final String phone;
  final String? nationalId;
  final DateTime createdAt;
  const Client({
    required this.id,
    required this.name,
    required this.phone,
    this.nationalId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || nationalId != null) {
      map['national_id'] = Variable<String>(nationalId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
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
      createdAt: Value(createdAt),
    );
  }

  factory Client.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Client(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      nationalId: serializer.fromJson<String?>(json['nationalId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'nationalId': serializer.toJson<String?>(nationalId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Client copyWith({
    int? id,
    String? name,
    String? phone,
    Value<String?> nationalId = const Value.absent(),
    DateTime? createdAt,
  }) => Client(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    nationalId: nationalId.present ? nationalId.value : this.nationalId,
    createdAt: createdAt ?? this.createdAt,
  );
  Client copyWithCompanion(ClientsCompanion data) {
    return Client(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      nationalId: data.nationalId.present
          ? data.nationalId.value
          : this.nationalId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Client(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('nationalId: $nationalId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, phone, nationalId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Client &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.nationalId == this.nationalId &&
          other.createdAt == this.createdAt);
}

class ClientsCompanion extends UpdateCompanion<Client> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<String?> nationalId;
  final Value<DateTime> createdAt;
  const ClientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ClientsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String phone,
    this.nationalId = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       phone = Value(phone);
  static Insertable<Client> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? nationalId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (nationalId != null) 'national_id': nationalId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ClientsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? phone,
    Value<String?>? nationalId,
    Value<DateTime>? createdAt,
  }) {
    return ClientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
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
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
          ..write('createdAt: $createdAt')
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
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<int> clientId = GeneratedColumn<int>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clients (id)',
    ),
  );
  static const VerificationMeta _apartmentDescriptionMeta =
      const VerificationMeta('apartmentDescription');
  @override
  late final GeneratedColumn<String> apartmentDescription =
      GeneratedColumn<String>(
        'apartment_description',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _apartmentAreaMeta = const VerificationMeta(
    'apartmentArea',
  );
  @override
  late final GeneratedColumn<double> apartmentArea = GeneratedColumn<double>(
    'apartment_area',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricePerSqmAtSigningMeta =
      const VerificationMeta('pricePerSqmAtSigning');
  @override
  late final GeneratedColumn<double> pricePerSqmAtSigning =
      GeneratedColumn<double>(
        'price_per_sqm_at_signing',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _totalContractValueMeta =
      const VerificationMeta('totalContractValue');
  @override
  late final GeneratedColumn<double> totalContractValue =
      GeneratedColumn<double>(
        'total_contract_value',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _monthlyInstallmentMeta =
      const VerificationMeta('monthlyInstallment');
  @override
  late final GeneratedColumn<double> monthlyInstallment =
      GeneratedColumn<double>(
        'monthly_installment',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _signatureDateMeta = const VerificationMeta(
    'signatureDate',
  );
  @override
  late final GeneratedColumn<DateTime> signatureDate =
      GeneratedColumn<DateTime>(
        'signature_date',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    apartmentDescription,
    apartmentArea,
    pricePerSqmAtSigning,
    totalContractValue,
    monthlyInstallment,
    signatureDate,
    isCompleted,
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
    if (data.containsKey('apartment_description')) {
      context.handle(
        _apartmentDescriptionMeta,
        apartmentDescription.isAcceptableOrUnknown(
          data['apartment_description']!,
          _apartmentDescriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_apartmentDescriptionMeta);
    }
    if (data.containsKey('apartment_area')) {
      context.handle(
        _apartmentAreaMeta,
        apartmentArea.isAcceptableOrUnknown(
          data['apartment_area']!,
          _apartmentAreaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_apartmentAreaMeta);
    }
    if (data.containsKey('price_per_sqm_at_signing')) {
      context.handle(
        _pricePerSqmAtSigningMeta,
        pricePerSqmAtSigning.isAcceptableOrUnknown(
          data['price_per_sqm_at_signing']!,
          _pricePerSqmAtSigningMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerSqmAtSigningMeta);
    }
    if (data.containsKey('total_contract_value')) {
      context.handle(
        _totalContractValueMeta,
        totalContractValue.isAcceptableOrUnknown(
          data['total_contract_value']!,
          _totalContractValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalContractValueMeta);
    }
    if (data.containsKey('monthly_installment')) {
      context.handle(
        _monthlyInstallmentMeta,
        monthlyInstallment.isAcceptableOrUnknown(
          data['monthly_installment']!,
          _monthlyInstallmentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthlyInstallmentMeta);
    }
    if (data.containsKey('signature_date')) {
      context.handle(
        _signatureDateMeta,
        signatureDate.isAcceptableOrUnknown(
          data['signature_date']!,
          _signatureDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_signatureDateMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Contract map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contract(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_id'],
      )!,
      apartmentDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apartment_description'],
      )!,
      apartmentArea: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}apartment_area'],
      )!,
      pricePerSqmAtSigning: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_per_sqm_at_signing'],
      )!,
      totalContractValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_contract_value'],
      )!,
      monthlyInstallment: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_installment'],
      )!,
      signatureDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}signature_date'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
    );
  }

  @override
  $ContractsTable createAlias(String alias) {
    return $ContractsTable(attachedDatabase, alias);
  }
}

class Contract extends DataClass implements Insertable<Contract> {
  final int id;
  final int clientId;
  final String apartmentDescription;
  final double apartmentArea;
  final double pricePerSqmAtSigning;
  final double totalContractValue;
  final double monthlyInstallment;
  final DateTime signatureDate;
  final bool isCompleted;
  const Contract({
    required this.id,
    required this.clientId,
    required this.apartmentDescription,
    required this.apartmentArea,
    required this.pricePerSqmAtSigning,
    required this.totalContractValue,
    required this.monthlyInstallment,
    required this.signatureDate,
    required this.isCompleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['client_id'] = Variable<int>(clientId);
    map['apartment_description'] = Variable<String>(apartmentDescription);
    map['apartment_area'] = Variable<double>(apartmentArea);
    map['price_per_sqm_at_signing'] = Variable<double>(pricePerSqmAtSigning);
    map['total_contract_value'] = Variable<double>(totalContractValue);
    map['monthly_installment'] = Variable<double>(monthlyInstallment);
    map['signature_date'] = Variable<DateTime>(signatureDate);
    map['is_completed'] = Variable<bool>(isCompleted);
    return map;
  }

  ContractsCompanion toCompanion(bool nullToAbsent) {
    return ContractsCompanion(
      id: Value(id),
      clientId: Value(clientId),
      apartmentDescription: Value(apartmentDescription),
      apartmentArea: Value(apartmentArea),
      pricePerSqmAtSigning: Value(pricePerSqmAtSigning),
      totalContractValue: Value(totalContractValue),
      monthlyInstallment: Value(monthlyInstallment),
      signatureDate: Value(signatureDate),
      isCompleted: Value(isCompleted),
    );
  }

  factory Contract.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contract(
      id: serializer.fromJson<int>(json['id']),
      clientId: serializer.fromJson<int>(json['clientId']),
      apartmentDescription: serializer.fromJson<String>(
        json['apartmentDescription'],
      ),
      apartmentArea: serializer.fromJson<double>(json['apartmentArea']),
      pricePerSqmAtSigning: serializer.fromJson<double>(
        json['pricePerSqmAtSigning'],
      ),
      totalContractValue: serializer.fromJson<double>(
        json['totalContractValue'],
      ),
      monthlyInstallment: serializer.fromJson<double>(
        json['monthlyInstallment'],
      ),
      signatureDate: serializer.fromJson<DateTime>(json['signatureDate']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clientId': serializer.toJson<int>(clientId),
      'apartmentDescription': serializer.toJson<String>(apartmentDescription),
      'apartmentArea': serializer.toJson<double>(apartmentArea),
      'pricePerSqmAtSigning': serializer.toJson<double>(pricePerSqmAtSigning),
      'totalContractValue': serializer.toJson<double>(totalContractValue),
      'monthlyInstallment': serializer.toJson<double>(monthlyInstallment),
      'signatureDate': serializer.toJson<DateTime>(signatureDate),
      'isCompleted': serializer.toJson<bool>(isCompleted),
    };
  }

  Contract copyWith({
    int? id,
    int? clientId,
    String? apartmentDescription,
    double? apartmentArea,
    double? pricePerSqmAtSigning,
    double? totalContractValue,
    double? monthlyInstallment,
    DateTime? signatureDate,
    bool? isCompleted,
  }) => Contract(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    apartmentDescription: apartmentDescription ?? this.apartmentDescription,
    apartmentArea: apartmentArea ?? this.apartmentArea,
    pricePerSqmAtSigning: pricePerSqmAtSigning ?? this.pricePerSqmAtSigning,
    totalContractValue: totalContractValue ?? this.totalContractValue,
    monthlyInstallment: monthlyInstallment ?? this.monthlyInstallment,
    signatureDate: signatureDate ?? this.signatureDate,
    isCompleted: isCompleted ?? this.isCompleted,
  );
  Contract copyWithCompanion(ContractsCompanion data) {
    return Contract(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      apartmentDescription: data.apartmentDescription.present
          ? data.apartmentDescription.value
          : this.apartmentDescription,
      apartmentArea: data.apartmentArea.present
          ? data.apartmentArea.value
          : this.apartmentArea,
      pricePerSqmAtSigning: data.pricePerSqmAtSigning.present
          ? data.pricePerSqmAtSigning.value
          : this.pricePerSqmAtSigning,
      totalContractValue: data.totalContractValue.present
          ? data.totalContractValue.value
          : this.totalContractValue,
      monthlyInstallment: data.monthlyInstallment.present
          ? data.monthlyInstallment.value
          : this.monthlyInstallment,
      signatureDate: data.signatureDate.present
          ? data.signatureDate.value
          : this.signatureDate,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Contract(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('apartmentDescription: $apartmentDescription, ')
          ..write('apartmentArea: $apartmentArea, ')
          ..write('pricePerSqmAtSigning: $pricePerSqmAtSigning, ')
          ..write('totalContractValue: $totalContractValue, ')
          ..write('monthlyInstallment: $monthlyInstallment, ')
          ..write('signatureDate: $signatureDate, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clientId,
    apartmentDescription,
    apartmentArea,
    pricePerSqmAtSigning,
    totalContractValue,
    monthlyInstallment,
    signatureDate,
    isCompleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contract &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.apartmentDescription == this.apartmentDescription &&
          other.apartmentArea == this.apartmentArea &&
          other.pricePerSqmAtSigning == this.pricePerSqmAtSigning &&
          other.totalContractValue == this.totalContractValue &&
          other.monthlyInstallment == this.monthlyInstallment &&
          other.signatureDate == this.signatureDate &&
          other.isCompleted == this.isCompleted);
}

class ContractsCompanion extends UpdateCompanion<Contract> {
  final Value<int> id;
  final Value<int> clientId;
  final Value<String> apartmentDescription;
  final Value<double> apartmentArea;
  final Value<double> pricePerSqmAtSigning;
  final Value<double> totalContractValue;
  final Value<double> monthlyInstallment;
  final Value<DateTime> signatureDate;
  final Value<bool> isCompleted;
  const ContractsCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.apartmentDescription = const Value.absent(),
    this.apartmentArea = const Value.absent(),
    this.pricePerSqmAtSigning = const Value.absent(),
    this.totalContractValue = const Value.absent(),
    this.monthlyInstallment = const Value.absent(),
    this.signatureDate = const Value.absent(),
    this.isCompleted = const Value.absent(),
  });
  ContractsCompanion.insert({
    this.id = const Value.absent(),
    required int clientId,
    required String apartmentDescription,
    required double apartmentArea,
    required double pricePerSqmAtSigning,
    required double totalContractValue,
    required double monthlyInstallment,
    required DateTime signatureDate,
    this.isCompleted = const Value.absent(),
  }) : clientId = Value(clientId),
       apartmentDescription = Value(apartmentDescription),
       apartmentArea = Value(apartmentArea),
       pricePerSqmAtSigning = Value(pricePerSqmAtSigning),
       totalContractValue = Value(totalContractValue),
       monthlyInstallment = Value(monthlyInstallment),
       signatureDate = Value(signatureDate);
  static Insertable<Contract> custom({
    Expression<int>? id,
    Expression<int>? clientId,
    Expression<String>? apartmentDescription,
    Expression<double>? apartmentArea,
    Expression<double>? pricePerSqmAtSigning,
    Expression<double>? totalContractValue,
    Expression<double>? monthlyInstallment,
    Expression<DateTime>? signatureDate,
    Expression<bool>? isCompleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (apartmentDescription != null)
        'apartment_description': apartmentDescription,
      if (apartmentArea != null) 'apartment_area': apartmentArea,
      if (pricePerSqmAtSigning != null)
        'price_per_sqm_at_signing': pricePerSqmAtSigning,
      if (totalContractValue != null)
        'total_contract_value': totalContractValue,
      if (monthlyInstallment != null) 'monthly_installment': monthlyInstallment,
      if (signatureDate != null) 'signature_date': signatureDate,
      if (isCompleted != null) 'is_completed': isCompleted,
    });
  }

  ContractsCompanion copyWith({
    Value<int>? id,
    Value<int>? clientId,
    Value<String>? apartmentDescription,
    Value<double>? apartmentArea,
    Value<double>? pricePerSqmAtSigning,
    Value<double>? totalContractValue,
    Value<double>? monthlyInstallment,
    Value<DateTime>? signatureDate,
    Value<bool>? isCompleted,
  }) {
    return ContractsCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      apartmentDescription: apartmentDescription ?? this.apartmentDescription,
      apartmentArea: apartmentArea ?? this.apartmentArea,
      pricePerSqmAtSigning: pricePerSqmAtSigning ?? this.pricePerSqmAtSigning,
      totalContractValue: totalContractValue ?? this.totalContractValue,
      monthlyInstallment: monthlyInstallment ?? this.monthlyInstallment,
      signatureDate: signatureDate ?? this.signatureDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<int>(clientId.value);
    }
    if (apartmentDescription.present) {
      map['apartment_description'] = Variable<String>(
        apartmentDescription.value,
      );
    }
    if (apartmentArea.present) {
      map['apartment_area'] = Variable<double>(apartmentArea.value);
    }
    if (pricePerSqmAtSigning.present) {
      map['price_per_sqm_at_signing'] = Variable<double>(
        pricePerSqmAtSigning.value,
      );
    }
    if (totalContractValue.present) {
      map['total_contract_value'] = Variable<double>(totalContractValue.value);
    }
    if (monthlyInstallment.present) {
      map['monthly_installment'] = Variable<double>(monthlyInstallment.value);
    }
    if (signatureDate.present) {
      map['signature_date'] = Variable<DateTime>(signatureDate.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContractsCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('apartmentDescription: $apartmentDescription, ')
          ..write('apartmentArea: $apartmentArea, ')
          ..write('pricePerSqmAtSigning: $pricePerSqmAtSigning, ')
          ..write('totalContractValue: $totalContractValue, ')
          ..write('monthlyInstallment: $monthlyInstallment, ')
          ..write('signatureDate: $signatureDate, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _contractIdMeta = const VerificationMeta(
    'contractId',
  );
  @override
  late final GeneratedColumn<int> contractId = GeneratedColumn<int>(
    'contract_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _originalInstallmentMeta =
      const VerificationMeta('originalInstallment');
  @override
  late final GeneratedColumn<double> originalInstallment =
      GeneratedColumn<double>(
        'original_installment',
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
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
  static const VerificationMeta _isSyncedToCloudMeta = const VerificationMeta(
    'isSyncedToCloud',
  );
  @override
  late final GeneratedColumn<bool> isSyncedToCloud = GeneratedColumn<bool>(
    'is_synced_to_cloud',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced_to_cloud" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contractId,
    installmentNumber,
    amountPaid,
    originalInstallment,
    fees,
    paymentDate,
    dueDate,
    isWhatsAppSent,
    isSyncedToCloud,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payment> instance, {
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
    if (data.containsKey('amount_paid')) {
      context.handle(
        _amountPaidMeta,
        amountPaid.isAcceptableOrUnknown(data['amount_paid']!, _amountPaidMeta),
      );
    } else if (isInserting) {
      context.missing(_amountPaidMeta);
    }
    if (data.containsKey('original_installment')) {
      context.handle(
        _originalInstallmentMeta,
        originalInstallment.isAcceptableOrUnknown(
          data['original_installment']!,
          _originalInstallmentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalInstallmentMeta);
    }
    if (data.containsKey('fees')) {
      context.handle(
        _feesMeta,
        fees.isAcceptableOrUnknown(data['fees']!, _feesMeta),
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
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
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
    if (data.containsKey('is_synced_to_cloud')) {
      context.handle(
        _isSyncedToCloudMeta,
        isSyncedToCloud.isAcceptableOrUnknown(
          data['is_synced_to_cloud']!,
          _isSyncedToCloudMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contractId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contract_id'],
      )!,
      installmentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installment_number'],
      )!,
      amountPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_paid'],
      )!,
      originalInstallment: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}original_installment'],
      )!,
      fees: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fees'],
      )!,
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_date'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      isWhatsAppSent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_whats_app_sent'],
      )!,
      isSyncedToCloud: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced_to_cloud'],
      )!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final int id;
  final int contractId;
  final int installmentNumber;
  final double amountPaid;
  final double originalInstallment;
  final double fees;
  final DateTime paymentDate;
  final DateTime? dueDate;
  final bool isWhatsAppSent;
  final bool isSyncedToCloud;
  const Payment({
    required this.id,
    required this.contractId,
    required this.installmentNumber,
    required this.amountPaid,
    required this.originalInstallment,
    required this.fees,
    required this.paymentDate,
    this.dueDate,
    required this.isWhatsAppSent,
    required this.isSyncedToCloud,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['contract_id'] = Variable<int>(contractId);
    map['installment_number'] = Variable<int>(installmentNumber);
    map['amount_paid'] = Variable<double>(amountPaid);
    map['original_installment'] = Variable<double>(originalInstallment);
    map['fees'] = Variable<double>(fees);
    map['payment_date'] = Variable<DateTime>(paymentDate);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['is_whats_app_sent'] = Variable<bool>(isWhatsAppSent);
    map['is_synced_to_cloud'] = Variable<bool>(isSyncedToCloud);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      contractId: Value(contractId),
      installmentNumber: Value(installmentNumber),
      amountPaid: Value(amountPaid),
      originalInstallment: Value(originalInstallment),
      fees: Value(fees),
      paymentDate: Value(paymentDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      isWhatsAppSent: Value(isWhatsAppSent),
      isSyncedToCloud: Value(isSyncedToCloud),
    );
  }

  factory Payment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<int>(json['id']),
      contractId: serializer.fromJson<int>(json['contractId']),
      installmentNumber: serializer.fromJson<int>(json['installmentNumber']),
      amountPaid: serializer.fromJson<double>(json['amountPaid']),
      originalInstallment: serializer.fromJson<double>(
        json['originalInstallment'],
      ),
      fees: serializer.fromJson<double>(json['fees']),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      isWhatsAppSent: serializer.fromJson<bool>(json['isWhatsAppSent']),
      isSyncedToCloud: serializer.fromJson<bool>(json['isSyncedToCloud']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contractId': serializer.toJson<int>(contractId),
      'installmentNumber': serializer.toJson<int>(installmentNumber),
      'amountPaid': serializer.toJson<double>(amountPaid),
      'originalInstallment': serializer.toJson<double>(originalInstallment),
      'fees': serializer.toJson<double>(fees),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'isWhatsAppSent': serializer.toJson<bool>(isWhatsAppSent),
      'isSyncedToCloud': serializer.toJson<bool>(isSyncedToCloud),
    };
  }

  Payment copyWith({
    int? id,
    int? contractId,
    int? installmentNumber,
    double? amountPaid,
    double? originalInstallment,
    double? fees,
    DateTime? paymentDate,
    Value<DateTime?> dueDate = const Value.absent(),
    bool? isWhatsAppSent,
    bool? isSyncedToCloud,
  }) => Payment(
    id: id ?? this.id,
    contractId: contractId ?? this.contractId,
    installmentNumber: installmentNumber ?? this.installmentNumber,
    amountPaid: amountPaid ?? this.amountPaid,
    originalInstallment: originalInstallment ?? this.originalInstallment,
    fees: fees ?? this.fees,
    paymentDate: paymentDate ?? this.paymentDate,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    isWhatsAppSent: isWhatsAppSent ?? this.isWhatsAppSent,
    isSyncedToCloud: isSyncedToCloud ?? this.isSyncedToCloud,
  );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      contractId: data.contractId.present
          ? data.contractId.value
          : this.contractId,
      installmentNumber: data.installmentNumber.present
          ? data.installmentNumber.value
          : this.installmentNumber,
      amountPaid: data.amountPaid.present
          ? data.amountPaid.value
          : this.amountPaid,
      originalInstallment: data.originalInstallment.present
          ? data.originalInstallment.value
          : this.originalInstallment,
      fees: data.fees.present ? data.fees.value : this.fees,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      isWhatsAppSent: data.isWhatsAppSent.present
          ? data.isWhatsAppSent.value
          : this.isWhatsAppSent,
      isSyncedToCloud: data.isSyncedToCloud.present
          ? data.isSyncedToCloud.value
          : this.isSyncedToCloud,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('contractId: $contractId, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('originalInstallment: $originalInstallment, ')
          ..write('fees: $fees, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('isWhatsAppSent: $isWhatsAppSent, ')
          ..write('isSyncedToCloud: $isSyncedToCloud')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contractId,
    installmentNumber,
    amountPaid,
    originalInstallment,
    fees,
    paymentDate,
    dueDate,
    isWhatsAppSent,
    isSyncedToCloud,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.contractId == this.contractId &&
          other.installmentNumber == this.installmentNumber &&
          other.amountPaid == this.amountPaid &&
          other.originalInstallment == this.originalInstallment &&
          other.fees == this.fees &&
          other.paymentDate == this.paymentDate &&
          other.dueDate == this.dueDate &&
          other.isWhatsAppSent == this.isWhatsAppSent &&
          other.isSyncedToCloud == this.isSyncedToCloud);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<int> id;
  final Value<int> contractId;
  final Value<int> installmentNumber;
  final Value<double> amountPaid;
  final Value<double> originalInstallment;
  final Value<double> fees;
  final Value<DateTime> paymentDate;
  final Value<DateTime?> dueDate;
  final Value<bool> isWhatsAppSent;
  final Value<bool> isSyncedToCloud;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.contractId = const Value.absent(),
    this.installmentNumber = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.originalInstallment = const Value.absent(),
    this.fees = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.isWhatsAppSent = const Value.absent(),
    this.isSyncedToCloud = const Value.absent(),
  });
  PaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int contractId,
    required int installmentNumber,
    required double amountPaid,
    required double originalInstallment,
    this.fees = const Value.absent(),
    required DateTime paymentDate,
    this.dueDate = const Value.absent(),
    this.isWhatsAppSent = const Value.absent(),
    this.isSyncedToCloud = const Value.absent(),
  }) : contractId = Value(contractId),
       installmentNumber = Value(installmentNumber),
       amountPaid = Value(amountPaid),
       originalInstallment = Value(originalInstallment),
       paymentDate = Value(paymentDate);
  static Insertable<Payment> custom({
    Expression<int>? id,
    Expression<int>? contractId,
    Expression<int>? installmentNumber,
    Expression<double>? amountPaid,
    Expression<double>? originalInstallment,
    Expression<double>? fees,
    Expression<DateTime>? paymentDate,
    Expression<DateTime>? dueDate,
    Expression<bool>? isWhatsAppSent,
    Expression<bool>? isSyncedToCloud,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contractId != null) 'contract_id': contractId,
      if (installmentNumber != null) 'installment_number': installmentNumber,
      if (amountPaid != null) 'amount_paid': amountPaid,
      if (originalInstallment != null)
        'original_installment': originalInstallment,
      if (fees != null) 'fees': fees,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (dueDate != null) 'due_date': dueDate,
      if (isWhatsAppSent != null) 'is_whats_app_sent': isWhatsAppSent,
      if (isSyncedToCloud != null) 'is_synced_to_cloud': isSyncedToCloud,
    });
  }

  PaymentsCompanion copyWith({
    Value<int>? id,
    Value<int>? contractId,
    Value<int>? installmentNumber,
    Value<double>? amountPaid,
    Value<double>? originalInstallment,
    Value<double>? fees,
    Value<DateTime>? paymentDate,
    Value<DateTime?>? dueDate,
    Value<bool>? isWhatsAppSent,
    Value<bool>? isSyncedToCloud,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      contractId: contractId ?? this.contractId,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      amountPaid: amountPaid ?? this.amountPaid,
      originalInstallment: originalInstallment ?? this.originalInstallment,
      fees: fees ?? this.fees,
      paymentDate: paymentDate ?? this.paymentDate,
      dueDate: dueDate ?? this.dueDate,
      isWhatsAppSent: isWhatsAppSent ?? this.isWhatsAppSent,
      isSyncedToCloud: isSyncedToCloud ?? this.isSyncedToCloud,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contractId.present) {
      map['contract_id'] = Variable<int>(contractId.value);
    }
    if (installmentNumber.present) {
      map['installment_number'] = Variable<int>(installmentNumber.value);
    }
    if (amountPaid.present) {
      map['amount_paid'] = Variable<double>(amountPaid.value);
    }
    if (originalInstallment.present) {
      map['original_installment'] = Variable<double>(originalInstallment.value);
    }
    if (fees.present) {
      map['fees'] = Variable<double>(fees.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (isWhatsAppSent.present) {
      map['is_whats_app_sent'] = Variable<bool>(isWhatsAppSent.value);
    }
    if (isSyncedToCloud.present) {
      map['is_synced_to_cloud'] = Variable<bool>(isSyncedToCloud.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('contractId: $contractId, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('originalInstallment: $originalInstallment, ')
          ..write('fees: $fees, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('isWhatsAppSent: $isWhatsAppSent, ')
          ..write('isSyncedToCloud: $isSyncedToCloud')
          ..write(')'))
        .toString();
  }
}

class $MaterialPricesTable extends MaterialPrices
    with TableInfo<$MaterialPricesTable, MaterialPrice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaterialPricesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _reinforcedConcretePriceMeta =
      const VerificationMeta('reinforcedConcretePrice');
  @override
  late final GeneratedColumn<double> reinforcedConcretePrice =
      GeneratedColumn<double>(
        'reinforced_concrete_price',
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
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ironPrice,
    cementPrice,
    block15Price,
    formworkAndPouringWages,
    reinforcedConcretePrice,
    aggregateMaterialsPrice,
    ordinaryWorkerWage,
    lastUpdated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'material_prices';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaterialPrice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
    if (data.containsKey('reinforced_concrete_price')) {
      context.handle(
        _reinforcedConcretePriceMeta,
        reinforcedConcretePrice.isAcceptableOrUnknown(
          data['reinforced_concrete_price']!,
          _reinforcedConcretePriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reinforcedConcretePriceMeta);
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
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MaterialPrice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaterialPrice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
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
      reinforcedConcretePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reinforced_concrete_price'],
      )!,
      aggregateMaterialsPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}aggregate_materials_price'],
      )!,
      ordinaryWorkerWage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ordinary_worker_wage'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
    );
  }

  @override
  $MaterialPricesTable createAlias(String alias) {
    return $MaterialPricesTable(attachedDatabase, alias);
  }
}

class MaterialPrice extends DataClass implements Insertable<MaterialPrice> {
  final int id;
  final double ironPrice;
  final double cementPrice;
  final double block15Price;
  final double formworkAndPouringWages;
  final double reinforcedConcretePrice;
  final double aggregateMaterialsPrice;
  final double ordinaryWorkerWage;
  final DateTime lastUpdated;
  const MaterialPrice({
    required this.id,
    required this.ironPrice,
    required this.cementPrice,
    required this.block15Price,
    required this.formworkAndPouringWages,
    required this.reinforcedConcretePrice,
    required this.aggregateMaterialsPrice,
    required this.ordinaryWorkerWage,
    required this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['iron_price'] = Variable<double>(ironPrice);
    map['cement_price'] = Variable<double>(cementPrice);
    map['block15_price'] = Variable<double>(block15Price);
    map['formwork_and_pouring_wages'] = Variable<double>(
      formworkAndPouringWages,
    );
    map['reinforced_concrete_price'] = Variable<double>(
      reinforcedConcretePrice,
    );
    map['aggregate_materials_price'] = Variable<double>(
      aggregateMaterialsPrice,
    );
    map['ordinary_worker_wage'] = Variable<double>(ordinaryWorkerWage);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  MaterialPricesCompanion toCompanion(bool nullToAbsent) {
    return MaterialPricesCompanion(
      id: Value(id),
      ironPrice: Value(ironPrice),
      cementPrice: Value(cementPrice),
      block15Price: Value(block15Price),
      formworkAndPouringWages: Value(formworkAndPouringWages),
      reinforcedConcretePrice: Value(reinforcedConcretePrice),
      aggregateMaterialsPrice: Value(aggregateMaterialsPrice),
      ordinaryWorkerWage: Value(ordinaryWorkerWage),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory MaterialPrice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaterialPrice(
      id: serializer.fromJson<int>(json['id']),
      ironPrice: serializer.fromJson<double>(json['ironPrice']),
      cementPrice: serializer.fromJson<double>(json['cementPrice']),
      block15Price: serializer.fromJson<double>(json['block15Price']),
      formworkAndPouringWages: serializer.fromJson<double>(
        json['formworkAndPouringWages'],
      ),
      reinforcedConcretePrice: serializer.fromJson<double>(
        json['reinforcedConcretePrice'],
      ),
      aggregateMaterialsPrice: serializer.fromJson<double>(
        json['aggregateMaterialsPrice'],
      ),
      ordinaryWorkerWage: serializer.fromJson<double>(
        json['ordinaryWorkerWage'],
      ),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ironPrice': serializer.toJson<double>(ironPrice),
      'cementPrice': serializer.toJson<double>(cementPrice),
      'block15Price': serializer.toJson<double>(block15Price),
      'formworkAndPouringWages': serializer.toJson<double>(
        formworkAndPouringWages,
      ),
      'reinforcedConcretePrice': serializer.toJson<double>(
        reinforcedConcretePrice,
      ),
      'aggregateMaterialsPrice': serializer.toJson<double>(
        aggregateMaterialsPrice,
      ),
      'ordinaryWorkerWage': serializer.toJson<double>(ordinaryWorkerWage),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  MaterialPrice copyWith({
    int? id,
    double? ironPrice,
    double? cementPrice,
    double? block15Price,
    double? formworkAndPouringWages,
    double? reinforcedConcretePrice,
    double? aggregateMaterialsPrice,
    double? ordinaryWorkerWage,
    DateTime? lastUpdated,
  }) => MaterialPrice(
    id: id ?? this.id,
    ironPrice: ironPrice ?? this.ironPrice,
    cementPrice: cementPrice ?? this.cementPrice,
    block15Price: block15Price ?? this.block15Price,
    formworkAndPouringWages:
        formworkAndPouringWages ?? this.formworkAndPouringWages,
    reinforcedConcretePrice:
        reinforcedConcretePrice ?? this.reinforcedConcretePrice,
    aggregateMaterialsPrice:
        aggregateMaterialsPrice ?? this.aggregateMaterialsPrice,
    ordinaryWorkerWage: ordinaryWorkerWage ?? this.ordinaryWorkerWage,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
  MaterialPrice copyWithCompanion(MaterialPricesCompanion data) {
    return MaterialPrice(
      id: data.id.present ? data.id.value : this.id,
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
      reinforcedConcretePrice: data.reinforcedConcretePrice.present
          ? data.reinforcedConcretePrice.value
          : this.reinforcedConcretePrice,
      aggregateMaterialsPrice: data.aggregateMaterialsPrice.present
          ? data.aggregateMaterialsPrice.value
          : this.aggregateMaterialsPrice,
      ordinaryWorkerWage: data.ordinaryWorkerWage.present
          ? data.ordinaryWorkerWage.value
          : this.ordinaryWorkerWage,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaterialPrice(')
          ..write('id: $id, ')
          ..write('ironPrice: $ironPrice, ')
          ..write('cementPrice: $cementPrice, ')
          ..write('block15Price: $block15Price, ')
          ..write('formworkAndPouringWages: $formworkAndPouringWages, ')
          ..write('reinforcedConcretePrice: $reinforcedConcretePrice, ')
          ..write('aggregateMaterialsPrice: $aggregateMaterialsPrice, ')
          ..write('ordinaryWorkerWage: $ordinaryWorkerWage, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ironPrice,
    cementPrice,
    block15Price,
    formworkAndPouringWages,
    reinforcedConcretePrice,
    aggregateMaterialsPrice,
    ordinaryWorkerWage,
    lastUpdated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaterialPrice &&
          other.id == this.id &&
          other.ironPrice == this.ironPrice &&
          other.cementPrice == this.cementPrice &&
          other.block15Price == this.block15Price &&
          other.formworkAndPouringWages == this.formworkAndPouringWages &&
          other.reinforcedConcretePrice == this.reinforcedConcretePrice &&
          other.aggregateMaterialsPrice == this.aggregateMaterialsPrice &&
          other.ordinaryWorkerWage == this.ordinaryWorkerWage &&
          other.lastUpdated == this.lastUpdated);
}

class MaterialPricesCompanion extends UpdateCompanion<MaterialPrice> {
  final Value<int> id;
  final Value<double> ironPrice;
  final Value<double> cementPrice;
  final Value<double> block15Price;
  final Value<double> formworkAndPouringWages;
  final Value<double> reinforcedConcretePrice;
  final Value<double> aggregateMaterialsPrice;
  final Value<double> ordinaryWorkerWage;
  final Value<DateTime> lastUpdated;
  const MaterialPricesCompanion({
    this.id = const Value.absent(),
    this.ironPrice = const Value.absent(),
    this.cementPrice = const Value.absent(),
    this.block15Price = const Value.absent(),
    this.formworkAndPouringWages = const Value.absent(),
    this.reinforcedConcretePrice = const Value.absent(),
    this.aggregateMaterialsPrice = const Value.absent(),
    this.ordinaryWorkerWage = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  });
  MaterialPricesCompanion.insert({
    this.id = const Value.absent(),
    required double ironPrice,
    required double cementPrice,
    required double block15Price,
    required double formworkAndPouringWages,
    required double reinforcedConcretePrice,
    required double aggregateMaterialsPrice,
    required double ordinaryWorkerWage,
    this.lastUpdated = const Value.absent(),
  }) : ironPrice = Value(ironPrice),
       cementPrice = Value(cementPrice),
       block15Price = Value(block15Price),
       formworkAndPouringWages = Value(formworkAndPouringWages),
       reinforcedConcretePrice = Value(reinforcedConcretePrice),
       aggregateMaterialsPrice = Value(aggregateMaterialsPrice),
       ordinaryWorkerWage = Value(ordinaryWorkerWage);
  static Insertable<MaterialPrice> custom({
    Expression<int>? id,
    Expression<double>? ironPrice,
    Expression<double>? cementPrice,
    Expression<double>? block15Price,
    Expression<double>? formworkAndPouringWages,
    Expression<double>? reinforcedConcretePrice,
    Expression<double>? aggregateMaterialsPrice,
    Expression<double>? ordinaryWorkerWage,
    Expression<DateTime>? lastUpdated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ironPrice != null) 'iron_price': ironPrice,
      if (cementPrice != null) 'cement_price': cementPrice,
      if (block15Price != null) 'block15_price': block15Price,
      if (formworkAndPouringWages != null)
        'formwork_and_pouring_wages': formworkAndPouringWages,
      if (reinforcedConcretePrice != null)
        'reinforced_concrete_price': reinforcedConcretePrice,
      if (aggregateMaterialsPrice != null)
        'aggregate_materials_price': aggregateMaterialsPrice,
      if (ordinaryWorkerWage != null)
        'ordinary_worker_wage': ordinaryWorkerWage,
      if (lastUpdated != null) 'last_updated': lastUpdated,
    });
  }

  MaterialPricesCompanion copyWith({
    Value<int>? id,
    Value<double>? ironPrice,
    Value<double>? cementPrice,
    Value<double>? block15Price,
    Value<double>? formworkAndPouringWages,
    Value<double>? reinforcedConcretePrice,
    Value<double>? aggregateMaterialsPrice,
    Value<double>? ordinaryWorkerWage,
    Value<DateTime>? lastUpdated,
  }) {
    return MaterialPricesCompanion(
      id: id ?? this.id,
      ironPrice: ironPrice ?? this.ironPrice,
      cementPrice: cementPrice ?? this.cementPrice,
      block15Price: block15Price ?? this.block15Price,
      formworkAndPouringWages:
          formworkAndPouringWages ?? this.formworkAndPouringWages,
      reinforcedConcretePrice:
          reinforcedConcretePrice ?? this.reinforcedConcretePrice,
      aggregateMaterialsPrice:
          aggregateMaterialsPrice ?? this.aggregateMaterialsPrice,
      ordinaryWorkerWage: ordinaryWorkerWage ?? this.ordinaryWorkerWage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
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
    if (reinforcedConcretePrice.present) {
      map['reinforced_concrete_price'] = Variable<double>(
        reinforcedConcretePrice.value,
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
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaterialPricesCompanion(')
          ..write('id: $id, ')
          ..write('ironPrice: $ironPrice, ')
          ..write('cementPrice: $cementPrice, ')
          ..write('block15Price: $block15Price, ')
          ..write('formworkAndPouringWages: $formworkAndPouringWages, ')
          ..write('reinforcedConcretePrice: $reinforcedConcretePrice, ')
          ..write('aggregateMaterialsPrice: $aggregateMaterialsPrice, ')
          ..write('ordinaryWorkerWage: $ordinaryWorkerWage, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClientsTable clients = $ClientsTable(this);
  late final $ContractsTable contracts = $ContractsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $MaterialPricesTable materialPrices = $MaterialPricesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    clients,
    contracts,
    payments,
    materialPrices,
  ];
}

typedef $$ClientsTableCreateCompanionBuilder =
    ClientsCompanion Function({
      Value<int> id,
      required String name,
      required String phone,
      Value<String?> nationalId,
      Value<DateTime> createdAt,
    });
typedef $$ClientsTableUpdateCompanionBuilder =
    ClientsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> phone,
      Value<String?> nationalId,
      Value<DateTime> createdAt,
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
    ).filter((f) => f.clientId.id.sqlEquals($_itemColumn<int>('id')!));

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
  ColumnFilters<int> get id => $composableBuilder(
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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
  ColumnOrderings<int> get id => $composableBuilder(
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

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
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String?> nationalId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClientsCompanion(
                id: id,
                name: name,
                phone: phone,
                nationalId: nationalId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String phone,
                Value<String?> nationalId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClientsCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                nationalId: nationalId,
                createdAt: createdAt,
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
      Value<int> id,
      required int clientId,
      required String apartmentDescription,
      required double apartmentArea,
      required double pricePerSqmAtSigning,
      required double totalContractValue,
      required double monthlyInstallment,
      required DateTime signatureDate,
      Value<bool> isCompleted,
    });
typedef $$ContractsTableUpdateCompanionBuilder =
    ContractsCompanion Function({
      Value<int> id,
      Value<int> clientId,
      Value<String> apartmentDescription,
      Value<double> apartmentArea,
      Value<double> pricePerSqmAtSigning,
      Value<double> totalContractValue,
      Value<double> monthlyInstallment,
      Value<DateTime> signatureDate,
      Value<bool> isCompleted,
    });

final class $$ContractsTableReferences
    extends BaseReferences<_$AppDatabase, $ContractsTable, Contract> {
  $$ContractsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientsTable _clientIdTable(_$AppDatabase db) => db.clients
      .createAlias($_aliasNameGenerator(db.contracts.clientId, db.clients.id));

  $$ClientsTableProcessedTableManager get clientId {
    final $_column = $_itemColumn<int>('client_id')!;

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

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: $_aliasNameGenerator(db.contracts.id, db.payments.contractId),
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.contractId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
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
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apartmentDescription => $composableBuilder(
    column: $table.apartmentDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get apartmentArea => $composableBuilder(
    column: $table.apartmentArea,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pricePerSqmAtSigning => $composableBuilder(
    column: $table.pricePerSqmAtSigning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalContractValue => $composableBuilder(
    column: $table.totalContractValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyInstallment => $composableBuilder(
    column: $table.monthlyInstallment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get signatureDate => $composableBuilder(
    column: $table.signatureDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
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

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.contractId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
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
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apartmentDescription => $composableBuilder(
    column: $table.apartmentDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get apartmentArea => $composableBuilder(
    column: $table.apartmentArea,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pricePerSqmAtSigning => $composableBuilder(
    column: $table.pricePerSqmAtSigning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalContractValue => $composableBuilder(
    column: $table.totalContractValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyInstallment => $composableBuilder(
    column: $table.monthlyInstallment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get signatureDate => $composableBuilder(
    column: $table.signatureDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get apartmentDescription => $composableBuilder(
    column: $table.apartmentDescription,
    builder: (column) => column,
  );

  GeneratedColumn<double> get apartmentArea => $composableBuilder(
    column: $table.apartmentArea,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pricePerSqmAtSigning => $composableBuilder(
    column: $table.pricePerSqmAtSigning,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalContractValue => $composableBuilder(
    column: $table.totalContractValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monthlyInstallment => $composableBuilder(
    column: $table.monthlyInstallment,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get signatureDate => $composableBuilder(
    column: $table.signatureDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

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

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.contractId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
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
          PrefetchHooks Function({bool clientId, bool paymentsRefs})
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
                Value<int> id = const Value.absent(),
                Value<int> clientId = const Value.absent(),
                Value<String> apartmentDescription = const Value.absent(),
                Value<double> apartmentArea = const Value.absent(),
                Value<double> pricePerSqmAtSigning = const Value.absent(),
                Value<double> totalContractValue = const Value.absent(),
                Value<double> monthlyInstallment = const Value.absent(),
                Value<DateTime> signatureDate = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
              }) => ContractsCompanion(
                id: id,
                clientId: clientId,
                apartmentDescription: apartmentDescription,
                apartmentArea: apartmentArea,
                pricePerSqmAtSigning: pricePerSqmAtSigning,
                totalContractValue: totalContractValue,
                monthlyInstallment: monthlyInstallment,
                signatureDate: signatureDate,
                isCompleted: isCompleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int clientId,
                required String apartmentDescription,
                required double apartmentArea,
                required double pricePerSqmAtSigning,
                required double totalContractValue,
                required double monthlyInstallment,
                required DateTime signatureDate,
                Value<bool> isCompleted = const Value.absent(),
              }) => ContractsCompanion.insert(
                id: id,
                clientId: clientId,
                apartmentDescription: apartmentDescription,
                apartmentArea: apartmentArea,
                pricePerSqmAtSigning: pricePerSqmAtSigning,
                totalContractValue: totalContractValue,
                monthlyInstallment: monthlyInstallment,
                signatureDate: signatureDate,
                isCompleted: isCompleted,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ContractsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({clientId = false, paymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (paymentsRefs) db.payments],
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
                  if (paymentsRefs)
                    await $_getPrefetchedData<
                      Contract,
                      $ContractsTable,
                      Payment
                    >(
                      currentTable: table,
                      referencedTable: $$ContractsTableReferences
                          ._paymentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ContractsTableReferences(
                            db,
                            table,
                            p0,
                          ).paymentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.contractId == item.id),
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
      PrefetchHooks Function({bool clientId, bool paymentsRefs})
    >;
typedef $$PaymentsTableCreateCompanionBuilder =
    PaymentsCompanion Function({
      Value<int> id,
      required int contractId,
      required int installmentNumber,
      required double amountPaid,
      required double originalInstallment,
      Value<double> fees,
      required DateTime paymentDate,
      Value<DateTime?> dueDate,
      Value<bool> isWhatsAppSent,
      Value<bool> isSyncedToCloud,
    });
typedef $$PaymentsTableUpdateCompanionBuilder =
    PaymentsCompanion Function({
      Value<int> id,
      Value<int> contractId,
      Value<int> installmentNumber,
      Value<double> amountPaid,
      Value<double> originalInstallment,
      Value<double> fees,
      Value<DateTime> paymentDate,
      Value<DateTime?> dueDate,
      Value<bool> isWhatsAppSent,
      Value<bool> isSyncedToCloud,
    });

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, Payment> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ContractsTable _contractIdTable(_$AppDatabase db) =>
      db.contracts.createAlias(
        $_aliasNameGenerator(db.payments.contractId, db.contracts.id),
      );

  $$ContractsTableProcessedTableManager get contractId {
    final $_column = $_itemColumn<int>('contract_id')!;

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
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
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

  ColumnFilters<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get originalInstallment => $composableBuilder(
    column: $table.originalInstallment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fees => $composableBuilder(
    column: $table.fees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWhatsAppSent => $composableBuilder(
    column: $table.isWhatsAppSent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSyncedToCloud => $composableBuilder(
    column: $table.isSyncedToCloud,
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
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
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

  ColumnOrderings<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get originalInstallment => $composableBuilder(
    column: $table.originalInstallment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fees => $composableBuilder(
    column: $table.fees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWhatsAppSent => $composableBuilder(
    column: $table.isWhatsAppSent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSyncedToCloud => $composableBuilder(
    column: $table.isSyncedToCloud,
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

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => column,
  );

  GeneratedColumn<double> get originalInstallment => $composableBuilder(
    column: $table.originalInstallment,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fees =>
      $composableBuilder(column: $table.fees, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<bool> get isWhatsAppSent => $composableBuilder(
    column: $table.isWhatsAppSent,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSyncedToCloud => $composableBuilder(
    column: $table.isSyncedToCloud,
    builder: (column) => column,
  );

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
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          Payment,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (Payment, $$PaymentsTableReferences),
          Payment,
          PrefetchHooks Function({bool contractId})
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> contractId = const Value.absent(),
                Value<int> installmentNumber = const Value.absent(),
                Value<double> amountPaid = const Value.absent(),
                Value<double> originalInstallment = const Value.absent(),
                Value<double> fees = const Value.absent(),
                Value<DateTime> paymentDate = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<bool> isWhatsAppSent = const Value.absent(),
                Value<bool> isSyncedToCloud = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                contractId: contractId,
                installmentNumber: installmentNumber,
                amountPaid: amountPaid,
                originalInstallment: originalInstallment,
                fees: fees,
                paymentDate: paymentDate,
                dueDate: dueDate,
                isWhatsAppSent: isWhatsAppSent,
                isSyncedToCloud: isSyncedToCloud,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int contractId,
                required int installmentNumber,
                required double amountPaid,
                required double originalInstallment,
                Value<double> fees = const Value.absent(),
                required DateTime paymentDate,
                Value<DateTime?> dueDate = const Value.absent(),
                Value<bool> isWhatsAppSent = const Value.absent(),
                Value<bool> isSyncedToCloud = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                contractId: contractId,
                installmentNumber: installmentNumber,
                amountPaid: amountPaid,
                originalInstallment: originalInstallment,
                fees: fees,
                paymentDate: paymentDate,
                dueDate: dueDate,
                isWhatsAppSent: isWhatsAppSent,
                isSyncedToCloud: isSyncedToCloud,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contractId = false}) {
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
                                referencedTable: $$PaymentsTableReferences
                                    ._contractIdTable(db),
                                referencedColumn: $$PaymentsTableReferences
                                    ._contractIdTable(db)
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

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      Payment,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (Payment, $$PaymentsTableReferences),
      Payment,
      PrefetchHooks Function({bool contractId})
    >;
typedef $$MaterialPricesTableCreateCompanionBuilder =
    MaterialPricesCompanion Function({
      Value<int> id,
      required double ironPrice,
      required double cementPrice,
      required double block15Price,
      required double formworkAndPouringWages,
      required double reinforcedConcretePrice,
      required double aggregateMaterialsPrice,
      required double ordinaryWorkerWage,
      Value<DateTime> lastUpdated,
    });
typedef $$MaterialPricesTableUpdateCompanionBuilder =
    MaterialPricesCompanion Function({
      Value<int> id,
      Value<double> ironPrice,
      Value<double> cementPrice,
      Value<double> block15Price,
      Value<double> formworkAndPouringWages,
      Value<double> reinforcedConcretePrice,
      Value<double> aggregateMaterialsPrice,
      Value<double> ordinaryWorkerWage,
      Value<DateTime> lastUpdated,
    });

class $$MaterialPricesTableFilterComposer
    extends Composer<_$AppDatabase, $MaterialPricesTable> {
  $$MaterialPricesTableFilterComposer({
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

  ColumnFilters<double> get reinforcedConcretePrice => $composableBuilder(
    column: $table.reinforcedConcretePrice,
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

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MaterialPricesTableOrderingComposer
    extends Composer<_$AppDatabase, $MaterialPricesTable> {
  $$MaterialPricesTableOrderingComposer({
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

  ColumnOrderings<double> get reinforcedConcretePrice => $composableBuilder(
    column: $table.reinforcedConcretePrice,
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

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MaterialPricesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaterialPricesTable> {
  $$MaterialPricesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

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

  GeneratedColumn<double> get reinforcedConcretePrice => $composableBuilder(
    column: $table.reinforcedConcretePrice,
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

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );
}

class $$MaterialPricesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaterialPricesTable,
          MaterialPrice,
          $$MaterialPricesTableFilterComposer,
          $$MaterialPricesTableOrderingComposer,
          $$MaterialPricesTableAnnotationComposer,
          $$MaterialPricesTableCreateCompanionBuilder,
          $$MaterialPricesTableUpdateCompanionBuilder,
          (
            MaterialPrice,
            BaseReferences<_$AppDatabase, $MaterialPricesTable, MaterialPrice>,
          ),
          MaterialPrice,
          PrefetchHooks Function()
        > {
  $$MaterialPricesTableTableManager(
    _$AppDatabase db,
    $MaterialPricesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaterialPricesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaterialPricesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaterialPricesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> ironPrice = const Value.absent(),
                Value<double> cementPrice = const Value.absent(),
                Value<double> block15Price = const Value.absent(),
                Value<double> formworkAndPouringWages = const Value.absent(),
                Value<double> reinforcedConcretePrice = const Value.absent(),
                Value<double> aggregateMaterialsPrice = const Value.absent(),
                Value<double> ordinaryWorkerWage = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
              }) => MaterialPricesCompanion(
                id: id,
                ironPrice: ironPrice,
                cementPrice: cementPrice,
                block15Price: block15Price,
                formworkAndPouringWages: formworkAndPouringWages,
                reinforcedConcretePrice: reinforcedConcretePrice,
                aggregateMaterialsPrice: aggregateMaterialsPrice,
                ordinaryWorkerWage: ordinaryWorkerWage,
                lastUpdated: lastUpdated,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double ironPrice,
                required double cementPrice,
                required double block15Price,
                required double formworkAndPouringWages,
                required double reinforcedConcretePrice,
                required double aggregateMaterialsPrice,
                required double ordinaryWorkerWage,
                Value<DateTime> lastUpdated = const Value.absent(),
              }) => MaterialPricesCompanion.insert(
                id: id,
                ironPrice: ironPrice,
                cementPrice: cementPrice,
                block15Price: block15Price,
                formworkAndPouringWages: formworkAndPouringWages,
                reinforcedConcretePrice: reinforcedConcretePrice,
                aggregateMaterialsPrice: aggregateMaterialsPrice,
                ordinaryWorkerWage: ordinaryWorkerWage,
                lastUpdated: lastUpdated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MaterialPricesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaterialPricesTable,
      MaterialPrice,
      $$MaterialPricesTableFilterComposer,
      $$MaterialPricesTableOrderingComposer,
      $$MaterialPricesTableAnnotationComposer,
      $$MaterialPricesTableCreateCompanionBuilder,
      $$MaterialPricesTableUpdateCompanionBuilder,
      (
        MaterialPrice,
        BaseReferences<_$AppDatabase, $MaterialPricesTable, MaterialPrice>,
      ),
      MaterialPrice,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClientsTableTableManager get clients =>
      $$ClientsTableTableManager(_db, _db.clients);
  $$ContractsTableTableManager get contracts =>
      $$ContractsTableTableManager(_db, _db.contracts);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$MaterialPricesTableTableManager get materialPrices =>
      $$MaterialPricesTableTableManager(_db, _db.materialPrices);
}
