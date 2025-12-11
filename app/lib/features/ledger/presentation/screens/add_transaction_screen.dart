import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  bool _isIncome = false;
  String _selectedCategory = '식비';
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();
  bool _hasReceipt = false;

  final _expenseCategories = ['식비', '교통', '생활', '쇼핑', '문화', '의료', '교육', '카페', '기타'];
  final _incomeCategories = ['급여', '용돈', '투자', '부업', '기타'];

  @override
  Widget build(BuildContext context) {
    final categories = _isIncome ? _incomeCategories : _expenseCategories;

    return Scaffold(
      appBar: AppBar(title: const Text('거래 추가')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 수입/지출 토글
            Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() { _isIncome = false; _selectedCategory = '식비'; }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: !_isIncome ? AppTheme.dangerColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '지출',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: !_isIncome ? Colors.white : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() { _isIncome = true; _selectedCategory = '급여'; }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _isIncome ? AppTheme.primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '수입',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isIncome ? Colors.white : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 금액 입력
            Text('금액', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '0',
                suffixText: '원',
                suffixStyle: TextStyle(fontSize: 24, color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 24),
            // 카테고리
            Text('카테고리', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) => ChoiceChip(
                label: Text(cat),
                selected: _selectedCategory == cat,
                onSelected: (selected) => setState(() => _selectedCategory = cat),
                selectedColor: _isIncome ? AppTheme.primaryColor : AppTheme.dangerColor,
                labelStyle: TextStyle(
                  color: _selectedCategory == cat ? Colors.white : AppTheme.textPrimary,
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
            // 메모
            Text('메모 (선택)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            TextField(
              controller: _memoController,
              decoration: const InputDecoration(hintText: '메모를 입력하세요'),
            ),
            const SizedBox(height: 24),
            // 영수증 인증
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _hasReceipt ? AppTheme.accentColor.withValues(alpha: 0.1) : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _hasReceipt ? AppTheme.accentColor : AppTheme.borderColor,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        _hasReceipt ? Icons.check_circle : Icons.camera_alt,
                        color: _hasReceipt ? AppTheme.accentColor : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '영수증 인증',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                            Text(
                              '인증 시 추가 보상 획득!',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _hasReceipt,
                        onChanged: (v) => setState(() => _hasReceipt = v),
                        activeColor: AppTheme.accentColor,
                      ),
                    ],
                  ),
                  if (_hasReceipt) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderColor, style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 32, color: AppTheme.textSecondary),
                          const SizedBox(height: 8),
                          Text('영수증 사진 추가', style: TextStyle(color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 예상 보상
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.goldColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.card_giftcard, color: AppTheme.goldColor),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('예상 보상', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.diamond, size: 16, color: AppTheme.primaryColor),
                          const SizedBox(width: 4),
                          const Text('강화석 1~2'),
                        ],
                      ),
                      if (_hasReceipt)
                        Row(
                          children: [
                            Icon(Icons.add, size: 14, color: AppTheme.accentColor),
                            const SizedBox(width: 4),
                            Text('추가 보상!', style: TextStyle(fontSize: 12, color: AppTheme.accentColor)),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // 저장 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isIncome ? AppTheme.primaryColor : AppTheme.dangerColor,
                ),
                child: const Text('기록하기', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTransaction() {
    // TODO: 저장 로직
    _showRewardDialog();
  }

  void _showRewardDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.celebration, color: AppTheme.goldColor),
            const SizedBox(width: 8),
            const Text('보상 획득!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRewardItem(Icons.diamond, '강화석', '+2', AppTheme.primaryColor),
            if (_hasReceipt)
              _buildRewardItem(Icons.menu_book, '스킬북', '+1', AppTheme.accentColor),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(IconData icon, String name, String count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(name),
          const Spacer(),
          Text(count, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
