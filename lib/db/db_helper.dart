import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/konsumsi_model.dart';
import '../utils/app_constants.dart';

/// Helper [DBHelper] bertindak sebagai lapisan jembatan (Data Access Object / Repository)
/// antara aplikasi Flutter dan Cloud Database Supabase.
///
/// Menggunakan pola **Singleton Pattern** agar hanya ada 1 instance `DBHelper` yang aktif di memori.
class DBHelper {
  // 1. Singleton Pattern Implementation
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  /// Mengakses SupabaseClient instance dari SDK `supabase_flutter`
  SupabaseClient get client => Supabase.instance.client;

  // ===========================================================================
  // ------------------------- MODUL USER & AUTENTIKASI ------------------------
  // ===========================================================================

  /// Melakukan autentikasi Login berdasarkan username & password.
  /// Mengembalikan [UserModel] jika ditemukan, atau `null` jika tidak cocok/gagal.
  Future<UserModel?> login(String username, String password) async {
    try {
      final response = await client
          .from(AppConstants.tableUsers)
          .select()
          .eq('username', username)
          .eq('password', password)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromMap(response);
    } catch (e) {
      debugPrint('Error DBHelper.login: $e');
      return null;
    }
  }

  /// Mengambil profil lengkap user berdasarkan ID pengguna.
  Future<UserModel?> getUserById(int userId) async {
    try {
      final response = await client
          .from(AppConstants.tableUsers)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromMap(response);
    } catch (e) {
      debugPrint('Error DBHelper.getUserById: $e');
      return null;
    }
  }

  /// Memperbarui target konsumsi air minum harian user (dalam satuan ml).
  Future<void> updateTargetAir(int userId, double targetMl) async {
    try {
      await client
          .from(AppConstants.tableUsers)
          .update({'targetAir': targetMl})
          .eq('id', userId);
    } catch (e) {
      debugPrint('Error DBHelper.updateTargetAir: $e');
      rethrow;
    }
  }

  /// Mendaftarkan pengguna baru ke tabel `users`.
  /// Mengembalikan objek [UserModel] data yang berhasil disimpan.
  Future<UserModel> registerUser(UserModel user) async {
    try {
      final response = await client
          .from(AppConstants.tableUsers)
          .insert(user.toMap())
          .select()
          .single();

      return UserModel.fromMap(response);
    } catch (e) {
      debugPrint('Error DBHelper.registerUser: $e');
      rethrow;
    }
  }

  /// Mengambil seluruh daftar pengguna yang terdaftar untuk ditampilkan di layar Anggota.
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await client
          .from(AppConstants.tableUsers)
          .select()
          .order('id', ascending: true);

      return (response as List).map((e) => UserModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error DBHelper.getAllUsers: $e');
      return [];
    }
  }

  /// Memperbarui data pengguna berdasarkan ID.
  Future<void> updateUser(int id, UserModel user) async {
    try {
      await client
          .from(AppConstants.tableUsers)
          .update(user.toMap())
          .eq('id', id);
    } catch (e) {
      debugPrint('Error DBHelper.updateUser: $e');
      rethrow;
    }
  }

  /// Menghapus pengguna berdasarkan ID.
  Future<void> deleteUser(int id) async {
    try {
      await client
          .from(AppConstants.tableUsers)
          .delete()
          .eq('id', id);
    } catch (e) {
      debugPrint('Error DBHelper.deleteUser: $e');
      rethrow;
    }
  }

  // ===========================================================================
  // ------------------- MODUL CATATAN KONSUMSI AIR (CRUD) --------------------
  // ===========================================================================

  /// Menambahkan satu baris catatan konsumsi air minum baru ke tabel `konsumsi`.
  Future<KonsumsiModel> tambahKonsumsi(KonsumsiModel konsumsi) async {
    try {
      final response = await client
          .from(AppConstants.tableKonsumsi)
          .insert(konsumsi.toMap())
          .select()
          .single();

      return KonsumsiModel.fromMap(response);
    } catch (e) {
      debugPrint('Error DBHelper.tambahKonsumsi: $e');
      rethrow;
    }
  }

  /// Mengambil riwayat catatan konsumsi air milik user tertentu (diurutkan dari yang terbaru).
  Future<List<KonsumsiModel>> getKonsumsiByUser(int userId) async {
    try {
      final response = await client
          .from(AppConstants.tableKonsumsi)
          .select()
          .eq('userId', userId)
          .order('id', ascending: false);

      return (response as List).map((e) => KonsumsiModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error DBHelper.getKonsumsiByUser: $e');
      return [];
    }
  }

  /// Mengambil daftar riwayat konsumsi air user khusus untuk hari ini (format 'yyyy-MM-dd').
  Future<List<KonsumsiModel>> getKonsumsiHariIni(int userId) async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final response = await client
          .from(AppConstants.tableKonsumsi)
          .select()
          .eq('userId', userId)
          .eq('tanggal', today)
          .order('id', ascending: false);

      return (response as List).map((e) => KonsumsiModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error DBHelper.getKonsumsiHariIni: $e');
      return [];
    }
  }

  /// Memperbarui catatan konsumsi air yang sudah ada berdasarkan ID catatan.
  Future<void> updateKonsumsi(int id, KonsumsiModel konsumsi) async {
    try {
      await client
          .from(AppConstants.tableKonsumsi)
          .update(konsumsi.toMap())
          .eq('id', id);
    } catch (e) {
      debugPrint('Error DBHelper.updateKonsumsi: $e');
      rethrow;
    }
  }

  /// Menghapus satu catatan konsumsi air berdasarkan ID catatan.
  Future<void> deleteKonsumsi(int id) async {
    try {
      await client
          .from(AppConstants.tableKonsumsi)
          .delete()
          .eq('id', id);
    } catch (e) {
      debugPrint('Error DBHelper.deleteKonsumsi: $e');
      rethrow;
    }
  }
}
