import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('인벤토리'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.sort)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '장비'),
            Tab(text: '소모품'),
            Tab(text: '재료'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEquipmentTab(),
          _buildConsumableTab(),
          _buildMaterialTab(),
        ],
      ),
    );
  }

  Widget _buildEquipmentTab() {
    final grades = [
      ('전설', const Color(0xFFFF9800)),
      ('영웅', const Color(0xFF9C27B0)),
      ('희귀', const Color(0xFF2196F3)),
      ('고급', const Color(0xFF4CAF50)),
      ('일반', Colors.grey),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 25,
      itemBuilder: (context, index) {
        final grade = grades[index % grades.length];
        return GestureDetector(
          onTap: () => context.push('/game/inventory/detail/$index'),
          child: Container(
            decoration: BoxDecoration(
              color: grade.$2.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: grade.$2),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    [Icons.gavel, Icons.shield, Icons.masks, Icons.checkroom, Icons.front_hand][index % 5],
                    color: grade.$2,
                  ),
                ),
                if (index < 5)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppTheme.dangerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('+7', style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConsumableTab() {
    final items = [
      ('HP 물약', Icons.local_drink, 25, AppTheme.hpBarFill),
      ('MP 물약', Icons.local_drink, 12, AppTheme.primaryColor),
      ('버프 물약', Icons.science, 5, AppTheme.accentColor),
      ('귀환서', Icons.home, 10, AppTheme.warningColor),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.$4.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.$2, color: item.$4),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(item.$1, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              ),
              Text('x${item.$3}', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () {}, child: const Text('사용')),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMaterialTab() {
    final materials = [
      ('강화석', Icons.diamond, 23, AppTheme.primaryColor),
      ('고급 강화석', Icons.diamond, 5, const Color(0xFF9C27B0)),
      ('스킬북 (일반)', Icons.menu_book, 8, AppTheme.accentColor),
      ('스킬북 (고급)', Icons.menu_book, 2, const Color(0xFFFF9800)),
      ('가챠 티켓', Icons.confirmation_number, 3, AppTheme.warningColor),
      ('프리미엄 티켓', Icons.confirmation_number, 1, const Color(0xFFFF9800)),
      ('각성석', Icons.auto_awesome, 2, const Color(0xFFF44336)),
      ('펫 먹이', Icons.pets, 45, const Color(0xFF4CAF50)),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final item = materials[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.$4.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.$2, color: item.$4),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(item.$1, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              ),
              Text('x${item.$3}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: item.$4)),
            ],
          ),
        );
      },
    );
  }
}
