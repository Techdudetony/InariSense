/// Resolves a persistent local user id, creating a guest account via the
/// backend (POST /auth/guest) on first launch if none exists yet.
///
/// This is what lets every screen that needs a userId — garden list,
/// forms, etc. — just work, without hand-editing main.dart's home:
/// property to plug in a manually-created id before every test run.
/// The id is created once and persisted in SharedPreferences from then
/// on, the same way a real "logged in as guest" session would behave.
library;

import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

const _userIdKey = 'inarisense_user_id';

class UserSession {
  UserSession._();

  static Future<String> resolveUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_userIdKey);
    if (existing != null) {
      return existing;
    }

    final response =
        await ApiClient.instance.post('/auth/guest', body: const {});
    if (response.statusCode != 201) {
      throw Exception(
          'Could not create a guest account. Is the backend running?');
    }

    final userId = (response.data as Map<String, dynamic>)['id'] as String;
    await prefs.setString(_userIdKey, userId);
    return userId;
  }
}
