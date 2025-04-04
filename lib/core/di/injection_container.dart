import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pos_machine/core/config/env_config.dart';
import 'package:pos_machine/core/services/cache_service.dart';
import 'package:pos_machine/core/services/interfaces/secure_storage_interface.dart';
import 'package:pos_machine/core/services/secure_storage_service.dart';
import 'package:pos_machine/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pos_machine/features/auth/domain/repositories/auth_repository.dart';
import 'package:pos_machine/features/auth/service/cubit/auth_cubit.dart';
import 'package:pos_machine/features/product/data/repositories/product_repository_impl.dart';
import 'package:pos_machine/features/product/domain/repositories/product_repository.dart';
import 'package:pos_machine/features/product/service/cubit/product_cubit.dart';
import 'package:pos_machine/features/sale/data/repositories/sale_repository_impl.dart';
import 'package:pos_machine/features/sale/domain/repositories/sale_repository.dart';
import 'package:pos_machine/features/sale/service/cubit/admin_sale_cubit.dart';
import 'package:pos_machine/features/sale/service/cubit/sale_cubit.dart';
import 'package:pos_machine/features/seller/data/repositories/seller_repository_impl.dart';
import 'package:pos_machine/features/seller/domain/repositories/seller_repository.dart';
import 'package:pos_machine/features/seller/service/cubit/seller_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> init() async {
  // External
  getIt.registerLazySingleton(
    () => Dio(BaseOptions(baseUrl: EnvConfig.apiUrl)),
  );
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  getIt.registerLazySingleton(() => const FlutterSecureStorage());

  // Services
  getIt.registerLazySingleton<CacheService>(() => CacheService(getIt()));
  getIt.registerLazySingleton<SecureStorage>(
    () => SecureStorageService(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<SellerRepository>(
    () => SellerRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<SaleRepository>(
    () => SaleRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt()),
  );

  // Cubits
  getIt.registerFactory(() => SellerCubit(repository: getIt()));
  getIt.registerFactory(() => ProductCubit(repository: getIt()));
  getIt.registerFactory(() => SaleCubit(repository: getIt()));
  getIt.registerFactory(() => AuthCubit(repository: getIt()));
  getIt.registerFactory(() => AdminSaleCubit(repository: getIt()));
}
