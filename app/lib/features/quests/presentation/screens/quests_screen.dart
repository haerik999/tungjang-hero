import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/quest_provider.dart';

class QuestsScreen extends ConsumerStatefulWidget {
  const QuestsScreen({super.key});

  @override
  ConsumerState<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends ConsumerState<QuestsScreen> {
  @override
  void initState() {
    super.initState();
    // 앱 시작시 퀘스트 생성
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(questManagerProvider.notifier).generateDailyQuestsIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('퀘스트'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '일일'),
              Tab(text: '진행중'),
              Tab(text: '완료'),
            ],
            indicatorColor: AppTheme.primaryColor,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textSecondary,
          ),
        ),
        body: TabBarView(
          children: [
            _buildDailyQuests(),
            _buildActiveQuests(),
            _buildCompletedQuests(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyQuests() {
    final questsAsync = ref.watch(dailyQuestsProvider);

    return questsAsync.when(
      data: (quests) {
        if (quests.isEmpty) {
          return _buildEmptyState(
            icon: Icons.wb_sunny,
            title: '오늘의 퀘스트가 없습니다',
            subtitle: '잠시 후 다시 확인해주세요',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: quests.length,
          itemBuilder: (context, index) {
            return _buildQuestCard(quests[index], isDaily: true)
                .animate()
                .fadeIn(delay: Duration(milliseconds: index * 100))
                .slideX(begin: -0.1);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('오류: $e')),
    );
  }

  Widget _buildActiveQuests() {
    final questsAsync = ref.watch(activeQuestsProvider);

    return questsAsync.when(
      data: (quests) {
        // 일일 퀘스트 제외
        final activeQuests = quests.where((q) => q.questType != 'daily').toList();

        if (activeQuests.isEmpty) {
          return _buildEmptyState(
            icon: Icons.flag,
            title: '진행중인 퀘스트가 없습니다',
            subtitle: '일일 퀘스트를 완료하고 도전하세요',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activeQuests.length,
          itemBuilder: (context, index) {
            return _buildQuestCard(activeQuests[index])
                .animate()
                .fadeIn(delay: Duration(milliseconds: index * 100))
                .slideX(begin: -0.1);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('오류: $e')),
    );
  }

  Widget _buildCompletedQuests() {
    final questsAsync = ref.watch(completedQuestsProvider);

    return questsAsync.when(
      data: (quests) {
        if (quests.isEmpty) {
          return _buildEmptyState(
            icon: Icons.emoji_events,
            title: '완료된 퀘스트가 없습니다',
            subtitle: '퀘스트를 완료하고 보상을 받으세요',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: quests.length,
          itemBuilder: (context, index) {
            return _buildQuestCard(quests[index])
                .animate()
                .fadeIn(delay: Duration(milliseconds: index * 100));
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('오류: $e')),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestCard(Quest quest, {bool isDaily = false}) {
    final progress = _calculateProgress(quest);
    final color = quest.isCompleted
        ? AppTheme.accentColor
        : (isDaily ? AppTheme.goldColor : AppTheme.primaryColor);
    final icon = QuestIconHelper.getIcon(quest.title);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              quest.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: quest.isCompleted
                                    ? AppTheme.textSecondary
                                    : AppTheme.textPrimary,
                                decoration: quest.isRewardClaimed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.goldColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '+${quest.rewardXp} XP',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.goldColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quest.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress Bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppTheme.surfaceColor,
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _getProgressText(quest),
                  style: TextStyle(
                    fontSize: 12,
                    color: quest.isCompleted ? color : AppTheme.textSecondary,
                    fontWeight: quest.isCompleted ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.textSecondary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getRemainingTime(quest),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                if (quest.isCompleted && !quest.isRewardClaimed)
                  ElevatedButton(
                    onPressed: () => _claimReward(quest),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('보상 받기'),
                  ),
                if (quest.isRewardClaimed)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check, size: 14, color: AppTheme.accentColor),
                        SizedBox(width: 4),
                        Text(
                          '완료',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateProgress(Quest quest) {
    if (quest.isCompleted) return 1.0;
    if (quest.targetAmount == 0) return 0.0;

    // 지출 제한 퀘스트는 역방향
    if (quest.title.contains('이하 지출') || quest.title.contains('무지출')) {
      // 지출이 목표 이하면 진행중
      if (quest.currentAmount <= quest.targetAmount) {
        return 0.8; // 진행중 표시
      } else {
        return 1.0; // 초과 (실패)
      }
    }

    return (quest.currentAmount / quest.targetAmount).clamp(0.0, 1.0);
  }

  String _getProgressText(Quest quest) {
    if (quest.isCompleted) return '완료!';

    // 지출 제한 퀘스트
    if (quest.title.contains('이하 지출')) {
      final remaining = quest.targetAmount - quest.currentAmount;
      if (remaining >= 0) {
        return '${_formatAmount(remaining)}원 남음';
      } else {
        return '${_formatAmount(-remaining)}원 초과';
      }
    }

    if (quest.title.contains('무지출')) {
      if (quest.currentAmount == 0) {
        return '유지중';
      } else {
        return '${_formatAmount(quest.currentAmount)}원 지출';
      }
    }

    return '${quest.currentAmount} / ${quest.targetAmount}';
  }

  String _formatAmount(int amount) {
    if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(1)}만';
    }
    return amount.toString();
  }

  String _getRemainingTime(Quest quest) {
    if (quest.isRewardClaimed) {
      return '${quest.endDate.month}/${quest.endDate.day} 완료';
    }

    final now = DateTime.now();
    if (now.isAfter(quest.endDate)) return '만료됨';

    final diff = quest.endDate.difference(now);
    if (diff.inDays > 0) return '${diff.inDays}일 남음';
    if (diff.inHours > 0) return '${diff.inHours}시간 남음';
    if (diff.inMinutes > 0) return '${diff.inMinutes}분 남음';
    return '곧 만료';
  }

  Future<void> _claimReward(Quest quest) async {
    final xp = await ref.read(questManagerProvider.notifier).claimReward(quest.id);

    if (xp > 0 && mounted) {
      // XP 획득 이펙트 표시
      GameEffectOverlay.show(
        context,
        GameEffectInfo(
          type: GameEffectType.questComplete,
          value: xp,
          message: '퀘스트 완료!',
        ),
      );

      // 스낵바도 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.star, color: AppTheme.goldColor),
              const SizedBox(width: 8),
              Text('$xp XP를 획득했습니다!'),
            ],
          ),
          backgroundColor: AppTheme.accentColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
