import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class BossScreen extends ConsumerWidget {
  const BossScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('보스 레이드')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeeklyBoss(context),
            const SizedBox(height: 24),
            Text('보스 목록', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            _buildBossCard(context, '불의 드래곤', '화염 지역', 50, AppTheme.dangerColor, true),
            _buildBossCard(context, '얼음 골렘', '빙하 동굴', 40, AppTheme.primaryColor, false),
            _buildBossCard(context, '독 히드라', '독안개 늪', 60, AppTheme.accentColor, false),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyBoss(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.dangerColor.withValues(alpha: 0.2), AppTheme.dangerColor.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dangerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.dangerColor, borderRadius: BorderRadius.circular(12)),
                child: const Text('이번 주 보스', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const Spacer(),
              const Icon(Icons.timer, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text('2일 15시간', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.dangerColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.whatshot, size: 48, color: AppTheme.dangerColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('불의 드래곤', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('HP:', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: 0.75,
                            backgroundColor: AppTheme.borderColor,
                            color: AppTheme.hpBarFill,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('75%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBossStat('내 피해량', '125,000'),
                Container(width: 1, height: 30, color: AppTheme.borderColor),
                _buildBossStat('순위', '12위'),
                Container(width: 1, height: 30, color: AppTheme.borderColor),
                _buildBossStat('남은 횟수', '2/3'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/game/boss/battle/weekly'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
              child: const Text('도전하기'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBossStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildBossCard(BuildContext context, String name, String location, int level, Color color, bool available) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: available ? AppTheme.surfaceColor : AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: available ? Border.all(color: color.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.whatshot, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: available ? AppTheme.textPrimary : AppTheme.textTertiary)),
                const SizedBox(height: 4),
                Text('$location · Lv.$level', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          if (available)
            ElevatedButton(
              onPressed: () => context.push('/game/boss/battle/1'),
              style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(horizontal: 16)),
              child: const Text('도전'),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.lock, size: 16, color: AppTheme.textTertiary),
            ),
        ],
      ),
    );
  }
}
