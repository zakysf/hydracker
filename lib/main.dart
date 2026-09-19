import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Session;
import 'db/supabase_config.dart';
import 'screens/login_screen.dart';
import 'screens/main_nav.dart';
import 'utils/app_colors.dart';
import 'utils/session.dart';

/// Titik masuk (Entry Point) utama seluruh aplikasi Flutter Hydracker.
///
/// Langkah Inisialisasi:
/// 1. [WidgetsFlutterBinding.ensureInitialized]: Memastikan binding widget Flutter sudah siap sebelum memanggil async.
/// 2. [dotenv.load]: Memuat variabel konfigurasi dari file `.env`.
/// 3. [Supabase.initialize]: Menginisialisasi koneksi SDK Supabase dengan URL & Anon Key.
/// 4. [runApp]: Menjalankan widget root [HydrackerApp].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Muat file environment .env untuk keamanan API key
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Peringatan: Gagal memuat file .env: $e');
  }

  // 2. Inisialisasi Supabase Database
  try {
    if (SupabaseConfig.url.isNotEmpty && SupabaseConfig.anonKey.isNotEmpty) {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
    } else {
      debugPrint('Peringatan: SUPABASE_URL atau SUPABASE_ANON_KEY di .env masih kosong.');
    }
  } catch (e) {
    debugPrint('Peringatan: Gagal inisialisasi Supabase: $e');
  }

  runApp(const HydrackerApp());
}

/// Root Widget aplikasi yang mengatur tema global (ThemeData), judul, dan rute awal.
class HydrackerApp extends StatelessWidget {
  const HydrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hydracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      home: const SplashDecider(),
    );
  }
}

/// Layar penentu (Splash & Auth Decider).
///
/// Memeriksa status sesi login di [SharedPreferences]:
/// - Jika sudah login -> Langsung diarahkan ke [MainNav] (Beranda).
/// - Jika belum login -> Diarahkan ke [LoginScreen] untuk masuk.
class SplashDecider extends StatefulWidget {
  const SplashDecider({super.key});

  @override
  State<SplashDecider> createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<SplashDecider> {
  @override
  void initState() {
    super.initState();
    _cekSesi();
  }

  /// Mengecek apakah ada sesi user aktif di perangkat
  Future<void> _cekSesi() async {
    final bool isUserLoggedIn = await Session.isLogin();

    // Beri jeda animasi splash screen singkat (600ms) agar transisi halus
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    // Arahkan ke rute yang sesuai
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => isUserLoggedIn ? const MainNav() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop, color: AppColors.textWhite, size: 80),
            SizedBox(height: 16),
            Text(
              'Hydracker',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: AppColors.textWhite),
          ],
        ),
      ),
    );
  }
}
