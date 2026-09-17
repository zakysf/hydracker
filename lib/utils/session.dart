import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static Future<void> login(int userId, String nama) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
    await prefs.setString('nama', nama);
    await prefs.setBool('isLogin', true);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLogin') ?? false;
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  static Future<String?> getNama() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nama');
  }
}
