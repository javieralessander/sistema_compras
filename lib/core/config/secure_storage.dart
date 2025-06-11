import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Guarda un valor
  static Future<void> set(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Obtiene un valor
  static Future<String?> get(String key) async {
    return await _storage.read(key: key);
  }

  /// Elimina un valor
  static Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  /// Limpia todo el almacenamiento seguro
  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
