import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class StageSelectScreen extends StatelessWidget {
  const StageSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stages = [
      ('초원', [15, 30], const Color(0xFF4CAF50), true),
      ('사막', [30, 50], const Color(0xFFFF9800), true),
      ('빙하', [50, 70], const Color(0xFF2196F3), false),
      ('화산', [70, 90], const Color(0xFFF44336), false),
      ('심연', [90, 100], const Color(0xFF9C27B0), false),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('스테이지 선택')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stages.length,
        itemBuilder: (context, index) {
          final stage = stages[index];
          return _buildStageCard(
            context,
            name: stage.$1,
            levelRange: stage.$2,
            color: stage.$3,
            unlocked: stage.$4,
            currentStage: index == 0,
          );
        },
      ),
    );
  }

  Widget _buildStageCard(
    BuildContext context, {
    required String name,
    required List<int> levelRange,
    required Color color,
    required bool unlocked,
    required bool currentStage,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: unlocked ? AppTheme.surfaceColor : AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: currentStage ? Border.all(color: color, width: 2) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: unlocked ? () => Navigator.pop(context) : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 아이콘
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: unlocked ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getStageIcon(name),
                    color: unlocked ? color : AppTheme.textTertiary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                // 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: unlocked ? AppTheme.textPrimary : AppTheme.textTertiary,
                            ),
                          ),
                          if (currentStage) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                              child: const Text('현재', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lv.${levelRange[0]} ~ ${levelRange[1]}',
                        style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                      ),
                      if (currentStage) ...[
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: 0.5, // 15/30
                          backgroundColor: AppTheme.borderColor,
                          color: color,
                        ),
                        const SizedBox(height: 4),
                        Text('15 / 30 스테이지', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ],
                  ),
                ),
                // 상태
                if (!unlocked)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.lock, color: AppTheme.textTertiary, size: 20),
                  )
                else
                  Icon(Icons.chevron_right, color: AppTheme.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getStageIcon(String name) {
    switch (name) {
      case '초원': return Icons.grass;
      case '사막': return Icons.wb_sunny;
      case '빙하': return Icons.ac_unit;
      case '화산': return Icons.whatshot;
      case '심연': return Icons.dark_mode;
      default: return Icons.place;
    }
  }
}
