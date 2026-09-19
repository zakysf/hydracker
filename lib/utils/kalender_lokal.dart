/// Kelas [KalenderLokal] menyediakan algoritma perhitungan penanggalan tradisional Indonesia:
/// 1. **Kalender Jawa**: Perhitungan Weton (kombinasi 7 hari Saptawara dan 5 hari Pasaran Pancawara).
/// 2. **Kalender Pawukon / Saka Bali**: Perhitungan 30 Wuku dan estimasi Tahun Saka Bali.
///
/// Logika Perhitungan:
/// Menggunakan selisih hari (day difference) dari tanggal acuan patokan yang telah divalidasi.
class KalenderLokal {
  KalenderLokal._();

  /// Siklus 5 hari pasaran Jawa (Pancawara)
  static const List<String> pasaran = [
    'Legi',
    'Pahing',
    'Pon',
    'Wage',
    'Kliwon',
  ];

  /// Nama 7 hari dalam sepekan (Saptawara)
  static const List<String> hariNama = [
    'Minggu',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];

  /// Tanggal acuan: 1 Januari 2000 bertepatan dengan pasaran "Legi" (index 0)
  static final DateTime _acuanPasaran = DateTime(2000, 1, 1);
  static const int _acuanPasaranIndex = 0;

  /// Daftar 30 Wuku dalam siklus Pawukon (1 siklus = 210 hari / 30 pekan)
  static const List<String> wuku = [
    'Sinta',
    'Landep',
    'Wukir',
    'Kurantil',
    'Tolu',
    'Gumbreg',
    'Warigalit',
    'Warigagung',
    'Julungwangi',
    'Sungsang',
    'Dungulan',
    'Kuningan',
    'Langkir',
    'Mandasiya',
    'Julungpujut',
    'Pahang',
    'Kuruwelut',
    'Marakeh',
    'Tambir',
    'Medangkungan',
    'Maktal',
    'Wuye',
    'Manail',
    'Prangbakat',
    'Bala',
    'Wugu',
    'Wayang',
    'Kulawu',
    'Dukut',
    'Watugunung',
  ];

  /// Acuan awal wuku Sinta
  static final DateTime _acuanWuku = DateTime(2000, 1, 1);

  /// Menghitung Weton (Hari Masehi + Hari Pasaran Jawa) berdasarkan [tanggal]
  /// Contoh output: `{ 'hari': 'Senin', 'pasaran': 'Pahing', 'weton': 'Senin Pahing' }`
  static Map<String, String> getWeton(DateTime tanggal) {
    // 1. Hitung selisih hari dari titik acuan
    final int selisih = tanggal.difference(_acuanPasaran).inDays;

    // 2. Modulo 5 untuk mencari indeks Pasaran (Legi, Pahing, Pon, Wage, Kliwon)
    final int pasaranIndex = ((_acuanPasaranIndex + selisih) % 5 + 5) % 5;

    // 3. Modulo 7 untuk nama hari Indonesia
    final String hari = hariNama[tanggal.weekday % 7];

    return {
      'hari': hari,
      'pasaran': pasaran[pasaranIndex],
      'weton': '$hari ${pasaran[pasaranIndex]}',
    };
  }

  /// Menghitung nama Wuku berdasarkan siklus 7 hari per wuku
  static String getWuku(DateTime tanggal) {
    final int selisih = tanggal.difference(_acuanWuku).inDays;
    final int idx = ((selisih ~/ 7) % 30 + 30) % 30;
    return wuku[idx];
  }

  /// Menghitung estimasi Tahun Saka Bali
  /// Rumus umum: Tahun Masehi dikurangi 78 tahun
  static int getTahunSaka(DateTime tanggal) {
    return tanggal.year - 78;
  }

  /// Menghitung seluruh atribut Kalender Bali (Wuku, Tahun Saka, Pasaran, dan Hari)
  static Map<String, dynamic> getKalenderBali(DateTime tanggal) {
    final weton = getWeton(tanggal);
    return {
      'wuku': getWuku(tanggal),
      'tahunSaka': getTahunSaka(tanggal),
      'pasaran': weton['pasaran'],
      'hari': weton['hari'],
    };
  }
}
