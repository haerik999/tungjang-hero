import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

part 'app_database.g.dart';

// ============ Enums ============

/// 동기화 상태
class SyncStatus {
  static const String pending = 'pending';
  static const String synced = 'synced';
  static const String conflict = 'conflict';
}

/// 영수증 OCR 상태
class ReceiptOcrStatus {
  static const String none = 'none'; // 영수증 없음
  static const String pending = 'pending'; // OCR 대기중
  static const String success = 'success'; // OCR 성공
  static const String failed = 'failed'; // OCR 실패
}

// ============ Tables ============

/// 거래 기록 테이블 (가계부 핵심)
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  IntColumn get amount => integer()();
  BoolColumn get isIncome => boolean().withDefault(const Constant(false))();
  TextColumn get category => text().withLength(min: 1, max: 50)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get transactionDate =>
      dateTime().withDefault(currentDateAndTime)(); // 실제 거래 날짜
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)(); // 레코드 생성 시간

  // 영수증 관련
  TextColumn get receiptImagePath => text().nullable()(); // 로컬 이미지 경로
  TextColumn get receiptOcrStatus =>
      text().withDefault(const Constant(ReceiptOcrStatus.none))();

  // 동기화 관련
  IntColumn get serverId => integer().nullable()();
  TextColumn get deviceId => text()(); // 생성된 기기 ID
  TextColumn get syncStatus =>
      text().withDefault(const Constant(SyncStatus.pending))();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()(); // soft delete (tombstone)
}

/// 카테고리별 월예산 테이블
class CategoryBudgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text().withLength(min: 1, max: 50)();
  IntColumn get amount => integer()();
  IntColumn get year => integer()();
  IntColumn get month => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // 동기화 관련
  IntColumn get serverId => integer().nullable()();
  TextColumn get deviceId => text()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant(SyncStatus.pending))();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

/// 사용자 정의 카테고리 테이블
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get icon => text().withDefault(const Constant('category'))();
  TextColumn get color =>
      text().withDefault(const Constant('#6366F1'))(); // hex color
  BoolColumn get isDefault =>
      boolean().withDefault(const Constant(false))(); // 기본 카테고리 여부
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  // 동기화 관련
  IntColumn get serverId => integer().nullable()();
  TextColumn get deviceId => text()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant(SyncStatus.pending))();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

/// 로컬 설정 테이블 (동기화 안 함)
class UserSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text()(); // 이 기기의 고유 ID
  DateTimeColumn get lastSyncAt => dateTime().nullable()(); // 마지막 동기화 시간
  BoolColumn get isGuestMode =>
      boolean().withDefault(const Constant(true))(); // 게스트 모드 여부
  TextColumn get defaultCurrency =>
      text().withDefault(const Constant('KRW'))();
  BoolColumn get notificationsEnabled =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// ============ Database ============

