import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class ChallengeScreen extends ConsumerWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('챌린지'),
          actions: [
            IconButton(onPressed: () => context.push('/challenge/ranking'), icon: const Icon(Icons.leaderboard)),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '일일'),
              Tab(text: '주간'),
              Tab(text: '월간'),
              Tab(text: '솔로'),
              Tab(text: '커뮤니티'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDailyQuests(),
            _buildWeeklyQuests(),
            _buildMonthlyQuests(),
            _buildSoloChallenges(context),
            _buildCommunityChallenges(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyQuests() {
    final quests = [
      ('오늘의 기록', '거래 1건 기록', '강화석 x3', true, 1, 1),
      ('성실한 기록', '거래 5건 기록', '강화석 x5, 스킬북 x1', true, 5, 5),
      ('인증왕', '영수증 인증 3건', '가챠 티켓 x1', false, 1, 3),
    ];

    return _buildQuestList(quests, '일일 퀘스트가 초기화됩니다', '12:34:56');
  }

  Widget _buildWeeklyQuests() {
    final quests = [
      ('7일 연속 기록', '7일 연속 기록', '가챠 티켓 x3, 스킬북 (고급) x1', false, 5, 7),
      ('인증 마스터', '주간 영수증 인증 20건', '프리미엄 티켓 x2', false, 8, 20),
      ('예산 수호자', '주간 예산 준수', '가챠 티켓 x2', false, 0, 1),
    ];

    return _buildQuestList(quests, '주간 퀘스트가 초기화됩니다', '3일 12:34:56');
  }

  Widget _buildMonthlyQuests() {
    final quests = [
      ('30일 연속 기록', '30일 연속 기록', '각성석 x2, 프리미엄 티켓 x5', false, 15, 30),
      ('인증 달인', '월간 영수증 인증 50건', '각성석 x3', false, 23, 50),
      ('예산의 제왕', '월간 예산 준수', '스킬북 (희귀) x1', false, 0, 1),
    ];

    return _buildQuestList(quests, '월간 퀘스트가 초기화됩니다', '15일 12:34:56');
  }

  Widget _buildQuestList(List<(String, String, String, bool, int, int)> quests, String resetLabel, String resetTime) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 연속 기록 배너
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppTheme.warningColor.withValues(alpha: 0.2), AppTheme.warningColor.withValues(alpha: 0.05)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department, color: AppTheme.warningColor, size: 32),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('연속 기록', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('15일째!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.warningColor)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(resetLabel, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                  Text(resetTime, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...quests.map((q) => _buildQuestCard(q.$1, q.$2, q.$3, q.$4, q.$5, q.$6)),
      ],
    );
  }

  Widget _buildQuestCard(String title, String desc, String reward, bool completed, int current, int max) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: completed ? AppTheme.accentColor.withValues(alpha: 0.1) : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: completed ? Border.all(color: AppTheme.accentColor) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(completed ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: completed ? AppTheme.accentColor : AppTheme.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: completed ? AppTheme.accentColor : AppTheme.textPrimary,
                      decoration: completed ? TextDecoration.lineThrough : null,
                    )),
                    Text(desc, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: current / max,
            backgroundColor: AppTheme.borderColor,
            color: completed ? AppTheme.accentColor : AppTheme.primaryColor,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$current / $max', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.goldColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(reward, style: TextStyle(fontSize: 12, color: AppTheme.goldColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSoloChallenges(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildChallengeCard('무지출 챌린지', '오늘 지출 0원', '프리미엄 티켓 x1', AppTheme.primaryColor, () => context.push('/challenge/solo')),
        _buildChallengeCard('절약왕', '일주일 지출 10만원 이하', '각성석 x1', AppTheme.accentColor, () => context.push('/challenge/solo')),
        _buildChallengeCard('저축 마스터', '이번 달 50만원 저축', '가챠 티켓 x5', AppTheme.goldColor, () => context.push('/challenge/solo')),
      ],
    );
  }

  Widget _buildCommunityChallenges(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCommunityCard('함께 절약!', '참가자 1,234명', '1,000,000원 절약 목표', 750000, 1000000, () => context.push('/challenge/community')),
        _buildCommunityCard('기록 챌린지', '참가자 856명', '총 10,000건 기록', 7500, 10000, () => context.push('/challenge/community')),
      ],
    );
  }

  Widget _buildChallengeCard(String title, String desc, String reward, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.flag, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  Text(desc, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  Text(reward, style: TextStyle(fontSize: 12, color: color)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityCard(String title, String participants, String goal, int current, int max, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppTheme.primaryColor.withValues(alpha: 0.1), AppTheme.primaryColor.withValues(alpha: 0.05)]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.groups, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                const Spacer(),
                Text(participants, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),
            Text(goal, style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: current / max, backgroundColor: AppTheme.borderColor, color: AppTheme.primaryColor),
            const SizedBox(height: 4),
            Text('${(current / max * 100).toInt()}% 달성', style: TextStyle(fontSize: 12, color: AppTheme.primaryColor)),
          ],
        ),
      ),
    );
  }
}
