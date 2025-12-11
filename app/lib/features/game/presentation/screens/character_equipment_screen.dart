import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';

class CharacterEquipmentScreen extends ConsumerWidget {
  const CharacterEquipmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('장비 관리')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 캐릭터 + 장비 슬롯
            Expanded(
              flex: 2,
              child: _buildEquipmentSlots(),
            ),
            const SizedBox(height: 16),
            // 장비 효과 요약
            _buildEquipmentStats(),
            const SizedBox(height: 16),
            // 세트 효과
            _buildSetEffect(),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentSlots() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // 좌측 슬롯
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSlot('투구', Icons.masks, '전설', const Color(0xFFFF9800)),
              _buildSlot('갑옷', Icons.checkroom, '영웅', const Color(0xFF9C27B0)),
              _buildSlot('장갑', Icons.front_hand, '희귀', const Color(0xFF2196F3)),
            ],
          ),
          // 캐릭터
          Expanded(
            child: Center(
              child: Container(
                width: 100,
                height: 140,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
          ),
          // 우측 슬롯
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSlot('무기', Icons.gavel, '영웅', const Color(0xFF9C27B0)),
              _buildSlot('방패', Icons.shield, '희귀', const Color(0xFF2196F3)),
              _buildSlot('신발', Icons.snowshoeing, '고급', const Color(0xFF4CAF50)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlot(String label, IconData icon, String grade, Color color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
        Text(grade, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildEquipmentStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('장비 효과', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatBadge('공격력', '+120', AppTheme.dangerColor),
              _buildStatBadge('방어력', '+85', AppTheme.primaryColor),
              _buildStatBadge('HP', '+200', AppTheme.hpBarFill),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
          Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSetEffect() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF9800).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFFFF9800)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('전설 세트 (2/4)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Text('공격력 +15%', style: TextStyle(fontSize: 12, color: const Color(0xFFFF9800))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
