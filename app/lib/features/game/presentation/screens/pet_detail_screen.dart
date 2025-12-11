import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PetDetailScreen extends StatelessWidget {
  final String petId;
  const PetDetailScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('펫 상세')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.goldColor.withValues(alpha: 0.2), AppTheme.goldColor.withValues(alpha: 0.05)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(color: AppTheme.goldColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(50)),
                    child: const Icon(Icons.pets, size: 60, color: AppTheme.goldColor),
                  ),
                  const SizedBox(height: 16),
                  const Text('골드냥이', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.goldColor, borderRadius: BorderRadius.circular(12)),
                    child: const Text('Lv.10', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('효과', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: AppTheme.goldColor),
                      const SizedBox(width: 8),
                      const Text('골드 획득'),
                      const Spacer(),
                      const Text('+15%', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentColor)),
                    ],
                  ),
                  const Divider(height: 24),
                  Text('다음 레벨 효과 (+1%)', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.surfaceColor, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('성장 경험치'),
                      Text('150 / 200', style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: 0.75, backgroundColor: AppTheme.borderColor, color: AppTheme.xpBarFill),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('해제'))),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.restaurant),
                    label: const Text('먹이 주기 (10)'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
