import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../utils/app_colors.dart';
import '../utils/session.dart';
import '../utils/ui_helper.dart';
import 'main_nav.dart';
import 'register_screen.dart';

/// Layar [LoginScreen] untuk autentikasi masuk pengguna ke dalam aplikasi Hydracker.
///
/// Konsep Flutter & Clean Code untuk Pemula:
/// 1. [StatefulWidget]: Digunakan karena halaman memiliki state dinamis (loading indicator, pesan error).
/// 2. [FormState] & [GlobalKey]: Digunakan untuk memvalidasi kolom input teks sebelum diproses ke server.
/// 3. [TextEditingController]: Digunakan untuk membaca dan mengontrol teks input pengguna.
/// 4. [dispose]: Wajib dipanggil untuk membersihkan controller dari memori guna mencegah memory leak.
/// 5. [Session]: Menyimpan status login secara lokal (SharedPreferences) setelah autentikasi berhasil.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Key form untuk memicu validasi kolom input
  final _formKey = GlobalKey<FormState>();

  // Controller untuk membaca nilai input teks
  final _usernameCtrl = TextEditingController(text: 'admin');
  final _passwordCtrl = TextEditingController(text: 'admin123');

  // Status proses loading dan pesan error login
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    // Selalu dispose controller saat widget dihancurkan agar tidak terjadi kebocoran memori
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// Fungsi untuk memproses autentikasi login ke database Supabase
  Future<void> _login() async {
    // 1. Validasi form input (memastikan kolom tidak kosong)
    if (!_formKey.currentState!.validate()) return;

    // 2. Set status loading dan bersihkan pesan error sebelumnya
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final username = _usernameCtrl.text.trim();
      final password = _passwordCtrl.text.trim();

      // 3. Panggil DBHelper untuk memeriksa kecocokan akun di Supabase
      final user = await DBHelper().login(username, password);

      // Pastikan widget masih terpasang (mounted) sebelum memperbarui state
      if (!mounted) return;

      setState(() => _loading = false);

      if (user != null && user.id != null) {
        // 4. Simpan sesi login lokal menggunakan SharedPreferences
        await Session.login(user.id!, user.nama, targetAir: user.targetAir);

        if (!mounted) return;

        // Berikan notifikasi feedback sukses
        UIHelper.showSuccessSnackBar(context, 'Selamat datang, ${user.nama}!');

        // Pindah ke layar utama (MainNav) dan bersihkan stack navigasi login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNav()),
        );
      } else {
        setState(() {
          _errorMessage = 'Username atau password salah. Silakan periksa kembali.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = 'Terjadi kesalahan koneksi: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo Ikon Air
                  const Icon(
                    Icons.water_drop,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),

                  // Judul Aplikasi
                  const Text(
                    'Hydracker',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pantau & jaga hidrasi harian tubuhmu',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // Input Username
                  TextFormField(
                    controller: _usernameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person, color: AppColors.primary),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (val) =>
                        (val == null || val.trim().isEmpty) ? 'Username wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  // Input Password
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock, color: AppColors.primary),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (val) =>
                        (val == null || val.trim().isEmpty) ? 'Password wajib diisi' : null,
                  ),

                  // Tampilan Pesan Error jika login gagal
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: AppColors.danger, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: AppColors.danger, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Tombol Masuk / Login
                  ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Masuk',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Tombol Navigasi ke Halaman Pendaftaran
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      'Belum punya akun? Daftar Sekarang',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
