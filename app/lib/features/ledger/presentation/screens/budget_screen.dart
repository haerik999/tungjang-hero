import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'ko_KR');

    return Scaffold(
      appBar: AppBar(title: const Text('예산 관리')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 총 예산
          _buildTotalBudget(formatter),
          const SizedBox(height: 24),
          // 카테고리별 예산
          Text('카테고리별 예산', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          _buildCategoryBudget('식비', 500000, 450000, formatter),
          _buildCategoryBudget('교통', 200000, 150000, formatter),
          _buildCategoryBudget('생활', 400000, 380000, formatter),
          _buildCategoryBudget('쇼핑', 300000, 320000, formatter), // 초과
          _buildCategoryBudget('문화', 200000, 180000, formatter),
          const SizedBox(height: 24),
          // 예산 퀘스트
          _buildBudgetQuest(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditBudgetDialog(context),
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildTotalBudget(NumberFormat formatter) {
    const budget = 2500000;
    const spent = 1823500;
    const ratio = spent / budget;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor.withValues(alpha: 0.1), AppTheme.primaryColor.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('이번 달 예산', style: TextStyle(fontSize: 16)),
              Text('${formatter.format(budget)}원', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 24,
                decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(12)),
              ),
              FractionallySizedBox(
                widthFactor: ratio.clamp(0, 1),
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: ratio > 1 ? AppTheme.dangerColor : ratio > 0.8 ? AppTheme.warningColor : AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Text(
                    '${(ratio * 100).toInt()}%',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('사용', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  Text('${formatter.format(spent)}원', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('남은 금액', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  Text('${formatter.format(budget - spent)}원', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentColor)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBudget(String name, int budget, int spent, NumberFormat formatter) {
    final ratio = spent / budget;
    final isOver = ratio > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: isOver ? Border.all(color: AppTheme.dangerColor.withValues(alpha: 0.3)) : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const Spacer(),
              Text('${formatter.format(spent)}', style: TextStyle(color: isOver ? AppTheme.dangerColor : AppTheme.textPrimary)),
              Text(' / ${formatter.format(budget)}원', style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: ratio.clamp(0, 1),
            backgroundColor: AppTheme.borderColor,
            color: isOver ? AppTheme.dangerColor : ratio > 0.8 ? AppTheme.warningColor : AppTheme.accentColor,
          ),
          if (isOver)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.warning, size: 14, color: AppTheme.dangerColor),
                  const SizedBox(width: 4),
                  Text('${formatter.format(spent - budget)}원 초과', style: TextStyle(fontSize: 12, color: AppTheme.dangerColor)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBudgetQuest() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.goldColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.goldColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: AppTheme.goldColor),
              const SizedBox(width: 8),
              const Text('예산 퀘스트', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text('이번 달 예산 지키기', style: TextStyle(color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text('보상: 가챠 티켓 x2, 고급 강화석 x5', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: 0.73, backgroundColor: AppTheme.borderColor, color: AppTheme.goldColor),
          const SizedBox(height: 4),
          Text('73% 달성 (27% 남음)', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('예산 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: '총 예산', suffixText: '원'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('저장')),
        ],
      ),
    );
  }
}
