import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

/// 커스텀 숫자 키패드 위젯 - 토스/뱅크샐러드 스타일
class NumberKeypad extends StatelessWidget {
  final Function(String) onNumberTap;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final Color? buttonColor;
  final Color? textColor;

  const NumberKeypad({
    super.key,
    required this.onNumberTap,
    required this.onBackspace,
    required this.onClear,
    this.buttonColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 8),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 8),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 8),
        _buildBottomRow(),
      ],
    );
  }

  Widget _buildRow(List<String> numbers) {
    return Row(
      children: numbers.map((number) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _KeypadButton(
              label: number,
              onTap: () {
                HapticFeedback.lightImpact();
                onNumberTap(number);
              },
              buttonColor: buttonColor,
              textColor: textColor,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        // Clear button
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _KeypadButton(
              label: 'C',
              onTap: () {
                HapticFeedback.mediumImpact();
                onClear();
              },
              buttonColor: AppTheme.dangerColor.withValues(alpha: 0.12),
              textColor: AppTheme.dangerColor,
            ),
          ),
        ),
        // Zero button
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _KeypadButton(
              label: '0',
              onTap: () {
                HapticFeedback.lightImpact();
                onNumberTap('0');
              },
              buttonColor: buttonColor,
              textColor: textColor,
            ),
          ),
        ),
        // Backspace button
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _KeypadButton(
              icon: Icons.backspace_outlined,
              onTap: () {
                HapticFeedback.lightImpact();
                onBackspace();
              },
              buttonColor: buttonColor,
              textColor: textColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _KeypadButton extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? buttonColor;
  final Color? textColor;

  const _KeypadButton({
    this.label,
    this.icon,
    required this.onTap,
    this.buttonColor,
    this.textColor,
  });

  @override
  State<_KeypadButton> createState() => _KeypadButtonState();
}

class _KeypadButtonState extends State<_KeypadButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.buttonColor ?? AppTheme.backgroundColor;
    final fgColor = widget.textColor ?? AppTheme.textPrimary;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Center(
                child: widget.icon != null
                    ? Icon(
                        widget.icon,
                        size: 22,
                        color: fgColor,
                      )
                    : Text(
                        widget.label ?? '',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: fgColor,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 금액 디스플레이 위젯 - 토스 스타일 (깔끔한 단색)
class AmountDisplay extends StatefulWidget {
  final String amount;
  final bool isIncome;
  final String? prefix;
  final String suffix;

  const AmountDisplay({
    super.key,
    required this.amount,
    this.isIncome = false,
    this.prefix,
    this.suffix = '원',
  });

  @override
  State<AmountDisplay> createState() => _AmountDisplayState();
}

class _AmountDisplayState extends State<AmountDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String _previousAmount = '0';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(AmountDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.amount != _previousAmount) {
      _previousAmount = widget.amount;
      _pulseController.forward().then((_) => _pulseController.reverse());
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String get _formattedAmount {
    final value = int.tryParse(widget.amount) ?? 0;
    if (value == 0) return '0';

    final formatted = value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isIncome ? AppTheme.accentColor : AppTheme.dangerColor;
    final value = int.tryParse(widget.amount) ?? 0;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (widget.prefix != null)
                Text(
                  widget.prefix!,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: -1,
                  ),
                ),
              Text(
                _formattedAmount,
                style: TextStyle(
                  fontSize: value > 999999 ? 42 : 48,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
              Text(
                widget.suffix,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 빠른 금액 버튼 - 토스 스타일 (깔끔한 테두리)
class QuickAmountButtons extends StatelessWidget {
  final Function(int) onAmountTap;
  final List<int> amounts;

  const QuickAmountButtons({
    super.key,
    required this.onAmountTap,
    this.amounts = const [1000, 5000, 10000, 50000],
  });

  String _formatAmount(int amount) {
    if (amount >= 10000) {
      return '+${amount ~/ 10000}만';
    }
    return '+${amount ~/ 1000}천';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: amounts.map((amount) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _QuickAmountButton(
              label: _formatAmount(amount),
              onTap: () {
                HapticFeedback.selectionClick();
                onAmountTap(amount);
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QuickAmountButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAmountButton({
    required this.label,
    required this.onTap,
  });

  @override
  State<_QuickAmountButton> createState() => _QuickAmountButtonState();
}

class _QuickAmountButtonState extends State<_QuickAmountButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
