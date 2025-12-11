import 'package:flutter/material.dart';
import 'shimmer_loading.dart';

/// 홈 화면 스켈레톤
class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 히어로 카드 스켈레톤
          const SkeletonHeroCard(),
          const SizedBox(height: 16),
          // 요약 카드 스켈레톤
          const SkeletonSummary(),
          const SizedBox(height: 16),
          // 퀘스트 섹션
          const ShimmerLoading(width: 100, height: 20),
          const SizedBox(height: 12),
          const SkeletonCard(),
          const SizedBox(height: 16),
          // 최근 거래 섹션
          const ShimmerLoading(width: 100, height: 20),
          const SizedBox(height: 12),
          const SkeletonTransactionList(itemCount: 3),
        ],
      ),
    );
  }
}

/// 히어로 화면 스켈레톤
class HeroScreenSkeleton extends StatelessWidget {
  const HeroScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 캐릭터 영역
          const ShimmerLoading(width: 120, height: 120, borderRadius: 60),
          const SizedBox(height: 24),
          // 레벨 & HP/XP
          const ShimmerLoading(width: 150, height: 24),
          const SizedBox(height: 16),
          const ShimmerLoading(height: 12, borderRadius: 6),
          const SizedBox(height: 8),
          const ShimmerLoading(height: 12, borderRadius: 6),
          const SizedBox(height: 24),
          // 스탯 카드
          const SkeletonCard(height: 200),
          const SizedBox(height: 16),
          // 장비 카드
          const SkeletonCard(height: 150),
        ],
      ),
    );
  }
}

/// 거래 목록 화면 스켈레톤
class TransactionsScreenSkeleton extends StatelessWidget {
  const TransactionsScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 요약 카드
        const Padding(
          padding: EdgeInsets.all(16),
          child: SkeletonSummary(),
        ),
        // 거래 목록
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 10,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, __) => const SkeletonListTile(),
          ),
        ),
      ],
    );
  }
}

/// 예산 화면 스켈레톤
class BudgetScreenSkeleton extends StatelessWidget {
  const BudgetScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 전체 예산 요약
          const SkeletonSummary(),
          const SizedBox(height: 16),
          // 카테고리별 예산
          ...List.generate(5, (index) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: SkeletonCard(height: 80),
          )),
        ],
      ),
    );
  }
}

/// 퀘스트 화면 스켈레톤
class QuestsScreenSkeleton extends StatelessWidget {
  const QuestsScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const SkeletonCard(height: 100),
    );
  }
}

/// 챌린지 화면 스켈레톤
class ChallengesScreenSkeleton extends StatelessWidget {
  const ChallengesScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const SkeletonCard(height: 120),
    );
  }
}

/// 업적 화면 스켈레톤
class AchievementsScreenSkeleton extends StatelessWidget {
  const AchievementsScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: 8,
      itemBuilder: (_, __) => const SkeletonCard(),
    );
  }
}

/// 인벤토리 화면 스켈레톤
class InventoryScreenSkeleton extends StatelessWidget {
  const InventoryScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: 16,
      itemBuilder: (_, __) => const ShimmerLoading(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 8,
      ),
    );
  }
}
