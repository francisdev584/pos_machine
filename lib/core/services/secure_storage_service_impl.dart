import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:pos_machine/core/services/interfaces/secure_storage.dart';

class SecureStorageServiceImpl implements SecureStorage {
  final FlutterSecureStorage _storage;

  SecureStorageServiceImpl(this._storage);

  @override
  Future<void> saveToken({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> getToken({required String key}) async {
    return await _storage.read(key: key);
  }

  @override
  Future<void> deleteToken({required String key}) async {
    await _storage.delete(key: key);
  }

  @override
  Future<bool> hasToken({required String key}) async {
    final token = await getToken(key: key);
    return token != null && token.isNotEmpty;
  }
}
