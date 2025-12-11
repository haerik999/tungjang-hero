import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_theme.dart';

/// 보상 아이템 정보
class RewardItem {
  final String type;
  final int quantity;
  final String? rarity;

  const RewardItem({
    required this.type,
    required this.quantity,
    this.rarity,
  });

  String get displayName {
    switch (type) {
      case 'xp':
        return '경험치';
      case 'gold':
        return '골드';
      case 'enhancement_stone':
        return '강화석';
      case 'skill_book':
        return '스킬북';
      case 'gacha_ticket':
        return '가챠 티켓';
      case 'pet_food':
        return '펫 먹이';
      case 'hp_potion':
        return 'HP 포션';
      case 'xp_potion':
        return '경험치 포션';
      default:
        return type;
    }
  }

  IconData get icon {
    switch (type) {
      case 'xp':
        return Icons.star;
      case 'gold':
        return Icons.monetization_on;
      case 'enhancement_stone':
        return Icons.diamond;
      case 'skill_book':
        return Icons.menu_book;
      case 'gacha_ticket':
        return Icons.confirmation_number;
      case 'pet_food':
        return Icons.pets;
      case 'hp_potion':
        return Icons.local_hospital;
      case 'xp_potion':
        return Icons.trending_up;
      default:
        return Icons.card_giftcard;
    }
  }

  Color get color {
    switch (type) {
      case 'xp':
        return AppTheme.xpBarFill;
      case 'gold':
        return Colors.amber;
      case 'enhancement_stone':
        return Colors.blue;
      case 'skill_book':
        return Colors.purple;
      case 'gacha_ticket':
        return Colors.orange;
      case 'pet_food':
        return Colors.green;
      case 'hp_potion':
        return Colors.red;
      case 'xp_potion':
        return Colors.teal;
      default:
        return AppTheme.primaryColor;
    }
  }
}

/// 보상 팝업 위젯
class RewardPopup extends StatefulWidget {
  final List<RewardItem> rewards;
  final String? title;
  final String? subtitle;
  final VoidCallback? onDismiss;

  const RewardPopup({
    super.key,
    required this.rewards,
    this.title,
    this.subtitle,
    this.onDismiss,
  });

  /// 보상 팝업 표시
  static Future<void> show(
    BuildContext context, {
    required List<RewardItem> rewards,
    String? title,
    String? subtitle,
  }) {
    if (rewards.isEmpty) return Future.value();

    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) => RewardPopup(
        rewards: rewards,
        title: title,
        subtitle: subtitle,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// 거래 보상 맵에서 RewardItem 리스트 생성
  static List<RewardItem> fromRewardMap(Map<String, dynamic>? rewardMap) {
    if (rewardMap == null) return [];

    final items = <RewardItem>[];

    // XP
    if (rewardMap['xp'] != null && rewardMap['xp'] > 0) {
      items.add(RewardItem(type: 'xp', quantity: rewardMap['xp']));
    }

    // Gold
    if (rewardMap['gold'] != null && rewardMap['gold'] > 0) {
      items.add(RewardItem(type: 'gold', quantity: rewardMap['gold']));
    }

    // Items
    if (rewardMap['items'] != null) {
      final itemsList = rewardMap['items'] as List<dynamic>?;
      if (itemsList != null) {
        for (final item in itemsList) {
          if (item is Map<String, dynamic>) {
            items.add(RewardItem(
              type: item['type'] ?? 'item',
              quantity: item['quantity'] ?? 1,
              rarity: item['rarity'],
            ));
          }
        }
      }
    }

    // Equipment
    if (rewardMap['equipment'] != null) {
      items.add(RewardItem(
        type: 'equipment',
        quantity: 1,
        rarity: rewardMap['equipment']['grade'],
      ));
    }

    return items;
  }

  @override
  State<RewardPopup> createState() => _RewardPopupState();
}

class _RewardPopupState extends State<RewardPopup>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sparkle particles
          ...List.generate(15, (index) => _buildSparkle(index)),

