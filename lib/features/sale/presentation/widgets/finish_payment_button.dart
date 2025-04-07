import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/widgets/scale_button.dart';

class FinishPaymentButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onPressed;
  final String? buttonText;

  const FinishPaymentButton({
    super.key,
    this.isEnabled = true,
    this.onPressed,
    this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: ScaleButton(
        text: buttonText ?? 'Finalizar Pagamento',
        isDisabled: !isEnabled,
        onPressed: isEnabled ? onPressed : null,
        backgroundColor: Colors.green.shade600,
        textColor: Colors.white,
        borderRadius: 8.r,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
