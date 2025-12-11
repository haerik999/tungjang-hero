// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isIncomeMeta =
      const VerificationMeta('isIncome');
  @override
  late final GeneratedColumn<bool> isIncome = GeneratedColumn<bool>(
      'is_income', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_income" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
      'server_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        amount,
        isIncome,
        category,
        note,
        createdAt,
        serverId,
        syncStatus,
        syncedAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(Insertable<Transaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('is_income')) {
      context.handle(_isIncomeMeta,
          isIncome.isAcceptableOrUnknown(data['is_income']!, _isIncomeMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      isIncome: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_income'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_id']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final String title;
  final int amount;
  final bool isIncome;
  final String category;
  final String? note;
  final DateTime createdAt;
  final int? serverId;
  final String syncStatus;
  final DateTime? syncedAt;
  final DateTime updatedAt;
  const Transaction(
      {required this.id,
      required this.title,
      required this.amount,
      required this.isIncome,
      required this.category,
      this.note,
      required this.createdAt,
      this.serverId,
      required this.syncStatus,
      this.syncedAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['amount'] = Variable<int>(amount);
    map['is_income'] = Variable<bool>(isIncome);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      title: Value(title),
      amount: Value(amount),
      isIncome: Value(isIncome),
      category: Value(category),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      syncStatus: Value(syncStatus),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      amount: serializer.fromJson<int>(json['amount']),
      isIncome: serializer.fromJson<bool>(json['isIncome']),
      category: serializer.fromJson<String>(json['category']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<int>(amount),
      'isIncome': serializer.toJson<bool>(isIncome),
      'category': serializer.toJson<String>(category),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'serverId': serializer.toJson<int?>(serverId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Transaction copyWith(
          {int? id,
          String? title,
          int? amount,
          bool? isIncome,
          String? category,
          Value<String?> note = const Value.absent(),
          DateTime? createdAt,
          Value<int?> serverId = const Value.absent(),
          String? syncStatus,
          Value<DateTime?> syncedAt = const Value.absent(),
          DateTime? updatedAt}) =>
      Transaction(
        id: id ?? this.id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        isIncome: isIncome ?? this.isIncome,
        category: category ?? this.category,
        note: note.present ? note.value : this.note,
        createdAt: createdAt ?? this.createdAt,
        serverId: serverId.present ? serverId.value : this.serverId,
        syncStatus: syncStatus ?? this.syncStatus,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      amount: data.amount.present ? data.amount.value : this.amount,
      isIncome: data.isIncome.present ? data.isIncome.value : this.isIncome,
      category: data.category.present ? data.category.value : this.category,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('isIncome: $isIncome, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, amount, isIncome, category, note,
      createdAt, serverId, syncStatus, syncedAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.isIncome == this.isIncome &&
          other.category == this.category &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.serverId == this.serverId &&
          other.syncStatus == this.syncStatus &&
          other.syncedAt == this.syncedAt &&
          other.updatedAt == this.updatedAt);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<String> title;
  final Value<int> amount;
  final Value<bool> isIncome;
  final Value<String> category;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<int?> serverId;
  final Value<String> syncStatus;
  final Value<DateTime?> syncedAt;
  final Value<DateTime> updatedAt;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.isIncome = const Value.absent(),
    this.category = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required int amount,
    this.isIncome = const Value.absent(),
    required String category,
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.serverId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : title = Value(title),
        amount = Value(amount),
        category = Value(category);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? amount,
    Expression<bool>? isIncome,
    Expression<String>? category,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<int>? serverId,
    Expression<String>? syncStatus,
    Expression<DateTime>? syncedAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (isIncome != null) 'is_income': isIncome,
      if (category != null) 'category': category,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (serverId != null) 'server_id': serverId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TransactionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<int>? amount,
      Value<bool>? isIncome,
      Value<String>? category,
      Value<String?>? note,
      Value<DateTime>? createdAt,
      Value<int?>? serverId,
      Value<String>? syncStatus,
      Value<DateTime?>? syncedAt,
      Value<DateTime>? updatedAt}) {
    return TransactionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      isIncome: isIncome ?? this.isIncome,
      category: category ?? this.category,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      serverId: serverId ?? this.serverId,
      syncStatus: syncStatus ?? this.syncStatus,
      syncedAt: syncedAt ?? this.syncedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (isIncome.present) {
      map['is_income'] = Variable<bool>(isIncome.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('isIncome: $isIncome, ')
          ..write('category: $category, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('serverId: $serverId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $HeroStatsTableTable extends HeroStatsTable
    with TableInfo<$HeroStatsTableTable, HeroStatsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HeroStatsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
      'level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _currentXpMeta =
      const VerificationMeta('currentXp');
  @override
  late final GeneratedColumn<int> currentXp = GeneratedColumn<int>(
      'current_xp', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _requiredXpMeta =
      const VerificationMeta('requiredXp');
  @override
  late final GeneratedColumn<int> requiredXp = GeneratedColumn<int>(
      'required_xp', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(100));
  static const VerificationMeta _currentHpMeta =
      const VerificationMeta('currentHp');
  @override
  late final GeneratedColumn<int> currentHp = GeneratedColumn<int>(
      'current_hp', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(100));
  static const VerificationMeta _maxHpMeta = const VerificationMeta('maxHp');
  @override
  late final GeneratedColumn<int> maxHp = GeneratedColumn<int>(
      'max_hp', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(100));
  static const VerificationMeta _totalSavedMeta =
      const VerificationMeta('totalSaved');
  @override
  late final GeneratedColumn<int> totalSaved = GeneratedColumn<int>(
      'total_saved', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalSpentMeta =
      const VerificationMeta('totalSpent');
  @override
  late final GeneratedColumn<int> totalSpent = GeneratedColumn<int>(
      'total_spent', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _streakMeta = const VerificationMeta('streak');
  @override
  late final GeneratedColumn<int> streak = GeneratedColumn<int>(
      'streak', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastRecordDateMeta =
      const VerificationMeta('lastRecordDate');
  @override
  late final GeneratedColumn<DateTime> lastRecordDate =
      GeneratedColumn<DateTime>('last_record_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        level,
        currentXp,
        requiredXp,
        currentHp,
        maxHp,
        totalSaved,
        totalSpent,
        streak,
        lastRecordDate,
        lastUpdated
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hero_stats';
  @override
  VerificationContext validateIntegrity(Insertable<HeroStatsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
          _levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    }
    if (data.containsKey('current_xp')) {
      context.handle(_currentXpMeta,
          currentXp.isAcceptableOrUnknown(data['current_xp']!, _currentXpMeta));
    }
    if (data.containsKey('required_xp')) {
      context.handle(
          _requiredXpMeta,
          requiredXp.isAcceptableOrUnknown(
              data['required_xp']!, _requiredXpMeta));
    }
    if (data.containsKey('current_hp')) {
      context.handle(_currentHpMeta,
          currentHp.isAcceptableOrUnknown(data['current_hp']!, _currentHpMeta));
    }
    if (data.containsKey('max_hp')) {
      context.handle(
          _maxHpMeta, maxHp.isAcceptableOrUnknown(data['max_hp']!, _maxHpMeta));
    }
    if (data.containsKey('total_saved')) {
      context.handle(
          _totalSavedMeta,
          totalSaved.isAcceptableOrUnknown(
              data['total_saved']!, _totalSavedMeta));
    }
    if (data.containsKey('total_spent')) {
      context.handle(
          _totalSpentMeta,
          totalSpent.isAcceptableOrUnknown(
              data['total_spent']!, _totalSpentMeta));
    }
    if (data.containsKey('streak')) {
      context.handle(_streakMeta,
          streak.isAcceptableOrUnknown(data['streak']!, _streakMeta));
    }
    if (data.containsKey('last_record_date')) {
      context.handle(
          _lastRecordDateMeta,
          lastRecordDate.isAcceptableOrUnknown(
              data['last_record_date']!, _lastRecordDateMeta));
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HeroStatsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HeroStatsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}level'])!,
      currentXp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_xp'])!,
      requiredXp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}required_xp'])!,
      currentHp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_hp'])!,
      maxHp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_hp'])!,
      totalSaved: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_saved'])!,
      totalSpent: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_spent'])!,
      streak: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}streak'])!,
      lastRecordDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_record_date']),
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
    );
  }

  @override
  $HeroStatsTableTable createAlias(String alias) {
    return $HeroStatsTableTable(attachedDatabase, alias);
  }
}

class HeroStatsTableData extends DataClass
    implements Insertable<HeroStatsTableData> {
  final int id;
  final int level;
  final int currentXp;
  final int requiredXp;
  final int currentHp;
  final int maxHp;
  final int totalSaved;
  final int totalSpent;
  final int streak;
  final DateTime? lastRecordDate;
  final DateTime lastUpdated;
  const HeroStatsTableData(
      {required this.id,
      required this.level,
      required this.currentXp,
      required this.requiredXp,
      required this.currentHp,
      required this.maxHp,
      required this.totalSaved,
      required this.totalSpent,
      required this.streak,
      this.lastRecordDate,
      required this.lastUpdated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['level'] = Variable<int>(level);
    map['current_xp'] = Variable<int>(currentXp);
    map['required_xp'] = Variable<int>(requiredXp);
    map['current_hp'] = Variable<int>(currentHp);
    map['max_hp'] = Variable<int>(maxHp);
    map['total_saved'] = Variable<int>(totalSaved);
    map['total_spent'] = Variable<int>(totalSpent);
    map['streak'] = Variable<int>(streak);
    if (!nullToAbsent || lastRecordDate != null) {
      map['last_record_date'] = Variable<DateTime>(lastRecordDate);
    }
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  HeroStatsTableCompanion toCompanion(bool nullToAbsent) {
    return HeroStatsTableCompanion(
      id: Value(id),
      level: Value(level),
      currentXp: Value(currentXp),
      requiredXp: Value(requiredXp),
      currentHp: Value(currentHp),
      maxHp: Value(maxHp),
      totalSaved: Value(totalSaved),
      totalSpent: Value(totalSpent),
      streak: Value(streak),
      lastRecordDate: lastRecordDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRecordDate),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory HeroStatsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HeroStatsTableData(
      id: serializer.fromJson<int>(json['id']),
      level: serializer.fromJson<int>(json['level']),
      currentXp: serializer.fromJson<int>(json['currentXp']),
      requiredXp: serializer.fromJson<int>(json['requiredXp']),
      currentHp: serializer.fromJson<int>(json['currentHp']),
      maxHp: serializer.fromJson<int>(json['maxHp']),
      totalSaved: serializer.fromJson<int>(json['totalSaved']),
      totalSpent: serializer.fromJson<int>(json['totalSpent']),
      streak: serializer.fromJson<int>(json['streak']),
      lastRecordDate: serializer.fromJson<DateTime?>(json['lastRecordDate']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'level': serializer.toJson<int>(level),
      'currentXp': serializer.toJson<int>(currentXp),
      'requiredXp': serializer.toJson<int>(requiredXp),
      'currentHp': serializer.toJson<int>(currentHp),
      'maxHp': serializer.toJson<int>(maxHp),
      'totalSaved': serializer.toJson<int>(totalSaved),
      'totalSpent': serializer.toJson<int>(totalSpent),
      'streak': serializer.toJson<int>(streak),
      'lastRecordDate': serializer.toJson<DateTime?>(lastRecordDate),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  HeroStatsTableData copyWith(
          {int? id,
          int? level,
          int? currentXp,
          int? requiredXp,
          int? currentHp,
          int? maxHp,
          int? totalSaved,
          int? totalSpent,
          int? streak,
          Value<DateTime?> lastRecordDate = const Value.absent(),
          DateTime? lastUpdated}) =>
      HeroStatsTableData(
        id: id ?? this.id,
        level: level ?? this.level,
        currentXp: currentXp ?? this.currentXp,
        requiredXp: requiredXp ?? this.requiredXp,
        currentHp: currentHp ?? this.currentHp,
        maxHp: maxHp ?? this.maxHp,
        totalSaved: totalSaved ?? this.totalSaved,
        totalSpent: totalSpent ?? this.totalSpent,
        streak: streak ?? this.streak,
        lastRecordDate:
            lastRecordDate.present ? lastRecordDate.value : this.lastRecordDate,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
  HeroStatsTableData copyWithCompanion(HeroStatsTableCompanion data) {
    return HeroStatsTableData(
      id: data.id.present ? data.id.value : this.id,
      level: data.level.present ? data.level.value : this.level,
      currentXp: data.currentXp.present ? data.currentXp.value : this.currentXp,
      requiredXp:
          data.requiredXp.present ? data.requiredXp.value : this.requiredXp,
      currentHp: data.currentHp.present ? data.currentHp.value : this.currentHp,
      maxHp: data.maxHp.present ? data.maxHp.value : this.maxHp,
      totalSaved:
          data.totalSaved.present ? data.totalSaved.value : this.totalSaved,
      totalSpent:
          data.totalSpent.present ? data.totalSpent.value : this.totalSpent,
      streak: data.streak.present ? data.streak.value : this.streak,
      lastRecordDate: data.lastRecordDate.present
          ? data.lastRecordDate.value
          : this.lastRecordDate,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HeroStatsTableData(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('currentXp: $currentXp, ')
          ..write('requiredXp: $requiredXp, ')
          ..write('currentHp: $currentHp, ')
          ..write('maxHp: $maxHp, ')
          ..write('totalSaved: $totalSaved, ')
          ..write('totalSpent: $totalSpent, ')
          ..write('streak: $streak, ')
          ..write('lastRecordDate: $lastRecordDate, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, level, currentXp, requiredXp, currentHp,
      maxHp, totalSaved, totalSpent, streak, lastRecordDate, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HeroStatsTableData &&
          other.id == this.id &&
          other.level == this.level &&
          other.currentXp == this.currentXp &&
          other.requiredXp == this.requiredXp &&
          other.currentHp == this.currentHp &&
          other.maxHp == this.maxHp &&
          other.totalSaved == this.totalSaved &&
          other.totalSpent == this.totalSpent &&
          other.streak == this.streak &&
          other.lastRecordDate == this.lastRecordDate &&
          other.lastUpdated == this.lastUpdated);
}

class HeroStatsTableCompanion extends UpdateCompanion<HeroStatsTableData> {
  final Value<int> id;
  final Value<int> level;
  final Value<int> currentXp;
  final Value<int> requiredXp;
  final Value<int> currentHp;
  final Value<int> maxHp;
  final Value<int> totalSaved;
  final Value<int> totalSpent;
  final Value<int> streak;
  final Value<DateTime?> lastRecordDate;
  final Value<DateTime> lastUpdated;
  const HeroStatsTableCompanion({
    this.id = const Value.absent(),
    this.level = const Value.absent(),
    this.currentXp = const Value.absent(),
    this.requiredXp = const Value.absent(),
    this.currentHp = const Value.absent(),
    this.maxHp = const Value.absent(),
    this.totalSaved = const Value.absent(),
    this.totalSpent = const Value.absent(),
    this.streak = const Value.absent(),
    this.lastRecordDate = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  });
  HeroStatsTableCompanion.insert({
    this.id = const Value.absent(),
    this.level = const Value.absent(),
    this.currentXp = const Value.absent(),
    this.requiredXp = const Value.absent(),
    this.currentHp = const Value.absent(),
    this.maxHp = const Value.absent(),
    this.totalSaved = const Value.absent(),
    this.totalSpent = const Value.absent(),
    this.streak = const Value.absent(),
    this.lastRecordDate = const Value.absent(),
    this.lastUpdated = const Value.absent(),
  });
  static Insertable<HeroStatsTableData> custom({
    Expression<int>? id,
    Expression<int>? level,
    Expression<int>? currentXp,
    Expression<int>? requiredXp,
    Expression<int>? currentHp,
    Expression<int>? maxHp,
    Expression<int>? totalSaved,
    Expression<int>? totalSpent,
    Expression<int>? streak,
    Expression<DateTime>? lastRecordDate,
    Expression<DateTime>? lastUpdated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (level != null) 'level': level,
      if (currentXp != null) 'current_xp': currentXp,
      if (requiredXp != null) 'required_xp': requiredXp,
      if (currentHp != null) 'current_hp': currentHp,
      if (maxHp != null) 'max_hp': maxHp,
      if (totalSaved != null) 'total_saved': totalSaved,
      if (totalSpent != null) 'total_spent': totalSpent,
      if (streak != null) 'streak': streak,
      if (lastRecordDate != null) 'last_record_date': lastRecordDate,
      if (lastUpdated != null) 'last_updated': lastUpdated,
    });
  }

  HeroStatsTableCompanion copyWith(
      {Value<int>? id,
      Value<int>? level,
      Value<int>? currentXp,
      Value<int>? requiredXp,
      Value<int>? currentHp,
      Value<int>? maxHp,
      Value<int>? totalSaved,
      Value<int>? totalSpent,
      Value<int>? streak,
      Value<DateTime?>? lastRecordDate,
      Value<DateTime>? lastUpdated}) {
    return HeroStatsTableCompanion(
      id: id ?? this.id,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      requiredXp: requiredXp ?? this.requiredXp,
      currentHp: currentHp ?? this.currentHp,
      maxHp: maxHp ?? this.maxHp,
      totalSaved: totalSaved ?? this.totalSaved,
      totalSpent: totalSpent ?? this.totalSpent,
      streak: streak ?? this.streak,
      lastRecordDate: lastRecordDate ?? this.lastRecordDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (currentXp.present) {
      map['current_xp'] = Variable<int>(currentXp.value);
    }
    if (requiredXp.present) {
      map['required_xp'] = Variable<int>(requiredXp.value);
    }
    if (currentHp.present) {
      map['current_hp'] = Variable<int>(currentHp.value);
    }
    if (maxHp.present) {
      map['max_hp'] = Variable<int>(maxHp.value);
    }
    if (totalSaved.present) {
      map['total_saved'] = Variable<int>(totalSaved.value);
    }
    if (totalSpent.present) {
      map['total_spent'] = Variable<int>(totalSpent.value);
    }
    if (streak.present) {
      map['streak'] = Variable<int>(streak.value);
    }
    if (lastRecordDate.present) {
      map['last_record_date'] = Variable<DateTime>(lastRecordDate.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HeroStatsTableCompanion(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('currentXp: $currentXp, ')
          ..write('requiredXp: $requiredXp, ')
          ..write('currentHp: $currentHp, ')
          ..write('maxHp: $maxHp, ')
          ..write('totalSaved: $totalSaved, ')
          ..write('totalSpent: $totalSpent, ')
          ..write('streak: $streak, ')
          ..write('lastRecordDate: $lastRecordDate, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }
}

class $QuestsTable extends Quests with TableInfo<$QuestsTable, Quest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _questTypeMeta =
      const VerificationMeta('questType');
  @override
  late final GeneratedColumn<String> questType = GeneratedColumn<String>(
      'quest_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('daily'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetAmountMeta =
      const VerificationMeta('targetAmount');
  @override
  late final GeneratedColumn<int> targetAmount = GeneratedColumn<int>(
      'target_amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currentAmountMeta =
      const VerificationMeta('currentAmount');
  @override
  late final GeneratedColumn<int> currentAmount = GeneratedColumn<int>(
      'current_amount', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _rewardXpMeta =
      const VerificationMeta('rewardXp');
  @override
  late final GeneratedColumn<int> rewardXp = GeneratedColumn<int>(
      'reward_xp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isRewardClaimedMeta =
      const VerificationMeta('isRewardClaimed');
  @override
  late final GeneratedColumn<bool> isRewardClaimed = GeneratedColumn<bool>(
      'is_reward_claimed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_reward_claimed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        questType,
        title,
        description,
        targetAmount,
        currentAmount,
        rewardXp,
        isCompleted,
        isRewardClaimed,
        startDate,
        endDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quests';
  @override
  VerificationContext validateIntegrity(Insertable<Quest> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('quest_type')) {
      context.handle(_questTypeMeta,
          questType.isAcceptableOrUnknown(data['quest_type']!, _questTypeMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
          _targetAmountMeta,
          targetAmount.isAcceptableOrUnknown(
              data['target_amount']!, _targetAmountMeta));
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('current_amount')) {
      context.handle(
          _currentAmountMeta,
          currentAmount.isAcceptableOrUnknown(
              data['current_amount']!, _currentAmountMeta));
    }
    if (data.containsKey('reward_xp')) {
      context.handle(_rewardXpMeta,
          rewardXp.isAcceptableOrUnknown(data['reward_xp']!, _rewardXpMeta));
    } else if (isInserting) {
      context.missing(_rewardXpMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('is_reward_claimed')) {
      context.handle(
          _isRewardClaimedMeta,
          isRewardClaimed.isAcceptableOrUnknown(
              data['is_reward_claimed']!, _isRewardClaimedMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Quest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Quest(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      questType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quest_type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      targetAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_amount'])!,
      currentAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_amount'])!,
      rewardXp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reward_xp'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      isRewardClaimed: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_reward_claimed'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date'])!,
    );
  }

  @override
  $QuestsTable createAlias(String alias) {
    return $QuestsTable(attachedDatabase, alias);
  }
}

class Quest extends DataClass implements Insertable<Quest> {
  final int id;
  final String questType;
  final String title;
  final String description;
  final int targetAmount;
  final int currentAmount;
  final int rewardXp;
  final bool isCompleted;
  final bool isRewardClaimed;
  final DateTime startDate;
  final DateTime endDate;
  const Quest(
      {required this.id,
      required this.questType,
      required this.title,
      required this.description,
      required this.targetAmount,
      required this.currentAmount,
      required this.rewardXp,
      required this.isCompleted,
      required this.isRewardClaimed,
      required this.startDate,
      required this.endDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['quest_type'] = Variable<String>(questType);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['target_amount'] = Variable<int>(targetAmount);
    map['current_amount'] = Variable<int>(currentAmount);
    map['reward_xp'] = Variable<int>(rewardXp);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['is_reward_claimed'] = Variable<bool>(isRewardClaimed);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    return map;
  }

  QuestsCompanion toCompanion(bool nullToAbsent) {
    return QuestsCompanion(
      id: Value(id),
      questType: Value(questType),
      title: Value(title),
      description: Value(description),
      targetAmount: Value(targetAmount),
      currentAmount: Value(currentAmount),
      rewardXp: Value(rewardXp),
      isCompleted: Value(isCompleted),
      isRewardClaimed: Value(isRewardClaimed),
      startDate: Value(startDate),
      endDate: Value(endDate),
    );
  }

  factory Quest.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Quest(
      id: serializer.fromJson<int>(json['id']),
      questType: serializer.fromJson<String>(json['questType']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      targetAmount: serializer.fromJson<int>(json['targetAmount']),
      currentAmount: serializer.fromJson<int>(json['currentAmount']),
      rewardXp: serializer.fromJson<int>(json['rewardXp']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      isRewardClaimed: serializer.fromJson<bool>(json['isRewardClaimed']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'questType': serializer.toJson<String>(questType),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'targetAmount': serializer.toJson<int>(targetAmount),
      'currentAmount': serializer.toJson<int>(currentAmount),
      'rewardXp': serializer.toJson<int>(rewardXp),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'isRewardClaimed': serializer.toJson<bool>(isRewardClaimed),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
    };
  }

  Quest copyWith(
          {int? id,
          String? questType,
          String? title,
          String? description,
          int? targetAmount,
          int? currentAmount,
          int? rewardXp,
          bool? isCompleted,
          bool? isRewardClaimed,
          DateTime? startDate,
          DateTime? endDate}) =>
      Quest(
        id: id ?? this.id,
        questType: questType ?? this.questType,
        title: title ?? this.title,
        description: description ?? this.description,
        targetAmount: targetAmount ?? this.targetAmount,
        currentAmount: currentAmount ?? this.currentAmount,
        rewardXp: rewardXp ?? this.rewardXp,
        isCompleted: isCompleted ?? this.isCompleted,
        isRewardClaimed: isRewardClaimed ?? this.isRewardClaimed,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
      );
  Quest copyWithCompanion(QuestsCompanion data) {
    return Quest(
      id: data.id.present ? data.id.value : this.id,
      questType: data.questType.present ? data.questType.value : this.questType,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      currentAmount: data.currentAmount.present
          ? data.currentAmount.value
          : this.currentAmount,
      rewardXp: data.rewardXp.present ? data.rewardXp.value : this.rewardXp,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      isRewardClaimed: data.isRewardClaimed.present
          ? data.isRewardClaimed.value
          : this.isRewardClaimed,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Quest(')
          ..write('id: $id, ')
          ..write('questType: $questType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('rewardXp: $rewardXp, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isRewardClaimed: $isRewardClaimed, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      questType,
      title,
      description,
      targetAmount,
      currentAmount,
      rewardXp,
      isCompleted,
      isRewardClaimed,
      startDate,
      endDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Quest &&
          other.id == this.id &&
          other.questType == this.questType &&
          other.title == this.title &&
          other.description == this.description &&
          other.targetAmount == this.targetAmount &&
          other.currentAmount == this.currentAmount &&
          other.rewardXp == this.rewardXp &&
          other.isCompleted == this.isCompleted &&
          other.isRewardClaimed == this.isRewardClaimed &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate);
}

class QuestsCompanion extends UpdateCompanion<Quest> {
  final Value<int> id;
  final Value<String> questType;
  final Value<String> title;
  final Value<String> description;
  final Value<int> targetAmount;
  final Value<int> currentAmount;
  final Value<int> rewardXp;
  final Value<bool> isCompleted;
  final Value<bool> isRewardClaimed;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  const QuestsCompanion({
    this.id = const Value.absent(),
    this.questType = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.currentAmount = const Value.absent(),
    this.rewardXp = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isRewardClaimed = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
  });
  QuestsCompanion.insert({
    this.id = const Value.absent(),
    this.questType = const Value.absent(),
    required String title,
    required String description,
    required int targetAmount,
    this.currentAmount = const Value.absent(),
    required int rewardXp,
    this.isCompleted = const Value.absent(),
    this.isRewardClaimed = const Value.absent(),
    required DateTime startDate,
    required DateTime endDate,
  })  : title = Value(title),
        description = Value(description),
        targetAmount = Value(targetAmount),
        rewardXp = Value(rewardXp),
        startDate = Value(startDate),
        endDate = Value(endDate);
  static Insertable<Quest> custom({
    Expression<int>? id,
    Expression<String>? questType,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? targetAmount,
    Expression<int>? currentAmount,
    Expression<int>? rewardXp,
    Expression<bool>? isCompleted,
    Expression<bool>? isRewardClaimed,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questType != null) 'quest_type': questType,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (currentAmount != null) 'current_amount': currentAmount,
      if (rewardXp != null) 'reward_xp': rewardXp,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (isRewardClaimed != null) 'is_reward_claimed': isRewardClaimed,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    });
  }

  QuestsCompanion copyWith(
      {Value<int>? id,
      Value<String>? questType,
      Value<String>? title,
      Value<String>? description,
      Value<int>? targetAmount,
      Value<int>? currentAmount,
      Value<int>? rewardXp,
      Value<bool>? isCompleted,
      Value<bool>? isRewardClaimed,
      Value<DateTime>? startDate,
      Value<DateTime>? endDate}) {
    return QuestsCompanion(
      id: id ?? this.id,
      questType: questType ?? this.questType,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      rewardXp: rewardXp ?? this.rewardXp,
      isCompleted: isCompleted ?? this.isCompleted,
      isRewardClaimed: isRewardClaimed ?? this.isRewardClaimed,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (questType.present) {
      map['quest_type'] = Variable<String>(questType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<int>(targetAmount.value);
    }
    if (currentAmount.present) {
      map['current_amount'] = Variable<int>(currentAmount.value);
    }
    if (rewardXp.present) {
      map['reward_xp'] = Variable<int>(rewardXp.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (isRewardClaimed.present) {
      map['is_reward_claimed'] = Variable<bool>(isRewardClaimed.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestsCompanion(')
          ..write('id: $id, ')
          ..write('questType: $questType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('rewardXp: $rewardXp, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isRewardClaimed: $isRewardClaimed, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, Achievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _achievementIdMeta =
      const VerificationMeta('achievementId');
  @override
  late final GeneratedColumn<String> achievementId = GeneratedColumn<String>(
      'achievement_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<String> emoji = GeneratedColumn<String>(
      'emoji', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isUnlockedMeta =
      const VerificationMeta('isUnlocked');
  @override
  late final GeneratedColumn<bool> isUnlocked = GeneratedColumn<bool>(
      'is_unlocked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_unlocked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _unlockedAtMeta =
      const VerificationMeta('unlockedAt');
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
      'unlocked_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        achievementId,
        category,
        title,
        description,
        emoji,
        isUnlocked,
        unlockedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(Insertable<Achievement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('achievement_id')) {
      context.handle(
          _achievementIdMeta,
          achievementId.isAcceptableOrUnknown(
              data['achievement_id']!, _achievementIdMeta));
    } else if (isInserting) {
      context.missing(_achievementIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('emoji')) {
      context.handle(
          _emojiMeta, emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta));
    } else if (isInserting) {
      context.missing(_emojiMeta);
    }
    if (data.containsKey('is_unlocked')) {
      context.handle(
          _isUnlockedMeta,
          isUnlocked.isAcceptableOrUnknown(
              data['is_unlocked']!, _isUnlockedMeta));
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
          _unlockedAtMeta,
          unlockedAt.isAcceptableOrUnknown(
              data['unlocked_at']!, _unlockedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Achievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Achievement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      achievementId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}achievement_id'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      emoji: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}emoji'])!,
      isUnlocked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_unlocked'])!,
      unlockedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}unlocked_at']),
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class Achievement extends DataClass implements Insertable<Achievement> {
  final int id;
  final String achievementId;
  final String category;
  final String title;
  final String description;
  final String emoji;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  const Achievement(
      {required this.id,
      required this.achievementId,
      required this.category,
      required this.title,
      required this.description,
      required this.emoji,
      required this.isUnlocked,
      this.unlockedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['achievement_id'] = Variable<String>(achievementId);
    map['category'] = Variable<String>(category);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['emoji'] = Variable<String>(emoji);
    map['is_unlocked'] = Variable<bool>(isUnlocked);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    }
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      id: Value(id),
      achievementId: Value(achievementId),
      category: Value(category),
      title: Value(title),
      description: Value(description),
      emoji: Value(emoji),
      isUnlocked: Value(isUnlocked),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
    );
  }

  factory Achievement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Achievement(
      id: serializer.fromJson<int>(json['id']),
      achievementId: serializer.fromJson<String>(json['achievementId']),
      category: serializer.fromJson<String>(json['category']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      emoji: serializer.fromJson<String>(json['emoji']),
      isUnlocked: serializer.fromJson<bool>(json['isUnlocked']),
      unlockedAt: serializer.fromJson<DateTime?>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'achievementId': serializer.toJson<String>(achievementId),
      'category': serializer.toJson<String>(category),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'emoji': serializer.toJson<String>(emoji),
      'isUnlocked': serializer.toJson<bool>(isUnlocked),
      'unlockedAt': serializer.toJson<DateTime?>(unlockedAt),
    };
  }

  Achievement copyWith(
          {int? id,
          String? achievementId,
          String? category,
          String? title,
          String? description,
          String? emoji,
          bool? isUnlocked,
          Value<DateTime?> unlockedAt = const Value.absent()}) =>
      Achievement(
        id: id ?? this.id,
        achievementId: achievementId ?? this.achievementId,
        category: category ?? this.category,
        title: title ?? this.title,
        description: description ?? this.description,
        emoji: emoji ?? this.emoji,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
      );
  Achievement copyWithCompanion(AchievementsCompanion data) {
    return Achievement(
      id: data.id.present ? data.id.value : this.id,
      achievementId: data.achievementId.present
          ? data.achievementId.value
          : this.achievementId,
      category: data.category.present ? data.category.value : this.category,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      isUnlocked:
          data.isUnlocked.present ? data.isUnlocked.value : this.isUnlocked,
      unlockedAt:
          data.unlockedAt.present ? data.unlockedAt.value : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Achievement(')
          ..write('id: $id, ')
          ..write('achievementId: $achievementId, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('emoji: $emoji, ')
          ..write('isUnlocked: $isUnlocked, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, achievementId, category, title,
      description, emoji, isUnlocked, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Achievement &&
          other.id == this.id &&
          other.achievementId == this.achievementId &&
          other.category == this.category &&
          other.title == this.title &&
          other.description == this.description &&
          other.emoji == this.emoji &&
          other.isUnlocked == this.isUnlocked &&
          other.unlockedAt == this.unlockedAt);
}

class AchievementsCompanion extends UpdateCompanion<Achievement> {
  final Value<int> id;
  final Value<String> achievementId;
  final Value<String> category;
  final Value<String> title;
  final Value<String> description;
  final Value<String> emoji;
  final Value<bool> isUnlocked;
  final Value<DateTime?> unlockedAt;
  const AchievementsCompanion({
    this.id = const Value.absent(),
    this.achievementId = const Value.absent(),
    this.category = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.emoji = const Value.absent(),
    this.isUnlocked = const Value.absent(),
    this.unlockedAt = const Value.absent(),
  });
  AchievementsCompanion.insert({
    this.id = const Value.absent(),
    required String achievementId,
    required String category,
    required String title,
    required String description,
    required String emoji,
    this.isUnlocked = const Value.absent(),
    this.unlockedAt = const Value.absent(),
  })  : achievementId = Value(achievementId),
        category = Value(category),
        title = Value(title),
        description = Value(description),
        emoji = Value(emoji);
  static Insertable<Achievement> custom({
    Expression<int>? id,
    Expression<String>? achievementId,
    Expression<String>? category,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? emoji,
    Expression<bool>? isUnlocked,
    Expression<DateTime>? unlockedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (achievementId != null) 'achievement_id': achievementId,
      if (category != null) 'category': category,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (emoji != null) 'emoji': emoji,
      if (isUnlocked != null) 'is_unlocked': isUnlocked,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
    });
  }

  AchievementsCompanion copyWith(
      {Value<int>? id,
      Value<String>? achievementId,
      Value<String>? category,
      Value<String>? title,
      Value<String>? description,
      Value<String>? emoji,
      Value<bool>? isUnlocked,
      Value<DateTime?>? unlockedAt}) {
    return AchievementsCompanion(
      id: id ?? this.id,
      achievementId: achievementId ?? this.achievementId,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (achievementId.present) {
      map['achievement_id'] = Variable<String>(achievementId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<String>(emoji.value);
    }
    if (isUnlocked.present) {
      map['is_unlocked'] = Variable<bool>(isUnlocked.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('id: $id, ')
          ..write('achievementId: $achievementId, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('emoji: $emoji, ')
          ..write('isUnlocked: $isUnlocked, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }
}

class $CategoryBudgetsTable extends CategoryBudgets
    with TableInfo<$CategoryBudgetsTable, CategoryBudget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryBudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
      'year', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
      'month', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, category, amount, year, month, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_budgets';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryBudget> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
          _monthMeta, month.isAcceptableOrUnknown(data['month']!, _monthMeta));
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryBudget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryBudget(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year'])!,
      month: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}month'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CategoryBudgetsTable createAlias(String alias) {
    return $CategoryBudgetsTable(attachedDatabase, alias);
  }
}

class CategoryBudget extends DataClass implements Insertable<CategoryBudget> {
  final int id;
  final String category;
  final int amount;
  final int year;
  final int month;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CategoryBudget(
      {required this.id,
      required this.category,
      required this.amount,
      required this.year,
      required this.month,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<int>(amount);
    map['year'] = Variable<int>(year);
    map['month'] = Variable<int>(month);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CategoryBudgetsCompanion toCompanion(bool nullToAbsent) {
    return CategoryBudgetsCompanion(
      id: Value(id),
      category: Value(category),
      amount: Value(amount),
      year: Value(year),
      month: Value(month),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CategoryBudget.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryBudget(
      id: serializer.fromJson<int>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<int>(json['amount']),
      year: serializer.fromJson<int>(json['year']),
      month: serializer.fromJson<int>(json['month']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<int>(amount),
      'year': serializer.toJson<int>(year),
      'month': serializer.toJson<int>(month),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CategoryBudget copyWith(
          {int? id,
          String? category,
          int? amount,
          int? year,
          int? month,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CategoryBudget(
        id: id ?? this.id,
        category: category ?? this.category,
        amount: amount ?? this.amount,
        year: year ?? this.year,
        month: month ?? this.month,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CategoryBudget copyWithCompanion(CategoryBudgetsCompanion data) {
    return CategoryBudget(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      year: data.year.present ? data.year.value : this.year,
      month: data.month.present ? data.month.value : this.month,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryBudget(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, category, amount, year, month, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryBudget &&
          other.id == this.id &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.year == this.year &&
          other.month == this.month &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CategoryBudgetsCompanion extends UpdateCompanion<CategoryBudget> {
  final Value<int> id;
  final Value<String> category;
  final Value<int> amount;
  final Value<int> year;
  final Value<int> month;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CategoryBudgetsCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.year = const Value.absent(),
    this.month = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CategoryBudgetsCompanion.insert({
    this.id = const Value.absent(),
    required String category,
    required int amount,
    required int year,
    required int month,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : category = Value(category),
        amount = Value(amount),
        year = Value(year),
        month = Value(month);
  static Insertable<CategoryBudget> custom({
    Expression<int>? id,
    Expression<String>? category,
    Expression<int>? amount,
    Expression<int>? year,
    Expression<int>? month,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CategoryBudgetsCompanion copyWith(
      {Value<int>? id,
      Value<String>? category,
      Value<int>? amount,
      Value<int>? year,
      Value<int>? month,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return CategoryBudgetsCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      year: year ?? this.year,
      month: month ?? this.month,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryBudgetsCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SkillsTable extends Skills with TableInfo<$SkillsTable, Skill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SkillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _skillIdMeta =
      const VerificationMeta('skillId');
  @override
  late final GeneratedColumn<String> skillId = GeneratedColumn<String>(
      'skill_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
      'level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _maxLevelMeta =
      const VerificationMeta('maxLevel');
  @override
  late final GeneratedColumn<int> maxLevel = GeneratedColumn<int>(
      'max_level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
  static const VerificationMeta _currentXpMeta =
      const VerificationMeta('currentXp');
  @override
  late final GeneratedColumn<int> currentXp = GeneratedColumn<int>(
      'current_xp', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _requiredXpMeta =
      const VerificationMeta('requiredXp');
  @override
  late final GeneratedColumn<int> requiredXp = GeneratedColumn<int>(
      'required_xp', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(100));
  static const VerificationMeta _isUnlockedMeta =
      const VerificationMeta('isUnlocked');
  @override
  late final GeneratedColumn<bool> isUnlocked = GeneratedColumn<bool>(
      'is_unlocked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_unlocked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _unlockedAtMeta =
      const VerificationMeta('unlockedAt');
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
      'unlocked_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        skillId,
        name,
        description,
        level,
        maxLevel,
        currentXp,
        requiredXp,
        isUnlocked,
        unlockedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'skills';
  @override
  VerificationContext validateIntegrity(Insertable<Skill> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('skill_id')) {
      context.handle(_skillIdMeta,
          skillId.isAcceptableOrUnknown(data['skill_id']!, _skillIdMeta));
    } else if (isInserting) {
      context.missing(_skillIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
          _levelMeta, level.isAcceptableOrUnknown(data['level']!, _levelMeta));
    }
    if (data.containsKey('max_level')) {
      context.handle(_maxLevelMeta,
          maxLevel.isAcceptableOrUnknown(data['max_level']!, _maxLevelMeta));
    }
    if (data.containsKey('current_xp')) {
      context.handle(_currentXpMeta,
          currentXp.isAcceptableOrUnknown(data['current_xp']!, _currentXpMeta));
    }
    if (data.containsKey('required_xp')) {
      context.handle(
          _requiredXpMeta,
          requiredXp.isAcceptableOrUnknown(
              data['required_xp']!, _requiredXpMeta));
    }
    if (data.containsKey('is_unlocked')) {
      context.handle(
          _isUnlockedMeta,
          isUnlocked.isAcceptableOrUnknown(
              data['is_unlocked']!, _isUnlockedMeta));
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
          _unlockedAtMeta,
          unlockedAt.isAcceptableOrUnknown(
              data['unlocked_at']!, _unlockedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Skill map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Skill(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      skillId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}skill_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      level: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}level'])!,
      maxLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_level'])!,
      currentXp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_xp'])!,
      requiredXp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}required_xp'])!,
      isUnlocked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_unlocked'])!,
      unlockedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}unlocked_at']),
    );
  }

  @override
  $SkillsTable createAlias(String alias) {
    return $SkillsTable(attachedDatabase, alias);
  }
}

class Skill extends DataClass implements Insertable<Skill> {
  final int id;
  final String skillId;
  final String name;
  final String description;
  final int level;
  final int maxLevel;
  final int currentXp;
  final int requiredXp;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  const Skill(
      {required this.id,
      required this.skillId,
      required this.name,
      required this.description,
      required this.level,
      required this.maxLevel,
      required this.currentXp,
      required this.requiredXp,
      required this.isUnlocked,
      this.unlockedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['skill_id'] = Variable<String>(skillId);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['level'] = Variable<int>(level);
    map['max_level'] = Variable<int>(maxLevel);
    map['current_xp'] = Variable<int>(currentXp);
    map['required_xp'] = Variable<int>(requiredXp);
    map['is_unlocked'] = Variable<bool>(isUnlocked);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    }
    return map;
  }

  SkillsCompanion toCompanion(bool nullToAbsent) {
    return SkillsCompanion(
      id: Value(id),
      skillId: Value(skillId),
      name: Value(name),
      description: Value(description),
      level: Value(level),
      maxLevel: Value(maxLevel),
      currentXp: Value(currentXp),
      requiredXp: Value(requiredXp),
      isUnlocked: Value(isUnlocked),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
    );
  }

  factory Skill.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Skill(
      id: serializer.fromJson<int>(json['id']),
      skillId: serializer.fromJson<String>(json['skillId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      level: serializer.fromJson<int>(json['level']),
      maxLevel: serializer.fromJson<int>(json['maxLevel']),
      currentXp: serializer.fromJson<int>(json['currentXp']),
      requiredXp: serializer.fromJson<int>(json['requiredXp']),
      isUnlocked: serializer.fromJson<bool>(json['isUnlocked']),
      unlockedAt: serializer.fromJson<DateTime?>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'skillId': serializer.toJson<String>(skillId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'level': serializer.toJson<int>(level),
      'maxLevel': serializer.toJson<int>(maxLevel),
      'currentXp': serializer.toJson<int>(currentXp),
      'requiredXp': serializer.toJson<int>(requiredXp),
      'isUnlocked': serializer.toJson<bool>(isUnlocked),
      'unlockedAt': serializer.toJson<DateTime?>(unlockedAt),
    };
  }

  Skill copyWith(
          {int? id,
          String? skillId,
          String? name,
          String? description,
          int? level,
          int? maxLevel,
          int? currentXp,
          int? requiredXp,
          bool? isUnlocked,
          Value<DateTime?> unlockedAt = const Value.absent()}) =>
      Skill(
        id: id ?? this.id,
        skillId: skillId ?? this.skillId,
        name: name ?? this.name,
        description: description ?? this.description,
        level: level ?? this.level,
        maxLevel: maxLevel ?? this.maxLevel,
        currentXp: currentXp ?? this.currentXp,
        requiredXp: requiredXp ?? this.requiredXp,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
      );
  Skill copyWithCompanion(SkillsCompanion data) {
    return Skill(
      id: data.id.present ? data.id.value : this.id,
      skillId: data.skillId.present ? data.skillId.value : this.skillId,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      level: data.level.present ? data.level.value : this.level,
      maxLevel: data.maxLevel.present ? data.maxLevel.value : this.maxLevel,
      currentXp: data.currentXp.present ? data.currentXp.value : this.currentXp,
      requiredXp:
          data.requiredXp.present ? data.requiredXp.value : this.requiredXp,
      isUnlocked:
          data.isUnlocked.present ? data.isUnlocked.value : this.isUnlocked,
      unlockedAt:
          data.unlockedAt.present ? data.unlockedAt.value : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Skill(')
          ..write('id: $id, ')
          ..write('skillId: $skillId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('level: $level, ')
          ..write('maxLevel: $maxLevel, ')
          ..write('currentXp: $currentXp, ')
          ..write('requiredXp: $requiredXp, ')
          ..write('isUnlocked: $isUnlocked, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, skillId, name, description, level,
      maxLevel, currentXp, requiredXp, isUnlocked, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Skill &&
          other.id == this.id &&
          other.skillId == this.skillId &&
          other.name == this.name &&
          other.description == this.description &&
          other.level == this.level &&
          other.maxLevel == this.maxLevel &&
          other.currentXp == this.currentXp &&
          other.requiredXp == this.requiredXp &&
          other.isUnlocked == this.isUnlocked &&
          other.unlockedAt == this.unlockedAt);
}

class SkillsCompanion extends UpdateCompanion<Skill> {
  final Value<int> id;
  final Value<String> skillId;
  final Value<String> name;
  final Value<String> description;
  final Value<int> level;
  final Value<int> maxLevel;
  final Value<int> currentXp;
  final Value<int> requiredXp;
  final Value<bool> isUnlocked;
  final Value<DateTime?> unlockedAt;
  const SkillsCompanion({
    this.id = const Value.absent(),
    this.skillId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.level = const Value.absent(),
    this.maxLevel = const Value.absent(),
    this.currentXp = const Value.absent(),
    this.requiredXp = const Value.absent(),
    this.isUnlocked = const Value.absent(),
    this.unlockedAt = const Value.absent(),
  });
  SkillsCompanion.insert({
    this.id = const Value.absent(),
    required String skillId,
    required String name,
    required String description,
    this.level = const Value.absent(),
    this.maxLevel = const Value.absent(),
    this.currentXp = const Value.absent(),
    this.requiredXp = const Value.absent(),
    this.isUnlocked = const Value.absent(),
    this.unlockedAt = const Value.absent(),
  })  : skillId = Value(skillId),
        name = Value(name),
        description = Value(description);
  static Insertable<Skill> custom({
    Expression<int>? id,
    Expression<String>? skillId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? level,
    Expression<int>? maxLevel,
    Expression<int>? currentXp,
    Expression<int>? requiredXp,
    Expression<bool>? isUnlocked,
    Expression<DateTime>? unlockedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (skillId != null) 'skill_id': skillId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (level != null) 'level': level,
      if (maxLevel != null) 'max_level': maxLevel,
      if (currentXp != null) 'current_xp': currentXp,
      if (requiredXp != null) 'required_xp': requiredXp,
      if (isUnlocked != null) 'is_unlocked': isUnlocked,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
    });
  }

  SkillsCompanion copyWith(
      {Value<int>? id,
      Value<String>? skillId,
      Value<String>? name,
      Value<String>? description,
      Value<int>? level,
      Value<int>? maxLevel,
      Value<int>? currentXp,
      Value<int>? requiredXp,
      Value<bool>? isUnlocked,
      Value<DateTime?>? unlockedAt}) {
    return SkillsCompanion(
      id: id ?? this.id,
      skillId: skillId ?? this.skillId,
      name: name ?? this.name,
      description: description ?? this.description,
      level: level ?? this.level,
      maxLevel: maxLevel ?? this.maxLevel,
      currentXp: currentXp ?? this.currentXp,
      requiredXp: requiredXp ?? this.requiredXp,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (skillId.present) {
      map['skill_id'] = Variable<String>(skillId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (maxLevel.present) {
      map['max_level'] = Variable<int>(maxLevel.value);
    }
    if (currentXp.present) {
      map['current_xp'] = Variable<int>(currentXp.value);
    }
    if (requiredXp.present) {
      map['required_xp'] = Variable<int>(requiredXp.value);
    }
    if (isUnlocked.present) {
      map['is_unlocked'] = Variable<bool>(isUnlocked.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SkillsCompanion(')
          ..write('id: $id, ')
          ..write('skillId: $skillId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('level: $level, ')
          ..write('maxLevel: $maxLevel, ')
          ..write('currentXp: $currentXp, ')
          ..write('requiredXp: $requiredXp, ')
          ..write('isUnlocked: $isUnlocked, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $HeroStatsTableTable heroStatsTable = $HeroStatsTableTable(this);
  late final $QuestsTable quests = $QuestsTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $CategoryBudgetsTable categoryBudgets =
      $CategoryBudgetsTable(this);
  late final $SkillsTable skills = $SkillsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        transactions,
        heroStatsTable,
        quests,
        achievements,
        categoryBudgets,
        skills
      ];
}

typedef $$TransactionsTableCreateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  required String title,
  required int amount,
  Value<bool> isIncome,
  required String category,
  Value<String?> note,
  Value<DateTime> createdAt,
  Value<int?> serverId,
  Value<String> syncStatus,
  Value<DateTime?> syncedAt,
  Value<DateTime> updatedAt,
});
typedef $$TransactionsTableUpdateCompanionBuilder = TransactionsCompanion
    Function({
  Value<int> id,
  Value<String> title,
  Value<int> amount,
  Value<bool> isIncome,
  Value<String> category,
  Value<String?> note,
  Value<DateTime> createdAt,
  Value<int?> serverId,
  Value<String> syncStatus,
  Value<DateTime?> syncedAt,
  Value<DateTime> updatedAt,
});

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isIncome => $composableBuilder(
      column: $table.isIncome, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isIncome => $composableBuilder(
      column: $table.isIncome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
      column: $table.syncedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<bool> get isIncome =>
      $composableBuilder(column: $table.isIncome, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (
      Transaction,
      BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>
    ),
    Transaction,
    PrefetchHooks Function()> {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<bool> isIncome = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              TransactionsCompanion(
            id: id,
            title: title,
            amount: amount,
            isIncome: isIncome,
            category: category,
            note: note,
            createdAt: createdAt,
            serverId: serverId,
            syncStatus: syncStatus,
            syncedAt: syncedAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required int amount,
            Value<bool> isIncome = const Value.absent(),
            required String category,
            Value<String?> note = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int?> serverId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> syncedAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              TransactionsCompanion.insert(
            id: id,
            title: title,
            amount: amount,
            isIncome: isIncome,
            category: category,
            note: note,
            createdAt: createdAt,
            serverId: serverId,
            syncStatus: syncStatus,
            syncedAt: syncedAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TransactionsTable,
    Transaction,
    $$TransactionsTableFilterComposer,
    $$TransactionsTableOrderingComposer,
    $$TransactionsTableAnnotationComposer,
    $$TransactionsTableCreateCompanionBuilder,
    $$TransactionsTableUpdateCompanionBuilder,
    (
      Transaction,
      BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>
    ),
    Transaction,
    PrefetchHooks Function()>;
typedef $$HeroStatsTableTableCreateCompanionBuilder = HeroStatsTableCompanion
    Function({
  Value<int> id,
  Value<int> level,
  Value<int> currentXp,
  Value<int> requiredXp,
  Value<int> currentHp,
  Value<int> maxHp,
  Value<int> totalSaved,
  Value<int> totalSpent,
  Value<int> streak,
  Value<DateTime?> lastRecordDate,
  Value<DateTime> lastUpdated,
});
typedef $$HeroStatsTableTableUpdateCompanionBuilder = HeroStatsTableCompanion
    Function({
  Value<int> id,
  Value<int> level,
  Value<int> currentXp,
  Value<int> requiredXp,
  Value<int> currentHp,
  Value<int> maxHp,
  Value<int> totalSaved,
  Value<int> totalSpent,
  Value<int> streak,
  Value<DateTime?> lastRecordDate,
  Value<DateTime> lastUpdated,
});

class $$HeroStatsTableTableFilterComposer
    extends Composer<_$AppDatabase, $HeroStatsTableTable> {
  $$HeroStatsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentXp => $composableBuilder(
      column: $table.currentXp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get requiredXp => $composableBuilder(
      column: $table.requiredXp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentHp => $composableBuilder(
      column: $table.currentHp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxHp => $composableBuilder(
      column: $table.maxHp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalSaved => $composableBuilder(
      column: $table.totalSaved, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalSpent => $composableBuilder(
      column: $table.totalSpent, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get streak => $composableBuilder(
      column: $table.streak, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastRecordDate => $composableBuilder(
      column: $table.lastRecordDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));
}

class $$HeroStatsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HeroStatsTableTable> {
  $$HeroStatsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentXp => $composableBuilder(
      column: $table.currentXp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get requiredXp => $composableBuilder(
      column: $table.requiredXp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentHp => $composableBuilder(
      column: $table.currentHp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxHp => $composableBuilder(
      column: $table.maxHp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalSaved => $composableBuilder(
      column: $table.totalSaved, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalSpent => $composableBuilder(
      column: $table.totalSpent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get streak => $composableBuilder(
      column: $table.streak, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastRecordDate => $composableBuilder(
      column: $table.lastRecordDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));
}

class $$HeroStatsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HeroStatsTableTable> {
  $$HeroStatsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get currentXp =>
      $composableBuilder(column: $table.currentXp, builder: (column) => column);

  GeneratedColumn<int> get requiredXp => $composableBuilder(
      column: $table.requiredXp, builder: (column) => column);

  GeneratedColumn<int> get currentHp =>
      $composableBuilder(column: $table.currentHp, builder: (column) => column);

  GeneratedColumn<int> get maxHp =>
      $composableBuilder(column: $table.maxHp, builder: (column) => column);

  GeneratedColumn<int> get totalSaved => $composableBuilder(
      column: $table.totalSaved, builder: (column) => column);

  GeneratedColumn<int> get totalSpent => $composableBuilder(
      column: $table.totalSpent, builder: (column) => column);

  GeneratedColumn<int> get streak =>
      $composableBuilder(column: $table.streak, builder: (column) => column);

  GeneratedColumn<DateTime> get lastRecordDate => $composableBuilder(
      column: $table.lastRecordDate, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);
}

class $$HeroStatsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HeroStatsTableTable,
    HeroStatsTableData,
    $$HeroStatsTableTableFilterComposer,
    $$HeroStatsTableTableOrderingComposer,
    $$HeroStatsTableTableAnnotationComposer,
    $$HeroStatsTableTableCreateCompanionBuilder,
    $$HeroStatsTableTableUpdateCompanionBuilder,
    (
      HeroStatsTableData,
      BaseReferences<_$AppDatabase, $HeroStatsTableTable, HeroStatsTableData>
    ),
    HeroStatsTableData,
    PrefetchHooks Function()> {
  $$HeroStatsTableTableTableManager(
      _$AppDatabase db, $HeroStatsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HeroStatsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HeroStatsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HeroStatsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> level = const Value.absent(),
            Value<int> currentXp = const Value.absent(),
            Value<int> requiredXp = const Value.absent(),
            Value<int> currentHp = const Value.absent(),
            Value<int> maxHp = const Value.absent(),
            Value<int> totalSaved = const Value.absent(),
            Value<int> totalSpent = const Value.absent(),
            Value<int> streak = const Value.absent(),
            Value<DateTime?> lastRecordDate = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
          }) =>
              HeroStatsTableCompanion(
            id: id,
            level: level,
            currentXp: currentXp,
            requiredXp: requiredXp,
            currentHp: currentHp,
            maxHp: maxHp,
            totalSaved: totalSaved,
            totalSpent: totalSpent,
            streak: streak,
            lastRecordDate: lastRecordDate,
            lastUpdated: lastUpdated,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> level = const Value.absent(),
            Value<int> currentXp = const Value.absent(),
            Value<int> requiredXp = const Value.absent(),
            Value<int> currentHp = const Value.absent(),
            Value<int> maxHp = const Value.absent(),
            Value<int> totalSaved = const Value.absent(),
            Value<int> totalSpent = const Value.absent(),
            Value<int> streak = const Value.absent(),
            Value<DateTime?> lastRecordDate = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
          }) =>
              HeroStatsTableCompanion.insert(
            id: id,
            level: level,
            currentXp: currentXp,
            requiredXp: requiredXp,
            currentHp: currentHp,
            maxHp: maxHp,
            totalSaved: totalSaved,
            totalSpent: totalSpent,
            streak: streak,
            lastRecordDate: lastRecordDate,
            lastUpdated: lastUpdated,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HeroStatsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HeroStatsTableTable,
    HeroStatsTableData,
    $$HeroStatsTableTableFilterComposer,
    $$HeroStatsTableTableOrderingComposer,
    $$HeroStatsTableTableAnnotationComposer,
    $$HeroStatsTableTableCreateCompanionBuilder,
    $$HeroStatsTableTableUpdateCompanionBuilder,
    (
      HeroStatsTableData,
      BaseReferences<_$AppDatabase, $HeroStatsTableTable, HeroStatsTableData>
    ),
    HeroStatsTableData,
    PrefetchHooks Function()>;
typedef $$QuestsTableCreateCompanionBuilder = QuestsCompanion Function({
  Value<int> id,
  Value<String> questType,
  required String title,
  required String description,
  required int targetAmount,
  Value<int> currentAmount,
  required int rewardXp,
  Value<bool> isCompleted,
  Value<bool> isRewardClaimed,
  required DateTime startDate,
  required DateTime endDate,
});
typedef $$QuestsTableUpdateCompanionBuilder = QuestsCompanion Function({
  Value<int> id,
  Value<String> questType,
  Value<String> title,
  Value<String> description,
  Value<int> targetAmount,
  Value<int> currentAmount,
  Value<int> rewardXp,
  Value<bool> isCompleted,
  Value<bool> isRewardClaimed,
  Value<DateTime> startDate,
  Value<DateTime> endDate,
});

class $$QuestsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestsTable> {
  $$QuestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questType => $composableBuilder(
      column: $table.questType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentAmount => $composableBuilder(
      column: $table.currentAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rewardXp => $composableBuilder(
      column: $table.rewardXp, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRewardClaimed => $composableBuilder(
      column: $table.isRewardClaimed,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));
}

class $$QuestsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestsTable> {
  $$QuestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questType => $composableBuilder(
      column: $table.questType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetAmount => $composableBuilder(
      column: $table.targetAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentAmount => $composableBuilder(
      column: $table.currentAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rewardXp => $composableBuilder(
      column: $table.rewardXp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRewardClaimed => $composableBuilder(
      column: $table.isRewardClaimed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));
}

class $$QuestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestsTable> {
  $$QuestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get questType =>
      $composableBuilder(column: $table.questType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => column);

  GeneratedColumn<int> get currentAmount => $composableBuilder(
      column: $table.currentAmount, builder: (column) => column);

  GeneratedColumn<int> get rewardXp =>
      $composableBuilder(column: $table.rewardXp, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<bool> get isRewardClaimed => $composableBuilder(
      column: $table.isRewardClaimed, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);
}

class $$QuestsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuestsTable,
    Quest,
    $$QuestsTableFilterComposer,
    $$QuestsTableOrderingComposer,
    $$QuestsTableAnnotationComposer,
    $$QuestsTableCreateCompanionBuilder,
    $$QuestsTableUpdateCompanionBuilder,
    (Quest, BaseReferences<_$AppDatabase, $QuestsTable, Quest>),
    Quest,
    PrefetchHooks Function()> {
  $$QuestsTableTableManager(_$AppDatabase db, $QuestsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> questType = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> targetAmount = const Value.absent(),
            Value<int> currentAmount = const Value.absent(),
            Value<int> rewardXp = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<bool> isRewardClaimed = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime> endDate = const Value.absent(),
          }) =>
              QuestsCompanion(
            id: id,
            questType: questType,
            title: title,
            description: description,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            rewardXp: rewardXp,
            isCompleted: isCompleted,
            isRewardClaimed: isRewardClaimed,
            startDate: startDate,
            endDate: endDate,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> questType = const Value.absent(),
            required String title,
            required String description,
            required int targetAmount,
            Value<int> currentAmount = const Value.absent(),
            required int rewardXp,
            Value<bool> isCompleted = const Value.absent(),
            Value<bool> isRewardClaimed = const Value.absent(),
            required DateTime startDate,
            required DateTime endDate,
          }) =>
              QuestsCompanion.insert(
            id: id,
            questType: questType,
            title: title,
            description: description,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            rewardXp: rewardXp,
            isCompleted: isCompleted,
            isRewardClaimed: isRewardClaimed,
            startDate: startDate,
            endDate: endDate,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QuestsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QuestsTable,
    Quest,
    $$QuestsTableFilterComposer,
    $$QuestsTableOrderingComposer,
    $$QuestsTableAnnotationComposer,
    $$QuestsTableCreateCompanionBuilder,
    $$QuestsTableUpdateCompanionBuilder,
    (Quest, BaseReferences<_$AppDatabase, $QuestsTable, Quest>),
    Quest,
    PrefetchHooks Function()>;
typedef $$AchievementsTableCreateCompanionBuilder = AchievementsCompanion
    Function({
  Value<int> id,
  required String achievementId,
  required String category,
  required String title,
  required String description,
  required String emoji,
  Value<bool> isUnlocked,
  Value<DateTime?> unlockedAt,
});
typedef $$AchievementsTableUpdateCompanionBuilder = AchievementsCompanion
    Function({
  Value<int> id,
  Value<String> achievementId,
  Value<String> category,
  Value<String> title,
  Value<String> description,
  Value<String> emoji,
  Value<bool> isUnlocked,
  Value<DateTime?> unlockedAt,
});

class $$AchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get achievementId => $composableBuilder(
      column: $table.achievementId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get emoji => $composableBuilder(
      column: $table.emoji, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isUnlocked => $composableBuilder(
      column: $table.isUnlocked, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => ColumnFilters(column));
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get achievementId => $composableBuilder(
      column: $table.achievementId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get emoji => $composableBuilder(
      column: $table.emoji, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isUnlocked => $composableBuilder(
      column: $table.isUnlocked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => ColumnOrderings(column));
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get achievementId => $composableBuilder(
      column: $table.achievementId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<bool> get isUnlocked => $composableBuilder(
      column: $table.isUnlocked, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => column);
}

class $$AchievementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AchievementsTable,
    Achievement,
    $$AchievementsTableFilterComposer,
    $$AchievementsTableOrderingComposer,
    $$AchievementsTableAnnotationComposer,
    $$AchievementsTableCreateCompanionBuilder,
    $$AchievementsTableUpdateCompanionBuilder,
    (
      Achievement,
      BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>
    ),
    Achievement,
    PrefetchHooks Function()> {
  $$AchievementsTableTableManager(_$AppDatabase db, $AchievementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> achievementId = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> emoji = const Value.absent(),
            Value<bool> isUnlocked = const Value.absent(),
            Value<DateTime?> unlockedAt = const Value.absent(),
          }) =>
              AchievementsCompanion(
            id: id,
            achievementId: achievementId,
            category: category,
            title: title,
            description: description,
            emoji: emoji,
            isUnlocked: isUnlocked,
            unlockedAt: unlockedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String achievementId,
            required String category,
            required String title,
            required String description,
            required String emoji,
            Value<bool> isUnlocked = const Value.absent(),
            Value<DateTime?> unlockedAt = const Value.absent(),
          }) =>
              AchievementsCompanion.insert(
            id: id,
            achievementId: achievementId,
            category: category,
            title: title,
            description: description,
            emoji: emoji,
            isUnlocked: isUnlocked,
            unlockedAt: unlockedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AchievementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AchievementsTable,
    Achievement,
    $$AchievementsTableFilterComposer,
    $$AchievementsTableOrderingComposer,
    $$AchievementsTableAnnotationComposer,
    $$AchievementsTableCreateCompanionBuilder,
    $$AchievementsTableUpdateCompanionBuilder,
    (
      Achievement,
      BaseReferences<_$AppDatabase, $AchievementsTable, Achievement>
    ),
    Achievement,
    PrefetchHooks Function()>;
typedef $$CategoryBudgetsTableCreateCompanionBuilder = CategoryBudgetsCompanion
    Function({
  Value<int> id,
  required String category,
  required int amount,
  required int year,
  required int month,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$CategoryBudgetsTableUpdateCompanionBuilder = CategoryBudgetsCompanion
    Function({
  Value<int> id,
  Value<String> category,
  Value<int> amount,
  Value<int> year,
  Value<int> month,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$CategoryBudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryBudgetsTable> {
  $$CategoryBudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get month => $composableBuilder(
      column: $table.month, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CategoryBudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryBudgetsTable> {
  $$CategoryBudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get month => $composableBuilder(
      column: $table.month, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CategoryBudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryBudgetsTable> {
  $$CategoryBudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CategoryBudgetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoryBudgetsTable,
    CategoryBudget,
    $$CategoryBudgetsTableFilterComposer,
    $$CategoryBudgetsTableOrderingComposer,
    $$CategoryBudgetsTableAnnotationComposer,
    $$CategoryBudgetsTableCreateCompanionBuilder,
    $$CategoryBudgetsTableUpdateCompanionBuilder,
    (
      CategoryBudget,
      BaseReferences<_$AppDatabase, $CategoryBudgetsTable, CategoryBudget>
    ),
    CategoryBudget,
    PrefetchHooks Function()> {
  $$CategoryBudgetsTableTableManager(
      _$AppDatabase db, $CategoryBudgetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryBudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryBudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryBudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<int> amount = const Value.absent(),
            Value<int> year = const Value.absent(),
            Value<int> month = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CategoryBudgetsCompanion(
            id: id,
            category: category,
            amount: amount,
            year: year,
            month: month,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String category,
            required int amount,
            required int year,
            required int month,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CategoryBudgetsCompanion.insert(
            id: id,
            category: category,
            amount: amount,
            year: year,
            month: month,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CategoryBudgetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoryBudgetsTable,
    CategoryBudget,
    $$CategoryBudgetsTableFilterComposer,
    $$CategoryBudgetsTableOrderingComposer,
    $$CategoryBudgetsTableAnnotationComposer,
    $$CategoryBudgetsTableCreateCompanionBuilder,
    $$CategoryBudgetsTableUpdateCompanionBuilder,
    (
      CategoryBudget,
      BaseReferences<_$AppDatabase, $CategoryBudgetsTable, CategoryBudget>
    ),
    CategoryBudget,
    PrefetchHooks Function()>;
typedef $$SkillsTableCreateCompanionBuilder = SkillsCompanion Function({
  Value<int> id,
  required String skillId,
  required String name,
  required String description,
  Value<int> level,
  Value<int> maxLevel,
  Value<int> currentXp,
  Value<int> requiredXp,
  Value<bool> isUnlocked,
  Value<DateTime?> unlockedAt,
});
typedef $$SkillsTableUpdateCompanionBuilder = SkillsCompanion Function({
  Value<int> id,
  Value<String> skillId,
  Value<String> name,
  Value<String> description,
  Value<int> level,
  Value<int> maxLevel,
  Value<int> currentXp,
  Value<int> requiredXp,
  Value<bool> isUnlocked,
  Value<DateTime?> unlockedAt,
});

class $$SkillsTableFilterComposer
    extends Composer<_$AppDatabase, $SkillsTable> {
  $$SkillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get skillId => $composableBuilder(
      column: $table.skillId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxLevel => $composableBuilder(
      column: $table.maxLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentXp => $composableBuilder(
      column: $table.currentXp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get requiredXp => $composableBuilder(
      column: $table.requiredXp, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isUnlocked => $composableBuilder(
      column: $table.isUnlocked, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => ColumnFilters(column));
}

class $$SkillsTableOrderingComposer
    extends Composer<_$AppDatabase, $SkillsTable> {
  $$SkillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get skillId => $composableBuilder(
      column: $table.skillId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get level => $composableBuilder(
      column: $table.level, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxLevel => $composableBuilder(
      column: $table.maxLevel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentXp => $composableBuilder(
      column: $table.currentXp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get requiredXp => $composableBuilder(
      column: $table.requiredXp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isUnlocked => $composableBuilder(
      column: $table.isUnlocked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => ColumnOrderings(column));
}

class $$SkillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SkillsTable> {
  $$SkillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get skillId =>
      $composableBuilder(column: $table.skillId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get maxLevel =>
      $composableBuilder(column: $table.maxLevel, builder: (column) => column);

  GeneratedColumn<int> get currentXp =>
      $composableBuilder(column: $table.currentXp, builder: (column) => column);

  GeneratedColumn<int> get requiredXp => $composableBuilder(
      column: $table.requiredXp, builder: (column) => column);

  GeneratedColumn<bool> get isUnlocked => $composableBuilder(
      column: $table.isUnlocked, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
      column: $table.unlockedAt, builder: (column) => column);
}

class $$SkillsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SkillsTable,
    Skill,
    $$SkillsTableFilterComposer,
    $$SkillsTableOrderingComposer,
    $$SkillsTableAnnotationComposer,
    $$SkillsTableCreateCompanionBuilder,
    $$SkillsTableUpdateCompanionBuilder,
    (Skill, BaseReferences<_$AppDatabase, $SkillsTable, Skill>),
    Skill,
    PrefetchHooks Function()> {
  $$SkillsTableTableManager(_$AppDatabase db, $SkillsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SkillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SkillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SkillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> skillId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> level = const Value.absent(),
            Value<int> maxLevel = const Value.absent(),
            Value<int> currentXp = const Value.absent(),
            Value<int> requiredXp = const Value.absent(),
            Value<bool> isUnlocked = const Value.absent(),
            Value<DateTime?> unlockedAt = const Value.absent(),
          }) =>
              SkillsCompanion(
            id: id,
            skillId: skillId,
            name: name,
            description: description,
            level: level,
            maxLevel: maxLevel,
            currentXp: currentXp,
            requiredXp: requiredXp,
            isUnlocked: isUnlocked,
            unlockedAt: unlockedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String skillId,
            required String name,
            required String description,
            Value<int> level = const Value.absent(),
            Value<int> maxLevel = const Value.absent(),
            Value<int> currentXp = const Value.absent(),
            Value<int> requiredXp = const Value.absent(),
            Value<bool> isUnlocked = const Value.absent(),
            Value<DateTime?> unlockedAt = const Value.absent(),
          }) =>
              SkillsCompanion.insert(
            id: id,
            skillId: skillId,
            name: name,
            description: description,
            level: level,
            maxLevel: maxLevel,
            currentXp: currentXp,
            requiredXp: requiredXp,
            isUnlocked: isUnlocked,
            unlockedAt: unlockedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SkillsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SkillsTable,
    Skill,
    $$SkillsTableFilterComposer,
    $$SkillsTableOrderingComposer,
    $$SkillsTableAnnotationComposer,
    $$SkillsTableCreateCompanionBuilder,
    $$SkillsTableUpdateCompanionBuilder,
    (Skill, BaseReferences<_$AppDatabase, $SkillsTable, Skill>),
    Skill,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$HeroStatsTableTableTableManager get heroStatsTable =>
      $$HeroStatsTableTableTableManager(_db, _db.heroStatsTable);
  $$QuestsTableTableManager get quests =>
      $$QuestsTableTableManager(_db, _db.quests);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
  $$CategoryBudgetsTableTableManager get categoryBudgets =>
      $$CategoryBudgetsTableTableManager(_db, _db.categoryBudgets);
  $$SkillsTableTableManager get skills =>
      $$SkillsTableTableManager(_db, _db.skills);
}
