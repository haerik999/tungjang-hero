import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/constants/app_constants.dart';

part 'hero_provider.g.dart';

/// 히어로 스탯 스트림
@riverpod
Stream<HeroStatsTableData?> heroStats(HeroStatsRef ref) {
  final db = ref.watch(databaseProvider);
  return db.watchHeroStats();
}

/// 히어로 레벨 계산기
class HeroLevelCalculator {
  /// 레벨에 필요한 XP 계산
  static int xpForLevel(int level) {
    return (AppConstants.baseXpPerLevel *
            (level * AppConstants.xpMultiplier))
        .round();
  }

  /// 레벨에 따른 최대 HP
  static int maxHpForLevel(int level) {
    return 100 + ((level - 1) * 10);
  }

  /// 저축 금액에 따른 XP (수입 기록)
  static int xpFromSaving(int amount) {
    return (amount / 1000 * AppConstants.savingXpMultiplier).round();
  }

  /// 기록 보상 XP (모든 거래 기록시)
  static int xpFromRecording(int amount) {
    // 기본 5 XP + 금액에 따른 추가 XP
    return 5 + (amount / 10000).round().clamp(0, 10);
  }

  /// 예산 내 지출 보너스 XP
  static int xpFromBudgetCompliance(int amount, double budgetRemaining) {
    if (budgetRemaining < 0) return 0; // 예산 초과시 보너스 없음
    // 예산 내 지출 = 2 XP
    return 2;
  }

  /// 예산 초과 데미지 계산
  static int damageFromOverBudget(int overAmount, int skillLevel) {
    // 기본 데미지: 초과금액 1000원당 5 데미지
    final baseDamage = (overAmount / 1000 * 5).round();
    // 스킬 레벨에 따른 감소 (레벨당 10% 감소)
    final reduction = 1 - (skillLevel * 0.1);
    return (baseDamage * reduction).round().clamp(1, 100);
  }

  /// 예산 절약 HP 회복량
  static int healFromSaving(int savedAmount, int skillLevel) {
    // 기본 회복: 절약금액 10000원당 5 HP
    final baseHeal = (savedAmount / 10000 * 5).round();
    // 스킬 레벨에 따른 증가 (레벨당 20% 증가)
    final bonus = 1 + (skillLevel * 0.2);
    return (baseHeal * bonus).round().clamp(0, 50);
  }

  /// 지출 금액에 따른 데미지 (구버전 - 예산 없을 때 사용)
  static int damageFromSpending(int amount) {
    return (amount / 1000 * AppConstants.overspendingDamageMultiplier).round();
  }
}

/// 히어로 관리 (레벨업, XP, HP 관리)
@riverpod
class HeroManager extends _$HeroManager {
  @override
  FutureOr<void> build() {}

  /// 거래 처리 (예산 기반 XP/HP 시스템)
  Future<TransactionResult> processTransaction({
    required int amount,
    required bool isIncome,
    required String category,
  }) async {
    final db = ref.read(databaseProvider);
    var heroStats = await db.getHeroStats();

    if (heroStats == null) {
      await db.initializeHeroIfNeeded();
      heroStats = await db.getHeroStats();
    }

    if (heroStats == null) {
      return TransactionResult(xpGained: 0, hpChange: 0);
    }

    int totalXp = 0;
    int hpChange = 0;
    LevelUpResult? levelUpResult;
    bool isOverBudget = false;

    // 1. 기록 보상 XP (모든 거래에 적용)
    final recordXp = HeroLevelCalculator.xpFromRecording(amount);
    totalXp += recordXp;

    if (isIncome) {
      // 수입 = 추가 XP 획득
      final savingXp = HeroLevelCalculator.xpFromSaving(amount);
      totalXp += savingXp;
    } else {
      // 지출 = 예산 체크 후 처리
      final now = DateTime.now();
      final budget = await db.getBudget(category, now.year, now.month);

      if (budget != null) {
        // 예산이 설정된 경우
        final spent = await db.getCategorySpentAmount(category, now.year, now.month);
        final remaining = budget.amount - spent;

        if (remaining >= amount) {
          // 예산 내 지출 = 보너스 XP
          totalXp += HeroLevelCalculator.xpFromBudgetCompliance(amount, remaining.toDouble());
        } else {
          // 예산 초과 = 데미지
          isOverBudget = true;
          final overAmount = amount - remaining.clamp(0, amount);
          final skill = await db.getSkillById('budget_shield');
          final skillLevel = skill?.isUnlocked == true ? skill!.level : 0;
          final damage = HeroLevelCalculator.damageFromOverBudget(overAmount, skillLevel);
          hpChange = -damage;
        }
      } else {
        // 예산 미설정 = 기록 XP만 (데미지 없음)
        // 사용자가 예산을 설정하도록 유도
      }
    }

    // XP 적용
    if (totalXp > 0) {
      levelUpResult = await _addXp(heroStats, totalXp);
    }

    // HP 변동 적용
    if (hpChange != 0) {
      heroStats = (await db.getHeroStats())!;
      if (hpChange < 0) {
        await _takeDamage(heroStats, -hpChange);
      } else {
        await _healHp(heroStats, hpChange);
      }
    }

    // 스트릭 업데이트
    heroStats = (await db.getHeroStats())!;
    await _updateStreak(heroStats);

    ref.invalidate(heroStatsProvider);

    return TransactionResult(
      xpGained: totalXp,
      hpChange: hpChange,
      levelUpResult: levelUpResult,
      isOverBudget: isOverBudget,
    );
  }

