import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/connectivity_provider.dart';

part 'quest_provider.g.dart';

// ============================================================
// 퀘스트는 게임의 일부로, 온라인 전용입니다.
// 모든 데이터는 서버에서 관리됩니다.
// 실제 API 연동은 Phase 4에서 구현됩니다.
// ============================================================

/// 퀘스트 데이터 (서버에서 조회)
class Quest {
  final int id;
  final String questType; // daily, weekly, challenge
  final String title;
  final String description;
  final int targetAmount;
  final int currentAmount;
  final int rewardXp;
  final bool isCompleted;
  final bool isRewardClaimed;
  final DateTime startDate;
  final DateTime endDate;

  const Quest({
    required this.id,
    required this.questType,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.rewardXp,
    required this.isCompleted,
    required this.isRewardClaimed,
    required this.startDate,
    required this.endDate,
  });

  double get progressPercentage =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  bool get canClaimReward => isCompleted && !isRewardClaimed;
}

/// 일일 퀘스트 Provider (온라인 전용)
@riverpod
Future<List<Quest>> dailyQuests(DailyQuestsRef ref) async {
  final isOnline = ref.watch(isOnlineProvider);

  if (!isOnline) {
    return []; // 오프라인이면 빈 리스트 반환
  }

  // TODO: Phase 4에서 실제 서버 API 연동
  // final response = await ref.read(apiClientProvider).getDailyQuests();
  // return response;

  // Placeholder: 샘플 퀘스트 반환
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

  return [
    Quest(
      id: 1,
      questType: 'daily',
      title: '오늘의 지출 기록하기',
      description: '오늘 발생한 지출을 1건 이상 기록하세요',
      targetAmount: 1,
      currentAmount: 0,
      rewardXp: 10,
      isCompleted: false,
      isRewardClaimed: false,
      startDate: startOfDay,
      endDate: endOfDay,
    ),
    Quest(
      id: 2,
      questType: 'daily',
      title: '3만원 이하 지출',
      description: '오늘 하루 지출을 3만원 이하로 유지하세요',
      targetAmount: 30000,
      currentAmount: 0,
      rewardXp: 20,
      isCompleted: false,
      isRewardClaimed: false,
      startDate: startOfDay,
      endDate: endOfDay,
    ),
    Quest(
      id: 3,
      questType: 'daily',
      title: '거래 3건 기록하기',
      description: '오늘 3건 이상의 거래를 기록하세요',
      targetAmount: 3,
      currentAmount: 0,
      rewardXp: 25,
      isCompleted: false,
      isRewardClaimed: false,
      startDate: startOfDay,
      endDate: endOfDay,
    ),
  ];
}

/// 진행중인 퀘스트 Provider (온라인 전용)
@riverpod
Future<List<Quest>> activeQuests(ActiveQuestsRef ref) async {
  final isOnline = ref.watch(isOnlineProvider);

  if (!isOnline) {
    return [];
  }

  // TODO: Phase 4에서 실제 서버 API 연동
  return [];
}

/// 완료된 퀘스트 Provider (온라인 전용)
@riverpod
Future<List<Quest>> completedQuests(CompletedQuestsRef ref) async {
  final isOnline = ref.watch(isOnlineProvider);

  if (!isOnline) {
    return [];
  }

  // TODO: Phase 4에서 실제 서버 API 연동
  return [];
}

/// 퀘스트 관리자 (온라인 전용)
@riverpod
class QuestManager extends _$QuestManager {
  @override
  FutureOr<void> build() {}

  /// 퀘스트 보상 받기 (서버 API 호출)
  Future<int> claimReward(int questId) async {
    final isOnline = ref.read(isOnlineProvider);

    if (!isOnline) {
      return 0;
    }

    // TODO: Phase 4에서 실제 서버 API 연동
    // final response = await ref.read(apiClientProvider).claimQuestReward(questId);
    // ref.invalidate(dailyQuestsProvider);
    // return response.xpGained;

    // Placeholder
    return 0;
  }
}

/// 퀘스트 아이콘 헬퍼
class QuestIconHelper {
  static IconData getIcon(String title) {
    if (title.contains('기록')) return Icons.edit_note;
    if (title.contains('지출')) return Icons.money_off;
    if (title.contains('수입')) return Icons.payments;
    if (title.contains('무지출')) return Icons.savings;
    if (title.contains('절약')) return Icons.savings;
    return Icons.flag;
  }
}
