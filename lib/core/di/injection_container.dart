import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:pos_machine/core/config/env_config.dart';
import 'package:pos_machine/features/product/data/repositories/product_repository_impl.dart';
import 'package:pos_machine/features/product/domain/repositories/product_repository.dart';
import 'package:pos_machine/features/product/presentation/cubit/product_cubit.dart';
import 'package:pos_machine/features/seller/data/repositories/seller_repository_impl.dart';
import 'package:pos_machine/features/seller/domain/repositories/seller_repository.dart';
import 'package:pos_machine/features/seller/presentation/cubit/seller_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> init() async {
  // External
  getIt.registerLazySingleton(() => Dio());
  // getIt.registerLazySingleton(() => SharedPreferences.getInstance());

  // Repositories
  getIt.registerLazySingleton<SellerRepository>(
    () => SellerRepositoryImpl(EnvConfig.apiUrl, getIt()),
  );
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(EnvConfig.apiUrl, getIt()),
  );

  // Cubits
  getIt.registerFactory(() => SellerCubit(repository: getIt()));
  getIt.registerFactory(() => ProductCubit(repository: getIt()));
}
