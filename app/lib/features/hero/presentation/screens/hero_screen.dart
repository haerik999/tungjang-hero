import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../providers/hero_provider.dart';

class HeroScreen extends ConsumerWidget {
  const HeroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heroStatsAsync = ref.watch(heroStatsProvider);
    final title = ref.watch(heroTitleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('히어로 상태'),
      ),
      body: heroStatsAsync.when(
        data: (stats) {
          final level = stats?.level ?? 1;
          final currentXp = stats?.currentXp ?? 0;
          final requiredXp = stats?.requiredXp ?? 100;
          final currentHp = stats?.currentHp ?? 100;
          final maxHp = stats?.maxHp ?? 100;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Hero Avatar & Level
                _buildHeroAvatar(
                  level: level,
                  title: title,
                  currentXp: currentXp,
                  requiredXp: requiredXp,
                  currentHp: currentHp,
                  maxHp: maxHp,
                ).animate().scale().fadeIn(),
                const SizedBox(height: 24),

                // Stats Cards
                _buildStatsGrid(currentHp, maxHp).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 24),

                // Skills Section
                Text(
                  '스킬',
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 12),
                _buildSkillsList().animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 24),

                // Titles Section
                Text(
                  '칭호',
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 12),
                _buildTitlesList(level).animate().fadeIn(delay: 600.ms),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
      ),
    );
  }

  Widget _buildHeroAvatar({
    required int level,
    required String title,
    required int currentXp,
    required int requiredXp,
    required int currentHp,
    required int maxHp,
  }) {
    final hpPercentage = maxHp > 0 ? currentHp / maxHp : 1.0;
    final xpProgress = requiredXp > 0 ? currentXp / requiredXp : 0.0;

    return Column(
      children: [
        // 캐릭터 위젯
        HeroCharacter.fromHp(
          hpPercentage: hpPercentage,
          size: HeroCharacterSize.large,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryColor),
          ),
          child: Text(
            'Lv. $level',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        // XP Progress
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'EXP',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  Text(
                    '$currentXp / $requiredXp',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: xpProgress.clamp(0.0, 1.0),
                backgroundColor: AppTheme.xpBarBackground,
                valueColor: const AlwaysStoppedAnimation(AppTheme.xpBarFill),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(int currentHp, int maxHp) {
    // 레벨 기반 스탯 계산 (추후 확장 가능)
    final attack = 10 + (currentHp ~/ 20);
    final defense = 5 + (maxHp ~/ 25);
    final luck = 10 + (currentHp ~/ 15);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('HP', '$currentHp', '$maxHp',
          currentHp < maxHp * 0.3 ? AppTheme.dangerColor : AppTheme.textSecondary,
          Icons.favorite),
        _buildStatCard('공격력', '$attack', null, AppTheme.textSecondary, Icons.flash_on),
        _buildStatCard('방어력', '$defense', null, AppTheme.textSecondary, Icons.shield),
        _buildStatCard('행운', '$luck', null, AppTheme.textSecondary, Icons.star),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String? max,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              max != null ? '$value/$max' : value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsList() {
    return Card(
      child: Column(
        children: [
          _buildSkillItem('알뜰 구매', '구매시 10% 추가 절약', 2, 5, AppTheme.primaryColor),
          const Divider(height: 1),
          _buildSkillItem('꾸준한 저축', '매일 저축시 보너스 XP', 3, 5, AppTheme.primaryColor),
          const Divider(height: 1),
          _buildSkillItem('충동 방어', '과소비 데미지 20% 감소', 1, 5, AppTheme.primaryColor),
        ],
      ),
    );
  }

  Widget _buildSkillItem(
    String name,
    String description,
    int level,
    int maxLevel,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'Lv.$level',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        description,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(maxLevel, (index) {
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: index < level ? color : AppTheme.surfaceColor,
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTitlesList(int level) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildTitleChip('🌱 텅장 뉴비', true), // 레벨 1
        _buildTitleChip('💪 절약 초보자', level >= 5),
        _buildTitleChip('📚 절약 수련생', level >= 10),
        _buildTitleChip('⚔️ 알뜰 전사', level >= 20),
        _buildTitleChip('🏆 저축 달인', level >= 30),
        _buildTitleChip('👑 절약의 왕', level >= 50),
      ],
    );
  }

  Widget _buildTitleChip(String title, bool unlocked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: unlocked
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unlocked ? AppTheme.primaryColor : AppTheme.borderColor,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: unlocked ? AppTheme.primaryColor : AppTheme.textTertiary,
          fontWeight: unlocked ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
