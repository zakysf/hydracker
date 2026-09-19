import 'package:flutter/material.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  Widget _panduanAccordion({
    required IconData icon,
    required String judul,
    required String isi,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Icon(icon, color: const Color(0xFF0288D1)),
        title: Text(
          judul,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 4),
          Text(
            isi,
            style: const TextStyle(color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bantuan & Panduan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Panduan Fitur Aplikasi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          _panduanAccordion(
            icon: Icons.group,
            judul: '1. Daftar Anggota',
            isi: 'Menampilkan daftar seluruh pengguna yang terdaftar di database cloud Supabase. Anda dapat melihat profil, berat badan, dan tinggi badan anggota.',
          ),
          _panduanAccordion(
            icon: Icons.calculate,
            judul: '2. Kalkulator Kebutuhan Air',
            isi: 'Masukkan berat badan (angka dalam kg) dan pilih tingkat aktivitas fisik Anda. Sistem akan menghitung target konsumsi air ideal harian Anda.',
          ),
          _panduanAccordion(
            icon: Icons.local_drink,
            judul: '3. Catatan Konsumsi Air (CRUD)',
            isi: 'Kelola riwayat minum Anda secara lengkap:\n'
                '• Tambah: Tekan tombol (+) di pojok kanan bawah.\n'
                '• Edit: Tekan tombol pensil biru pada item catatan.\n'
                '• Hapus: Tekan tombol tempat sampah merah untuk menghapus catatan.',
          ),
          _panduanAccordion(
            icon: Icons.calendar_month,
            judul: '4. Konversi Tanggal Hijriah',
            isi: 'Pilih tanggal Masehi melalui pemilih kalender untuk melihat padanan tanggal dalam penanggalan kalender Islam (Hijriah).',
          ),
          _panduanAccordion(
            icon: Icons.cake,
            judul: '5. Konversi Umur Detail',
            isi: 'Pilih tanggal lahir Anda untuk menghitung umur secara detail (Tahun, Bulan, Hari, Jam, Menit, hingga Detik yang berjalan realtime).',
          ),
          _panduanAccordion(
            icon: Icons.auto_awesome,
            judul: '6. Weton & Kalender Saka Bali',
            isi: 'Pilih tanggal untuk melihat nama hari pasaran Jawa (Weton: Legi, Pahing, Pon, Wage, Kliwon) serta penanggalan kalender Saka Bali.',
          ),
          _panduanAccordion(
            icon: Icons.timer,
            judul: '7. Stopwatch',
            isi: 'Gunakan timer stopwatch untuk mengukur interval waktu, jeda olahraga, maupun pengingat waktu jeda minum air.',
          ),
        ],
      ),
    );
  }
}
