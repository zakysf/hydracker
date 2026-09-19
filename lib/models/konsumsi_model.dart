/// Model data untuk entitas Catatan Konsumsi Air Minum.
///
/// Menyediakan representasi terstruktur untuk satu catatan minum:
/// - [id]: ID unik catatan di database
/// - [userId]: ID user pemilik catatan
/// - [jenis]: Jenis minuman (Air Putih, Teh, Kopi, Jus, Susu, dll.)
/// - [volume]: Volume dalam satuan mililiter (ml)
/// - [tanggal]: Tanggal pencatatan dalam format 'YYYY-MM-DD'
/// - [waktu]: Waktu pencatatan dalam format 'HH:mm'
class KonsumsiModel {
  final int? id;
  final int userId;
  final String jenis;
  final double volume;
  final String tanggal;
  final String waktu;

  const KonsumsiModel({
    this.id,
    required this.userId,
    required this.jenis,
    required this.volume,
    required this.tanggal,
    required this.waktu,
  });

  /// Factory constructor untuk mem-parsing data dari Supabase/Database Map menjadi objek [KonsumsiModel]
  factory KonsumsiModel.fromMap(Map<String, dynamic> map) {
    double parseVolume(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return KonsumsiModel(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      userId: int.tryParse(map['userId']?.toString() ?? '0') ?? 0,
      jenis: map['jenis']?.toString() ?? 'Air Putih',
      volume: parseVolume(map['volume']),
      tanggal: map['tanggal']?.toString() ?? '',
      waktu: map['waktu']?.toString() ?? '',
    );
  }

  /// Mengonversi objek [KonsumsiModel] ke dalam format [Map] untuk INSERT atau UPDATE ke Supabase
  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = <String, dynamic>{
      'userId': userId,
      'jenis': jenis,
      'volume': volume,
      'tanggal': tanggal,
      'waktu': waktu,
    };
    if (includeId && id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Teks keterangan ringkas untuk ditampilkan di UI (misal: "Air Putih - 250 ml")
  String get infoRingkas => '$jenis - ${volume.toStringAsFixed(0)} ml';

  /// Helper untuk membuat salinan objek dengan modifikasi atribut tertentu
  KonsumsiModel copyWith({
    int? id,
    int? userId,
    String? jenis,
    double? volume,
    String? tanggal,
    String? waktu,
  }) {
    return KonsumsiModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      jenis: jenis ?? this.jenis,
      volume: volume ?? this.volume,
      tanggal: tanggal ?? this.tanggal,
      waktu: waktu ?? this.waktu,
    );
  }
}
