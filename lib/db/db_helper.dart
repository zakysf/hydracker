import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

/// Helper Database menggunakan Supabase Client
/// 
/// Seluruh operasi database (CRUD User, Target Air, & Konsumsi) terhubung langsung ke cloud Supabase.
/// Konfigurasi URL dan Anon Key terdapat pada [SupabaseConfig].
class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  /// Supabase Client Instance
  SupabaseClient get client => Supabase.instance.client;

  // ==========================================
  // ---------- USER / AUTHENTICATION ----------
  // ==========================================

  /// Login berdasarkan username & password
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('username', username)
          .eq('password', password)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error DBHelper.login: $e');
      return null;
    }
  }

  /// Ambil profil user berdasarkan ID
  Future<Map<String, dynamic>?> getUserById(int userId) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error DBHelper.getUserById: $e');
      return null;
    }
  }

  /// Update target air minum harian user (dalam satuan ml)
  Future<void> updateTargetAir(int userId, double targetMl) async {
    try {
      await client
          .from('users')
          .update({'targetAir': targetMl})
          .eq('id', userId);
    } catch (e) {
      debugPrint('Error DBHelper.updateTargetAir: $e');
      rethrow;
    }
  }

  /// Pendaftaran User Baru
  Future<dynamic> registerUser(Map<String, dynamic> data) async {
    try {
      final response = await client
          .from('users')
          .insert(data)
          .select()
          .single();
      return response;
    } catch (e) {
      debugPrint('Error DBHelper.registerUser: $e');
      rethrow;
    }
  }

  /// Mengambil semua daftar user / anggota
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await client
          .from('users')
          .select()
          .order('id', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error DBHelper.getAllUsers: $e');
      return [];
    }
  }

  /// Update data user berdasarkan ID
  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    try {
      await client
          .from('users')
          .update(data)
          .eq('id', id);
    } catch (e) {
      debugPrint('Error DBHelper.updateUser: $e');
      rethrow;
    }
  }

  /// Hapus user berdasarkan ID
  Future<void> deleteUser(int id) async {
    try {
      await client
          .from('users')
          .delete()
          .eq('id', id);
    } catch (e) {
      debugPrint('Error DBHelper.deleteUser: $e');
      rethrow;
    }
  }

  // ==========================================
  // ---------- KONSUMSI AIR (CRUD) -----------
  // ==========================================

  /// Tambah catatan konsumsi air baru
  Future<dynamic> tambahKonsumsi(Map<String, dynamic> data) async {
    try {
      final response = await client
          .from('konsumsi')
          .insert(data)
          .select()
          .single();
      return response;
    } catch (e) {
      debugPrint('Error DBHelper.tambahKonsumsi: $e');
      rethrow;
    }
  }

  /// Ambil riwayat konsumsi air per user (diurutkan dari yang terbaru)
  Future<List<Map<String, dynamic>>> getKonsumsiByUser(int userId) async {
    try {
      final response = await client
          .from('konsumsi')
          .select()
          .eq('userId', userId)
          .order('id', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error DBHelper.getKonsumsiByUser: $e');
      return [];
    }
  }

  /// Ambil riwayat konsumsi air user khusus hari ini
  Future<List<Map<String, dynamic>>> getKonsumsiHariIni(int userId) async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final response = await client
          .from('konsumsi')
          .select()
          .eq('userId', userId)
          .eq('tanggal', today)
          .order('id', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error DBHelper.getKonsumsiHariIni: $e');
      return [];
    }
  }

  /// Update catatan konsumsi air
  Future<void> updateKonsumsi(int id, Map<String, dynamic> data) async {
    try {
      await client
          .from('konsumsi')
          .update(data)
          .eq('id', id);
    } catch (e) {
      debugPrint('Error DBHelper.updateKonsumsi: $e');
      rethrow;
    }
  }

  /// Hapus catatan konsumsi air
  Future<void> deleteKonsumsi(int id) async {
    try {
      await client
          .from('konsumsi')
          .delete()
          .eq('id', id);
    } catch (e) {
      debugPrint('Error DBHelper.deleteKonsumsi: $e');
      rethrow;
    }
  }
}
