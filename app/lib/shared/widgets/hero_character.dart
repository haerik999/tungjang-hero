import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_theme.dart';

/// 캐릭터 상태 enum
enum HeroCharacterState {
  idle, // 기본 대기
  happy, // HP 높음 (>70%)
  normal, // HP 보통 (30-70%)
  hurt, // HP 낮음 (<30%)
  critical, // HP 위험 (<10%)
  victory, // 레벨업/보상
  damage, // 피격
  attack, // 공격 (지출 시)
}

/// 캐릭터 크기
enum HeroCharacterSize {
  small(48), // 미니 (거래 추가 화면)
  medium(80), // 중간 (홈 화면)
  large(120); // 크게 (히어로 화면)

  final double size;
  const HeroCharacterSize(this.size);
}

/// 히어로 캐릭터 위젯
///
/// Lottie 애니메이션을 사용한 캐릭터 위젯
class HeroCharacter extends StatefulWidget {
  final HeroCharacterState state;
  final HeroCharacterSize size;
  final double? hpPercentage;
  final VoidCallback? onTap;
  final bool showGlow;
  final bool useLottie; // Lottie 사용 여부

  const HeroCharacter({
    super.key,
    this.state = HeroCharacterState.idle,
    this.size = HeroCharacterSize.medium,
    this.hpPercentage,
    this.onTap,
    this.showGlow = true,
    this.useLottie = true,
  });

  /// HP 퍼센티지에 따라 자동으로 상태 결정
  factory HeroCharacter.fromHp({
    Key? key,
    required double hpPercentage,
    HeroCharacterSize size = HeroCharacterSize.medium,
    VoidCallback? onTap,
    bool showGlow = true,
    bool useLottie = true,
  }) {
    HeroCharacterState state;
    if (hpPercentage < 0.1) {
      state = HeroCharacterState.critical;
    } else if (hpPercentage < 0.3) {
      state = HeroCharacterState.hurt;
    } else if (hpPercentage > 0.7) {
      state = HeroCharacterState.happy;
    } else {
      state = HeroCharacterState.normal;
    }

    return HeroCharacter(
      key: key,
      state: state,
      size: size,
      hpPercentage: hpPercentage,
      onTap: onTap,
      showGlow: showGlow,
      useLottie: useLottie,
    );
  }

  @override
  State<HeroCharacter> createState() => _HeroCharacterState();
}

