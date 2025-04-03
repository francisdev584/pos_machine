import 'package:pos_machine/features/auth/domain/entities/auth_credentials.dart';

abstract class AuthRepository {
  Future<String> login(AuthCredentials credentials);
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<String?> getToken();
}