          // Confetti animation
          Positioned.fill(
            child: IgnorePointer(
              child: Lottie.asset(
                'assets/animations/confetti.json',
                fit: BoxFit.cover,
                repeat: false,
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),

          // Main content
          Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                _buildTitle(),
                const SizedBox(height: 20),

                // Rewards Grid
                _buildRewardsGrid(),
                const SizedBox(height: 24),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onDismiss,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 600.ms)
                    .slideY(begin: 0.2),
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

  Widget _buildTitle() {
    return Column(
      children: [
        // Gift icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.card_giftcard,
            size: 32,
            color: AppTheme.primaryColor,
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.5, 0.5),
              duration: 400.ms,
              curve: Curves.elasticOut,
            ),
        const SizedBox(height: 16),

        // Title text
        Text(
          widget.title ?? '보상 획득!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms),

        if (widget.subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.subtitle!,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ],
    );
  }

  Widget _buildRewardsGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: widget.rewards.asMap().entries.map((entry) {
        final index = entry.key;
        final reward = entry.value;
        return _RewardItemWidget(
          reward: reward,
          delay: Duration(milliseconds: 300 + index * 100),
        );
      }).toList(),
    );
  }

  Widget _buildSparkle(int index) {
    final angle = (index * 24.0) * 3.14159 / 180;
    final radius = 120.0 + (index % 3) * 30;

    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        final progress = (_sparkleController.value + index / 15) % 1.0;
        final currentRadius = radius * (0.5 + progress * 0.5);
        final x = currentRadius * (index.isEven ? 1 : -1) *
            (0.5 + 0.5 * (progress));
        final y = -currentRadius * progress;

        return Positioned(
          left: 160 + x,
          top: 200 + y,
          child: Opacity(
            opacity: (1 - progress) * 0.8,
            child: Icon(
              index % 3 == 0
                  ? Icons.star
                  : index % 3 == 1
                      ? Icons.auto_awesome
                      : Icons.diamond,
              size: 12.0 + (index % 3) * 4,
              color: AppTheme.primaryColor.withOpacity(0.7),
            ),
          ),
        );
      },
    );
  }
}

class _RewardItemWidget extends StatelessWidget {
  final RewardItem reward;
  final Duration delay;

  const _RewardItemWidget({
    required this.reward,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: reward.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: reward.color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with glow
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: reward.color.withOpacity(0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: reward.color.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              reward.icon,
              color: reward.color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),

          // Name
          Text(
            reward.displayName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: reward.color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Quantity
          Text(
            reward.type == 'xp' || reward.type == 'gold'
                ? '+${reward.quantity}'
                : 'x${reward.quantity}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: reward.color,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delay)
        .scale(
          begin: const Offset(0.5, 0.5),
          duration: 300.ms,
          curve: Curves.elasticOut,
        );
  }
}

/// 퀵 보상 토스트 (화면 상단에 잠깐 표시)
class RewardToast extends StatelessWidget {
  final List<RewardItem> rewards;

  const RewardToast({
    super.key,
    required this.rewards,
  });

  /// 토스트 표시
  static void show(BuildContext context, List<RewardItem> rewards) {
    if (rewards.isEmpty) return;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 60,
        left: 20,
        right: 20,
        child: RewardToast(rewards: rewards),
      ),
    );

    overlay.insert(entry);

    // Auto dismiss after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      entry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Wrap(
                spacing: 12,
                children: rewards.map((r) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(r.icon, size: 16, color: r.color),
                      const SizedBox(width: 4),
                      Text(
                        '+${r.quantity}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: r.color,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 200.ms)
          .slideY(begin: -0.5, duration: 300.ms, curve: Curves.easeOut)
          .then(delay: 2000.ms)
          .fadeOut(duration: 300.ms)
          .slideY(end: -0.5),
    );
  }
}
