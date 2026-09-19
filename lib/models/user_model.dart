/// Model data untuk entitas Pengguna (User).
///
/// Penggunaan Model Class mempermudah:
/// 1. Type Safety (menghindari error akibat salah tipe data / null pointer).
/// 2. Konversi dari Map (Database Supabase) ke objek Dart via [UserModel.fromMap].
/// 3. Konversi dari objek Dart ke Map untuk dikirim ke Supabase via [UserModel.toMap].
class UserModel {
  final int? id;
  final String nama;
  final String username;
  final String password;
  final double berat;
  final double tinggi;
  final DateTime? tanggalLahir;
  final double targetAir;

  const UserModel({
    this.id,
    required this.nama,
    required this.username,
    required this.password,
    this.berat = 0.0,
    this.tinggi = 0.0,
    this.tanggalLahir,
    this.targetAir = 2000.0,
  });

  /// Factory constructor untuk mem-parsing data dari Supabase/Database Map menjadi objek [UserModel]
  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Parsing nilai numerik dengan fallback aman (mencegah error jika data di DB berupa int/double/string)
    double parseDouble(dynamic value, double fallback) {
      if (value == null) return fallback;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? fallback;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    return UserModel(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      nama: map['nama']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      berat: parseDouble(map['berat'], 0.0),
      tinggi: parseDouble(map['tinggi'], 0.0),
      tanggalLahir: parseDate(map['tanggalLahir']),
      targetAir: parseDouble(map['targetAir'], 2000.0),
    );
  }

  /// Mengonversi objek [UserModel] ke dalam format [Map] untuk keperluan INSERT atau UPDATE ke Supabase
  Map<String, dynamic> toMap({bool includeId = false}) {
    final map = <String, dynamic>{
      'nama': nama,
      'username': username,
      'password': password,
      'berat': berat,
      'tinggi': tinggi,
      'tanggalLahir': tanggalLahir?.toIso8601String(),
      'targetAir': targetAir,
    };
    if (includeId && id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Helper untuk membuat salinan data baru dengan modifikasi atribut tertentu
  UserModel copyWith({
    int? id,
    String? nama,
    String? username,
    String? password,
    double? berat,
    double? tinggi,
    DateTime? tanggalLahir,
    double? targetAir,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      username: username ?? this.username,
      password: password ?? this.password,
      berat: berat ?? this.berat,
      tinggi: tinggi ?? this.tinggi,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      targetAir: targetAir ?? this.targetAir,
    );
  }
}
