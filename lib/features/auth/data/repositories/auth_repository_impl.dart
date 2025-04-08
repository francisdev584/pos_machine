import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pos_machine/core/services/interfaces/secure_storage_interface.dart';
import 'package:pos_machine/core/utils/error_handler.dart';
import 'package:pos_machine/features/auth/domain/entities/auth_credentials.dart';
import 'package:pos_machine/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SecureStorage _secureStorage;
  final Dio _dio;

  static const String _tokenKey = 'admin_token';
  static const String _tokenExpiryKey = 'admin_token_expiry';
  static const int _sessionTimeoutMinutes = 30; // 30 minutos de timeout

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

        // Salvar o token
        await _secureStorage.saveToken(key: _tokenKey, value: token);

        // Salvar o tempo de expiração
        await _saveExpiryTimestamp();

        return token;
      } else {
        throw AppException('Falha na autenticação');
      }
    } on DioException catch (e) {
      // O tratamento de erros agora é feito pelo interceptor,
      // mas ainda podemos adicionar lógica específica de autenticação aqui
      if (e.response?.statusCode == 401) {
        throw AppException('Usuário ou senha inválidos');
      }

      // Utilize a mensagem amigável já formatada pelo interceptor
      throw AppException(e.error.toString());
    } catch (e) {
      throw AppException(
        'Erro inesperado durante a autenticação: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.deleteToken(key: _tokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenExpiryKey);
  }

  @override
  Future<bool> isAuthenticated() async {
    final hasToken = await _secureStorage.hasToken(key: _tokenKey);
    if (!hasToken) return false;

    // Verificar se a sessão expirou
    return !await _isSessionExpired();
  }

  @override
  Future<String?> getToken() async {
    if (await _isSessionExpired()) {
      await logout();
      return null;
    }

    // Renovar o tempo de expiração ao acessar o token
    await _saveExpiryTimestamp();
    return await _secureStorage.getToken(key: _tokenKey);
  }

  @override
  Future<bool> refreshSession() async {
    final hasToken = await _secureStorage.hasToken(key: _tokenKey);
    if (!hasToken) return false;

    await _saveExpiryTimestamp();
    return true;
  }

  // Salva o timestamp de expiração
  Future<void> _saveExpiryTimestamp() async {
    final expiryTime =
        DateTime.now()
            .add(Duration(minutes: _sessionTimeoutMinutes))
            .millisecondsSinceEpoch;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tokenExpiryKey, expiryTime);
  }

  // Verifica se a sessão expirou com base no timestamp
  Future<bool> _isSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTimestamp = prefs.getInt(_tokenExpiryKey);

    if (expiryTimestamp == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch;
    return now > expiryTimestamp;
  }
}
