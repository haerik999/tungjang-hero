import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';

class CharacterStatsScreen extends ConsumerWidget {
  const CharacterStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('스탯 배분')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatPoints(),
            const SizedBox(height: 24),
            _buildStatSlider('STR (힘)', 80, AppTheme.dangerColor),
            _buildStatSlider('DEX (민첩)', 60, AppTheme.accentColor),
            _buildStatSlider('INT (지능)', 40, AppTheme.primaryColor),
            _buildStatSlider('VIT (체력)', 50, AppTheme.warningColor),
            _buildStatSlider('LUK (행운)', 30, AppTheme.goldColor),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPoints() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stars, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Text(
            '사용 가능 포인트:',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(width: 8),
          const Text(
            '15',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatSlider(String label, int value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              Text('$value', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.remove_circle),
                color: AppTheme.textSecondary,
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: color,
                    inactiveTrackColor: color.withValues(alpha: 0.2),
                    thumbColor: color,
                  ),
                  child: Slider(
                    value: value.toDouble(),
                    min: 0,
                    max: 200,
                    onChanged: (v) {},
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add_circle),
                color: color,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            child: const Text('초기화'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            child: const Text('적용'),
          ),
        ),
      ],
    );
  }
}
