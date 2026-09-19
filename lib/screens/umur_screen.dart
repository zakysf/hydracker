import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';

/// Layar [UmurScreen] menghitung usia pengguna secara presisi dan realtime (detik berjalan).
///
/// Logika:
/// Menghitung selisih antara waktu saat ini ([DateTime.now]) dan tanggal lahir yang dipilih pengguna,
/// lalu memecahnya menjadi komponen: Tahun, Bulan, Hari, Jam, Menit, dan Detik.
class UmurScreen extends StatefulWidget {
  const UmurScreen({super.key});

  @override
  State<UmurScreen> createState() => _UmurScreenState();
}

class _UmurScreenState extends State<UmurScreen> {
  DateTime? _tglLahir;
  Timer? _timerRealtime;
  Map<String, int> _umurDetail = {};

  @override
  void dispose() {
    // Mematikan timer agar tidak terus berjalan di background saat user meninggalkan layar
    _timerRealtime?.cancel();
    super.dispose();
  }

  /// Membuka DatePicker untuk memilih tanggal lahir
  Future<void> _pilihTanggalLahir() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tglLahir ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _tglLahir = picked);
      _timerRealtime?.cancel();

      // Hitung segera dan jalankan timer periodik setiap 1 detik untuk efek realtime
      _hitungUmurDetail();
      _timerRealtime = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _hitungUmurDetail(),
      );
    }
  }

  /// Algoritma perhitungan detail usia (Tahun, Bulan, Hari, Jam, Menit, Detik)
  void _hitungUmurDetail() {
    if (_tglLahir == null) return;
    final now = DateTime.now();

    int years = now.year - _tglLahir!.year;
    int months = now.month - _tglLahir!.month;
    int days = now.day - _tglLahir!.day;
    int hours = now.hour - _tglLahir!.hour;
    int minutes = now.minute - _tglLahir!.minute;
    int seconds = now.second - _tglLahir!.second;

    // Koreksi pembulatan mundur jika terjadi nilai negatif
    if (seconds < 0) {
      seconds += 60;
      minutes--;
    }
    if (minutes < 0) {
      minutes += 60;
      hours--;
    }
    if (hours < 0) {
      hours += 24;
      days--;
    }
    if (days < 0) {
      // Ambil jumlah hari di bulan sebelumnya
      final prevMonth = DateTime(now.year, now.month, 0);
      days += prevMonth.day;
      months--;
    }
    if (months < 0) {
      months += 12;
      years--;
    }

    if (mounted) {
      setState(() {
        _umurDetail = {
          'tahun': years,
          'bulan': months,
          'hari': days,
          'jam': hours,
          'menit': minutes,
          'detik': seconds,
        };
      });
    }
  }

  /// Widget kotak kartu untuk setiap satuan waktu usia
  Widget _buildUnitCard(String label, int value) {
    return Expanded(
      child: Card(
        color: AppColors.primaryLight,
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Konversi Umur Detail'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kartu Pemilih Tanggal
            Card(
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.cake, color: AppColors.primary),
                title: Text(
                  _tglLahir == null
                      ? 'Pilih Tanggal Lahir Anda'
                      : 'Lahir: ${DateFormat('dd MMMM yyyy').format(_tglLahir!)}',
                  style: TextStyle(
                    fontWeight: _tglLahir != null ? FontWeight.bold : FontWeight.normal,
                    color: _tglLahir != null ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                trailing: const Icon(Icons.calendar_month, color: AppColors.primary),
                onTap: _pilihTanggalLahir,
              ),
            ),
            const SizedBox(height: 24),

            // Tampilan Grid Hasil Detail Umur
            if (_umurDetail.isNotEmpty) ...[
              const Text(
                'Detail Usia Anda (Berjalan Realtime)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Baris 1: Tahun, Bulan, Hari
              Row(
                children: [
                  _buildUnitCard('Tahun', _umurDetail['tahun'] ?? 0),
                  const SizedBox(width: 8),
                  _buildUnitCard('Bulan', _umurDetail['bulan'] ?? 0),
                  const SizedBox(width: 8),
                  _buildUnitCard('Hari', _umurDetail['hari'] ?? 0),
                ],
              ),
              const SizedBox(height: 8),

              // Baris 2: Jam, Menit, Detik
              Row(
                children: [
                  _buildUnitCard('Jam', _umurDetail['jam'] ?? 0),
                  const SizedBox(width: 8),
                  _buildUnitCard('Menit', _umurDetail['menit'] ?? 0),
                  const SizedBox(width: 8),
                  _buildUnitCard('Detik', _umurDetail['detik'] ?? 0),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
