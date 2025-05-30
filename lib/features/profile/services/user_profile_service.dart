import 'package:flutter/material.dart';
import '../../../core/config/api_client.dart';
import '../../../core/config/secure_storage.dart';
import '../../../core/models/user.dart';
import '../../../core/odoo/payloads.dart';
import '../../../core/services/preferences.dart';

class UserProfileService extends ChangeNotifier {
  User? user;
  bool isLoading = true;
  String? errorMessage;

  UserProfileService() {
    loadUser();
  }

  Future<void> loadUser() async {
    isLoading = true;
    notifyListeners();

    try {
      final userId = await SecureStorage.get('user_id');
      if (userId == null) throw Exception("No session found");

      final payload = getUserQueryPayload(userId);

      final response = await ApiClient.post(
        '/web/dataset/call_kw/res.users/web_read',
        authenticated: true,
        body: {
          "jsonrpc": "2.0",
          "method": "call",
          "params": payload,
          "id": DateTime.now().millisecondsSinceEpoch,
        },
      );

      final result = response['body']['result'];
      if (result == null || result.isEmpty) throw Exception("Usuario no encontrado");
      final rawUser = result.first;
      if (rawUser == null) throw Exception("Usuario no encontrado");
      

      user = User(
        id: rawUser['id'].toString(),
        completeName: rawUser['name'],
        username: rawUser['login'],
        email: rawUser['email'],
        phoneNumber: rawUser['phone'],
        nationality:
            rawUser['country_of_birth'] is List
                ? rawUser['country_of_birth'][1]
                : rawUser['country_of_birth'],
      );

      Preferences.user = user!;

      errorMessage = null;
    } catch (e) {
      debugPrint("Error al cargar el usuario: $e");
      errorMessage = e.toString();
      user = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
