import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

part 'app_database.g.dart';

// Sync status enum values
class SyncStatus {
  static const String pending = 'pending';
  static const String synced = 'synced';
  static const String conflict = 'conflict';
}

// Transaction table
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  IntColumn get amount => integer()();
  BoolColumn get isIncome => boolean().withDefault(const Constant(false))();
  TextColumn get category => text().withLength(min: 1, max: 50)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  // Sync fields
  IntColumn get serverId => integer().nullable()(); // Server ID
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))(); // pending, synced, conflict
  DateTimeColumn get syncedAt => dateTime().nullable()(); // Last sync time
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)(); // Last update time (for conflict resolution)
}

// Category Budget table (카테고리별 월예산)
class CategoryBudgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text().withLength(min: 1, max: 50)();
  IntColumn get amount => integer()(); // 예산 금액
  IntColumn get year => integer()();
  IntColumn get month => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Skill table (스킬 시스템)
class Skills extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get skillId => text().unique()(); // 스킬 고유 ID
  TextColumn get name => text()();
  TextColumn get description => text()();
  IntColumn get level => integer().withDefault(const Constant(1))();
  IntColumn get maxLevel => integer().withDefault(const Constant(5))();
  IntColumn get currentXp => integer().withDefault(const Constant(0))();
  IntColumn get requiredXp => integer().withDefault(const Constant(100))();
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get unlockedAt => dateTime().nullable()();
}

// Hero stats table
class HeroStatsTable extends Table {
  @override
  String get tableName => 'hero_stats';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get level => integer().withDefault(const Constant(1))();
  IntColumn get currentXp => integer().withDefault(const Constant(0))();
  IntColumn get requiredXp => integer().withDefault(const Constant(100))();
  IntColumn get currentHp => integer().withDefault(const Constant(100))();
  IntColumn get maxHp => integer().withDefault(const Constant(100))();
  IntColumn get totalSaved => integer().withDefault(const Constant(0))();
  IntColumn get totalSpent => integer().withDefault(const Constant(0))();
  IntColumn get streak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastRecordDate => dateTime().nullable()();
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();
}

// Quest table
class Quests extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get questType => text().withDefault(const Constant('daily'))(); // daily, weekly, challenge
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get description => text()();
  IntColumn get targetAmount => integer()();
  IntColumn get currentAmount => integer().withDefault(const Constant(0))();
  IntColumn get rewardXp => integer()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isRewardClaimed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
}

// Achievement table
class Achievements extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get achievementId => text().unique()();
  TextColumn get category => text()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get description => text()();
  TextColumn get emoji => text()();
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get unlockedAt => dateTime().nullable()();
}

