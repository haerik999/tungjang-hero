import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_theme.dart';
import 'hero_character.dart';

/// 레벨업 결과 정보
class LevelUpInfo {
  final int oldLevel;
  final int newLevel;
  final String? newTitle;
  final int xpGained;

  LevelUpInfo({
    required this.oldLevel,
    required this.newLevel,
    this.newTitle,
    required this.xpGained,
  });

  int get levelsGained => newLevel - oldLevel;
}

/// 레벨업 다이얼로그 위젯
class LevelUpDialog extends StatefulWidget {
  final LevelUpInfo info;
  final VoidCallback? onDismiss;

  const LevelUpDialog({
    super.key,
    required this.info,
    this.onDismiss,
  });

  /// 레벨업 다이얼로그 표시
  static Future<void> show(BuildContext context, LevelUpInfo info) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) => LevelUpDialog(
        info: info,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  State<LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<LevelUpDialog>
    with TickerProviderStateMixin {
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 파티클
          ...List.generate(20, (index) => _buildFloatingParticle(index)),

          // Confetti Lottie 애니메이션 (배경)
          Positioned.fill(
            child: IgnorePointer(
              child: Lottie.asset(
                'assets/animations/confetti.json',
                fit: BoxFit.cover,
                repeat: true,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),

          // 메인 컨텐츠
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.primaryColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // LEVEL UP 텍스트
                _buildLevelUpText(),
                const SizedBox(height: 24),

                // 캐릭터
                const HeroCharacter(
                  state: HeroCharacterState.victory,
                  size: HeroCharacterSize.large,
                ).animate().scale(
                      begin: const Offset(0.5, 0.5),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),
                const SizedBox(height: 24),

                // 레벨 변화
                _buildLevelChange(),
                const SizedBox(height: 16),

                // 새 칭호 (있는 경우)
                if (widget.info.newTitle != null) ...[
                  _buildNewTitle(),
                  const SizedBox(height: 16),
                ],

                // 획득 XP
                _buildXpGained(),
                const SizedBox(height: 24),

                // 확인 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onDismiss,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 800.ms)
                    .slideY(begin: 0.3),
              ],
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.8, 0.8),
                duration: 300.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(),
        ],
      ),
    );
  }

  Widget _buildLevelUpText() {
    return Column(
      children: [
        Text(
          'LEVEL UP!',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
            letterSpacing: 4,
          ),
        ).animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        ).shimmer(
          duration: 1500.ms,
          color: Colors.white.withValues(alpha: 0.5),
        ),
        if (widget.info.levelsGained > 1)
          Text(
            '+${widget.info.levelsGained} Levels!',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildLevelChange() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLevelBadge(widget.info.oldLevel, false),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Icon(
            Icons.arrow_forward,
            color: AppTheme.primaryColor,
            size: 32,
          )
              .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              )
              .moveX(begin: -5, end: 5, duration: 500.ms),
        ),
        _buildLevelBadge(widget.info.newLevel, true),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildLevelBadge(int level, bool isNew) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isNew
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNew ? AppTheme.primaryColor : AppTheme.borderColor,
          width: isNew ? 2 : 1,
        ),
        boxShadow: isNew
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Text(
        'Lv. $level',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isNew ? AppTheme.primaryColor : AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildNewTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor),
      ),
      child: Column(
        children: [
          const Text(
            '새 칭호 획득!',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.info.newTitle!,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms)
        .scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildXpGained() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.star,
          color: AppTheme.xpBarFill,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          '+${widget.info.xpGained} XP',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.xpBarFill,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildFloatingParticle(int index) {
    final random = index * 17 % 360;
    final size = 8.0 + (index % 3) * 4;

    return Positioned(
      left: (random * 1.5) % 200 + 50,
      top: (random * 2) % 300 + 50,
      child: AnimatedBuilder(
        animation: _particleController,
        builder: (context, child) {
          final value = (_particleController.value + index / 20) % 1.0;
          return Opacity(
            opacity: (1 - value) * 0.5,
            child: Transform.translate(
              offset: Offset(0, -value * 100),
              child: Icon(
                index.isEven ? Icons.star : Icons.auto_awesome,
                size: size,
                color: AppTheme.primaryColor.withValues(alpha: 0.6),
              ),
            ),
          );
        },
      ),
    );
  }
}
