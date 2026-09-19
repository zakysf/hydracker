import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Kelas [SupabaseConfig] bertugas membaca kredensial Supabase dari file `.env`.
///
/// Variabel yang dibutuhkan:
/// - `SUPABASE_URL`: Endpoint proyek Supabase Anda.
/// - `SUPABASE_ANON_KEY`: Kunci anonim publik (API Key) untuk akses data klien.
///
/// Keamanan:
/// File `.env` berada di root project dan dicatat dalam `.gitignore`
/// sehingga API key tidak akan bocor ke GitHub publik.
class SupabaseConfig {
  SupabaseConfig._();

  /// Mengambil SUPABASE_URL dari .env
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';

  /// Mengambil SUPABASE_ANON_KEY dari .env
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Mengecek apakah URL dan Anon Key sudah terisi dan tidak kosong
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
