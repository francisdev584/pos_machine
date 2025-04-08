import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/navigation/routes.dart';
import 'package:pos_machine/shared/widgets/scale_button.dart';

class NavigationButtons extends StatelessWidget {
  final VoidCallback? onNewSalePressed;
  final VoidCallback? onHomePressed;
  final String? newSaleButtonText;
  final String? homeButtonText;

  const NavigationButtons({
    super.key,
    this.onNewSalePressed,
    this.onHomePressed,
    this.newSaleButtonText,
    this.homeButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ScaleButton(
              text: newSaleButtonText ?? 'Iniciar Nova Venda',
              onPressed:
                  onNewSalePressed ??
                  () => Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(Routes.seller, (route) => false),
              backgroundColor: Colors.green.shade600,
              textColor: Colors.white,
              borderRadius: 8.r,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          TextButton(
            onPressed:
                onHomePressed ??
                () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(Routes.home, (route) => false),
            child: Text(
              homeButtonText ?? 'Voltar para a Tela Inicial',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