  /// 구버전 거래 처리 (하위 호환용)
  Future<LevelUpResult?> processTransactionLegacy({
    required int amount,
    required bool isIncome,
  }) async {
    final db = ref.read(databaseProvider);
    var heroStats = await db.getHeroStats();

    if (heroStats == null) {
      await db.initializeHeroIfNeeded();
      heroStats = await db.getHeroStats();
    }

    if (heroStats == null) return null;

    LevelUpResult? result;

    if (isIncome) {
      final xpGained = HeroLevelCalculator.xpFromSaving(amount);
      result = await _addXp(heroStats, xpGained);
    } else {
      final damage = HeroLevelCalculator.damageFromSpending(amount);
      await _takeDamage(heroStats, damage);
    }

    await _updateStreak(heroStats);

    ref.invalidate(heroStatsProvider);
    return result;
  }

  /// XP 추가 및 레벨업 처리
  Future<LevelUpResult?> _addXp(HeroStatsTableData stats, int xpAmount) async {
    final db = ref.read(databaseProvider);

    int newXp = stats.currentXp + xpAmount;
    int newLevel = stats.level;
    int newRequiredXp = stats.requiredXp;
    int newMaxHp = stats.maxHp;
    int newCurrentHp = stats.currentHp;
    bool leveledUp = false;

    // 레벨업 체크
    while (newXp >= newRequiredXp && newLevel < AppConstants.maxLevel) {
      newXp -= newRequiredXp;
      newLevel++;
      newRequiredXp = HeroLevelCalculator.xpForLevel(newLevel);
      newMaxHp = HeroLevelCalculator.maxHpForLevel(newLevel);
      newCurrentHp = newMaxHp; // 레벨업시 HP 풀 회복
      leveledUp = true;
    }

    await db.updateHeroStats(
      stats.copyWith(
        currentXp: newXp,
        level: newLevel,
        requiredXp: newRequiredXp,
        maxHp: newMaxHp,
        currentHp: newCurrentHp,
        totalSaved: stats.totalSaved + (xpAmount * 100), // XP * 100 = 저축액
        lastUpdated: DateTime.now(),
      ),
    );

    if (leveledUp) {
      return LevelUpResult(
        oldLevel: stats.level,
        newLevel: newLevel,
        xpGained: xpAmount,
      );
    }
    return null;
  }

