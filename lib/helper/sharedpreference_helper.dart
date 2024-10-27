import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String isLoggedInKey = 'isLoggedIn';
  static const String isNewUserKey = 'isNewUser';

  static Future<void> setIsLoggedIn(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLoggedInKey, value);
  }

  static Future<bool> getIsLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false;
  }

  static Future<void> setIsNewUser(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isNewUserKey, value);
  }

  static Future<bool> getIsNewUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isNewUserKey) ?? true; // Default to true for new users
  }

  static Future<void> clearPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
