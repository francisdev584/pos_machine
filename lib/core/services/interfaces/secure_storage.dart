abstract class SecureStorage {
  Future<void> saveToken({required String key, required String value});
  Future<String?> getToken({required String key});
  Future<void> deleteToken({required String key});
  Future<bool> hasToken({required String key});
}
