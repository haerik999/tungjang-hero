import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';

class SkillScreen extends ConsumerWidget {
  const SkillScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('스킬'),
          bottom: const TabBar(tabs: [Tab(text: '공용 스킬'), Tab(text: '장비 스킬')]),
        ),
        body: TabBarView(
          children: [_buildCommonSkills(), _buildEquipmentSkills()],
        ),
      ),
    );
  }

  Widget _buildCommonSkills() {
    final skills = [
      ('강타', 'STR 비례 데미지', Icons.gavel, 5, AppTheme.dangerColor),
      ('방어 태세', '방어력 30% 증가', Icons.shield, 3, AppTheme.primaryColor),
      ('신속', '공격 속도 20% 증가', Icons.speed, 2, AppTheme.accentColor),
      ('치명타 강화', '치명타 확률 +15%', Icons.flash_on, 1, AppTheme.warningColor),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: skills.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.menu_book, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                const Text('보유 스킬북:', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                const Text('8', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
              ],
            ),
          );
        }
        final skill = skills[index - 1];
        return _buildSkillCard(skill.$1, skill.$2, skill.$3, skill.$4, skill.$5);
      },
    );
  }

  Widget _buildSkillCard(String name, String desc, IconData icon, int level, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                      child: Text('Lv.$level', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
            child: const Text('강화'),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentSkills() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_fix_high, size: 64, color: AppTheme.textTertiary),
          const SizedBox(height: 16),
          Text('장비에 부여된 스킬이 없습니다', style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Text('영웅 등급 이상 장비에서 스킬 확인', style: TextStyle(fontSize: 12, color: AppTheme.textTertiary)),
        ],
      ),
    );
  }
}
