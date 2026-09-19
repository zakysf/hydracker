import 'package:shared_preferences/shared_preferences.dart';
import 'app_constants.dart';

/// Kelas [Session] bertugas mengelola penyimpanan data sesi pengguna secara lokal di perangkat.
///
/// Menggunakan package `shared_preferences` untuk menyimpan preferensi kunci-nilai (key-value).
///
/// Manfaat pemusatan fungsi Session:
/// - Kunci (Keys) tersimpan konsisten dan tidak tersebar sembarangan di banyak file.
/// - Mempermudah pengecekan status login di SplashScreen (`SplashDecider`).
class Session {
  Session._();

  // Kunci (Key) Penyimpanan Sesi
  static const String _keyUserId = 'userId';
  static const String _keyNama = 'nama';
  static const String _keyTargetAir = 'targetAir';
  static const String _keyIsLogin = 'isLogin';

  /// Menyimpan data sesi saat user berhasil login
  static Future<void> login(int userId, String nama, {double? targetAir}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyNama, nama);
    if (targetAir != null && targetAir > 0) {
      await prefs.setDouble(_keyTargetAir, targetAir);
    }
    await prefs.setBool(_keyIsLogin, true);
  }

  /// Menghapus seluruh data sesi saat user melakukan logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Mengecek apakah saat ini ada user yang sedang dalam status login
  static Future<bool> isLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLogin) ?? false;
  }

  /// Mengambil ID user yang sedang aktif login
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  /// Mengambil nama lengkap user yang sedang aktif login
  static Future<String?> getNama() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNama);
  }

  /// Menyimpan atau memperbarui target konsumsi air harian user
  static Future<void> setTargetAir(double target) async {
    if (target <= 0 || target.isNaN) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTargetAir, target);
  }

  /// Mengambil target konsumsi air harian user (default 2000 ml jika belum diatur)
  static Future<double> getTargetAir() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyTargetAir) ?? AppConstants.defaultTargetAirMl;
  }
}
