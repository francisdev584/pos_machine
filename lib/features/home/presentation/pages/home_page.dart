import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/config/env_config.dart';
import 'package:pos_machine/core/navigation/routes.dart';
import 'package:pos_machine/core/theme/app_theme.dart';
import 'package:pos_machine/features/home/presentation/widget/main_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 84.w,
                    height: 84.w,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Icon(
                      Icons.point_of_sale_outlined,
                      color: Colors.white,
                      size: 48.w,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                EnvConfig.appName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Sistema de Vendas',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 54.h),
              MainButton(
                title: 'Iniciar Venda',
                subtitle: 'Realizar nova transação',
                icon: Icons.shopping_cart_outlined,
                onTap: () => Navigator.pushNamed(context, Routes.seller),
                isPrimary: true,
              ),
              SizedBox(height: 16.h),
              MainButton(
                title: 'Administrador',
                subtitle: 'Gerenciar vendas',
                icon: Icons.admin_panel_settings_rounded,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
