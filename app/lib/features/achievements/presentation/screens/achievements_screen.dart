import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('업적'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Summary
            _buildStatsSummary().animate().fadeIn().slideY(begin: -0.1),
            const SizedBox(height: 24),

            // Achievement Categories
            _buildAchievementSection(
              '절약의 달인',
              [
                _Achievement('🌱', '첫 걸음', '첫 저축을 시작했습니다', true),
                _Achievement('💰', '동전 모으기', '10,000원 절약 달성', true),
                _Achievement('💵', '지폐 모으기', '100,000원 절약 달성', true),
                _Achievement('💎', '다이아몬드 손', '1,000,000원 절약 달성', false),
              ],
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 16),

            _buildAchievementSection(
              '꾸준함의 증거',
              [
                _Achievement('📝', '하루 기록', '첫 가계부 작성', true),
                _Achievement('📅', '일주일 연속', '7일 연속 기록', true),
                _Achievement('📆', '한 달 연속', '30일 연속 기록', false),
                _Achievement('🗓️', '1년 마스터', '365일 연속 기록', false),
              ],
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 16),

            _buildAchievementSection(
              '퀘스트 헌터',
              [
                _Achievement('⚔️', '첫 퀘스트', '첫 퀘스트 완료', true),
                _Achievement('🗡️', '퀘스트 수집가', '10개 퀘스트 완료', false),
                _Achievement('🏹', '퀘스트 전문가', '50개 퀘스트 완료', false),
                _Achievement('👑', '퀘스트 마스터', '100개 퀘스트 완료', false),
              ],
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 16),

            _buildAchievementSection(
              '레벨업 여정',
              [
                _Achievement('⭐', '입문자', '레벨 5 달성', true),
                _Achievement('⭐⭐', '숙련자', '레벨 10 달성', false),
                _Achievement('⭐⭐⭐', '전문가', '레벨 25 달성', false),
                _Achievement('🌟', '마스터', '레벨 50 달성', false),
                _Achievement('✨', '그랜드 마스터', '레벨 100 달성', false),
              ],
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.goldColor.withValues(alpha: 0.2),
            AppTheme.primaryColor.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.goldColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('🏆', '획득', '6/17'),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.textSecondary.withValues(alpha: 0.3),
          ),
          _buildStatItem('⭐', '완료율', '35%'),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.textSecondary.withValues(alpha: 0.3),
          ),
          _buildStatItem('🔥', '연속', '12일'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.goldColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementSection(String title, List<_Achievement> achievements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return _buildAchievementItem(achievement);
          },
        ),
      ],
    );
  }

  Widget _buildAchievementItem(_Achievement achievement) {
    return GestureDetector(
      onTap: () {
        // Show achievement details
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: achievement.unlocked
              ? AppTheme.goldColor.withValues(alpha: 0.15)
              : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: achievement.unlocked
                ? AppTheme.goldColor.withValues(alpha: 0.5)
                : AppTheme.textSecondary.withValues(alpha: 0.2),
            width: achievement.unlocked ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              achievement.unlocked ? achievement.emoji : '🔒',
              style: TextStyle(
                fontSize: 28,
                color: achievement.unlocked ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: achievement.unlocked
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary.withValues(alpha: 0.5),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _Achievement {
  final String emoji;
  final String title;
  final String description;
  final bool unlocked;

  _Achievement(this.emoji, this.title, this.description, this.unlocked);
}
