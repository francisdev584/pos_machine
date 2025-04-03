import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pos_machine/core/config/env_config.dart';
import 'package:pos_machine/core/di/injection_container.dart' as di;
import 'package:pos_machine/core/navigation/routes.dart';
import 'package:pos_machine/core/theme/app_theme.dart';
import 'package:pos_machine/features/auth/service/cubit/auth_cubit.dart';
import 'package:pos_machine/features/product/service/cubit/product_cubit.dart';
import 'package:pos_machine/features/sale/service/cubit/admin_sale_cubit.dart';
import 'package:pos_machine/features/sale/service/cubit/sale_cubit.dart';
import 'package:pos_machine/features/seller/service/cubit/seller_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.getIt<SellerCubit>()),
        BlocProvider(create: (context) => di.getIt<ProductCubit>()),
        BlocProvider(create: (context) => di.getIt<SaleCubit>()),
        BlocProvider(create: (context) => di.getIt<AuthCubit>()),
        BlocProvider(create: (context) => di.getIt<AdminSaleCubit>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: EnvConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: Routes.home, // Defina a rota inicial
            onGenerateRoute: Routes.generateRoute,
          );
        },
      ),
    );
  }
}
