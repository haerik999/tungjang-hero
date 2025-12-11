import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class GachaScreen extends ConsumerWidget {
  const GachaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('가챠')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 보유 재화
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCurrency(Icons.confirmation_number, '일반 티켓', '3', AppTheme.warningColor),
                  Container(width: 1, height: 40, color: AppTheme.borderColor),
                  _buildCurrency(Icons.star, '프리미엄 티켓', '1', const Color(0xFFFF9800)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 일반 가챠
            _buildGachaBanner(
              context,
              title: '일반 뽑기',
              subtitle: '고급~영웅 장비 획득',
              color: AppTheme.primaryColor,
              icon: Icons.inventory_2,
              ticketCount: 3,
              onTap: () => _showGachaDialog(context, false),
            ),
            const SizedBox(height: 16),
            // 프리미엄 가챠
            _buildGachaBanner(
              context,
              title: '프리미엄 뽑기',
              subtitle: '영웅~신화 장비 획득',
              color: const Color(0xFFFF9800),
              icon: Icons.auto_awesome,
              ticketCount: 1,
              isPremium: true,
              onTap: () => _showGachaDialog(context, true),
            ),
            const SizedBox(height: 24),
            // 확률표
            _buildProbabilityTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrency(IconData icon, String label, String count, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildGachaBanner(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required int ticketCount,
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: ticketCount >= 1 ? onTap : null,
                  style: OutlinedButton.styleFrom(side: BorderSide(color: color)),
                  child: Text('1회 뽑기', style: TextStyle(color: ticketCount >= 1 ? color : AppTheme.textTertiary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: ticketCount >= 10 ? onTap : null,
                  style: ElevatedButton.styleFrom(backgroundColor: color),
                  child: const Text('10회 뽑기'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProbabilityTable() {
    final grades = [
      ('신화', const Color(0xFFF44336), '0.5%'),
      ('전설', const Color(0xFFFF9800), '2%'),
      ('영웅', const Color(0xFF9C27B0), '7%'),
      ('희귀', const Color(0xFF2196F3), '20%'),
      ('고급', const Color(0xFF4CAF50), '70.5%'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('프리미엄 뽑기 확률', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          ...grades.map((g) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: g.$2, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(g.$1, style: TextStyle(color: g.$2, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(g.$3, style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _showGachaDialog(BuildContext context, bool isPremium) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isPremium ? '프리미엄 뽑기' : '일반 뽑기'),
        content: const Text('뽑기를 진행하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/game/gacha/result');
            },
            child: const Text('뽑기'),
          ),
        ],
      ),
    );
  }
}
