import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/utils/format_utils.dart';

class QuickAmountButtons extends StatefulWidget {
  final double totalAmount;
  final ValueChanged<double> onAmountSelected;

  const QuickAmountButtons({
    super.key,
    required this.totalAmount,
    required this.onAmountSelected,
  });

  @override
  State<QuickAmountButtons> createState() => _QuickAmountButtonsState();
}

class _QuickAmountButtonsState extends State<QuickAmountButtons> {
  double? _selectedAmount;

  @override
  Widget build(BuildContext context) {
    final List<double> suggestedAmounts = [5, 10, 20, 50, 100, 200];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Valores Rápidos',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children:
              suggestedAmounts.map((amount) {
                return _QuickAmountButton(
                  amount: amount,
                  isSelected: _selectedAmount == amount,
                  onTap: () {
                    setState(() {
                      _selectedAmount = amount;
                    });
                    widget.onAmountSelected(amount);
                  },
                );
              }).toList(),
        ),
      ],
    );
  }
}

class _QuickAmountButton extends StatefulWidget {
  final double amount;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickAmountButton({
    required this.amount,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<_QuickAmountButton> createState() => _QuickAmountButtonState();
}

class _QuickAmountButtonState extends State<_QuickAmountButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(_) {
    _animationController.forward();
  }

  void _handleTapUp(_) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 105.w,
              height: 70.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                color:
                    widget.isSelected
                        ? Colors.green.shade100
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color:
                      widget.isSelected
                          ? Colors.green.shade300
                          : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  FormatUtils.formatCurrencyWithSymbol(widget.amount),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        widget.isSelected
                            ? Colors.green.shade700
                            : Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
