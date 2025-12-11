import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

/// 가계부 내부 탭 종류
enum LedgerTab { transactions, stats, budget }

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  final _formatter = NumberFormat('#,###', 'ko_KR');
  DateTime _selectedMonth = DateTime.now();

  // 현재 선택된 탭
  LedgerTab _currentTab = LedgerTab.transactions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f1a2e),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildMonthlySummary(),
            Expanded(child: _buildContent()),
            _buildQuickMenu(),
          ],
        ),
      ),
      floatingActionButton: _currentTab == LedgerTab.transactions
          ? FloatingActionButton(
              onPressed: _showAddTransaction,
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  /// 메인 콘텐츠 영역 - 탭에 따라 다른 내용 표시
  Widget _buildContent() {
    switch (_currentTab) {
      case LedgerTab.transactions:
        return _buildTransactionsPanel();
      case LedgerTab.stats:
        return _buildStatsPanel();
      case LedgerTab.budget:
        return _buildBudgetPanel();
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1)),
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Text(
            DateFormat('yyyy년 M월').format(_selectedMonth),
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1)),
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Spacer(),
          // 보상 정보
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.card_giftcard, color: AppTheme.primaryColor, size: 14),
                const SizedBox(width: 4),
                Text('3/10', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0f3460)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem('수입', '+${_formatter.format(2500000)}', AppTheme.accentColor),
          ),
          Container(width: 1, height: 36, color: const Color(0xFF1b263b)),
          Expanded(
            child: _buildSummaryItem('지출', '-${_formatter.format(1823500)}', AppTheme.dangerColor),
          ),
          Container(width: 1, height: 36, color: const Color(0xFF1b263b)),
          Expanded(
            child: _buildSummaryItem('잔액', '+${_formatter.format(676500)}', const Color(0xFF00d9ff)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6))),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 거래 내역 패널
  // ═══════════════════════════════════════════════════════════
  Widget _buildTransactionsPanel() {
    return _buildPanel(
      icon: Icons.receipt_long,
      title: '거래 내역',
      trailing: Text('총 15건', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
      child: _buildTransactionList(),
    );
  }

  Widget _buildTransactionList() {
    final transactions = [
      ('오늘', [
        ('점심 식사', '식비', -12000, true),
        ('지하철', '교통', -1500, false),
        ('커피', '카페', -6500, true),
      ]),
      ('어제', [
        ('급여', '수입', 3500000, false),
        ('마트', '생활', -45000, true),
      ]),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: transactions.length,
      itemBuilder: (context, sectionIndex) {
        final section = transactions[sectionIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(section.$1, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
            ),
            ...section.$2.map((t) => _buildTransactionItem(t.$1, t.$2, t.$3, t.$4)),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(String title, String category, int amount, bool verified) {
    final isIncome = amount > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1b263b),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: (isIncome ? AppTheme.accentColor : const Color(0xFF778da9)).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getCategoryIcon(category), color: isIncome ? AppTheme.accentColor : const Color(0xFF778da9), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 13)),
                    if (verified) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: AppTheme.accentColor, borderRadius: BorderRadius.circular(4)),
                        child: const Text('인증', style: TextStyle(color: Colors.white, fontSize: 9)),
                      ),
                    ],
                  ],
                ),
                Text(category, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : ''}${_formatter.format(amount)}원',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isIncome ? AppTheme.accentColor : AppTheme.dangerColor),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '식비': return Icons.restaurant;
      case '교통': return Icons.directions_bus;
      case '카페': return Icons.coffee;
      case '생활': return Icons.home;
      case '수입': return Icons.payments;
      default: return Icons.receipt;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 통계 패널
  // ═══════════════════════════════════════════════════════════
  Widget _buildStatsPanel() {
    return _buildPanel(
      icon: Icons.bar_chart,
      title: '지출 통계',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildStatCategory('식비', 450000, 0.35, const Color(0xFFe94560)),
            _buildStatCategory('교통', 180000, 0.14, const Color(0xFF00d9ff)),
            _buildStatCategory('쇼핑', 320000, 0.25, const Color(0xFFa78bfa)),
            _buildStatCategory('생활', 280000, 0.22, const Color(0xFF4ade80)),
            _buildStatCategory('기타', 50000, 0.04, const Color(0xFF778da9)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1b263b),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('총 지출', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('${_formatter.format(1280000)}원', style: const TextStyle(color: AppTheme.dangerColor, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCategory(String name, int amount, double ratio, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 8),
              Text(name, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
              const Spacer(),
              Text('${(ratio * 100).toInt()}%', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
              const SizedBox(width: 8),
              Text('${_formatter.format(amount)}원', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 예산 패널
  // ═══════════════════════════════════════════════════════════
  Widget _buildBudgetPanel() {
    return _buildPanel(
      icon: Icons.account_balance_wallet,
      title: '예산 관리',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildBudgetOverview(),
            const SizedBox(height: 16),
            _buildBudgetCategory('식비', 500000, 450000, const Color(0xFFe94560)),
            _buildBudgetCategory('교통', 200000, 180000, const Color(0xFF00d9ff)),
            _buildBudgetCategory('쇼핑', 300000, 320000, const Color(0xFFa78bfa)),
            _buildBudgetCategory('생활', 400000, 280000, const Color(0xFF4ade80)),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFe94560).withValues(alpha: 0.2), const Color(0xFF0f3460).withValues(alpha: 0.2)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFe94560).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text('이번 달 예산', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Text('${_formatter.format(2500000)}원', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBudgetStat('사용', '${_formatter.format(1823500)}원', AppTheme.dangerColor),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildBudgetStat('남은', '${_formatter.format(676500)}원', AppTheme.accentColor),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.73,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFffd700)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text('73% 사용', style: TextStyle(color: const Color(0xFFffd700), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBudgetStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildBudgetCategory(String name, int budget, int spent, Color color) {
    final ratio = spent / budget;
    final isOver = ratio > 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1b263b),
        borderRadius: BorderRadius.circular(8),
        border: isOver ? Border.all(color: AppTheme.dangerColor.withValues(alpha: 0.5)) : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              const Spacer(),
              if (isOver)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppTheme.dangerColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                  child: const Text('초과', style: TextStyle(color: AppTheme.dangerColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(isOver ? AppTheme.dangerColor : color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_formatter.format(spent)} / ${_formatter.format(budget)}원',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
              Text('${(ratio * 100).toInt()}%',
                style: TextStyle(color: isOver ? AppTheme.dangerColor : color, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  /// 공통 패널 위젯
  Widget _buildPanel({
    required IconData icon,
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0d1b2a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1b263b)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF1b263b),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(11), topRight: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF778da9), size: 16),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(color: Color(0xFF778da9), fontSize: 13, fontWeight: FontWeight.w600)),
                const Spacer(),
                if (trailing != null) trailing,
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildQuickMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickButton(Icons.receipt_long, '내역', LedgerTab.transactions),
          _buildQuickButton(Icons.bar_chart, '통계', LedgerTab.stats),
          _buildQuickButton(Icons.account_balance_wallet, '예산', LedgerTab.budget),
        ],
      ),
    );
  }

  Widget _buildQuickButton(IconData icon, String label, LedgerTab tab) {
    final isSelected = _currentTab == tab;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = tab),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFe94560).withValues(alpha: 0.2) : const Color(0xFF0f3460),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? const Color(0xFFe94560) : const Color(0xFF1b263b)),
            ),
            child: Icon(icon, color: isSelected ? const Color(0xFFe94560) : const Color(0xFF00d9ff), size: 22),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFe94560) : Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              )),
        ],
      ),
    );
  }

  void _showAddTransaction() {
    // TODO: 거래 추가 바텀시트 또는 모달
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            const Text('거래 추가', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildAddButton(Icons.remove, '지출', AppTheme.dangerColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAddButton(Icons.add, '수입', AppTheme.accentColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        // TODO: 실제 거래 추가 화면으로 이동
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
