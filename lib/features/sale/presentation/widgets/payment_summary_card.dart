import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/utils/format_utils.dart';

class PaymentSummaryCard extends StatelessWidget {
  final double totalAmount;
  final double amountPaid;
  final double change;

  const PaymentSummaryCard({
    super.key,
    required this.totalAmount,
    required this.amountPaid,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            'Valor Total',
            FormatUtils.formatCurrencyWithSymbol(totalAmount),
          ),
          SizedBox(height: 12.h),
          _buildSummaryRow(
            'Valor Pago',
            FormatUtils.formatCurrencyWithSymbol(amountPaid),
          ),
          SizedBox(height: 12.h),
          Divider(color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          _buildSummaryRow(
            'Troco',
            FormatUtils.formatCurrencyWithSymbol(change),
            valueStyle: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
        Text(
          value,
          style:
              valueStyle ??
              TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
