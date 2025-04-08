import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pos_machine/features/auth/domain/entities/auth_credentials.dart';
import 'package:pos_machine/features/auth/domain/repositories/auth_repository.dart';
import 'package:pos_machine/features/auth/service/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  Timer? _sessionCheckTimer;
  static const int _sessionCheckIntervalSeconds = 60; // Verificar cada minuto

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
          _startSessionCheck();
        } else {
          emit(AuthInitial());
        }
      } else {
        emit(AuthInitial());
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
      _startSessionCheck();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      _stopSessionCheck();
      await _authRepository.logout();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Inicia a verificação periódica de sessão
  void _startSessionCheck() {
    _stopSessionCheck();
    _sessionCheckTimer = Timer.periodic(
      Duration(seconds: _sessionCheckIntervalSeconds),
      (_) => _verifySession(),
    );
  }

  // Para o timer de verificação
  void _stopSessionCheck() {
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer = null;
  }

  // Verifica se a sessão ainda é válida
  Future<void> _verifySession() async {
    try {
      final isAuthenticated = await _authRepository.isAuthenticated();
      if (!isAuthenticated) {
        _stopSessionCheck();
        emit(AuthSessionExpired());
      }
    } catch (e) {
      // Ignora erros na verificação automática
    }
  }

  // Renovar a sessão explicitamente (pode ser chamado em interações do usuário)
  Future<void> refreshSession() async {
    if (state is AuthSuccess) {
      await _authRepository.refreshSession();
    }
  }

  @override
  Future<void> close() {
    _stopSessionCheck();
    return super.close();
  }
}
