import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import '../utils/kalender_lokal.dart';

/// Layar [KalenderLokalScreen] menghitung penanggalan tradisional Nusantara:
/// 1. **Kalender Jawa**: Weton (Hari Saptawara + Pasaran Pancawara).
/// 2. **Kalender Bali**: Siklus 30 Wuku Pawukon dan Tahun Saka Bali.
///
/// Konsep Flutter & Clean Code untuk Pemula:
/// 1. [StatefulWidget]: Menyimpan state tanggal yang dipilih dan hasil kalkulasi penanggalan.
/// 2. Algoritma Kalender Terpisah: Logika perhitungan ditempatkan di [KalenderLokal] (Separation of Concerns).
/// 3. Modular UI Components: Memecah baris data ke dalam method [_buildInfoRow].
class KalenderLokalScreen extends StatefulWidget {
  const KalenderLokalScreen({super.key});

  @override
  State<KalenderLokalScreen> createState() => _KalenderLokalScreenState();
}

class _KalenderLokalScreenState extends State<KalenderLokalScreen> {
  DateTime _tanggalPilihan = DateTime.now();
  Map<String, dynamic> _hasilKalender = {};

  @override
  void initState() {
    super.initState();
    // Hitung penanggalan saat pertama kali layar dibuka
    _hitungPenanggalan();
  }

  /// Memanggil fungsi kalkulasi penanggalan dari kelas utilitas [KalenderLokal]
  void _hitungPenanggalan() {
    setState(() {
      _hasilKalender = KalenderLokal.getKalenderBali(_tanggalPilihan);
    });
  }

  /// Menampilkan dialog pemilih tanggal (DatePicker)
  Future<void> _pilihTanggal() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalPilihan,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _tanggalPilihan) {
      setState(() => _tanggalPilihan = picked);
      _hitungPenanggalan();
    }
  }

  /// Widget pembantu untuk merender satu baris informasi data penanggalan
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Weton & Kalender Saka Bali'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Kartu Pemilih Tanggal
            Card(
              color: Colors.white,
              elevation: 1.5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.calendar_today, color: AppColors.primary),
                ),
                title: const Text(
                  'Tanggal Terpilih',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                subtitle: Text(
                  DateFormat('EEEE, dd MMMM yyyy').format(_tanggalPilihan),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Ubah'),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Kartu Rincian Penanggalan Lokal
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Kartu
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: AppColors.primary, size: 26),
                        SizedBox(width: 8),
                        Text(
                          'Hasil Penanggalan Nusantara',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Baris Data Hari
                    _buildInfoRow(
                      icon: Icons.today,
                      label: 'Hari (Saptawara)',
                      value: _hasilKalender['hari'] ?? '-',
                    ),
                    const Divider(height: 1),

                    // Baris Data Pasaran Weton Jawa
                    _buildInfoRow(
                      icon: Icons.nights_stay_outlined,
                      label: 'Pasaran Jawa (Pancawara)',
                      value: _hasilKalender['pasaran'] ?? '-',
                    ),
                    const Divider(height: 1),

                    // Baris Data Weton Lengkap
                    _buildInfoRow(
                      icon: Icons.star_border,
                      label: 'Weton Lengkap',
                      value: '${_hasilKalender['hari'] ?? ''} ${_hasilKalender['pasaran'] ?? ''}',
                    ),
                    const Divider(height: 1),

                    // Baris Data Wuku Pawukon Bali
                    _buildInfoRow(
                      icon: Icons.spa_outlined,
                      label: 'Wuku Pawukon',
                      value: _hasilKalender['wuku'] ?? '-',
                    ),
                    const Divider(height: 1),

                    // Baris Data Tahun Saka Bali
                    _buildInfoRow(
                      icon: Icons.history_edu,
                      label: 'Tahun Saka Bali',
                      value: '${_hasilKalender['tahunSaka'] ?? '-'} Saka',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Penjelasan / Catatan
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '💡 Info: Perhitungan Pasaran Jawa (Pancawara: Legi, Pahing, Pon, Wage, Kliwon) '
                'dan siklus 30 Wuku Pawukon dihitung berdasarkan selisih siklus hari dari titik acuan.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
