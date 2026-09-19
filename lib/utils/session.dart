import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static Future<void> login(int userId, String nama, {double? targetAir}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
    await prefs.setString('nama', nama);
    if (targetAir != null) {
      await prefs.setDouble('targetAir', targetAir);
    }
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

  static Future<void> setTargetAir(double target) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('targetAir', target);
  }

  static Future<double> getTargetAir() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('targetAir') ?? 2000.0;
  }
}
