import 'package:pos_machine/core/services/cache_service.dart';

abstract class BaseRepository {
  final CacheService _cacheService;

  BaseRepository(this._cacheService);

  Future<T?> getFromCache<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final cachedData = await _cacheService.get(key);
    if (cachedData == null) return null;
    return fromJson(cachedData);
  }

  Future<void> saveToCache<T>(
    String key,
    T data,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    await _cacheService.save(key, toJson(data));
  }

  Future<void> clearCache(String key) async {
    await _cacheService.remove(key);
  }
}
