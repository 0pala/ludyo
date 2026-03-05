import 'package:hive/hive.dart';

class ApiCacheManager {
  final box = Hive.box('ApiCache');

  Future<void> save(String key, dynamic data, Duration ttl) async {
    final expiry = DateTime.now().add(ttl);

    await box.put(key, {
      'expiry': expiry.millisecondsSinceEpoch,
      'data': data,
    });
  }

  dynamic get(String key) {
    final item = box.get(key);
    if (item == null) return null;

    final expiry = DateTime.fromMillisecondsSinceEpoch(item['expiry']);
    if (DateTime.now().isAfter(expiry)) {
      box.delete(key);
      return null;
    }

    return item['data'];
  }
}
