import 'package:dio/dio.dart';

import 'package:pos_machine/core/services/interfaces/secure_storage_interface.dart';
import 'package:pos_machine/features/auth/domain/entities/auth_credentials.dart';
import 'package:pos_machine/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SecureStorage _secureStorage;
  final Dio _dio;

  AuthRepositoryImpl(this._secureStorage, this._dio);

  @override
  Future<String> login(AuthCredentials credentials) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: credentials.toJson(),
      );

      if (response.statusCode == 200) {
        final token = response.data['token'] as String;
        var key = 'admin_token';
        await _secureStorage.saveToken(key: key, value: token);
        return token;
      } else {
        throw AuthException('Falha na autenticação');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw AuthException('Tempo limite de conexão excedido');
      } else if (e.response?.statusCode == 401) {
        throw AuthException('Usuário ou senha inválidos');
      } else {
        throw AuthException('Erro ao conectar com o servidor');
      }
    } catch (e) {
      throw AuthException('Erro inesperado durante a autenticação');
    }
  }

  @override
  Future<void> logout() async {
    var key = 'admin_token';
    await _secureStorage.deleteToken(key: key);
  }

  @override
  Future<bool> isAuthenticated() async {
    var key = 'admin_token';
    return await _secureStorage.hasToken(key: key);
  }

  @override
  Future<String?> getToken() async {
    var key = 'admin_token';
    return await _secureStorage.getToken(key: key);
  }
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
