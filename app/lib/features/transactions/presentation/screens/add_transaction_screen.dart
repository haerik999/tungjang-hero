import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/number_keypad.dart';
import '../providers/transaction_provider.dart';
import '../../../budget/presentation/providers/budget_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  final bool? initialIsIncome;

  const AddTransactionScreen({
    super.key,
    this.initialCategory,
    this.initialIsIncome,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  int _currentStep = 0;

  late bool _isIncome;
  late String _selectedCategory;
  String _amount = '0';
  String _title = '';
  String _note = '';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  final List<Map<String, dynamic>> _expenseCategories = [
    {'name': '식비', 'icon': Icons.restaurant},
    {'name': '교통', 'icon': Icons.directions_bus},
    {'name': '생활', 'icon': Icons.home},
    {'name': '쇼핑', 'icon': Icons.shopping_bag},
    {'name': '문화', 'icon': Icons.movie},
    {'name': '의료', 'icon': Icons.local_hospital},
    {'name': '교육', 'icon': Icons.school},
    {'name': '기타', 'icon': Icons.category},
  ];

  final List<Map<String, dynamic>> _incomeCategories = [
    {'name': '급여', 'icon': Icons.account_balance_wallet},
    {'name': '용돈', 'icon': Icons.wallet},
    {'name': '투자', 'icon': Icons.trending_up},
    {'name': '부업', 'icon': Icons.work},
    {'name': '기타', 'icon': Icons.card_giftcard},
  ];

  @override
  void initState() {
    super.initState();
    _isIncome = widget.initialIsIncome ?? false;
    _selectedCategory = widget.initialCategory ?? '';

    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      _currentStep = 1;
    }
  }

  void _onNumberTap(String number) {
    setState(() {
      if (_amount == '0') {
        _amount = number;
      } else if (_amount.length < 10) {
        _amount += number;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_amount.length > 1) {
        _amount = _amount.substring(0, _amount.length - 1);
      } else {
        _amount = '0';
      }
    });
  }

  void _onClear() {
    setState(() {
      _amount = '0';
    });
  }

  void _onQuickAmount(int quickAmount) {
    setState(() {
      final currentAmount = int.tryParse(_amount) ?? 0;
      final newAmount = currentAmount + quickAmount;
      if (newAmount.toString().length <= 10) {
        _amount = newAmount.toString();
      }
    });
  }

  void _selectCategory(String category) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedCategory = category;
      _currentStep = 1;
    });
  }

  void _goBackToCategory() {
    setState(() {
      _currentStep = 0;
      _amount = '0';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          _currentStep == 0 ? '거래 추가' : _selectedCategory,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () {
            if (_currentStep == 1) {
              _goBackToCategory();
            } else {
              context.pop();
            }
          },
        ),
        actions: _currentStep == 1
            ? [
                TextButton(
                  onPressed: _showDetailsSheet,
                  child: const Text(
                    '상세',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _currentStep == 0
              ? _buildCategorySelectionStep()
              : _buildAmountInputStep(),
        ),
      ),
    );
  }

  Widget _buildCategorySelectionStep() {
    return Column(
      key: const ValueKey('category_step'),
      children: [
        // Type Toggle
        Container(
          color: AppTheme.surfaceColor,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: _buildTypeToggle(),
        ),

        // Category Grid
        Expanded(
          child: Container(
            color: AppTheme.backgroundColor,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isIncome ? '수입 카테고리' : '지출 카테고리',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryGrid(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _isIncome = false;
                  _selectedCategory = '';
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: !_isIncome ? AppTheme.surfaceColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  boxShadow: !_isIncome ? AppTheme.shadowSm : null,
                ),
                child: Center(
                  child: Text(
                    '지출',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: !_isIncome ? AppTheme.dangerColor : AppTheme.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _isIncome = true;
                  _selectedCategory = '';
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _isIncome ? AppTheme.surfaceColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  boxShadow: _isIncome ? AppTheme.shadowSm : null,
                ),
                child: Center(
                  child: Text(
                    '수입',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _isIncome ? AppTheme.accentColor : AppTheme.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = _isIncome ? _incomeCategories : _expenseCategories;
    // 포인트 컬러: 지출=토스블루, 수입=그린
    final accentColor = _isIncome ? AppTheme.accentColor : AppTheme.primaryColor;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = _selectedCategory == category['name'];

        return GestureDetector(
          onTap: () => _selectCategory(category['name']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isSelected ? accentColor.withValues(alpha: 0.08) : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: isSelected ? accentColor : AppTheme.borderColor,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category['icon'] as IconData,
                  size: 28,
                  color: isSelected ? accentColor : AppTheme.textSecondary,
                ),
                const SizedBox(height: 6),
                Text(
                  category['name'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? accentColor : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ).animate(delay: Duration(milliseconds: 30 * index))
            .fadeIn(duration: 200.ms)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
      },
    );
  }

  Widget _buildAmountInputStep() {
    return Container(
      key: const ValueKey('amount_step'),
      color: AppTheme.surfaceColor,
      child: Column(
        children: [
          // Category chip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: GestureDetector(
              onTap: _goBackToCategory,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(_selectedCategory),
                      size: 18,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedCategory,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Amount Display
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: AmountDisplay(
              amount: _amount,
              isIncome: _isIncome,
              prefix: _isIncome ? '+' : '-',
            ),
          ),

          // Quick Amount Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: QuickAmountButtons(onAmountTap: _onQuickAmount),
          ),

          // Budget Status
          if (!_isIncome) ...[
            const SizedBox(height: 12),
            _buildBudgetStatus(),
          ],

          const Spacer(),

          // Keypad
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                NumberKeypad(
                  onNumberTap: _onNumberTap,
                  onBackspace: _onBackspace,
                  onClear: _onClear,
                ),
                const SizedBox(height: 12),
                _buildSaveButton(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    final buttonColor = _isIncome ? AppTheme.accentColor : AppTheme.primaryColor;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                _isIncome ? '수입 추가' : '지출 추가',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildBudgetStatus() {
    return FutureBuilder<BudgetStatus?>(
      future: ref.read(budgetManagerProvider.notifier).getBudgetStatus(_selectedCategory),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppTheme.textTertiary),
                  SizedBox(width: 6),
                  Text(
                    '예산 미설정',
                    style: TextStyle(fontSize: 13, color: AppTheme.textTertiary),
                  ),
                ],
              ),
            ),
          );
        }

        final status = snapshot.data!;
        final amount = int.tryParse(_amount) ?? 0;
        final newRemaining = status.remaining - amount;
        final willOverBudget = newRemaining < 0;
        final budgetAmount = status.budget.amount;
        final usagePercent = budgetAmount > 0
            ? ((status.spent + amount) / budgetAmount).clamp(0.0, 1.0)
            : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: willOverBudget
                  ? AppTheme.hpBarBackground
                  : AppTheme.xpBarBackground,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      willOverBudget
                          ? '예산 초과 ${_formatAmount(-newRemaining)}원'
                          : '남은 예산 ${_formatAmount(newRemaining)}원',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: willOverBudget
                            ? AppTheme.dangerColor
                            : AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      '${(usagePercent * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: willOverBudget
                            ? AppTheme.dangerColor
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: usagePercent,
                    backgroundColor: AppTheme.borderColor,
                    valueColor: AlwaysStoppedAnimation(
                      willOverBudget ? AppTheme.dangerColor : AppTheme.primaryColor,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    final allCategories = [..._expenseCategories, ..._incomeCategories];
    final found = allCategories.firstWhere(
      (c) => c['name'] == category,
      orElse: () => {'icon': Icons.category},
    );
    return found['icon'] as IconData;
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _showDetailsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '상세 정보',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: '내용',
                  hintText: '거래 내용을 입력하세요',
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => _title = value,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  labelText: '메모 (선택)',
                  hintText: '메모를 입력하세요',
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 2,
                onChanged: (value) => _note = value,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: AppTheme.textSecondary),
                title: const Text('날짜', style: TextStyle(color: AppTheme.textSecondary)),
                trailing: Text(
                  '${_selectedDate.year}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.day.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
                ),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  child: const Text('확인', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              surface: AppTheme.surfaceColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveTransaction() async {
    final amount = int.tryParse(_amount) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('금액을 입력해주세요'),
          backgroundColor: AppTheme.dangerColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    final title = _title.isEmpty ? _selectedCategory : _title;
    setState(() => _isSaving = true);

    try {
      await ref.read(transactionManagerProvider.notifier).addTransaction(
            title: title,
            amount: amount,
            isIncome: _isIncome,
            category: _selectedCategory,
            note: _note.isEmpty ? null : _note,
            transactionDate: _selectedDate,
          );

      if (mounted) {
        // 예산 상태 확인 (지출인 경우)
        String message;
        Color bgColor;

        if (!_isIncome) {
          final budgetStatus = await ref
              .read(budgetManagerProvider.notifier)
              .getBudgetStatus(_selectedCategory);

          if (budgetStatus != null && budgetStatus.isOverBudget) {
            message = '기록 완료! (예산 초과 주의)';
            bgColor = AppTheme.warningColor;
          } else if (budgetStatus != null && budgetStatus.isWarning) {
            message = '기록 완료! (예산 80% 이상 사용)';
            bgColor = AppTheme.warningColor;
          } else {
            message = '지출이 기록되었습니다';
            bgColor = AppTheme.primaryColor;
          }
        } else {
          message = '수입이 기록되었습니다';
          bgColor = AppTheme.accentColor;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: bgColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
