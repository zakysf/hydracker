import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../db/db_helper.dart';
import '../utils/session.dart';

class KalkulatorScreen extends StatefulWidget {
  const KalkulatorScreen({super.key});
  @override
  State<KalkulatorScreen> createState() => _KalkulatorScreenState();
}

class _KalkulatorScreenState extends State<KalkulatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _berat = TextEditingController();
  double _aktivitas = 1.0; // faktor pengali
  double? _hasilLiter;
  bool _isSaving = false;

  void _hitung() {
    if (!_formKey.currentState!.validate()) return;

    final berat = double.tryParse(_berat.text);
    if (berat == null || berat < 10 || berat > 350) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan angka berat badan yang masuk akal (10 - 350 kg)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Rumus dasar: 30-35 ml per kg berat badan, dikali faktor aktivitas
    double dasarMl = berat * 33;
    double totalMl = dasarMl * _aktivitas;
    setState(() => _hasilLiter = totalMl / 1000);
  }

  Future<void> _simpanSebagaiTarget() async {
    if (_hasilLiter == null) return;
    final targetMl = _hasilLiter! * 1000;
    final userId = await Session.getUserId();

    setState(() => _isSaving = true);
    try {
      // Simpan ke SharedPreferences
      await Session.setTargetAir(targetMl);

      // Simpan ke Supabase jika user sedang login
      if (userId != null) {
        await DBHelper().updateTargetAir(userId, targetMl);
      }

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Target harian ${targetMl.toStringAsFixed(0)} ml berhasil disimpan!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan target ke server: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _berat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kalkulator Kebutuhan Air')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _berat,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  LengthLimitingTextInputFormatter(5), // Maksimal 5 karakter (misal: 120.5)
                ],
                decoration: const InputDecoration(
                  labelText: 'Berat Badan (kg)',
                  hintText: 'Rentang: 10 - 350 kg (Contoh: 60)',
                  prefixIcon: Icon(Icons.monitor_weight_outlined),
                  border: OutlineInputBorder(),
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
                  if (numVal < 10) {
                    return 'Berat badan minimal 10 kg';
                  }
                  if (numVal > 350) {
                    return 'Berat badan maksimal 350 kg (angka di luar batas wajar)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Tingkat Aktivitas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    RadioListTile<double>(
                      title: const Text('Ringan (jarang olahraga)'),
                      value: 1.0,
                      groupValue: _aktivitas,
                      onChanged: (v) => setState(() => _aktivitas = v!),
                    ),
                    RadioListTile<double>(
                      title: const Text('Sedang (olahraga 3-4x/minggu)'),
                      value: 1.15,
                      groupValue: _aktivitas,
                      onChanged: (v) => setState(() => _aktivitas = v!),
                    ),
                    RadioListTile<double>(
                      title: const Text('Berat (olahraga tiap hari)'),
                      value: 1.3,
                      groupValue: _aktivitas,
                      onChanged: (v) => setState(() => _aktivitas = v!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _hitung,
                icon: const Icon(Icons.calculate),
                label: const Text('Hitung Kebutuhan Air'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 24),
              if (_hasilLiter != null)
                Card(
                  color: const Color(0xFFE1F5FE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.water_drop, size: 48, color: Color(0xFF0288D1)),
                        const SizedBox(height: 8),
                        Text(
                          '${_hasilLiter!.toStringAsFixed(2)} Liter / hari',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0288D1),
                          ),
                        ),
                        Text(
                          '(${( _hasilLiter! * 1000).toStringAsFixed(0)} ml / hari)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Kebutuhan air harian ideal untuk tubuh Anda',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _simpanSebagaiTarget,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0288D1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
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
