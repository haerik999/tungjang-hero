import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 기본 Shimmer 로딩 효과
class ShimmerLoading extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final shimmerColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 1500),
          color: shimmerColor,
        );
  }
}

/// 카드 형태 스켈레톤
class SkeletonCard extends StatelessWidget {
  final double? height;

  const SkeletonCard({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ShimmerLoading(width: 48, height: 48, borderRadius: 8),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerLoading(height: 16, width: 120),
                      const SizedBox(height: 8),
                      const ShimmerLoading(height: 12, width: 80),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const ShimmerLoading(height: 12),
            const SizedBox(height: 8),
            const ShimmerLoading(height: 12, width: 200),
          ],
        ),
      ),
    );
  }
}

/// 리스트 아이템 스켈레톤
class SkeletonListTile extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;

  const SkeletonListTile({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (hasLeading) ...[
            const ShimmerLoading(width: 40, height: 40, borderRadius: 8),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoading(height: 14, width: 120),
                const SizedBox(height: 6),
                const ShimmerLoading(height: 12, width: 80),
              ],
            ),
          ),
          if (hasTrailing)
            const ShimmerLoading(width: 60, height: 14),
        ],
      ),
    );
  }
}

/// 히어로 카드 스켈레톤
class SkeletonHeroCard extends StatelessWidget {
  const SkeletonHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 캐릭터 영역
            const ShimmerLoading(width: 80, height: 80, borderRadius: 40),
            const SizedBox(height: 16),
            // 레벨 & 이름
            const ShimmerLoading(width: 100, height: 20),
            const SizedBox(height: 8),
            const ShimmerLoading(width: 60, height: 14),
            const SizedBox(height: 16),
            // HP/XP 바
            const ShimmerLoading(height: 8, borderRadius: 4),
            const SizedBox(height: 8),
            const ShimmerLoading(height: 8, borderRadius: 4),
          ],
        ),
      ),
    );
  }
}

/// 통계 요약 스켈레톤
class SkeletonSummary extends StatelessWidget {
  final int itemCount;

  const SkeletonSummary({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            itemCount,
            (_) => Column(
              children: [
                const ShimmerLoading(width: 40, height: 12),
                const SizedBox(height: 8),
                const ShimmerLoading(width: 60, height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 거래 목록 스켈레톤
class SkeletonTransactionList extends StatelessWidget {
  final int itemCount;

  const SkeletonTransactionList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Column(
          children: [
            const SkeletonListTile(),
            if (index < itemCount - 1) const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}
