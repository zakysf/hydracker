import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Konfigurasi Supabase yang dimuat dari file `.env`.
///
/// File `.env` berada di root project dan sudah masuk ke dalam `.gitignore`
/// sehingga aman dan tidak akan ter-push ke git repository.
class SupabaseConfig {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}