  /// 데미지 처리
  Future<void> _takeDamage(HeroStatsTableData stats, int damage) async {
    final db = ref.read(databaseProvider);

    int newHp = (stats.currentHp - damage).clamp(0, stats.maxHp);

    // HP가 0이 되면 레벨 다운 (최소 1레벨)
    int newLevel = stats.level;
    int newMaxHp = stats.maxHp;
    int newRequiredXp = stats.requiredXp;

    if (newHp <= 0 && stats.level > 1) {
      newLevel = stats.level - 1;
      newMaxHp = HeroLevelCalculator.maxHpForLevel(newLevel);
      newRequiredXp = HeroLevelCalculator.xpForLevel(newLevel);
      newHp = newMaxHp ~/ 2; // 레벨 다운시 HP 50%로 부활
    }

    await db.updateHeroStats(
      stats.copyWith(
        currentHp: newHp,
        level: newLevel,
        maxHp: newMaxHp,
        requiredXp: newRequiredXp,
        totalSpent: stats.totalSpent + (damage * 200), // 데미지 * 200 = 지출액
        lastUpdated: DateTime.now(),
      ),
    );
  }

  /// 연속 기록 업데이트
  Future<void> _updateStreak(HeroStatsTableData stats) async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int newStreak = stats.streak;
    final lastDate = stats.lastRecordDate;

    if (lastDate == null) {
      newStreak = 1;
    } else {
      final lastRecordDay = DateTime(
        lastDate.year,
        lastDate.month,
        lastDate.day,
      );
      final difference = today.difference(lastRecordDay).inDays;

      if (difference == 1) {
        // 어제 기록함 -> 연속 +1
        newStreak = stats.streak + 1;
      } else if (difference > 1) {
        // 하루 이상 놓침 -> 리셋
        newStreak = 1;
      }
      // difference == 0 이면 오늘 이미 기록함 -> 유지
    }

    if (newStreak != stats.streak || stats.lastRecordDate == null) {
      await db.updateHeroStats(
        stats.copyWith(
          streak: newStreak,
          lastRecordDate: Value(today),
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  /// HP 회복 (일일 회복 등) - 공개용
  Future<void> healHp(int amount) async {
    final db = ref.read(databaseProvider);
    final stats = await db.getHeroStats();
    if (stats == null) return;

    await _healHp(stats, amount);
    ref.invalidate(heroStatsProvider);
  }

  /// HP 회복 - 내부용
  Future<void> _healHp(HeroStatsTableData stats, int amount) async {
    final db = ref.read(databaseProvider);
    final newHp = (stats.currentHp + amount).clamp(0, stats.maxHp);
    await db.updateHeroStats(
      stats.copyWith(
        currentHp: newHp,
        lastUpdated: DateTime.now(),
      ),
    );
  }

  /// 보너스 XP 추가
  Future<LevelUpResult?> addBonusXp(int xpAmount) async {
    final db = ref.read(databaseProvider);
    final stats = await db.getHeroStats();
    if (stats == null) return null;

    final result = await _addXp(stats, xpAmount);
    ref.invalidate(heroStatsProvider);
    return result;
  }
}

/// 레벨업 결과
class LevelUpResult {
  final int oldLevel;
  final int newLevel;
  final int xpGained;

  LevelUpResult({
    required this.oldLevel,
    required this.newLevel,
    required this.xpGained,
  });

  int get levelsGained => newLevel - oldLevel;
}

/// 거래 처리 결과 (새 시스템)
class TransactionResult {
  final int xpGained;
  final int hpChange;
  final LevelUpResult? levelUpResult;
  final bool isOverBudget;

  TransactionResult({
    required this.xpGained,
    required this.hpChange,
    this.levelUpResult,
    this.isOverBudget = false,
  });

  bool get hasLevelUp => levelUpResult != null;
  bool get hasDamage => hpChange < 0;
  bool get hasHeal => hpChange > 0;
}

/// 히어로 칭호 계산
@riverpod
String heroTitle(HeroTitleRef ref) {
  final heroStatsAsync = ref.watch(heroStatsProvider);

  return heroStatsAsync.when(
    data: (stats) {
      if (stats == null) return '텅장 뉴비';
      final level = stats.level;

      if (level >= 50) return '절약의 왕';
      if (level >= 30) return '저축 달인';
      if (level >= 20) return '알뜰 전사';
      if (level >= 10) return '절약 수련생';
      if (level >= 5) return '절약 초보자';
      return '텅장 뉴비';
    },
    loading: () => '로딩중...',
    error: (_, __) => '???',
  );
}
