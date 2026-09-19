import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Model data sederhana untuk merepresentasikan Anggota Kelompok
class AnggotaKelompok {
  final String nama;
  final String nim;
  final String peran;

  const AnggotaKelompok({
    required this.nama,
    required this.nim,
    this.peran = 'Anggota Pengembang',
  });
}

/// Layar [AnggotaScreen] menampilkan daftar statik anggota pengembang aplikasi Hydracker.
///
/// Konsep Flutter & Clean Code untuk Pemula:
/// 1. [StatelessWidget]: Digunakan karena data anggota bersifat statik dan tidak berubah saat aplikasi berjalan.
/// 2. [ListView.builder]: Membuat daftar widget secara dinamis berdasarkan list data statik.
/// 3. Modular & Clean UI: Menggunakan [AppColors] untuk tampilan kartu yang rapi dan konsisten.
class AnggotaScreen extends StatelessWidget {
  const AnggotaScreen({super.key});

  // Daftar data statik anggota kelompok
  static const List<AnggotaKelompok> daftarAnggota = [
    AnggotaKelompok(
      nama: 'Zaky Surya Fadillah',
      nim: '124240071',
    ),
    AnggotaKelompok(
      nama: 'Andhika Guntur Ramadan',
      nim: '124240077',
    ),
    AnggotaKelompok(
      nama: 'Dimas Rhito Aryomukti',
      nim: '124240136',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Daftar Anggota Kelompok'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Info Kelompok
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.groups, size: 32, color: Colors.white),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tim Pengembang Hydracker',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tugas Pemrograman Aplikasi Mobile',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'Anggota Tim',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Daftar Anggota Statik
            ...daftarAnggota.asMap().entries.map((entry) {
              final int index = entry.key + 1;
              final AnggotaKelompok anggota = entry.value;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Badge Nomor Urut
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          '$index',
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Nama dan NIM
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              anggota.nama,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'NIM: ${anggota.nim}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Ikon Verifikasi / Pengembang
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
