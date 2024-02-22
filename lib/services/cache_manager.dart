class CacheManager {
  final Map<String, dynamic> _cache = {};

  dynamic get(String key) => _cache[key];

  void set(String key, dynamic data, {Duration? ttl}) {
    _cache[key] = data;
    if (ttl != null) {
      Future.delayed(ttl, () => _cache.remove(key));
    }
  }

  bool has(String key) => _cache.containsKey(key);
}
