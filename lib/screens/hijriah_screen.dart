import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';

/// Layar [HijriahScreen] menyediakan konversi tanggal kalender Masehi (Gregorian) ke kalender Islam (Hijriah).
///
/// Konsep Flutter & Clean Code untuk Pemula:
/// 1. [HijriCalendar]: Library pihak ketiga (`hijri`) untuk konversi tanggal Masehi ke Hijriah secara akurat.
/// 2. [showDatePicker]: Dialog bawaan Flutter untuk memilih tanggal dari kalender visual.
/// 3. [DateFormat]: Formatter dari library `intl` untuk format tampilan tanggal Indonesia/internasional.
/// 4. [StatefulWidget]: Digunakan untuk menyimpan tanggal yang dipilih dan memicu render ulang saat tanggal berubah.
class HijriahScreen extends StatefulWidget {
  const HijriahScreen({super.key});

  @override
  State<HijriahScreen> createState() => _HijriahScreenState();
}

class _HijriahScreenState extends State<HijriahScreen> {
  // Tanggal Masehi yang sedang dipilih (default: hari ini)
  DateTime _tanggalMasehi = DateTime.now();

  // Objek kalender Hijriah hasil konversi
  late HijriCalendar _hijriDate;

  @override
  void initState() {
    super.initState();
    // Lakukan konversi awal saat layar dibuka
    _konversiTanggal();
  }

  /// Mengonversi objek [DateTime] Masehi menjadi objek [HijriCalendar]
  void _konversiTanggal() {
    _hijriDate = HijriCalendar.fromDate(_tanggalMasehi);
  }

  /// Menampilkan dialog pemilih tanggal (DatePicker)
  Future<void> _pilihTanggal() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalMasehi,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _tanggalMasehi) {
      setState(() {
        _tanggalMasehi = picked;
        _konversiTanggal();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Konversi Tanggal Hijriah'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Kartu Pemilih Tanggal Masehi
            Card(
              color: Colors.white,
              elevation: 1.5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.calendar_month, color: AppColors.primary),
                ),
                title: const Text(
                  'Tanggal Masehi',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                subtitle: Text(
                  DateFormat('EEEE, dd MMMM yyyy').format(_tanggalMasehi),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                trailing: ElevatedButton(
                  onPressed: _pilihTanggal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.primaryDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Ubah'),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Kartu Hasil Konversi Penanggalan Hijriah
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0288D1), Color(0xFF0097A7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.mosque, size: 52, color: Colors.white),
                    const SizedBox(height: 12),
                    const Text(
                      'Tanggal Hijriah',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_hijriDate.hDay} ${_hijriDate.longMonthName} ${_hijriDate.hYear} H',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Tahun ke-${_hijriDate.hYear} Hijriah',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Catatan Keterangan
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '💡 Info: Konversi kalender Hijriah menggunakan metode kalkulasi astronomis Umm al-Qura. '
                'Hari baru dalam kalender Hijriah dimulai saat matahari terbenam (Maghrib).',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
