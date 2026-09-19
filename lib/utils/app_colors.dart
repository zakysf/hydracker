import 'package:flutter/material.dart';

/// Kelas [AppColors] menyimpan seluruh palet warna yang digunakan di dalam aplikasi.
///
/// Manfaat pemusatan warna (Clean Code):
/// 1. Konsistensi tampilan di seluruh layar (UI/UX seragam).
/// 2. Jika ingin mengganti warna tema, cukup ubah satu baris di file ini.
/// 3. Memudahkan pemula menemukan dan mengelola warna tanpa hardcoding `Color(0xFF...)`.
class AppColors {
  // Mencegah instansiasi class karena semua properti bersifat static
  AppColors._();

  // Warna Utama (Primary Theme)
  static const Color primary = Color(0xFF0288D1);        // Biru Cerah (Warna Utama Air)
  static const Color primaryLight = Color(0xFFE1F5FE);   // Biru Sangat Muda (Background Kartu/Aksen)
  static const Color primaryDark = Color(0xFF01579B);    // Biru Tua
  static const Color accent = Color(0xFF26C6DA);         // Biru Kehijauan (Cyan Gradient)

  // Warna Latar Belakang (Background)
  static const Color scaffoldBackground = Color(0xFFF0F8FF); // Alice Blue (Latar belakang aplikasi)
  static const Color cardBackground = Colors.white;

  // Warna Status Hidrasi & Aksen
  static const Color progressBackground = Colors.white24;
  static const Color progressComplete = Colors.lightGreenAccent;
  static const Color progressIncomplete = Colors.amberAccent;

  // Warna Teks
  static const Color textPrimary = Color(0xFF1E293B);    // Teks Gelap Utama
  static const Color textSecondary = Color(0xFF64748B);  // Teks Abu-abu Keterangan
  static const Color textWhite = Colors.white;
  static const Color textWhite70 = Colors.white70;

  // Warna Aksi / Notifikasi
  static const Color success = Colors.green;
  static const Color danger = Colors.red;
  static const Color warning = Colors.orange;
}
