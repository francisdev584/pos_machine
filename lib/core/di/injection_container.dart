import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

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
    () => SellerRepositoryImpl(dio: getIt()),
  );

  // Cubits
  getIt.registerFactory(() => SellerCubit(repository: getIt()));
}
