import 'dart:math' show Random;

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../hero/presentation/providers/hero_provider.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';

part 'quest_provider.g.dart';

/// 오늘의 일일 퀘스트 스트림
@riverpod
Stream<List<Quest>> dailyQuests(DailyQuestsRef ref) {
  final db = ref.watch(databaseProvider);
  return db.watchDailyQuests();
}

/// 진행중인 퀘스트 스트림
@riverpod
Stream<List<Quest>> activeQuests(ActiveQuestsRef ref) {
  final db = ref.watch(databaseProvider);
  return db.watchActiveQuests();
}

/// 완료된 퀘스트 스트림
@riverpod
Stream<List<Quest>> completedQuests(CompletedQuestsRef ref) {
  final db = ref.watch(databaseProvider);
  return db.watchCompletedQuests();
}

/// 퀘스트 관리자
@riverpod
class QuestManager extends _$QuestManager {
  @override
  FutureOr<void> build() async {
    // 앱 시작시 오늘의 퀘스트 생성
    await generateDailyQuestsIfNeeded();
  }

  /// 오늘의 일일 퀘스트 생성 (아직 없는 경우)
  Future<void> generateDailyQuestsIfNeeded() async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    // 오늘 퀘스트가 이미 있는지 확인
    final existingQuests = await db.watchDailyQuests().first;
    if (existingQuests.isNotEmpty) return;

    // 오늘의 퀘스트 3개 생성
    final templates = DailyQuestTemplates.getTodaysQuests();
    for (final template in templates) {
      await db.insertQuest(QuestsCompanion(
        questType: const Value('daily'),
        title: Value(template.title),
        description: Value(template.description),
        targetAmount: Value(template.targetAmount),
        currentAmount: const Value(0),
        rewardXp: Value(template.rewardXp),
        isCompleted: const Value(false),
        isRewardClaimed: const Value(false),
        startDate: Value(startOfDay),
        endDate: Value(endOfDay),
      ));
    }

    ref.invalidateSelf();
  }

  /// 퀘스트 진행도 업데이트 (거래 추가시 호출)
  Future<void> updateQuestProgress({
    required int amount,
    required bool isIncome,
  }) async {
    final db = ref.read(databaseProvider);
    final dailyQuests = await db.watchDailyQuests().first;

    for (final quest in dailyQuests) {
      if (quest.isCompleted) continue;

      bool shouldUpdate = false;
      int newAmount = quest.currentAmount;
      bool isCompleted = false;

      // 퀘스트 타입에 따라 처리
      if (quest.title.contains('기록하기')) {
        // 기록 퀘스트 - 거래 횟수
        newAmount = quest.currentAmount + 1;
        shouldUpdate = true;
      } else if (quest.title.contains('수입 기록')) {
        // 수입 기록 퀘스트
        if (isIncome) {
          newAmount = quest.currentAmount + 1;
          shouldUpdate = true;
        }
      } else if (quest.title.contains('이하 지출') || quest.title.contains('무지출')) {
        // 지출 제한 퀘스트 - 오늘 총 지출 계산
        if (!isIncome) {
          final todayStats = await ref.read(todayStatsProvider.future);
          newAmount = todayStats.expense;
          shouldUpdate = true;
        }
      }

      if (shouldUpdate) {
        // 완료 조건 체크
        if (quest.title.contains('이하 지출')) {
          // 역방향 퀘스트: 목표 이하면 완료 (자정에 체크)
          // 현재는 진행도만 업데이트
        } else if (quest.title.contains('무지출')) {
          // 무지출은 하루 동안 지출 0 유지해야 함 (자정에 체크)
        } else {
          // 일반 퀘스트: 목표 달성시 완료
          isCompleted = newAmount >= quest.targetAmount;
        }

        await db.updateQuest(quest.copyWith(
          currentAmount: newAmount,
          isCompleted: isCompleted,
        ));
      }
    }

    ref.invalidate(dailyQuestsProvider);
    ref.invalidate(activeQuestsProvider);
  }

  /// 퀘스트 보상 받기
  Future<int> claimReward(int questId) async {
    final db = ref.read(databaseProvider);

    // 퀘스트 조회
    final quests = await db.watchActiveQuests().first;
    final quest = quests.where((q) => q.id == questId).firstOrNull;

    if (quest == null || !quest.isCompleted || quest.isRewardClaimed) {
      return 0;
    }

    // 보상 처리
    await db.updateQuest(quest.copyWith(
      isRewardClaimed: true,
    ));

    // XP 지급
    await ref.read(heroManagerProvider.notifier).addBonusXp(quest.rewardXp);

    ref.invalidate(dailyQuestsProvider);
    ref.invalidate(activeQuestsProvider);
    ref.invalidate(completedQuestsProvider);

    return quest.rewardXp;
  }

  /// 자정에 지출 제한 퀘스트 완료 처리 (앱 시작시 호출)
  Future<void> checkLimitQuests() async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now();

    // 어제 날짜의 지출 제한 퀘스트 확인
    final yesterday = now.subtract(const Duration(days: 1));
    final startOfYesterday = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final endOfYesterday = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);

    // 어제의 퀘스트 조회 (직접 쿼리)
    final yesterdayQuests = await (db.select(db.quests)
          ..where((q) =>
              q.questType.equals('daily') &
              q.startDate.isBiggerOrEqualValue(startOfYesterday) &
              q.endDate.isSmallerOrEqualValue(endOfYesterday) &
              q.isCompleted.equals(false)))
        .get();

    for (final quest in yesterdayQuests) {
      if (quest.title.contains('이하 지출')) {
        // 지출이 목표 이하면 완료
        if (quest.currentAmount <= quest.targetAmount) {
          await db.updateQuest(quest.copyWith(isCompleted: true));
        }
      } else if (quest.title.contains('무지출')) {
        // 지출이 0이면 완료
        if (quest.currentAmount == 0) {
          await db.updateQuest(quest.copyWith(isCompleted: true));
        }
      }
    }
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

