import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/budget_provider.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final List<Map<String, dynamic>> _categories = [
    {'name': '식비', 'icon': Icons.restaurant, 'recommended': 300000},
    {'name': '교통', 'icon': Icons.directions_bus, 'recommended': 100000},
    {'name': '생활', 'icon': Icons.home, 'recommended': 150000},
    {'name': '쇼핑', 'icon': Icons.shopping_bag, 'recommended': 100000},
    {'name': '문화', 'icon': Icons.movie, 'recommended': 50000},
    {'name': '의료', 'icon': Icons.local_hospital, 'recommended': 50000},
    {'name': '교육', 'icon': Icons.school, 'recommended': 100000},
    {'name': '기타', 'icon': Icons.category, 'recommended': 50000},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: const Text(
          '예산 설정',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _showRecommendedBudgetDialog,
            child: const Text(
              '추천 예산',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<BudgetStatus>>(
        future: ref.read(budgetManagerProvider.notifier).getAllBudgetStatuses(),
        builder: (context, snapshot) {
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 이번 달 총 예산 요약
                _buildSummaryCard(snapshot.data ?? [])
                    .animate()
                    .fadeIn()
                    .slideY(begin: -0.1),
                const SizedBox(height: 24),

                // 카테고리별 예산
                const Text(
                  '카테고리별 예산',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ..._categories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  final status = snapshot.data?.firstWhere(
                    (s) => s.budget.category == category['name'],
                    orElse: () => BudgetStatus(
                      budget: _createEmptyBudget(category['name']),
                      spent: 0,
                      remaining: 0,
                      percentage: 0,
                      isOverBudget: false,
                      isWarning: false,
                    ),
                  );

                  return _buildCategoryBudgetCard(
                    category: category,
                    status: status,
                  ).animate(delay: (50 * index).ms).fadeIn().slideX(begin: -0.1);
                }),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(List<BudgetStatus> statuses) {
    final totalBudget = statuses.fold<int>(0, (sum, s) => sum + s.budget.amount);
    final totalSpent = statuses.fold<int>(0, (sum, s) => sum + s.spent);
    final remaining = totalBudget - totalSpent;
    final percentage = totalBudget > 0 ? (totalSpent / totalBudget * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '이번 달 예산',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: percentage > 100
                      ? AppTheme.dangerColor.withValues(alpha: 0.1)
                      : percentage > 80
                          ? Colors.orange.withValues(alpha: 0.1)
                          : AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(0)}% 사용',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: percentage > 100
                        ? AppTheme.dangerColor
                        : percentage > 80
                            ? Colors.orange
                            : AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatAmount(totalBudget),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          // 프로그레스 바
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              backgroundColor: AppTheme.borderColor,
              valueColor: AlwaysStoppedAnimation(
                percentage > 100
                    ? AppTheme.dangerColor
                    : percentage > 80
                        ? Colors.orange
                        : AppTheme.primaryColor,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '지출',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatAmount(totalSpent),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.dangerColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '남은 예산',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatAmount(remaining),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: remaining < 0 ? AppTheme.dangerColor : AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBudgetCard({
    required Map<String, dynamic> category,
    BudgetStatus? status,
  }) {
    final hasBudget = status != null && status.budget.amount > 0;
    final percentage = status?.percentage ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSetBudgetDialog(category),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // 카테고리 아이콘
                    Icon(
                      category['icon'] as IconData,
                      size: 24,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    // 카테고리 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category['name'],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (hasBudget)
                            Text(
                              '${_formatAmount(status!.spent)} / ${_formatAmount(status.budget.amount)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            )
                          else
                            const Text(
                              '예산 미설정',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textTertiary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // 설정/편집 아이콘
                    Icon(
                      hasBudget ? Icons.edit_outlined : Icons.add,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ],
                ),
                if (hasBudget) ...[
                  const SizedBox(height: 12),
                  // 프로그레스 바
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: (percentage / 100).clamp(0.0, 1.0),
                      backgroundColor: AppTheme.borderColor,
                      valueColor: AlwaysStoppedAnimation(
                        percentage > 100
                            ? AppTheme.dangerColor
                            : percentage > 80
                                ? Colors.orange
                                : AppTheme.accentColor,
                      ),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${status!.statusEmoji} ${status.statusText}',
                        style: TextStyle(
                          fontSize: 12,
                          color: status.isOverBudget
                              ? AppTheme.dangerColor
                              : status.isWarning
                                  ? Colors.orange
                                  : AppTheme.accentColor,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSetBudgetDialog(Map<String, dynamic> category) {
    final controller = TextEditingController();
    final recommended = category['recommended'] as int;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 핸들
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 24,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${category['name']} 예산 설정',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: const TextStyle(color: AppTheme.textTertiary),
                  suffixText: '원',
                  suffixStyle: const TextStyle(
                    fontSize: 18,
                    color: AppTheme.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // 빠른 설정 버튼
              Row(
                children: [
                  _buildQuickBudgetButton(controller, 50000),
                  const SizedBox(width: 8),
                  _buildQuickBudgetButton(controller, 100000),
                  const SizedBox(width: 8),
                  _buildQuickBudgetButton(controller, 200000),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.text = recommended.toString();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '추천',
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppTheme.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '취소',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final amount = int.tryParse(controller.text) ?? 0;
                        if (amount > 0) {
                          await ref
                              .read(budgetManagerProvider.notifier)
                              .setBudget(
                                category: category['name'],
                                amount: amount,
                              );
                          Navigator.pop(context);
                          setState(() {});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '저장',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickBudgetButton(TextEditingController controller, int amount) {
    return OutlinedButton(
      onPressed: () {
        controller.text = amount.toString();
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        side: const BorderSide(color: AppTheme.borderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        _formatShortAmount(amount),
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  void _showRecommendedBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '추천 예산 적용',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '추천 예산을 모든 카테고리에 적용할까요?',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            Text(
              '총 ${_formatAmount(_categories.fold<int>(0, (sum, c) => sum + (c['recommended'] as int)))}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '취소',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              for (final category in _categories) {
                await ref.read(budgetManagerProvider.notifier).setBudget(
                      category: category['name'],
                      amount: category['recommended'],
                    );
              }
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('추천 예산이 적용되었습니다'),
                  backgroundColor: AppTheme.accentColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('적용'),
          ),
        ],
      ),
    );
  }

  dynamic _createEmptyBudget(String category) {
    return _EmptyBudget(category);
  }

  String _formatAmount(int amount) {
    return '${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}원';
  }

  String _formatShortAmount(int amount) {
    if (amount >= 10000) {
      return '${amount ~/ 10000}만';
    }
    return '${amount ~/ 1000}천';
  }
}

class _EmptyBudget {
  final String category;
  final int amount = 0;

  _EmptyBudget(this.category);
}
