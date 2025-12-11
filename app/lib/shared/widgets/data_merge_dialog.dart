import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/auth/data_merge_service.dart';
import '../../core/theme/app_theme.dart';

/// 데이터 병합 선택 다이얼로그
class DataMergeDialog extends ConsumerStatefulWidget {
  const DataMergeDialog({super.key});

  /// 다이얼로그 표시
  static Future<MergeOption?> show(BuildContext context) {
    return showDialog<MergeOption>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const DataMergeDialog(),
    );
  }

  @override
  ConsumerState<DataMergeDialog> createState() => _DataMergeDialogState();
}

class _DataMergeDialogState extends ConsumerState<DataMergeDialog> {
  MergeOption? _selectedOption;
  bool _isProcessing = false;

  final _formatter = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    final mergeState = ref.watch(dataMergeServiceProvider);
    final localData = mergeState.localData ?? const DataSummary();
    final serverData = mergeState.serverData ?? const DataSummary();

    return Dialog(
      backgroundColor: AppTheme.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 헤더
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.merge_type,
                    color: AppTheme.warningColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '데이터 병합 필요',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '기존 데이터가 발견되었습니다',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 데이터 비교 카드
            Row(
              children: [
                Expanded(
                  child: _buildDataCard(
                    title: '이 기기',
                    icon: Icons.phone_android,
                    color: const Color(0xFF00d9ff),
                    summary: localData,
                    isSelected: _selectedOption == MergeOption.keepLocal,
                    onTap: () => setState(() {
                      _selectedOption = MergeOption.keepLocal;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDataCard(
                    title: '서버',
                    icon: Icons.cloud,
                    color: const Color(0xFF4ade80),
                    summary: serverData,
                    isSelected: _selectedOption == MergeOption.keepServer,
                    onTap: () => setState(() {
                      _selectedOption = MergeOption.keepServer;
                    }),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 양쪽 병합 옵션
            _buildMergeOption(
              title: '양쪽 모두 병합',
              description: '두 데이터를 모두 합칩니다 (중복 가능)',
              icon: Icons.compare_arrows,
              isSelected: _selectedOption == MergeOption.mergeBoth,
              onTap: () => setState(() {
                _selectedOption = MergeOption.mergeBoth;
              }),
            ),

            const SizedBox(height: 16),

            // 경고 메시지
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.dangerColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.dangerColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: AppTheme.dangerColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getWarningMessage(),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.dangerColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing
                        ? null
                        : () {
                            ref
                                .read(dataMergeServiceProvider.notifier)
                                .cancelMergeDecision();
                            Navigator.of(context).pop(null);
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('나중에'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedOption == null || _isProcessing
                        ? null
                        : _handleConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('확인'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard({
    required String title,
    required IconData icon,
    required Color color,
    required DataSummary summary,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppTheme.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.check_circle, color: color, size: 16),
                ],
              ],
            ),
            const SizedBox(height: 12),
            _buildDataRow('거래', '${summary.transactionCount}건'),
            const SizedBox(height: 4),
            _buildDataRow('예산', '${summary.budgetCount}건'),
            const SizedBox(height: 4),
            _buildDataRow('총 지출', '${_formatter.format(summary.totalAmount)}원'),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMergeOption({
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isSelected ? AppTheme.primaryColor : AppTheme.textSecondary)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  String _getWarningMessage() {
    switch (_selectedOption) {
      case MergeOption.keepLocal:
        return '서버의 기존 데이터가 이 기기의 데이터로 대체됩니다.';
      case MergeOption.keepServer:
        return '이 기기의 데이터가 삭제되고 서버 데이터로 대체됩니다.';
      case MergeOption.mergeBoth:
        return '두 데이터가 병합되며, 중복 항목이 생길 수 있습니다.';
      case null:
        return '선택한 옵션에 따라 데이터가 변경됩니다.';
    }
  }

  Future<void> _handleConfirm() async {
    if (_selectedOption == null) return;

    setState(() => _isProcessing = true);

    final success = await ref
        .read(dataMergeServiceProvider.notifier)
        .executeMerge(_selectedOption!);

    if (mounted) {
      setState(() => _isProcessing = false);

      if (success) {
        Navigator.of(context).pop(_selectedOption);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('데이터 병합 중 오류가 발생했습니다'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    }
  }
}
