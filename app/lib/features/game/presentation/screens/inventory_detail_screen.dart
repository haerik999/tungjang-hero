import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class InventoryDetailScreen extends StatelessWidget {
  final String itemId;
  const InventoryDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('아이템 상세')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 아이템 미리보기
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFFF9800).withValues(alpha: 0.2), const Color(0xFFFF9800).withValues(alpha: 0.05)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFF9800)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.gavel, size: 48, color: Color(0xFFFF9800)),
                  ),
                  const SizedBox(height: 12),
                  const Text('전설의 검 +7', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('전설', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 스탯
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('기본 능력치', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  _buildStatRow('공격력', '+125'),
                  _buildStatRow('치명타 확률', '+8%'),
                  _buildStatRow('공격 속도', '+5%'),
                  const Divider(height: 24),
                  Text('강화 보너스 (+7)', style: TextStyle(fontWeight: FontWeight.bold, color: const Color(0xFFFF9800))),
                  const SizedBox(height: 8),
                  _buildStatRow('공격력', '+42', color: const Color(0xFFFF9800)),
                ],
              ),
            ),
            const Spacer(),
            // 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/game/inventory/enhance/$itemId'),
                    icon: const Icon(Icons.upgrade),
                    label: const Text('강화'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.checkroom),
                    label: const Text('장착'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color ?? AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
