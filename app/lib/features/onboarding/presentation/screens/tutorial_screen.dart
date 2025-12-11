import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _step = 0;

  final _steps = [
    (
      title: '첫 번째 거래 기록하기',
      desc: '가계부에서 오늘 사용한 금액을 기록해보세요!',
      icon: Icons.receipt_long,
      action: '거래 기록하러 가기',
    ),
    (
      title: '보상 획득!',
      desc: '거래를 기록하면 게임에 필요한 재화를 얻을 수 있어요.',
      icon: Icons.card_giftcard,
      action: '보상 확인하기',
    ),
    (
      title: '자동 사냥 시작',
      desc: '이제 캐릭터가 자동으로 사냥을 시작합니다!\n앱을 끄고 있어도 성장해요.',
      icon: Icons.auto_mode,
      action: '사냥 시작!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentStep = _steps[_step];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            // 진행률
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(_steps.length, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index <= _step ? AppTheme.primaryColor : Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 아이콘
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(currentStep.icon, size: 64, color: AppTheme.primaryColor),
                    )
                        .animate(key: ValueKey(_step))
                        .fadeIn()
                        .scale(begin: const Offset(0.8, 0.8)),
                    const SizedBox(height: 48),

                    // 타이틀
                    Text(
                      currentStep.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate(key: ValueKey('t$_step')).fadeIn(delay: 200.ms),

                    const SizedBox(height: 16),

                    // 설명
                    Text(
                      currentStep.desc,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                    ).animate(key: ValueKey('d$_step')).fadeIn(delay: 400.ms),

                    // 보상 미리보기 (2단계)
                    if (_step == 1) ...[
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildRewardRow(Icons.diamond, '강화석', '+2', AppTheme.primaryColor),
                            const Divider(color: Colors.white24),
                            _buildRewardRow(Icons.menu_book, '스킬북', '+1', AppTheme.accentColor),
                          ],
                        ),
                      ).animate().fadeIn(delay: 600.ms),
                    ],
                  ],
                ),
              ),
            ),

            // 버튼
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  child: Text(
                    currentStep.action,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardRow(IconData icon, String name, String count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(color: Colors.white)),
          const Spacer(),
          Text(count, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      // 튜토리얼 완료 -> 게임으로 이동
      context.go('/game');
    }
  }
}
