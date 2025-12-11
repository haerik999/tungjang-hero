import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/connectivity_provider.dart';

part 'hero_provider.g.dart';

// ============================================================
// 게임 데이터는 온라인 전용입니다.
// 모든 데이터는 서버에서 관리되며, 클라이언트는 캐싱하지 않습니다.
// 실제 API 연동은 Phase 4에서 구현됩니다.
// ============================================================

/// 히어로 스탯 (서버에서 조회)
class HeroStats {
  final int level;
  final int currentXp;
  final int requiredXp;
  final int currentHp;
  final int maxHp;
  final int totalSaved;
  final int totalSpent;
  final int streak;
  final String title;

  const HeroStats({
    this.level = 1,
    this.currentXp = 0,
    this.requiredXp = 100,
    this.currentHp = 100,
    this.maxHp = 100,
    this.totalSaved = 0,
    this.totalSpent = 0,
    this.streak = 0,
    this.title = '텅장 뉴비',
  });

  double get xpPercentage => requiredXp > 0 ? currentXp / requiredXp : 0;
  double get hpPercentage => maxHp > 0 ? currentHp / maxHp : 1;
}

/// 히어로 스탯 Provider (온라인 전용)
@riverpod
Future<HeroStats?> heroStats(HeroStatsRef ref) async {
  final isOnline = ref.watch(isOnlineProvider);

  if (!isOnline) {
    return null; // 오프라인이면 null 반환
  }

  // TODO: Phase 4에서 실제 서버 API 연동
  // final response = await ref.read(apiClientProvider).getHeroStats();
  // return response;

  // Placeholder: 기본값 반환
  return const HeroStats();
}

/// 게임 접근 가능 여부 Provider
@riverpod
bool canAccessGame(CanAccessGameRef ref) {
  final isOnline = ref.watch(isOnlineProvider);
  // 게임은 온라인 상태에서만 접근 가능
  return isOnline;
}

/// 히어로 칭호 Provider
@riverpod
String heroTitle(HeroTitleRef ref) {
  final heroStatsAsync = ref.watch(heroStatsProvider);

  return heroStatsAsync.when(
    data: (stats) {
      if (stats == null) return '오프라인';

      final level = stats.level;
      if (level >= 50) return '절약의 왕';
      if (level >= 30) return '저축 달인';
      if (level >= 20) return '알뜰 전사';
      if (level >= 10) return '절약 수련생';
      if (level >= 5) return '절약 초보자';
      return '텅장 뉴비';
    },
    loading: () => '로딩중...',
    error: (_, __) => '오류',
  );
}

/// 자동사냥 결과 (서버에서 계산)
class AutoHuntResult {
  final int hoursHunted;
  final int xpGained;
  final int goldGained;
  final List<String> itemsFound;

  const AutoHuntResult({
    this.hoursHunted = 0,
    this.xpGained = 0,
    this.goldGained = 0,
    this.itemsFound = const [],
  });
}

/// 자동사냥 결과 조회 Provider (온라인 전용)
@riverpod
Future<AutoHuntResult?> autoHuntResult(AutoHuntResultRef ref) async {
  final isOnline = ref.watch(isOnlineProvider);

  if (!isOnline) {
    return null;
  }

  // TODO: Phase 4에서 실제 서버 API 연동
  // final response = await ref.read(apiClientProvider).claimAutoHunt();
  // return response;

  // Placeholder: 빈 결과 반환
  return const AutoHuntResult();
}

/// 거래 처리 결과 (동기화 시 서버에서 계산)
class TransactionRewardResult {
  final int xpGained;
  final int goldGained;
  final bool leveledUp;
  final int? newLevel;

  const TransactionRewardResult({
    this.xpGained = 0,
    this.goldGained = 0,
    this.leveledUp = false,
    this.newLevel,
  });
}

/// 보상 지급 요청 (동기화 시 호출)
@riverpod
class RewardManager extends _$RewardManager {
  @override
  FutureOr<void> build() {}

  /// 동기화된 거래에 대한 보상 요청
  /// 서버에서 검증 후 보상 지급
  Future<TransactionRewardResult?> claimTransactionRewards(
      List<int> transactionIds) async {
    final isOnline = ref.read(isOnlineProvider);

    if (!isOnline) {
      return null;
    }

    // TODO: Phase 4에서 실제 서버 API 연동
    // final response = await ref.read(apiClientProvider).claimRewards(transactionIds);
    // return response;

    // Placeholder
    return const TransactionRewardResult();
  }
}

// 하위 호환성을 위한 클래스들 (deprecated, Phase 4 이후 제거 예정)

/// @deprecated 서버 기반으로 전환됨
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

/// @deprecated 서버 기반으로 전환됨
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
