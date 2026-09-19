import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Layar [BantuanScreen] menampilkan panduan lengkap penggunaan seluruh fitur aplikasi.
///
/// Konsep Flutter & Clean Code untuk Pemula:
/// 1. [StatelessWidget]: Digunakan karena layar hanya menampilkan informasi statis yang tidak berubah (tidak ada state).
/// 2. [ExpansionTile]: Widget accordion bawaan Flutter yang dapat diperluas (expand) dan dilipat (collapse).
/// 3. Modular Helper Method: Method [_buildPanduanItem] memisahkan pembuatan UI berulang agar kode rapi (DRY).
/// 4. [AppColors]: Menggunakan palet warna terpusat untuk menjaga konsistensi tema aplikasi.
class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  /// Widget pembantu untuk merender item accordion panduan fitur
  Widget _buildPanduanItem({
    required IconData icon,
    required String judul,
    required String isi,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        title: Text(
          judul,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 6),
          Text(
            isi,
            style: const TextStyle(
              color: AppColors.textPrimary,
              height: 1.5,
              fontSize: 14,
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
        title: const Text('Bantuan & Panduan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Judul Seksi
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Panduan Fitur Hydracker',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // 1. Panduan Daftar Anggota
          _buildPanduanItem(
            icon: Icons.group,
            judul: '1. Daftar Anggota Kelompok',
            isi: 'Menampilkan identitas nama dan NIM dari seluruh anggota tim pengembang aplikasi Hydracker.',
          ),

          // 2. Panduan Kalkulator Kebutuhan Air
          _buildPanduanItem(
            icon: Icons.calculate,
            judul: '2. Kalkulator Kebutuhan Air',
            isi: 'Masukkan berat badan (kg) dan tentukan intensitas aktivitas fisik harian Anda. '
                'Sistem akan menghitung target konsumsi air ideal dan Anda dapat menyimpannya sebagai target harian.',
          ),

          // 3. Panduan Catatan Konsumsi Air (CRUD)
          _buildPanduanItem(
            icon: Icons.local_drink,
            judul: '3. Catatan Konsumsi Air (CRUD)',
            isi: 'Kelola catatan minum Anda secara lengkap:\n'
                '• Tambah: Tekan tombol (+) Catat Minum di kanan bawah.\n'
                '• Edit: Tekan tombol pensil pada item riwayat.\n'
                '• Hapus: Tekan tombol tempat sampah merah untuk menghapus item.\n'
                '• Status Bar: Memantau sisa volume dan persentase capaian target harian.',
          ),

          // 4. Panduan Konversi Tanggal Hijriah
          _buildPanduanItem(
            icon: Icons.calendar_month,
            judul: '4. Konversi Tanggal Hijriah',
            isi: 'Pilih tanggal Masehi dari kalender untuk melihat padanan tanggal dalam kalender Islam (Hijriah).',
          ),

          // 5. Panduan Konversi Umur Detail
          _buildPanduanItem(
            icon: Icons.cake,
            judul: '5. Konversi Umur Detail',
            isi: 'Pilih tanggal lahir untuk melihat rincian usia lengkap (Tahun, Bulan, Hari, Jam, Menit, dan Detik) '
                'yang diperbarui secara realtime setiap detik.',
          ),

          // 6. Panduan Weton & Kalender Saka Bali
          _buildPanduanItem(
            icon: Icons.auto_awesome,
            judul: '6. Weton & Kalender Saka Bali',
            isi: 'Menghitung siklus penanggalan tradisional Indonesia meliputi Hari Pasaran Jawa (Legi, Pahing, Pon, Wage, Kliwon), '
                'Wuku Pawukon, dan estimasi Tahun Saka Bali.',
          ),

          // 7. Panduan Stopwatch
          _buildPanduanItem(
            icon: Icons.timer,
            judul: '7. Stopwatch Minum Air',
            isi: 'Pengukur waktu digital presisi dengan fitur putaran (Lap). '
                'Bisa dimanfaatkan untuk mengukur jeda interval antar waktu minum atau durasi olahraga.',
          ),
        ],
      ),
    );
  }
}
