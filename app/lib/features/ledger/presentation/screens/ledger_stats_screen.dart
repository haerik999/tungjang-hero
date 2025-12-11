import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

class LedgerStatsScreen extends StatelessWidget {
  const LedgerStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'ko_KR');

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('통계'),
          bottom: const TabBar(tabs: [Tab(text: '카테고리'), Tab(text: '추이'), Tab(text: '비교')]),
        ),
        body: TabBarView(
          children: [
            _buildCategoryStats(formatter),
            _buildTrendStats(),
            _buildCompareStats(formatter),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryStats(NumberFormat formatter) {
    final categories = [
      ('식비', 450000, 0.25, AppTheme.dangerColor),
      ('교통', 150000, 0.08, AppTheme.primaryColor),
      ('생활', 380000, 0.21, AppTheme.accentColor),
      ('쇼핑', 320000, 0.18, AppTheme.warningColor),
      ('문화', 180000, 0.10, const Color(0xFF9C27B0)),
      ('기타', 343500, 0.18, AppTheme.textSecondary),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(16)),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150, height: 150,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 20,
                    backgroundColor: AppTheme.borderColor,
                    color: AppTheme.dangerColor,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('총 지출', style: TextStyle(fontSize: 12)),
                    Text('${formatter.format(1823500)}원', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...categories.map((cat) => _buildCategoryItem(cat.$1, cat.$2, cat.$3, cat.$4, formatter)),
      ],
    );
  }

  Widget _buildCategoryItem(String name, int amount, double ratio, Color color, NumberFormat formatter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const Spacer(),
              Text('${formatter.format(amount)}원', style: TextStyle(color: AppTheme.textPrimary)),
              const SizedBox(width: 8),
              Text('${(ratio * 100).toInt()}%', style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: ratio, backgroundColor: AppTheme.borderColor, color: color),
        ],
      ),
    );
  }

  Widget _buildTrendStats() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 64, color: AppTheme.textTertiary),
          const SizedBox(height: 16),
          Text('지출 추이 그래프', style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Text('(차트 라이브러리 연동 예정)', style: TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildCompareStats(NumberFormat formatter) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCompareCard('이번 달', 1823500, '저번 달', 2100000, formatter),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.trending_down, color: AppTheme.accentColor),
              const SizedBox(width: 12),
              const Expanded(child: Text('지난달 대비')),
              Text('-${formatter.format(276500)}원', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentColor)),
              const SizedBox(width: 8),
              const Text('(-13%)', style: TextStyle(color: AppTheme.accentColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompareCard(String label1, int amount1, String label2, int amount2, NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(label1, style: TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Text('${formatter.format(amount1)}원', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(width: 1, height: 60, color: AppTheme.borderColor),
          Expanded(
            child: Column(
              children: [
                Text(label2, style: TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Text('${formatter.format(amount2)}원', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
