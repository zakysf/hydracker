/// Kelas [AppConstants] menyimpan nilai-nilai konstanta dan konfigurasi umum aplikasi.
///
/// Memudahkan pengelolaan nilai konstan seperti batas input, nilai default,
/// dan nama tabel database agar terhindar dari salah ketik (typo).
class AppConstants {
  AppConstants._();

  // Nama Tabel Supabase Database
  static const String tableUsers = 'users';
  static const String tableKonsumsi = 'konsumsi';

  // Target Air Default (dalam satuan mililiter / ml)
  static const double defaultTargetAirMl = 2000.0;

  // Batasan Input Berat Badan (kg)
  static const double minBeratBadan = 10.0;
  static const double maxBeratBadan = 350.0;

  // Batasan Input Tinggi Badan (cm)
  static const double minTinggiBadan = 30.0;
  static const double maxTinggiBadan = 300.0;

  // Batasan Input Volume Air Minum (ml)
  static const double minVolumeMinum = 10.0;
  static const double maxVolumeMinum = 5000.0;

  // Daftar Pilihan Jenis Minuman
  static const List<String> jenisMinumanList = [
    'Air Putih',
    'Teh',
    'Kopi',
    'Jus',
    'Susu',
    'Lainnya',
  ];
}
