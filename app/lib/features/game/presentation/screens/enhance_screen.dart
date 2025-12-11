import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class EnhanceScreen extends StatelessWidget {
  final String itemId;
  const EnhanceScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('장비 강화')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 장비 미리보기
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildItemPreview('+7'),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Icon(Icons.arrow_forward, size: 32, color: AppTheme.primaryColor),
                  ),
                  _buildItemPreview('+8', isTarget: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 성공 확률
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('성공 확률', style: TextStyle(color: AppTheme.textSecondary)),
                      Text('45%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.accentColor)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: 0.45, backgroundColor: AppTheme.borderColor, color: AppTheme.accentColor),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('실패 시', style: TextStyle(color: AppTheme.textSecondary)),
                      Text('강화 수치 유지', style: TextStyle(color: AppTheme.warningColor)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 재료
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('필요 재료', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  _buildMaterialRow('강화석', 10, 23),
                  _buildMaterialRow('골드', 5000, 125340),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('강화하기', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemPreview(String level, {bool isTarget = false}) {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFFF9800).withValues(alpha: isTarget ? 0.3 : 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF9800), width: isTarget ? 2 : 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.gavel, size: 36, color: const Color(0xFFFF9800)),
          const SizedBox(height: 8),
          Text(level, style: TextStyle(fontWeight: FontWeight.bold, color: isTarget ? AppTheme.accentColor : AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildMaterialRow(String name, int required, int owned) {
    final enough = owned >= required;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(name == '골드' ? Icons.monetization_on : Icons.diamond, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(name, style: TextStyle(color: AppTheme.textPrimary)),
          const Spacer(),
          Text('$required', style: TextStyle(fontWeight: FontWeight.bold, color: enough ? AppTheme.accentColor : AppTheme.dangerColor)),
          Text(' / $owned', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
