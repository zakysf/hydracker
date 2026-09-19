import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../db/db_helper.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/session.dart';
import '../utils/ui_helper.dart';

/// Layar [KalkulatorScreen] untuk menghitung estimasi kebutuhan air minum harian ideal
/// berdasarkan berat badan (kg) dan intensitas aktivitas fisik pengguna.
///
/// Rumus Ilmiah Dasar:
/// Kebutuhan Air (ml) = Berat Badan (kg) × 33 ml × Faktor Pengali Aktivitas
/// - Ringan (jarang olahraga): × 1.0
/// - Sedang (olahraga 3-4x seminggu): × 1.15
/// - Berat (olahraga setiap hari): × 1.3
class KalkulatorScreen extends StatefulWidget {
  const KalkulatorScreen({super.key});

  @override
  State<KalkulatorScreen> createState() => _KalkulatorScreenState();
}

class _KalkulatorScreenState extends State<KalkulatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _beratCtrl = TextEditingController();

  double _faktorAktivitas = 1.0;
  double? _hasilLiter;
  bool _isSaving = false;

  @override
  void dispose() {
    _beratCtrl.dispose();
    super.dispose();
  }

  /// Menghitung rekomendasi air minum harian
  void _hitungKebutuhanAir() {
    if (!_formKey.currentState!.validate()) return;

    final berat = double.tryParse(_beratCtrl.text.trim());
    if (berat == null ||
        berat < AppConstants.minBeratBadan ||
        berat > AppConstants.maxBeratBadan) {
      UIHelper.showErrorSnackBar(
        context,
        'Masukkan angka berat badan yang masuk akal (${AppConstants.minBeratBadan.toInt()} - ${AppConstants.maxBeratBadan.toInt()} kg)',
      );
      return;
    }

    // 33 ml per kg berat badan dikalikan faktor pengali aktivitas
    final double kebutuhanMl = (berat * 33) * _faktorAktivitas;
    setState(() {
      _hasilLiter = kebutuhanMl / 1000.0;
    });
  }

  /// Menyimpan hasil kalkulasi sebagai target minum harian user ke Session & Supabase
  Future<void> _simpanSebagaiTarget() async {
    if (_hasilLiter == null) return;
    final double targetMl = _hasilLiter! * 1000.0;
    final userId = await Session.getUserId();

    setState(() => _isSaving = true);
    try {
      // 1. Simpan target di local SharedPreferences
      await Session.setTargetAir(targetMl);

      // 2. Simpan target di cloud database Supabase jika user terdaftar
      if (userId != null) {
        await DBHelper().updateTargetAir(userId, targetMl);
      }

      if (mounted) {
        setState(() => _isSaving = false);
        UIHelper.showSuccessSnackBar(
          context,
          'Target harian ${targetMl.toStringAsFixed(0)} ml berhasil diperbarui!',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        UIHelper.showErrorSnackBar(context, 'Gagal menyimpan target ke server: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Kalkulator Kebutuhan Air'),
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
              // 1. Input Berat Badan
              TextFormField(
                controller: _beratCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  LengthLimitingTextInputFormatter(5),
                ],
                decoration: InputDecoration(
                  labelText: 'Berat Badan (kg)',
                  hintText: 'Contoh: 60',
                  prefixIcon: const Icon(Icons.monitor_weight_outlined, color: AppColors.primary),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  helperText: 'Rentang berat badan yang wajar: 10 - 350 kg',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Berat badan wajib diisi';
                  }
                  final numVal = double.tryParse(value);
                  if (numVal == null) {
                    return 'Masukkan format angka yang valid';
                  }
                  if (numVal < AppConstants.minBeratBadan) {
                    return 'Berat badan minimal ${AppConstants.minBeratBadan.toInt()} kg';
                  }
                  if (numVal > AppConstants.maxBeratBadan) {
                    return 'Berat badan maksimal ${AppConstants.maxBeratBadan.toInt()} kg';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 2. Pilihan Tingkat Aktivitas
              const Text(
                'Tingkat Aktivitas Fisik',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                child: Column(
                  children: [
                    RadioListTile<double>(
                      activeColor: AppColors.primary,
                      title: const Text('Ringan (jarang berolahraga)'),
                      subtitle: const Text('Faktor: 1.0x'),
                      value: 1.0,
                      groupValue: _faktorAktivitas,
                      onChanged: (v) => setState(() => _faktorAktivitas = v!),
                    ),
                    const Divider(height: 1),
                    RadioListTile<double>(
                      activeColor: AppColors.primary,
                      title: const Text('Sedang (olahraga 3-4x / minggu)'),
                      subtitle: const Text('Faktor: 1.15x'),
                      value: 1.15,
                      groupValue: _faktorAktivitas,
                      onChanged: (v) => setState(() => _faktorAktivitas = v!),
                    ),
                    const Divider(height: 1),
                    RadioListTile<double>(
                      activeColor: AppColors.primary,
                      title: const Text('Berat (olahraga rutin setiap hari)'),
                      subtitle: const Text('Faktor: 1.3x'),
                      value: 1.3,
                      groupValue: _faktorAktivitas,
                      onChanged: (v) => setState(() => _faktorAktivitas = v!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Tombol Hitung
              ElevatedButton.icon(
                onPressed: _hitungKebutuhanAir,
                icon: const Icon(Icons.calculate),
                label: const Text('Hitung Kebutuhan Air', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 24),

              // 4. Kartu Hasil Perhitungan
              if (_hasilLiter != null)
                Card(
                  color: AppColors.primaryLight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.water_drop, size: 48, color: AppColors.primary),
                        const SizedBox(height: 8),
                        Text(
                          '${_hasilLiter!.toStringAsFixed(2)} Liter / hari',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        Text(
                          '(${( _hasilLiter! * 1000).toStringAsFixed(0)} ml / hari)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Rekomendasi asupan air harian ideal untuk tubuh Anda.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _simpanSebagaiTarget,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: const Text(
                              'Simpan Sebagai Target Harian',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
