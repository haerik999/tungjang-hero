import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../hero/presentation/providers/hero_provider.dart';
import '../../../transactions/presentation/providers/transaction_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('텅장히어로'),
        actions: [
          const NetworkStatusIcon(),
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () => context.go('/achievements'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          const NetworkStatusBanner(),
          Expanded(
            child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(heroStatsProvider);
          ref.invalidate(todayTransactionsProvider);
          ref.invalidate(todayStatsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Summary Card
              _HeroSummaryCard().animate().fadeIn().slideY(begin: -0.1),
              const SizedBox(height: 16),

              // Today's Summary
              _TodaySummaryCard()
                  .animate()
                  .fadeIn(delay: 100.ms)
                  .slideY(begin: -0.1),
              const SizedBox(height: 12),

              // Quick Add Transaction Buttons
              _QuickAddButtons()
                  .animate()
                  .fadeIn(delay: 150.ms),
              const SizedBox(height: 16),

              // Active Quests
              Text(
                '진행중인 퀘스트',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              _ActiveQuestCard()
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .slideX(begin: -0.1),
              const SizedBox(height: 16),

              // Recent Transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '오늘의 거래',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => context.go('/transactions'),
                    child: const Text('전체보기'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _RecentTransactionsList().animate().fadeIn(delay: 300.ms),
            ],
          ),
        ),
      ),
          ),
        ],
      ),
    );
  }
}

class _HeroSummaryCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heroStatsAsync = ref.watch(heroStatsProvider);
    final title = ref.watch(heroTitleProvider);

    return heroStatsAsync.when(
      data: (stats) {
        final level = stats?.level ?? 1;
        final currentXp = stats?.currentXp ?? 0;
        final requiredXp = stats?.requiredXp ?? 100;
        final currentHp = stats?.currentHp ?? 100;
        final maxHp = stats?.maxHp ?? 100;
        final streak = stats?.streak ?? 0;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Hero Avatar - 캐릭터 위젯
                    HeroCharacter.fromHp(
                      hpPercentage: maxHp > 0 ? currentHp / maxHp : 1.0,
                      size: HeroCharacterSize.medium,
                      onTap: () => context.go('/hero'),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Lv. $level',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (streak > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.local_fire_department,
                                    size: 16,
                                    color: AppTheme.primaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$streak일 연속 기록!',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 8),
                          // XP Bar
                          _buildProgressBar(
                            label: 'XP',
                            current: currentXp,
                            max: requiredXp,
                            color: AppTheme.xpBarFill,
                          ),
                          const SizedBox(height: 4),
                          // HP Bar
                          _buildProgressBar(
                            label: 'HP',
                            current: currentHp,
                            max: maxHp,
                            color: currentHp < maxHp * 0.3
                                ? AppTheme.hpBarLow
                                : AppTheme.hpBarFill,
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
      },
      loading: () => const SkeletonHeroCard(),
      error: (e, _) => Card(
        child: AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(heroStatsProvider),
        ),
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required int current,
    required int max,
    required Color color,
  }) {
    final progress = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: AppTheme.xpBarBackground,
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$current/$max',
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _TodaySummaryCard extends ConsumerWidget {
  final _formatter = NumberFormat('#,###', 'ko_KR');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(todayStatsProvider);

    return statsAsync.when(
      data: (stats) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘의 요약',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      '수입',
                      '+${_formatter.format(stats.income)}원',
                      AppTheme.accentColor,
                    ),
                    _buildSummaryItem(
                      '지출',
                      '-${_formatter.format(stats.expense)}원',
                      AppTheme.dangerColor,
                    ),
                    _buildSummaryItem(
                      '잔액',
                      '${stats.balance >= 0 ? '+' : ''}${_formatter.format(stats.balance)}원',
                      stats.balance >= 0
                          ? AppTheme.primaryColor
                          : AppTheme.dangerColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SkeletonSummary(),
      error: (e, _) => Card(
        child: AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(todayStatsProvider),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ActiveQuestCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: 퀘스트 Provider 연결
    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.savings,
            color: AppTheme.primaryColor,
          ),
        ),
        title: const Text(
          '오늘 지출 기록하기',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: 0.0,
              backgroundColor: AppTheme.borderColor,
              valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
            ),
            const SizedBox(height: 4),
            const Text(
              '거래를 추가해서 퀘스트를 완료하세요!',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '+10 XP',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentTransactionsList extends ConsumerWidget {
  final _formatter = NumberFormat('#,###', 'ko_KR');

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '식비':
        return Icons.restaurant;
      case '교통':
        return Icons.directions_bus;
      case '생활':
        return Icons.home;
      case '쇼핑':
        return Icons.shopping_bag;
      case '문화':
        return Icons.movie;
      case '의료':
        return Icons.local_hospital;
      case '교육':
        return Icons.school;
      case '급여':
        return Icons.payments;
      case '용돈':
        return Icons.wallet;
      case '투자':
        return Icons.trending_up;
      case '부업':
        return Icons.work;
      default:
        return Icons.receipt;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(todayTransactionsProvider);

    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 48,
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '오늘 거래가 없습니다',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '거래를 추가해보세요!',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final displayTransactions = transactions.take(5).toList();

        return Card(
          child: Column(
            children: displayTransactions.asMap().entries.map((entry) {
              final index = entry.key;
              final t = entry.value;
              final isLast = index == displayTransactions.length - 1;

              return Column(
                children: [
                  _buildTransactionItem(t),
                  if (!isLast) const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: SkeletonTransactionList(itemCount: 3),
        ),
      ),
      error: (e, _) => Card(
        child: AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(todayTransactionsProvider),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Transaction t) {
    final amountText = t.isIncome
        ? '+${_formatter.format(t.amount)}원'
        : '-${_formatter.format(t.amount)}원';
    // 수입/지출 구분만 색상 사용
    final amountColor = t.isIncome ? AppTheme.accentColor : AppTheme.dangerColor;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getCategoryIcon(t.category),
          color: AppTheme.textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        t.title,
        style: const TextStyle(color: AppTheme.textPrimary),
      ),
      subtitle: Text(
        t.category,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: Text(
        amountText,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: amountColor,
        ),
      ),
    );
  }
}

class _QuickAddButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAddButton(
            label: '지출',
            icon: Icons.remove,
            color: AppTheme.dangerColor,
            onTap: () => context.go('/transactions/add'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickAddButton(
            label: '수입',
            icon: Icons.add,
            color: AppTheme.accentColor,
            onTap: () => context.go('/transactions/add?isIncome=true'),
          ),
        ),
      ],
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                '$label 추가',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