@DriftDatabase(tables: [Transactions, HeroStatsTable, Quests, Achievements, CategoryBudgets, Skills])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(categoryBudgets);
            await m.createTable(skills);
          }
          if (from < 3) {
            // Add sync columns to transactions table
            await m.addColumn(transactions, transactions.serverId);
            await m.addColumn(transactions, transactions.syncStatus);
            await m.addColumn(transactions, transactions.syncedAt);
            await m.addColumn(transactions, transactions.updatedAt);
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
            debugPrint('Using ${result.chosenImplementation} due to missing browser features: ${result.missingFeatures}');
          }
        },
      ),
    );
  }

  // ============ Transaction Operations ============

  Future<List<Transaction>> getAllTransactions() => select(transactions).get();

  Stream<List<Transaction>> watchAllTransactions() =>
      (select(transactions)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Stream<List<Transaction>> watchTransactionsByMonth(int year, int month) {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    return (select(transactions)
          ..where((t) => t.createdAt.isBetweenValues(startDate, endDate))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Stream<List<Transaction>> watchTodayTransactions() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return (select(transactions)
          ..where((t) => t.createdAt.isBetweenValues(startOfDay, endOfDay))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<int> insertTransaction(TransactionsCompanion entry) =>
      into(transactions).insert(entry);

  Future<bool> updateTransaction(Transaction entry) =>
      update(transactions).replace(entry);

  Future<int> deleteTransaction(int id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();

  // ============ Sync Operations ============

  /// 동기화 대기 중인 거래 조회
  Future<List<Transaction>> getPendingTransactions() =>
      (select(transactions)
            ..where((t) => t.syncStatus.equals(SyncStatus.pending)))
          .get();

  /// 충돌 상태인 거래 조회
  Future<List<Transaction>> getConflictTransactions() =>
      (select(transactions)
            ..where((t) => t.syncStatus.equals(SyncStatus.conflict)))
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

  /// 거래 충돌 상태로 표시
  Future<void> markTransactionConflict(int localId) async {
    await (update(transactions)..where((t) => t.id.equals(localId))).write(
      const TransactionsCompanion(
        syncStatus: Value(SyncStatus.conflict),
      ),
    );
  }

  /// 서버 ID로 거래 조회
  Future<Transaction?> getTransactionByServerId(int serverId) =>
      (select(transactions)..where((t) => t.serverId.equals(serverId)))
          .getSingleOrNull();

  /// 서버 데이터로 거래 upsert (동기화용)
  Future<void> upsertTransactionFromServer({
    required int serverId,
    required String title,
    required int amount,
    required bool isIncome,
    required String category,
    String? note,
    required DateTime createdAt,
    required DateTime updatedAt,
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
          createdAt: Value(createdAt),
          serverId: Value(serverId),
          syncStatus: const Value(SyncStatus.synced),
          syncedAt: Value(DateTime.now()),
          updatedAt: Value(updatedAt),
        ),
      );
    } else {
      // 기존 거래 업데이트 (서버가 더 최신인 경우만)
      if (updatedAt.isAfter(existing.updatedAt)) {
        await (update(transactions)..where((t) => t.id.equals(existing.id))).write(
          TransactionsCompanion(
            title: Value(title),
            amount: Value(amount),
            isIncome: Value(isIncome),
            category: Value(category),
            note: Value(note),
            syncStatus: const Value(SyncStatus.synced),
            syncedAt: Value(DateTime.now()),
            updatedAt: Value(updatedAt),
          ),
        );
      }
    }
  }

  // ============ Hero Stats Operations ============

  Future<HeroStatsTableData?> getHeroStats() =>
      (select(heroStatsTable)..limit(1)).getSingleOrNull();

  Stream<HeroStatsTableData?> watchHeroStats() =>
      (select(heroStatsTable)..limit(1)).watchSingleOrNull();

  Future<int> insertHeroStats(HeroStatsTableCompanion entry) =>
      into(heroStatsTable).insert(entry);

  Future<bool> updateHeroStats(HeroStatsTableData entry) =>
      update(heroStatsTable).replace(entry);

  Future<void> initializeHeroIfNeeded() async {
    final existing = await getHeroStats();
    if (existing == null) {
      await insertHeroStats(const HeroStatsTableCompanion());
    }
  }

  // ============ Quest Operations ============

  Stream<List<Quest>> watchActiveQuests() => (select(quests)
        ..where((q) => q.isCompleted.equals(false))
        ..orderBy([(q) => OrderingTerm.asc(q.endDate)]))
      .watch();

  Stream<List<Quest>> watchDailyQuests() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return (select(quests)
          ..where((q) =>
              q.questType.equals('daily') &
              q.startDate.isBiggerOrEqualValue(startOfDay) &
              q.endDate.isSmallerOrEqualValue(endOfDay)))
        .watch();
  }

  Stream<List<Quest>> watchCompletedQuests() => (select(quests)
        ..where((q) => q.isCompleted.equals(true))
        ..orderBy([(q) => OrderingTerm.desc(q.endDate)]))
      .watch();

  Future<int> insertQuest(QuestsCompanion entry) => into(quests).insert(entry);

  Future<bool> updateQuest(Quest entry) => update(quests).replace(entry);

  // ============ Achievement Operations ============

  Stream<List<Achievement>> watchAllAchievements() =>
      select(achievements).watch();

  Stream<List<Achievement>> watchUnlockedAchievements() =>
      (select(achievements)..where((a) => a.isUnlocked.equals(true))).watch();

  Future<int> insertAchievement(AchievementsCompanion entry) =>
      into(achievements).insert(entry);

  Future<bool> updateAchievement(Achievement entry) =>
      update(achievements).replace(entry);

  Future<Achievement?> getAchievementById(String achievementId) =>
      (select(achievements)..where((a) => a.achievementId.equals(achievementId)))
          .getSingleOrNull();

  // ============ Budget Operations ============

  /// 특정 카테고리/월의 예산 조회
  Future<CategoryBudget?> getBudget(String category, int year, int month) =>
      (select(categoryBudgets)
            ..where((b) =>
                b.category.equals(category) &
                b.year.equals(year) &
                b.month.equals(month)))
          .getSingleOrNull();

  /// 특정 월의 모든 예산 조회
  Future<List<CategoryBudget>> getBudgetsByMonth(int year, int month) =>
      (select(categoryBudgets)
            ..where((b) => b.year.equals(year) & b.month.equals(month)))
          .get();

  /// 특정 월의 예산 스트림
  Stream<List<CategoryBudget>> watchBudgetsByMonth(int year, int month) =>
      (select(categoryBudgets)
            ..where((b) => b.year.equals(year) & b.month.equals(month)))
          .watch();

  /// 예산 추가/업데이트
  Future<int> upsertBudget(CategoryBudgetsCompanion entry) =>
      into(categoryBudgets).insertOnConflictUpdate(entry);

  /// 예산 삭제
  Future<int> deleteBudget(int id) =>
      (delete(categoryBudgets)..where((b) => b.id.equals(id))).go();

  /// 카테고리별 지출 합계 조회 (특정 월)
  Future<int> getCategorySpentAmount(String category, int year, int month) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final result = await (select(transactions)
          ..where((t) =>
              t.category.equals(category) &
              t.isIncome.equals(false) &
              t.createdAt.isBetweenValues(startDate, endDate)))
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

  // ============ Skill Operations ============

  /// 모든 스킬 조회
  Stream<List<Skill>> watchAllSkills() => select(skills).watch();

  /// 해금된 스킬만 조회
  Stream<List<Skill>> watchUnlockedSkills() =>
      (select(skills)..where((s) => s.isUnlocked.equals(true))).watch();

  /// 특정 스킬 조회
  Future<Skill?> getSkillById(String skillId) =>
      (select(skills)..where((s) => s.skillId.equals(skillId))).getSingleOrNull();

  /// 스킬 추가
  Future<int> insertSkill(SkillsCompanion entry) => into(skills).insert(entry);

  /// 스킬 업데이트
  Future<bool> updateSkill(Skill entry) => update(skills).replace(entry);

  /// 스킬 해금
  Future<void> unlockSkill(String skillId) async {
    final skill = await getSkillById(skillId);
    if (skill != null && !skill.isUnlocked) {
      await updateSkill(skill.copyWith(
        isUnlocked: true,
        unlockedAt: Value(DateTime.now()),
      ));
    }
  }

  /// 스킬 레벨업
  Future<void> levelUpSkill(String skillId) async {
    final skill = await getSkillById(skillId);
    if (skill != null && skill.level < skill.maxLevel) {
      await updateSkill(skill.copyWith(
        level: skill.level + 1,
        currentXp: 0,
        requiredXp: (skill.requiredXp * 1.5).round(),
      ));
    }
  }

  /// 기본 스킬 초기화
  Future<void> initializeSkillsIfNeeded() async {
    final existingSkills = await select(skills).get();
    if (existingSkills.isEmpty) {
      final defaultSkills = [
        SkillsCompanion.insert(
          skillId: 'budget_shield',
          name: '예산 방패',
          description: '예산 초과 데미지 감소',
          level: const Value(1),
          maxLevel: const Value(5),
          isUnlocked: const Value(true),
        ),
        SkillsCompanion.insert(
          skillId: 'saving_heal',
          name: '절약 회복',
          description: '예산 절약시 HP 회복 증가',
          level: const Value(1),
          maxLevel: const Value(5),
          isUnlocked: const Value(false),
        ),
        SkillsCompanion.insert(
          skillId: 'xp_boost',
          name: '경험 부스트',
          description: '모든 XP 획득량 증가',
          level: const Value(1),
          maxLevel: const Value(5),
          isUnlocked: const Value(false),
        ),
        SkillsCompanion.insert(
          skillId: 'streak_bonus',
          name: '연속 보너스',
          description: '연속 기록 보너스 증가',
          level: const Value(1),
          maxLevel: const Value(5),
          isUnlocked: const Value(false),
        ),
        SkillsCompanion.insert(
          skillId: 'record_master',
          name: '기록의 달인',
          description: '거래 기록시 추가 XP 획득',
          level: const Value(1),
          maxLevel: const Value(5),
          isUnlocked: const Value(true),
        ),
      ];

      for (final skill in defaultSkills) {
        await insertSkill(skill);
      }
    }
  }
}
