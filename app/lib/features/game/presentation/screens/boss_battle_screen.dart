import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class BossBattleScreen extends StatefulWidget {
  final String bossId;
  const BossBattleScreen({super.key, required this.bossId});

  @override
  State<BossBattleScreen> createState() => _BossBattleScreenState();
}

class _BossBattleScreenState extends State<BossBattleScreen> {
  bool _isBattling = false;
  int _damage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 바
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text('불의 드래곤', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // 보스 HP
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('BOSS HP', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const Text('75,000,000 / 100,000,000', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: 0.75,
                    backgroundColor: Colors.white24,
                    color: AppTheme.dangerColor,
                    minHeight: 12,
                  ),
                ],
              ),
            ),
            // 보스 이미지
            Expanded(
              child: Center(
                child: Container(
                  width: 200, height: 200,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(colors: [AppTheme.dangerColor.withValues(alpha: 0.3), Colors.transparent]),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.whatshot, size: 120, color: AppTheme.dangerColor)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1000.ms),
                )
                    .animate(target: _isBattling ? 1 : 0)
                    .shake(duration: 500.ms),
              ),
            ),
            // 데미지 표시
            if (_isBattling)
              Text(
                '-$_damage',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.dangerColor),
              ).animate().fadeIn().moveY(begin: 0, end: -30).fadeOut(delay: 500.ms),
            // 캐릭터 & 스킬
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // 캐릭터 상태
                  Row(
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.person, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Lv.15 절약의 기사', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(value: 0.85, backgroundColor: AppTheme.borderColor, color: AppTheme.hpBarFill),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // 스킬 버튼들
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSkillButton(Icons.gavel, '강타', AppTheme.dangerColor, () => _attack(5000)),
                      _buildSkillButton(Icons.flash_on, '연타', AppTheme.warningColor, () => _attack(3000)),
                      _buildSkillButton(Icons.auto_awesome, '필살기', const Color(0xFF9C27B0), () => _attack(15000)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 공격 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _attack(1500),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
                      child: const Text('공격!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: color)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  void _attack(int baseDamage) {
    setState(() {
      _isBattling = true;
      _damage = baseDamage + (baseDamage * 0.2 * (DateTime.now().millisecond % 10)).round();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isBattling = false);
    });
  }
}
