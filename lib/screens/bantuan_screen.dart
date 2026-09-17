import 'package:flutter/material.dart';
import '../utils/session.dart';
import 'login_screen.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout')),
        ],
      ),
    );
    if (konfirmasi == true) {
      await Session.logout();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _panduanItem(String judul, String isi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(judul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 2),
          Text(isi, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bantuan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Cara Penggunaan Aplikasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _panduanItem('1. Daftar Anggota',
              'Menampilkan daftar seluruh pengguna yang sudah terdaftar di aplikasi.'),
          _panduanItem('2. Kalkulator Kebutuhan Air',
              'Masukkan berat badan dan tingkat aktivitas untuk mengetahui target minum harian.'),
          _panduanItem('3. Catatan Konsumsi Air',
              'Tambah, ubah, atau hapus catatan minuman yang sudah Anda konsumsi hari ini. Geser ke kiri untuk menghapus.'),
          _panduanItem('4. Konversi Tanggal Hijriah',
              'Pilih tanggal Masehi untuk melihat tanggal Hijriah yang sesuai.'),
          _panduanItem('5. Konversi Umur Detail',
              'Pilih tanggal lahir untuk melihat umur secara rinci mulai dari tahun hingga detik (berjalan realtime).'),
          _panduanItem('6. Weton & Kalender Saka Bali',
              'Pilih tanggal untuk melihat weton (hari pasaran Jawa) dan tahun Saka Bali.'),
          _panduanItem('7. Stopwatch',
              'Gunakan untuk mengukur interval waktu, misalnya jeda antar waktu minum air.'),
          const Divider(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
