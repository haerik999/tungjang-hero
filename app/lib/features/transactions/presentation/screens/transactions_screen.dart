import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('가계부'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              // Show calendar picker
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Summary
          _buildMonthSummary().animate().fadeIn().slideY(begin: -0.1),

          // Quick Add Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildQuickAddButtons(context),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 8),

          // Transactions List
          Expanded(
            child: _buildTransactionsList().animate().fadeIn(delay: 200.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          const Text(
            '2024년 12월',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryColumn('수입', '+1,500,000원', AppTheme.accentColor),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.borderColor,
              ),
              _buildSummaryColumn('지출', '-850,000원', AppTheme.dangerColor),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.borderColor,
              ),
              _buildSummaryColumn('잔액', '+650,000원', AppTheme.primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryColumn(String label, String value, Color color) {
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
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    final transactions = [
      _TransactionGroup(
        date: '오늘',
        items: [
          _TransactionItem('커피', '식비', -4500, Icons.local_cafe),
          _TransactionItem('점심', '식비', -8000, Icons.restaurant),
        ],
      ),
      _TransactionGroup(
        date: '어제',
        items: [
          _TransactionItem('월급', '수입', 3000000, Icons.payments),
          _TransactionItem('쇼핑', '생활', -55000, Icons.shopping_bag),
          _TransactionItem('지하철', '교통', -1500, Icons.train),
        ],
      ),
      _TransactionGroup(
        date: '12월 5일',
        items: [
          _TransactionItem('마트', '식비', -42000, Icons.shopping_cart),
          _TransactionItem('통신비', '고정', -55000, Icons.phone_android),
        ],
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final group = transactions[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                group.date,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            Card(
              child: Column(
                children: group.items.asMap().entries.map((entry) {
                  final item = entry.value;
                  final isLast = entry.key == group.items.length - 1;
                  return Column(
                    children: [
                      _buildTransactionTile(item),
                      if (!isLast) const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ).animate().fadeIn(delay: Duration(milliseconds: index * 100));
      },
    );
  }

  Widget _buildTransactionTile(_TransactionItem item) {
    final isIncome = item.amount > 0;
    final amountColor = isIncome ? AppTheme.accentColor : AppTheme.dangerColor;
    final amountText = isIncome
        ? '+${_formatNumber(item.amount)}원'
        : '${_formatNumber(item.amount)}원';

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(item.icon, color: AppTheme.textSecondary, size: 20),
      ),
      title: Text(
        item.title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        item.category,
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
      onTap: () {
        // Show transaction details
      },
    );
  }

  String _formatNumber(int number) {
    return number.abs().toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  Widget _buildQuickAddButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAddButton(
            label: '지출',
            icon: Icons.remove,
            color: AppTheme.dangerColor,
            onTap: () => context.goNamed('addTransaction'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickAddButton(
            label: '수입',
            icon: Icons.add,
            color: AppTheme.accentColor,
            onTap: () => context.goNamed('addTransaction'),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 6),
              Text(
                '$label 추가',
                style: const TextStyle(
                  fontSize: 14,
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

class _TransactionGroup {
  final String date;
  final List<_TransactionItem> items;

  _TransactionGroup({required this.date, required this.items});
}

class _TransactionItem {
  final String title;
  final String category;
  final int amount;
  final IconData icon;

  _TransactionItem(this.title, this.category, this.amount, this.icon);
}