@DriftDatabase(tables: [Transactions, CategoryBudgets, Categories, UserSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _initializeDefaultCategories();
        },
        onUpgrade: (m, from, to) async {
          // 버전 4로 마이그레이션: 게임 테이블 제거, 새 컬럼 추가
          if (from < 4) {
            // 기존 게임 테이블 삭제
            await m.deleteTable('hero_stats');
            await m.deleteTable('quests');
            await m.deleteTable('achievements');
            await m.deleteTable('skills');

            // 새 테이블 생성
            await m.createTable(categories);
            await m.createTable(userSettings);

            // transactions 테이블에 새 컬럼 추가
            await m.addColumn(transactions, transactions.transactionDate);
            await m.addColumn(transactions, transactions.receiptImagePath);
            await m.addColumn(transactions, transactions.receiptOcrStatus);
            await m.addColumn(transactions, transactions.deviceId);
            await m.addColumn(transactions, transactions.deletedAt);

            // categoryBudgets 테이블에 새 컬럼 추가
            await m.addColumn(categoryBudgets, categoryBudgets.serverId);
            await m.addColumn(categoryBudgets, categoryBudgets.deviceId);
            await m.addColumn(categoryBudgets, categoryBudgets.syncStatus);
            await m.addColumn(categoryBudgets, categoryBudgets.syncedAt);
            await m.addColumn(categoryBudgets, categoryBudgets.deletedAt);
          }
        },
        beforeOpen: (details) async {
          // 기본 카테고리 초기화 확인
          if (details.wasCreated) {
            await _initializeDefaultCategories();
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'tungjang_hero_db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
        onResult: (result) {
          if (result.missingFeatures.isNotEmpty) {
            debugPrint(
                'Using ${result.chosenImplementation} due to missing browser features: ${result.missingFeatures}');
          }
        },
      ),
    );
  }

  /// 기본 카테고리 초기화
  Future<void> _initializeDefaultCategories() async {
    final existing = await select(categories).get();
    if (existing.isNotEmpty) return;

    final defaultCategories = [
      ('식비', 'restaurant', '#EF4444', 1),
      ('교통', 'directions_car', '#F97316', 2),
      ('쇼핑', 'shopping_bag', '#EAB308', 3),
      ('생활', 'home', '#22C55E', 4),
      ('의료', 'medical_services', '#06B6D4', 5),
      ('문화', 'movie', '#8B5CF6', 6),
      ('교육', 'school', '#EC4899', 7),
      ('저축', 'savings', '#10B981', 8),
      ('급여', 'payments', '#3B82F6', 9),
      ('기타', 'more_horiz', '#6B7280', 10),
    ];

    for (final (name, icon, color, order) in defaultCategories) {
      await into(categories).insert(
        CategoriesCompanion.insert(
          name: name,
          icon: Value(icon),
          color: Value(color),
          isDefault: const Value(true),
          sortOrder: Value(order),
          deviceId: 'system',
          syncStatus: const Value(SyncStatus.synced),
        ),
      );
    }
  }

  // ============ Transaction Operations ============

  /// 삭제되지 않은 모든 거래 조회
  Future<List<Transaction>> getAllTransactions() => (select(transactions)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
      .get();

  /// 삭제되지 않은 거래 스트림
  Stream<List<Transaction>> watchAllTransactions() => (select(transactions)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
      .watch();

  /// 특정 월의 거래 스트림
  Stream<List<Transaction>> watchTransactionsByMonth(int year, int month) {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    return (select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.transactionDate.isBetweenValues(startDate, endDate))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .watch();
  }

  /// 오늘 거래 스트림
  Stream<List<Transaction>> watchTodayTransactions() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return (select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.transactionDate.isBetweenValues(startOfDay, endOfDay))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .watch();
  }

  /// 거래 추가
  Future<int> insertTransaction(TransactionsCompanion entry) =>
      into(transactions).insert(entry);

  /// 거래 수정
  Future<bool> updateTransaction(Transaction entry) =>
      update(transactions).replace(entry);

  /// 거래 soft delete
  Future<void> softDeleteTransaction(int id) async {
    await (update(transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value(SyncStatus.pending),
      ),
    );
  }

  /// 거래 물리 삭제 (tombstone 정리용)
  Future<int> hardDeleteTransaction(int id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();

  // ============ Sync Operations ============

  /// 동기화 대기 중인 거래 조회
  Future<List<Transaction>> getPendingTransactions() => (select(transactions)
        ..where((t) => t.syncStatus.equals(SyncStatus.pending)))
      .get();

  /// 삭제된 거래 조회 (tombstone)
  Future<List<Transaction>> getDeletedTransactions() => (select(transactions)
        ..where((t) => t.deletedAt.isNotNull()))
      .get();

  /// 거래 동기화 상태 업데이트
  Future<void> markTransactionSynced(int localId, int serverId) async {
    await (update(transactions)..where((t) => t.id.equals(localId))).write(
      TransactionsCompanion(
        serverId: Value(serverId),
        syncStatus: const Value(SyncStatus.synced),
        syncedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 서버 ID로 거래 조회
  Future<Transaction?> getTransactionByServerId(int serverId) =>
      (select(transactions)..where((t) => t.serverId.equals(serverId)))
          .getSingleOrNull();

  /// 로컬 ID로 거래 조회
  Future<Transaction?> getTransactionById(int id) =>
      (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// 서버 데이터로 거래 upsert (동기화용, LWW 적용)
  Future<void> upsertTransactionFromServer({
    required int serverId,
    required String title,
    required int amount,
    required bool isIncome,
    required String category,
    required String deviceId,
    String? note,
    String? receiptImagePath,
    String? receiptOcrStatus,
    required DateTime transactionDate,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) async {
    final existing = await getTransactionByServerId(serverId);

    if (existing == null) {
      // 새 거래 삽입
      await into(transactions).insert(
        TransactionsCompanion.insert(
          title: title,
          amount: amount,
          isIncome: Value(isIncome),
          category: category,
          note: Value(note),
          transactionDate: Value(transactionDate),
          createdAt: Value(createdAt),
          receiptImagePath: Value(receiptImagePath),
          receiptOcrStatus: Value(receiptOcrStatus ?? ReceiptOcrStatus.none),
          serverId: Value(serverId),
          deviceId: deviceId,
          syncStatus: const Value(SyncStatus.synced),
          syncedAt: Value(DateTime.now()),
          updatedAt: Value(updatedAt),
          deletedAt: Value(deletedAt),
        ),
      );
    } else {
      // LWW: 서버가 더 최신인 경우만 업데이트
      if (updatedAt.isAfter(existing.updatedAt)) {
        await (update(transactions)..where((t) => t.id.equals(existing.id)))
            .write(
          TransactionsCompanion(
            title: Value(title),
            amount: Value(amount),
            isIncome: Value(isIncome),
            category: Value(category),
            note: Value(note),
            transactionDate: Value(transactionDate),
            receiptImagePath: Value(receiptImagePath),
            receiptOcrStatus: Value(receiptOcrStatus ?? ReceiptOcrStatus.none),
            syncStatus: const Value(SyncStatus.synced),
            syncedAt: Value(DateTime.now()),
            updatedAt: Value(updatedAt),
            deletedAt: Value(deletedAt),
          ),
        );
      }
    }
  }

  /// 마지막 동기화 이후 변경된 거래 조회
  Future<List<Transaction>> getTransactionsSince(DateTime since) =>
      (select(transactions)..where((t) => t.updatedAt.isBiggerThanValue(since)))
          .get();

  // ============ Budget Operations ============

  /// 특정 카테고리/월의 예산 조회
  Future<CategoryBudget?> getBudget(String category, int year, int month) =>
      (select(categoryBudgets)
            ..where((b) =>
                b.deletedAt.isNull() &
                b.category.equals(category) &
                b.year.equals(year) &
                b.month.equals(month)))
          .getSingleOrNull();

  /// 특정 월의 모든 예산 조회
  Future<List<CategoryBudget>> getBudgetsByMonth(int year, int month) =>
      (select(categoryBudgets)
            ..where((b) =>
                b.deletedAt.isNull() &
                b.year.equals(year) &
                b.month.equals(month)))
          .get();

  /// 특정 월의 예산 스트림
  Stream<List<CategoryBudget>> watchBudgetsByMonth(int year, int month) =>
      (select(categoryBudgets)
            ..where((b) =>
                b.deletedAt.isNull() &
                b.year.equals(year) &
                b.month.equals(month)))
          .watch();

  /// 예산 추가/업데이트
  Future<int> upsertBudget(CategoryBudgetsCompanion entry) =>
      into(categoryBudgets).insertOnConflictUpdate(entry);

  /// 예산 soft delete
  Future<void> softDeleteBudget(int id) async {
    await (update(categoryBudgets)..where((b) => b.id.equals(id))).write(
      CategoryBudgetsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value(SyncStatus.pending),
      ),
    );
  }

  /// 동기화 대기 중인 예산 조회
  Future<List<CategoryBudget>> getPendingBudgets() => (select(categoryBudgets)
        ..where((b) => b.syncStatus.equals(SyncStatus.pending)))
      .get();

  /// 예산 동기화 상태 업데이트
  Future<void> markBudgetSynced(int localId, int serverId) async {
    await (update(categoryBudgets)..where((b) => b.id.equals(localId))).write(
      CategoryBudgetsCompanion(
        serverId: Value(serverId),
        syncStatus: const Value(SyncStatus.synced),
        syncedAt: Value(DateTime.now()),
      ),
    );
  }

  /// 카테고리별 지출 합계 조회 (특정 월)
  Future<int> getCategorySpentAmount(
      String category, int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final result = await (select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.category.equals(category) &
              t.isIncome.equals(false) &
              t.transactionDate.isBetweenValues(startDate, endDate)))
        .get();

    return result.fold<int>(0, (sum, t) => sum + t.amount);
  }

  /// 예산 대비 지출 정보 조회
  Future<Map<String, dynamic>?> getBudgetWithSpending(
      String category, int year, int month) async {
    final budget = await getBudget(category, year, month);
    if (budget == null) return null;

    final spent = await getCategorySpentAmount(category, year, month);
    final remaining = budget.amount - spent;
    final percentage = budget.amount > 0 ? (spent / budget.amount * 100) : 0.0;

    return {
      'budget': budget,
      'spent': spent,
      'remaining': remaining,
      'percentage': percentage,
    };
  }

  // ============ Category Operations ============

  /// 모든 카테고리 조회
  Future<List<Category>> getAllCategories() => (select(categories)
        ..where((c) => c.deletedAt.isNull())
        ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
      .get();

  /// 카테고리 스트림
  Stream<List<Category>> watchAllCategories() => (select(categories)
        ..where((c) => c.deletedAt.isNull())
        ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
      .watch();

  /// 카테고리 추가
  Future<int> insertCategory(CategoriesCompanion entry) =>
      into(categories).insert(entry);

  /// 카테고리 수정
  Future<bool> updateCategory(Category entry) =>
      update(categories).replace(entry);

  /// 카테고리 soft delete
  Future<void> softDeleteCategory(int id) async {
    await (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value(SyncStatus.pending),
      ),
    );
  }

  // ============ User Settings Operations ============

  /// 사용자 설정 조회
  Future<UserSetting?> getUserSettings() =>
      (select(userSettings)..limit(1)).getSingleOrNull();

  /// 사용자 설정 스트림
  Stream<UserSetting?> watchUserSettings() =>
      (select(userSettings)..limit(1)).watchSingleOrNull();

  /// 사용자 설정 초기화
  Future<int> initializeUserSettings(String deviceId) =>
      into(userSettings).insert(
        UserSettingsCompanion.insert(
          deviceId: deviceId,
          isGuestMode: const Value(true),
        ),
      );

  /// 사용자 설정 업데이트
  Future<bool> updateUserSettings(UserSetting entry) =>
      update(userSettings).replace(entry);

  /// 마지막 동기화 시간 업데이트
  Future<void> updateLastSyncTime([DateTime? time]) async {
    final settings = await getUserSettings();
    if (settings != null) {
      await updateUserSettings(settings.copyWith(
        lastSyncAt: Value(time ?? DateTime.now()),
        updatedAt: DateTime.now(),
      ));
    }
  }

  /// 마지막 동기화 시간 조회
  Future<DateTime?> getLastSyncTime() async {
    final settings = await getUserSettings();
    return settings?.lastSyncAt;
  }

  /// 게스트 모드 해제 (로그인 완료)
  Future<void> setLoggedIn() async {
    final settings = await getUserSettings();
    if (settings != null) {
      await updateUserSettings(settings.copyWith(
        isGuestMode: false,
        updatedAt: DateTime.now(),
      ));
    }
  }

  /// 게스트 모드로 전환 (로그아웃)
  Future<void> setGuestMode() async {
    final settings = await getUserSettings();
    if (settings != null) {
      await updateUserSettings(settings.copyWith(
        isGuestMode: true,
        lastSyncAt: const Value(null),
        updatedAt: DateTime.now(),
      ));
    }
  }

  // ============ Statistics ============

  /// 동기화 대기 건수
  Future<int> getPendingSyncCount() async {
    final transactions = await getPendingTransactions();
    final budgets = await (select(categoryBudgets)
          ..where((b) => b.syncStatus.equals(SyncStatus.pending)))
        .get();
    final cats = await (select(categories)
          ..where((c) => c.syncStatus.equals(SyncStatus.pending)))
        .get();
    return transactions.length + budgets.length + cats.length;
  }

  /// 월별 통계 조회
  Future<Map<String, int>> getMonthlyStats(int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final txns = await (select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.transactionDate.isBetweenValues(startDate, endDate)))
        .get();

    int income = 0;
    int expense = 0;

    for (final t in txns) {
      if (t.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
      'count': txns.length,
    };
  }
}
