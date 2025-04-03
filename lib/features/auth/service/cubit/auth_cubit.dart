import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pos_machine/features/auth/domain/entities/auth_credentials.dart';
import 'package:pos_machine/features/auth/domain/repositories/auth_repository.dart';
import 'package:pos_machine/features/auth/service/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository repository})
    : _authRepository = repository,
      super(AuthInitial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final isAuthenticated = await _authRepository.isAuthenticated();
      if (isAuthenticated) {
        final token = await _authRepository.getToken();
        if (token != null) {
          emit(AuthSuccess(token));
        }
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login(String username, String password) async {
    emit(AuthLoading());

    try {
      final credentials = AuthCredentials(
        username: username,
        password: password,
      );

      final token = await _authRepository.login(credentials);
      emit(AuthSuccess(token));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
