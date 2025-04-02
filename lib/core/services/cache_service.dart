import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _selectedSellerKey = 'selected_seller';
  static const String _selectedProductsKey = 'selected_products';
  static const String _expirationPrefix = 'exp_';

  final SharedPreferences _prefs;

  CacheService(this._prefs);

  Future<Map<String, dynamic>?> get(String key) async {
    final json = _prefs.getString(key);
    if (json == null) return null;

    // Verifica se o cache expirou
    final expirationKey = _expirationPrefix + key;
    final expirationTimestamp = _prefs.getInt(expirationKey);
    if (expirationTimestamp != null &&
        DateTime.now().millisecondsSinceEpoch > expirationTimestamp) {
      await remove(key);
      await _prefs.remove(expirationKey);
      return null;
    }

    return jsonDecode(json);
  }

  Future<void> save(
    String key,
    Map<String, dynamic> data, {
    Duration? expiration,
  }) async {
    await _prefs.setString(key, jsonEncode(data));

    if (expiration != null) {
      final expirationTimestamp =
          DateTime.now().millisecondsSinceEpoch + expiration.inMilliseconds;
      await _prefs.setInt(_expirationPrefix + key, expirationTimestamp);
    } else {
      await _prefs.remove(_expirationPrefix + key);
    }
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
    await _prefs.remove(_expirationPrefix + key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }

  // Métodos específicos para manter compatibilidade
  Future<void> saveSelectedSeller(Map<String, dynamic> seller) async {
    await save(_selectedSellerKey, seller);
  }

  Future<Map<String, dynamic>?> getSelectedSeller() async {
    return get(_selectedSellerKey);
  }

  Future<void> saveSelectedProducts(List<Map<String, dynamic>> products) async {
    await save(_selectedProductsKey, {'products': products});
  }

  Future<List<Map<String, dynamic>>> getSelectedProducts() async {
    final data = await get(_selectedProductsKey);
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(data['products'] ?? []);
  }
}
