import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/utils/format_utils.dart';

class QuickAmountButtons extends StatelessWidget {
  final double totalAmount;
  final ValueChanged<double> onAmountSelected;

  const QuickAmountButtons({
    super.key,
    required this.totalAmount,
    required this.onAmountSelected,
  });

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
                return InkWell(
                  onTap: () => onAmountSelected(amount),
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    width: 105.w,
                    height: 40.h,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      'R\$ ${FormatUtils.formatCurrency(amount)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
