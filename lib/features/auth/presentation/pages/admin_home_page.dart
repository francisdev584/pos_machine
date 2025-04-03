import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/navigation/routes.dart';
import 'package:pos_machine/core/theme/app_theme.dart';
import 'package:pos_machine/features/auth/service/cubit/auth_cubit.dart';
import 'package:pos_machine/features/auth/service/cubit/auth_state.dart';
import 'package:pos_machine/features/home/presentation/widget/main_button.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(Routes.home, (route) => false);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('Área do Administrador'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthCubit>().logout();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        Icons.admin_panel_settings_rounded,
                        color: Colors.white,
                        size: 48.w,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  'Bem-vindo, Administrador',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Gerencie suas vendas',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 54.h),
                MainButton(
                  title: 'Cancelar Vendas',
                  subtitle: 'Gerenciar vendas realizadas',
                  icon: Icons.cancel_outlined,
                  onTap: () {},
                  // () => Navigator.pushNamedAndRemoveUntil(
                  //   context,
                  //   Routes.saleCancellation,
                  //   (route) => false,
                  // ),
                  isPrimary: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
