import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

/// 게임 이펙트 타입
enum GameEffectType {
  damage, // 데미지 받음 (빨간색 플래시)
  heal, // HP 회복 (초록색)
  xpGain, // XP 획득 (파란색/청록색)
  levelUp, // 레벨업 (금색)
  questComplete, // 퀘스트 완료 (보라색)
  critical, // 위험 상태 (빨간색 깜빡임)
}

/// 게임 이펙트 정보
class GameEffectInfo {
  final GameEffectType type;
  final int? value; // 데미지량, XP량 등
  final String? message; // 추가 메시지

  GameEffectInfo({
    required this.type,
    this.value,
    this.message,
  });
}

/// 게임 이펙트 오버레이
///
/// 화면 전체에 표시되는 이펙트 (데미지 플래시, XP 획득 등)
class GameEffectOverlay extends StatefulWidget {
  final GameEffectInfo effect;
  final VoidCallback? onComplete;

  const GameEffectOverlay({
    super.key,
    required this.effect,
    this.onComplete,
  });

  /// 이펙트 오버레이 표시
  static OverlayEntry? show(
    BuildContext context,
    GameEffectInfo effect, {
    VoidCallback? onComplete,
  }) {
    final overlay = Overlay.of(context);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => GameEffectOverlay(
        effect: effect,
        onComplete: () {
          entry.remove();
          onComplete?.call();
        },
      ),
    );

    overlay.insert(entry);
    return entry;
  }

  @override
  State<GameEffectOverlay> createState() => _GameEffectOverlayState();
}

class _GameEffectOverlayState extends State<GameEffectOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _getDuration(),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  Duration _getDuration() {
    switch (widget.effect.type) {
      case GameEffectType.damage:
        return const Duration(milliseconds: 600);
      case GameEffectType.heal:
        return const Duration(milliseconds: 800);
      case GameEffectType.xpGain:
        return const Duration(milliseconds: 1000);
      case GameEffectType.levelUp:
        return const Duration(milliseconds: 1500);
      case GameEffectType.questComplete:
        return const Duration(milliseconds: 1200);
      case GameEffectType.critical:
        return const Duration(milliseconds: 2000);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // 배경 플래시
              _buildFlashOverlay(),
              // 값 표시
              if (widget.effect.value != null) _buildValueDisplay(),
              // 메시지
              if (widget.effect.message != null) _buildMessage(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFlashOverlay() {
    final config = _getEffectConfig();
    final flashOpacity = _getFlashOpacity();

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              config.color.withValues(alpha: flashOpacity * 0.3),
              config.color.withValues(alpha: flashOpacity * 0.1),
              Colors.transparent,
            ],
            center: Alignment.center,
            radius: 1.5,
          ),
        ),
      ),
    );
  }

  double _getFlashOpacity() {
    switch (widget.effect.type) {
      case GameEffectType.damage:
        // 빠르게 나타났다가 사라짐
        if (_controller.value < 0.3) {
          return _controller.value / 0.3;
        } else {
          return 1 - ((_controller.value - 0.3) / 0.7);
        }
      case GameEffectType.critical:
        // 깜빡임 효과
        return (_controller.value * 4).floor().isEven ? 0.8 : 0.2;
      default:
        // 부드럽게 사라짐
        return 1 - _controller.value;
    }
  }

  Widget _buildValueDisplay() {
    final config = _getEffectConfig();
    final value = widget.effect.value!;
    final prefix = config.isPositive ? '+' : '-';
    final suffix = config.suffix;

    // 위로 올라가는 애니메이션
    final yOffset = -80 * _controller.value;
    final opacity = _controller.value < 0.8 ? 1.0 : (1 - _controller.value) / 0.2;

    return Positioned(
      top: MediaQuery.of(context).size.height * 0.3 + yOffset,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (config.icon != null) ...[
              Icon(
                config.icon,
                color: config.color,
                size: 32,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              '$prefix${value.abs()}$suffix',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: config.color,
                shadows: [
                  Shadow(
                    color: config.color.withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                  const Shadow(
                    color: Colors.black54,
                    blurRadius: 5,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage() {
    final config = _getEffectConfig();
    final opacity = _controller.value < 0.7 ? 1.0 : (1 - _controller.value) / 0.3;

    return Positioned(
      top: MediaQuery.of(context).size.height * 0.4,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Text(
          widget.effect.message!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: config.color,
            shadows: const [
              Shadow(
                color: Colors.black54,
                blurRadius: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _EffectConfig _getEffectConfig() {
    switch (widget.effect.type) {
      case GameEffectType.damage:
        return _EffectConfig(
          color: AppTheme.dangerColor,
          icon: Icons.heart_broken,
          isPositive: false,
          suffix: ' HP',
        );
      case GameEffectType.heal:
        return _EffectConfig(
          color: AppTheme.accentColor,
          icon: Icons.favorite,
          isPositive: true,
          suffix: ' HP',
        );
      case GameEffectType.xpGain:
        return _EffectConfig(
          color: AppTheme.xpBarFill,
          icon: Icons.star,
          isPositive: true,
          suffix: ' XP',
        );
      case GameEffectType.levelUp:
        return _EffectConfig(
          color: AppTheme.goldColor,
          icon: Icons.arrow_upward,
          isPositive: true,
          suffix: ' LV',
        );
      case GameEffectType.questComplete:
        return _EffectConfig(
          color: AppTheme.primaryColor,
          icon: Icons.check_circle,
          isPositive: true,
          suffix: ' XP',
        );
      case GameEffectType.critical:
        return _EffectConfig(
          color: AppTheme.dangerColor,
          icon: Icons.warning,
          isPositive: false,
          suffix: '',
        );
    }
  }
}

class _EffectConfig {
  final Color color;
  final IconData? icon;
  final bool isPositive;
  final String suffix;

  _EffectConfig({
    required this.color,
    this.icon,
    required this.isPositive,
    required this.suffix,
  });
}

/// 데미지 이펙트만 간단히 표시하는 위젯
class DamageFlash extends StatelessWidget {
  final int damage;
  final Widget child;

  const DamageFlash({
    super.key,
    required this.damage,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (damage > 0)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: AppTheme.dangerColor.withValues(alpha: 0.3),
              )
                  .animate()
                  .fadeIn(duration: 100.ms)
                  .then()
                  .fadeOut(duration: 400.ms),
            ),
          ),
      ],
    );
  }
}

/// XP 획득 플로팅 텍스트
class FloatingXpText extends StatelessWidget {
  final int xp;

  const FloatingXpText({
    super.key,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '+$xp XP',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppTheme.xpBarFill,
        shadows: [
          Shadow(
            color: Colors.black54,
            blurRadius: 4,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .moveY(begin: 0, end: -30, duration: 800.ms)
        .then()
        .fadeOut(duration: 200.ms);
  }
}
