abstract class CacheService {
  Future<void> save(String key, dynamic data, {Duration? expiration});
  Future<dynamic> get(String key);
  Future<void> remove(String key);
  Future<void> clear();
}
