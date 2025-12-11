import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/inventory_provider.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formatter = NumberFormat('#,###', 'ko_KR');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inventoryNotifierProvider.notifier).loadInventory();
      ref.read(inventoryNotifierProvider.notifier).loadEquipments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('인벤토리'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '아이템'),
            Tab(text: '장비'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  _formatter.format(state.gold),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _ItemsTab(items: state.items),
                _EquipmentsTab(
                  equipped: state.equippedItems,
                  inventory: state.inventoryEquipments,
                ),
              ],
            ),
    );
  }
}

class _ItemsTab extends ConsumerWidget {
  final List<dynamic> items;

  const _ItemsTab({required this.items});

  IconData _getItemIcon(String itemType) {
    switch (itemType) {
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
        return Icons.inventory_2;
    }
  }

  Color _getItemColor(String itemType) {
    switch (itemType) {
      case 'enhancement_stone':
        return Colors.blue;
      case 'skill_book':
        return Colors.purple;
      case 'gacha_ticket':
        return Colors.amber;
      case 'pet_food':
        return Colors.green;
      case 'hp_potion':
        return Colors.red;
      case 'xp_potion':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getItemName(String itemType) {
    switch (itemType) {
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
        return itemType;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '아이템이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '거래를 기록하면 보상 아이템을 받을 수 있어요!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final itemType = item['item_type'] as String;
        final quantity = item['quantity'] as int;
        final color = _getItemColor(itemType);

        return InkWell(
          onTap: () => _showItemOptions(context, ref, itemType, quantity),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getItemIcon(itemType),
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getItemName(itemType),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'x$quantity',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showItemOptions(
      BuildContext context, WidgetRef ref, String itemType, int quantity) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _getItemName(itemType),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '보유: $quantity개',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (itemType == 'hp_potion' || itemType == 'xp_potion')
                ElevatedButton.icon(
                  onPressed: quantity > 0
                      ? () async {
                          Navigator.pop(context);
                          await ref
                              .read(inventoryNotifierProvider.notifier)
                              .useItem(itemType, 1);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('${_getItemName(itemType)}을(를) 사용했습니다!'),
                              ),
                            );
                          }
                        }
                      : null,
                  icon: const Icon(Icons.check),
                  label: const Text('사용하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.black87,
                  ),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: quantity > 0
                    ? () async {
                        Navigator.pop(context);
                        await ref
                            .read(inventoryNotifierProvider.notifier)
                            .sellItems(itemType, 1);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('${_getItemName(itemType)}을(를) 판매했습니다!'),
                            ),
                          );
                        }
                      }
                    : null,
                icon: const Icon(Icons.sell),
                label: const Text('판매하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EquipmentsTab extends ConsumerWidget {
  final List<dynamic> equipped;
  final List<dynamic> inventory;

  const _EquipmentsTab({
    required this.equipped,
    required this.inventory,
  });

  String _getSlotName(String slot) {
    switch (slot) {
      case 'weapon':
        return '무기';
      case 'armor':
        return '방어구';
      case 'accessory':
        return '장신구';
      default:
        return slot;
    }
  }

  IconData _getSlotIcon(String slot) {
    switch (slot) {
      case 'weapon':
        return Icons.gavel;
      case 'armor':
        return Icons.shield;
      case 'accessory':
        return Icons.diamond;
      default:
        return Icons.inventory;
    }
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'legendary':
        return Colors.orange;
      case 'epic':
        return Colors.purple;
      case 'rare':
        return Colors.blue;
      case 'uncommon':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Equipped Section
          const Text(
            '장착 중',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: ['weapon', 'armor', 'accessory'].map((slot) {
              final equip = equipped.firstWhere(
                (e) => e['slot'] == slot,
                orElse: () => null,
              );

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _EquipmentSlot(
                    slot: slot,
                    equipment: equip,
                    onTap: () {
                      if (equip != null) {
                        _showEquipmentDetails(context, ref, equip, true);
                      }
                    },
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Inventory Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '보관함',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${inventory.length}개',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (inventory.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '장비가 없습니다',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.9,
              ),
              itemCount: inventory.length,
              itemBuilder: (context, index) {
                final equip = inventory[index];
                final grade = equip['grade'] as String? ?? 'common';
                final level = equip['enhancement_level'] as int? ?? 0;
                final color = _getGradeColor(grade);

                return InkWell(
                  onTap: () => _showEquipmentDetails(context, ref, equip, false),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.5)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getSlotIcon(equip['slot'] ?? 'weapon'),
                          color: color,
                          size: 24,
                        ),
                        if (level > 0)
                          Text(
                            '+$level',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showEquipmentDetails(
      BuildContext context, WidgetRef ref, dynamic equip, bool isEquipped) {
    final grade = equip['grade'] as String? ?? 'common';
    final color = _getGradeColor(grade);
    final level = equip['enhancement_level'] as int? ?? 0;
    final slot = equip['slot'] as String? ?? 'weapon';
    final stats = equip['stats'] as Map<String, dynamic>? ?? {};

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color),
                    ),
                    child: Icon(
                      _getSlotIcon(slot),
                      color: color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              equip['name'] ?? _getSlotName(slot),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            if (level > 0)
                              Text(
                                ' +$level',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          '${grade.toUpperCase()} ${_getSlotName(slot)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Stats
              if (stats.isNotEmpty)
                ...stats.entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key.toUpperCase()),
                          Text(
                            '+${e.value}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    )),

              const SizedBox(height: 16),

              // Actions
              if (isEquipped)
                OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await ref
                        .read(inventoryNotifierProvider.notifier)
                        .unequipItem(equip['id']);
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  label: const Text('장착 해제'),
                )
              else ...[
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await ref
                        .read(inventoryNotifierProvider.notifier)
                        .equipItem(equip['id']);
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('장착하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          final result = await ref
                              .read(inventoryNotifierProvider.notifier)
                              .enhanceEquipment(equip['id']);
                          if (context.mounted && result != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result['success'] == true
                                      ? '강화 성공!'
                                      : '강화 실패...',
                                ),
                                backgroundColor: result['success'] == true
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.arrow_upward),
                        label: const Text('강화'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          await ref
                              .read(inventoryNotifierProvider.notifier)
                              .sellEquipment(equip['id']);
                        },
                        icon: const Icon(Icons.sell),
                        label: const Text('판매'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EquipmentSlot extends StatelessWidget {
  final String slot;
  final dynamic equipment;
  final VoidCallback onTap;

  const _EquipmentSlot({
    required this.slot,
    required this.equipment,
    required this.onTap,
  });

  String _getSlotName(String slot) {
    switch (slot) {
      case 'weapon':
        return '무기';
      case 'armor':
        return '방어구';
      case 'accessory':
        return '장신구';
      default:
        return slot;
    }
  }

  IconData _getSlotIcon(String slot) {
    switch (slot) {
      case 'weapon':
        return Icons.gavel;
      case 'armor':
        return Icons.shield;
      case 'accessory':
        return Icons.diamond;
      default:
        return Icons.inventory;
    }
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'legendary':
        return Colors.orange;
      case 'epic':
        return Colors.purple;
      case 'rare':
        return Colors.blue;
      case 'uncommon':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (equipment == null) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getSlotIcon(slot),
              color: Colors.grey[400],
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              _getSlotName(slot),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    final grade = equipment['grade'] as String? ?? 'common';
    final level = equipment['enhancement_level'] as int? ?? 0;
    final color = _getGradeColor(grade);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getSlotIcon(slot),
              color: color,
              size: 32,
            ),
            const SizedBox(height: 4),
            if (level > 0)
              Text(
                '+$level',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            Text(
              _getSlotName(slot),
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