/// 일일 퀘스트 템플릿
class DailyQuestTemplates {
  static List<QuestTemplate> get templates => [
    QuestTemplate(
      id: 'record_today',
      title: '오늘의 지출 기록하기',
      description: '오늘 발생한 지출을 1건 이상 기록하세요',
      targetAmount: 1,
      rewardXp: 10,
    ),
    QuestTemplate(
      id: 'limit_30k',
      title: '3만원 이하 지출',
      description: '오늘 하루 지출을 3만원 이하로 유지하세요',
      targetAmount: 30000,
      rewardXp: 20,
      isInverse: true,
    ),
    QuestTemplate(
      id: 'record_income',
      title: '수입 기록하기',
      description: '오늘 발생한 수입을 기록하세요',
      targetAmount: 1,
      rewardXp: 15,
    ),
    QuestTemplate(
      id: 'limit_10k',
      title: '1만원 이하 지출',
      description: '오늘 하루 지출을 1만원 이하로 유지하세요',
      targetAmount: 10000,
      rewardXp: 30,
      isInverse: true,
    ),
    QuestTemplate(
      id: 'no_expense',
      title: '무지출 챌린지',
      description: '오늘 하루 지출 없이 보내세요',
      targetAmount: 0,
      rewardXp: 50,
      isInverse: true,
    ),
    QuestTemplate(
      id: 'record_3',
      title: '거래 3건 기록하기',
      description: '오늘 3건 이상의 거래를 기록하세요',
      targetAmount: 3,
      rewardXp: 25,
    ),
  ];

  /// 오늘의 퀘스트 3개 선택 (매일 다르게)
  static List<QuestTemplate> getTodaysQuests() {
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final shuffled = List<QuestTemplate>.from(templates);
    shuffled.shuffle(Random(seed));
    return shuffled.take(3).toList();
  }
}

/// 퀘스트 템플릿
class QuestTemplate {
  final String id;
  final String title;
  final String description;
  final int targetAmount;
  final int rewardXp;
  final bool isInverse;

  const QuestTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.rewardXp,
    this.isInverse = false,
  });
}
