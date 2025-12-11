import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class PetScreen extends ConsumerWidget {
  const PetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('펫'),
          bottom: const TabBar(tabs: [Tab(text: '내 펫'), Tab(text: '도감'), Tab(text: '부화')]),
        ),
        body: TabBarView(children: [_buildMyPets(context), _buildPetCollection(), _buildHatchery()]),
      ),
    );
  }

  Widget _buildMyPets(BuildContext context) {
    final pets = [
      ('골드냥이', '골드 획득 +15%', Icons.pets, 10, AppTheme.goldColor, true),
      ('경험돼지', 'XP 획득 +10%', Icons.savings, 5, AppTheme.xpBarFill, false),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(Icons.egg, color: AppTheme.warningColor),
              const SizedBox(width: 12),
              const Text('펫 먹이:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              const Text('45', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.warningColor)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...pets.map((pet) => _buildPetCard(context, pet.$1, pet.$2, pet.$3, pet.$4, pet.$5, pet.$6)),
      ],
    );
  }

  Widget _buildPetCard(BuildContext context, String name, String effect, IconData icon, int level, Color color, bool isActive) {
    return GestureDetector(
      onTap: () => context.push('/game/pet/detail/1'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: isActive ? Border.all(color: AppTheme.accentColor, width: 2) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                        child: Text('Lv.$level', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle, color: AppTheme.accentColor, size: 16),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(effect, style: TextStyle(fontSize: 12, color: AppTheme.accentColor)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildPetCollection() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 12, crossAxisSpacing: 12),
      itemCount: 12,
      itemBuilder: (context, index) {
        final owned = index < 2;
        return Container(
          decoration: BoxDecoration(
            color: owned ? AppTheme.surfaceColor : AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: owned ? AppTheme.primaryColor : AppTheme.borderColor),
          ),
          child: Icon(owned ? Icons.pets : Icons.help_outline, color: owned ? AppTheme.primaryColor : AppTheme.textTertiary, size: 32),
        );
      },
    );
  }

  Widget _buildHatchery() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(color: AppTheme.warningColor, width: 3),
            ),
            child: const Icon(Icons.egg, size: 64, color: AppTheme.warningColor),
          ),
          const SizedBox(height: 24),
          Text('펫 알', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text('필요 먹이: 50개', style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Text('보유: 45개', style: TextStyle(color: AppTheme.warningColor)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.egg_alt),
            label: const Text('부화하기 (5개 부족)'),
          ),
        ],
      ),
    );
  }
}
