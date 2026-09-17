import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/kalender_lokal.dart';

class KalenderLokalScreen extends StatefulWidget {
  const KalenderLokalScreen({super.key});
  @override
  State<KalenderLokalScreen> createState() => _KalenderLokalScreenState();
}

class _KalenderLokalScreenState extends State<KalenderLokalScreen> {
  DateTime _tanggal = DateTime.now();
  Map<String, dynamic> _hasil = {};

  @override
  void initState() {
    super.initState();
    _hitung();
  }

  void _hitung() {
    setState(() => _hasil = KalenderLokal.getKalenderBali(_tanggal));
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _tanggal = picked);
      _hitung();
    }
  }

  Widget _baris(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weton & Kalender Saka Bali')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                title: Text('Tanggal: ${DateFormat('dd MMMM yyyy').format(_tanggal)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pilihTanggal,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: const Color(0xFFE1F5FE),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.auto_awesome, size: 36, color: Color(0xFF0288D1)),
                    const SizedBox(height: 12),
                    _baris('Hari', _hasil['hari'] ?? '-'),
                    _baris('Pasaran (Weton)', _hasil['pasaran'] ?? '-'),
                    _baris('Wuku', _hasil['wuku'] ?? '-'),
                    _baris('Tahun Saka Bali', '${_hasil['tahunSaka'] ?? '-'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Catatan: perhitungan weton & saka menggunakan pendekatan siklus kalender tradisional dan bersifat estimasi.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
