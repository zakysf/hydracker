// Konversi sederhana Kalender Jawa (Weton) dan Kalender Saka Bali (Pawukon)
// Perhitungan berbasis selisih hari dari tanggal acuan yang sudah diketahui.

class KalenderLokal {
  static const List<String> pasaran = [
    'Legi', 'Pahing', 'Pon', 'Wage', 'Kliwon'
  ];

  static const List<String> hariNama = [
    'Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
  ];

  // Tanggal acuan: 1 Januari 2000 = pasaran "Legi" (index 0)
  static final DateTime _acuanPasaran = DateTime(2000, 1, 1);
  static const int _acuanPasaranIndex = 0;

  // Wuku (30 wuku dalam siklus 210 hari), acuan sederhana
  static const List<String> wuku = [
    'Sinta', 'Landep', 'Wukir', 'Kurantil', 'Tolu', 'Gumbreg', 'Warigalit',
    'Warigagung', 'Julungwangi', 'Sungsang', 'Dungulan', 'Kuningan',
    'Langkir', 'Mandasiya', 'Julungpujut', 'Pahang', 'Kuruwelut', 'Marakeh',
    'Tambir', 'Medangkungan', 'Maktal', 'Wuye', 'Manail', 'Prangbakat',
    'Bala', 'Wugu', 'Wayang', 'Kulawu', 'Dukut', 'Watugunung'
  ];
  static final DateTime _acuanWuku = DateTime(2000, 1, 1); // asumsi awal Sinta

  static Map<String, String> getWeton(DateTime tanggal) {
    int selisih = tanggal.difference(_acuanPasaran).inDays;
    int pasaranIndex = (( _acuanPasaranIndex + selisih) % 5 + 5) % 5;
    String hari = hariNama[tanggal.weekday % 7];
    return {
      'hari': hari,
      'pasaran': pasaran[pasaranIndex],
      'weton': '$hari ${pasaran[pasaranIndex]}',
    };
  }

  static String getWuku(DateTime tanggal) {
    int selisih = tanggal.difference(_acuanWuku).inDays;
    int idx = ((selisih ~/ 7) % 30 + 30) % 30;
    return wuku[idx];
  }

  // Tahun Saka Bali = Tahun Masehi - 78 (untuk tanggal setelah Nyepi, perkiraan umum)
  static int getTahunSaka(DateTime tanggal) {
    return tanggal.year - 78;
  }

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
