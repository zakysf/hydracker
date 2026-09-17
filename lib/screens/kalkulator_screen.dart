import 'package:flutter/material.dart';

class KalkulatorScreen extends StatefulWidget {
  const KalkulatorScreen({super.key});
  @override
  State<KalkulatorScreen> createState() => _KalkulatorScreenState();
}

class _KalkulatorScreenState extends State<KalkulatorScreen> {
  final _berat = TextEditingController();
  double _aktivitas = 1.0; // faktor pengali
  double? _hasilLiter;

  void _hitung() {
    final berat = double.tryParse(_berat.text);
    if (berat == null || berat <= 0) return;
    // Rumus dasar: 30-35 ml per kg berat badan, dikali faktor aktivitas
    double dasarMl = berat * 33;
    double totalMl = dasarMl * _aktivitas;
    setState(() => _hasilLiter = totalMl / 1000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kalkulator Kebutuhan Air')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _berat,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Berat Badan (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Tingkat Aktivitas', style: TextStyle(fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _hitung, child: const Text('Hitung')),
            const SizedBox(height: 24),
            if (_hasilLiter != null)
              Card(
                color: const Color(0xFFE1F5FE),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.water_drop, size: 40, color: Color(0xFF0288D1)),
                      const SizedBox(height: 8),
                      Text('${_hasilLiter!.toStringAsFixed(2)} Liter / hari',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const Text('Kebutuhan air harian Anda'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