class _HeroCharacterState extends State<HeroCharacter>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _actionController;
  late Animation<double> _breathAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Idle 애니메이션 (숨쉬기)
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _breathAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _idleController,
      curve: Curves.easeInOut,
    ));

    // 액션 애니메이션 (피격, 승리 등)
    _actionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _bounceAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _actionController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void didUpdateWidget(HeroCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 상태가 변경되면 액션 애니메이션 실행
    if (oldWidget.state != widget.state) {
      if (widget.state == HeroCharacterState.damage ||
          widget.state == HeroCharacterState.victory) {
        _actionController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_idleController, _actionController]),
        builder: (context, child) {
          return Transform.scale(
            scale: _getScale(),
            child: Transform.translate(
              offset: _getOffset(),
              child: widget.useLottie ? _buildLottieCharacter() : _buildCharacter(),
            ),
          );
        },
      ),
    );
  }

  double _getScale() {
    double baseScale = _breathAnimation.value;

    if (widget.state == HeroCharacterState.victory) {
      baseScale += _bounceAnimation.value * 0.1;
    } else if (widget.state == HeroCharacterState.damage) {
      baseScale -= _bounceAnimation.value * 0.05;
    }

    return baseScale;
  }

  Offset _getOffset() {
    if (widget.state == HeroCharacterState.damage) {
      // 피격 시 좌우로 흔들림
      final shake = _bounceAnimation.value * 5;
      return Offset(shake * ((_actionController.value * 10).floor().isEven ? 1 : -1), 0);
    }
    return Offset.zero;
  }

  /// Lottie 애니메이션을 사용한 캐릭터 빌드
  Widget _buildLottieCharacter() {
    final size = widget.size.size;
    final config = _getStateConfig();

    Widget lottieWidget = ClipOval(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: config.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: widget.showGlow
              ? [
                  BoxShadow(
                    color: config.glowColor.withValues(alpha: config.glowIntensity),
                    blurRadius: size / 4,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Lottie 애니메이션
            Lottie.asset(
              config.lottieAsset,
              width: size * 0.9,
              height: size * 0.9,
              fit: BoxFit.contain,
              repeat: true,
              errorBuilder: (context, error, stackTrace) {
                // Lottie 로딩 실패 시 아이콘으로 폴백
                return Icon(
                  config.icon,
                  size: size * 0.5,
                  color: Colors.white,
                );
              },
            ),
            // 상태 이모티콘
            if (config.emoji != null)
              Positioned(
                top: size * 0.02,
                right: size * 0.02,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(size * 0.15),
                  ),
                  child: Text(
                    config.emoji!,
                    style: TextStyle(fontSize: size * 0.2),
                  ),
                ),
              ),
            // 위험 상태 표시
            if (widget.state == HeroCharacterState.critical)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.dangerColor,
                      width: 3,
                    ),
                  ),
                )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .fadeIn(duration: 500.ms)
                    .then()
                    .fadeOut(duration: 500.ms),
              ),
          ],
        ),
      ),
    );

    // Victory 상태일 때 파티클 효과
    if (widget.state == HeroCharacterState.victory) {
      lottieWidget = Stack(
        alignment: Alignment.center,
        children: [
          lottieWidget,
          ...List.generate(6, (index) {
            return _buildParticle(size, index);
          }),
        ],
      );
    }

    return lottieWidget;
  }

  /// 기본 아이콘 캐릭터 빌드 (폴백)
  Widget _buildCharacter() {
    final size = widget.size.size;
    final config = _getStateConfig();

    Widget character = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: config.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: widget.showGlow
            ? [
                BoxShadow(
                  color: config.glowColor.withValues(alpha: config.glowIntensity),
                  blurRadius: size / 4,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 메인 캐릭터 아이콘
          Icon(
            config.icon,
            size: size * 0.5,
            color: Colors.white,
          ),
          // 상태 이모티콘
          if (config.emoji != null)
            Positioned(
              top: size * 0.05,
              right: size * 0.05,
              child: Text(
                config.emoji!,
                style: TextStyle(fontSize: size * 0.25),
              ),
            ),
          // 위험 상태 표시
          if (widget.state == HeroCharacterState.critical)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(size / 2),
                  border: Border.all(
                    color: AppTheme.dangerColor,
                    width: 3,
                  ),
                ),
              )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .fadeIn(duration: 500.ms)
                  .then()
                  .fadeOut(duration: 500.ms),
            ),
        ],
      ),
    );

    // Victory 상태일 때 파티클 효과
    if (widget.state == HeroCharacterState.victory) {
      character = Stack(
        alignment: Alignment.center,
        children: [
          character,
          ...List.generate(6, (index) {
            return _buildParticle(size, index);
          }),
        ],
      );
    }

    return character;
  }

  Widget _buildParticle(double size, int index) {
    final distance = size * 0.8;

    return Positioned(
      left: size / 2 + distance * 0.5 * (index.isEven ? 1 : -1),
      top: size / 2 - distance * 0.3 * (index % 3 == 0 ? 1 : -0.5),
      child: Icon(
        Icons.star,
        size: size * 0.15,
        color: AppTheme.goldColor,
      )
          .animate(
            onPlay: (controller) => controller.repeat(),
          )
          .scale(
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
            duration: 600.ms,
            delay: Duration(milliseconds: index * 100),
          )
          .fadeOut(delay: 400.ms, duration: 200.ms)
          .moveY(begin: 0, end: -20, duration: 600.ms),
    );
  }

  _CharacterStateConfig _getStateConfig() {
    switch (widget.state) {
      case HeroCharacterState.idle:
        return _CharacterStateConfig(
          icon: Icons.shield,
          lottieAsset: 'assets/animations/character_bot.json',
          gradientColors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
          glowColor: AppTheme.primaryColor,
          glowIntensity: 0.3,
        );
      case HeroCharacterState.happy:
        return _CharacterStateConfig(
          icon: Icons.shield,
          emoji: '😊',
          lottieAsset: 'assets/animations/character_bot.json',
          gradientColors: [
            AppTheme.accentColor,
            AppTheme.primaryColor,
          ],
          glowColor: AppTheme.accentColor,
          glowIntensity: 0.5,
        );
      case HeroCharacterState.normal:
        return _CharacterStateConfig(
          icon: Icons.shield,
          lottieAsset: 'assets/animations/character_bot.json',
          gradientColors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
          glowColor: AppTheme.primaryColor,
          glowIntensity: 0.3,
        );
      case HeroCharacterState.hurt:
        return _CharacterStateConfig(
          icon: Icons.shield,
          emoji: '😰',
          lottieAsset: 'assets/animations/character_bot.json',
          gradientColors: [
            AppTheme.dangerColor.withValues(alpha: 0.8),
            AppTheme.primaryColor,
          ],
          glowColor: AppTheme.dangerColor,
          glowIntensity: 0.4,
        );
      case HeroCharacterState.critical:
        return _CharacterStateConfig(
          icon: Icons.shield,
          emoji: '😵',
          lottieAsset: 'assets/animations/character_bot.json',
          gradientColors: [
            AppTheme.dangerColor,
            AppTheme.hpBarLow,
          ],
          glowColor: AppTheme.dangerColor,
          glowIntensity: 0.6,
        );
      case HeroCharacterState.victory:
        return _CharacterStateConfig(
          icon: Icons.shield,
          emoji: '🎉',
          lottieAsset: 'assets/animations/trophy.json',
          gradientColors: [
            AppTheme.goldColor,
            AppTheme.accentColor,
          ],
          glowColor: AppTheme.goldColor,
          glowIntensity: 0.7,
        );
      case HeroCharacterState.damage:
        return _CharacterStateConfig(
          icon: Icons.shield,
          emoji: '💥',
          lottieAsset: 'assets/animations/swords.json',
          gradientColors: [
            AppTheme.dangerColor,
            AppTheme.secondaryColor,
          ],
          glowColor: AppTheme.dangerColor,
          glowIntensity: 0.5,
        );
      case HeroCharacterState.attack:
        return _CharacterStateConfig(
          icon: Icons.shield,
          emoji: '⚔️',
          lottieAsset: 'assets/animations/swords.json',
          gradientColors: [
            AppTheme.primaryColor,
            AppTheme.dangerColor,
          ],
          glowColor: AppTheme.primaryColor,
          glowIntensity: 0.5,
        );
    }
  }
}

class _CharacterStateConfig {
  final IconData icon;
  final String? emoji;
  final String lottieAsset;
  final List<Color> gradientColors;
  final Color glowColor;
  final double glowIntensity;

  _CharacterStateConfig({
    required this.icon,
    this.emoji,
    required this.lottieAsset,
    required this.gradientColors,
    required this.glowColor,
    required this.glowIntensity,
  });
}
