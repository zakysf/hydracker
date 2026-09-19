import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../db/db_helper.dart';
import '../models/user_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/ui_helper.dart';

/// Layar [RegisterScreen] untuk pendaftaran pengguna baru ke dalam database Supabase.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Key form untuk memvalidasi seluruh input
  final _formKey = GlobalKey<FormState>();

  // TextEditingController untuk membaca nilai input teks dari form
  final _namaCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _beratCtrl = TextEditingController();
  final _tinggiCtrl = TextEditingController();

  DateTime? _tglLahir;
  bool _isLoading = false;

  @override
  void dispose() {
    // Membersihkan semua controller saat widget dihapus dari tree untuk mencegah memory leak
    _namaCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _beratCtrl.dispose();
    _tinggiCtrl.dispose();
    super.dispose();
  }

  /// Menampilkan dialog pemilih tanggal lahir
  Future<void> _pilihTanggalLahir() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tglLahir ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _tglLahir) {
      setState(() => _tglLahir = picked);
    }
  }

  /// Memproses penyimpanan data pendaftaran pengguna ke Supabase
  Future<void> _daftar() async {
    // 1. Validasi form
    if (!_formKey.currentState!.validate()) return;

    if (_tglLahir == null) {
      UIHelper.showErrorSnackBar(context, 'Silakan pilih tanggal lahir Anda');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Buat objek UserModel dari input
      final newUser = UserModel(
        nama: _namaCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        berat: double.tryParse(_beratCtrl.text.trim()) ?? 0.0,
        tinggi: double.tryParse(_tinggiCtrl.text.trim()) ?? 0.0,
        tanggalLahir: _tglLahir,
        targetAir: AppConstants.defaultTargetAirMl,
      );

      // 3. Simpan ke database Supabase melalui DBHelper
      await DBHelper().registerUser(newUser);

      if (!mounted) return;

      setState(() => _isLoading = false);
      UIHelper.showSuccessSnackBar(context, 'Pendaftaran berhasil! Silakan login.');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        UIHelper.showErrorSnackBar(
          context,
          'Pendaftaran gagal: Username mungkin sudah dipakai atau cek koneksi internet.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Nama Lengkap
              TextFormField(
                controller: _namaCtrl,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap *',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama lengkap wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              // 2. Username
              TextFormField(
                controller: _usernameCtrl,
                decoration: InputDecoration(
                  labelText: 'Username *',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Username wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              // 3. Password
              TextFormField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Password wajib diisi';
                  }
                  if (v.length < 4) {
                    return 'Password minimal 4 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // 4. Berat Badan (Opsional tapi valid)
              TextFormField(
                controller: _beratCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  LengthLimitingTextInputFormatter(5),
                ],
                decoration: InputDecoration(
                  labelText: 'Berat Badan (kg)',
                  hintText: 'Contoh: 60 (Rentang: 10 - 350 kg)',
                  prefixIcon: const Icon(Icons.monitor_weight_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null; // Bersifat opsional
                  final val = double.tryParse(v);
                  if (val == null ||
                      val < AppConstants.minBeratBadan ||
                      val > AppConstants.maxBeratBadan) {
                    return 'Masukkan berat badan wajar (10 - 350 kg)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // 5. Tinggi Badan (Opsional tapi valid)
              TextFormField(
                controller: _tinggiCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  LengthLimitingTextInputFormatter(5),
                ],
                decoration: InputDecoration(
                  labelText: 'Tinggi Badan (cm)',
                  hintText: 'Contoh: 170 (Rentang: 30 - 300 cm)',
                  prefixIcon: const Icon(Icons.height),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null; // Bersifat opsional
                  final val = double.tryParse(v);
                  if (val == null ||
                      val < AppConstants.minTinggiBadan ||
                      val > AppConstants.maxTinggiBadan) {
                    return 'Masukkan tinggi badan wajar (30 - 300 cm)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // 6. Tanggal Lahir (Picker)
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
                color: Colors.white,
                child: ListTile(
                  leading: const Icon(Icons.cake_outlined, color: AppColors.primary),
                  title: Text(
                    _tglLahir == null
                        ? 'Pilih Tanggal Lahir *'
                        : 'Lahir: ${DateFormat('dd MMMM yyyy').format(_tglLahir!)}',
                    style: TextStyle(
                      color: _tglLahir == null ? AppColors.textSecondary : AppColors.textPrimary,
                      fontWeight: _tglLahir != null ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: const Icon(Icons.calendar_month, color: AppColors.primary),
                  onTap: _pilihTanggalLahir,
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Daftar
              ElevatedButton(
                onPressed: _isLoading ? null : _daftar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Daftar Akun',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
