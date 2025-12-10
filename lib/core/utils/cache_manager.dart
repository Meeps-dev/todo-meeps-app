import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class CacheManager {
  static final _boxName = 'apiCacheBox';

  // 🧠 Initialize Hive box for caching
  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  // 💾 Save API response data to cache
  static Future<void> saveResponse(String key, dynamic data) async {
    final box = Hive.box(_boxName);

    // Convert complex data to JSON if needed
    final jsonString = jsonEncode(data);

    await box.put(key, {
      'data': jsonString,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // 📦 Get cached data (if available & fresh)
  static dynamic getResponse(
    String key, {
    Duration maxAge = const Duration(hours: 1),
  }) {
    final box = Hive.box(_boxName);
    final cached = box.get(key);

    if (cached == null) return null;

    final age = DateTime.now().millisecondsSinceEpoch - cached['timestamp'];
    if (age > maxAge.inMilliseconds) {
      // Cache is too old — delete it
      box.delete(key);
      return null;
    }

    return jsonDecode(cached['data']);
  }

  // ❌ Clear all cache
  static Future<void> clearCache() async {
    final box = Hive.box(_boxName);
    await box.clear();
  }
}
