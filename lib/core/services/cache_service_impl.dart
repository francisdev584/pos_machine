import 'package:shared_preferences/shared_preferences.dart';

import 'package:pos_machine/core/services/interfaces/cache_service.dart';

class CacheServiceImpl implements CacheService {
  static const String _selectedSellerKey = 'selected_seller';
  static const String _selectedProductsKey = 'selected_products';

  final SharedPreferences _prefs;

  CacheServiceImpl(this._prefs);

  @override
  Future<void> save(String key, dynamic data, {Duration? expiration}) async {
    final jsonString = data.toString();
    await _prefs.setString(key, jsonString);

    if (expiration != null) {
      final expiryTime = DateTime.now().add(expiration).millisecondsSinceEpoch;
      await _prefs.setInt('${key}_expiry', expiryTime);
    }
  }

  @override
  Future<dynamic> get(String key) async {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;

    final expiryTime = _prefs.getInt('${key}_expiry');
    if (expiryTime != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now > expiryTime) {
        await remove(key);
        return null;
      }
    }

    return jsonString;
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
    await _prefs.remove('${key}_expiry');
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }

  // Métodos específicos para manter compatibilidade
  Future<void> saveSelectedSeller(Map<String, dynamic> seller) async {
    await save(_selectedSellerKey, seller);
  }

  Future<Map<String, dynamic>?> getSelectedSeller() async {
    final data = await get(_selectedSellerKey);
    return data as Map<String, dynamic>?;
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
