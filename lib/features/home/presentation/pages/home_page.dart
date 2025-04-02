import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/navigation/routes.dart';
import 'package:pos_machine/core/theme/app_theme.dart';
import 'package:pos_machine/features/home/presentation/widget/option_card_widget.dart';
// import 'package:pos_machine/features/admin/presentation/pages/admin_login_page.dart';
// import 'package:pos_machine/features/seller/presentation/pages/seller_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'PDV Loja Fácil',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48.h),
              OptionCardWidget(
                context: context,
                title: 'Venda',
                icon: Icons.shopping_cart,
                onTap: () => Navigator.pushNamed(context, Routes.seller),
              ),
              SizedBox(height: 24.h),
              OptionCardWidget(
                context: context,
                title: 'Administrador',
                icon: Icons.admin_panel_settings,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
