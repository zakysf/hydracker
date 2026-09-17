import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UmurScreen extends StatefulWidget {
  const UmurScreen({super.key});
  @override
  State<UmurScreen> createState() => _UmurScreenState();
}

class _UmurScreenState extends State<UmurScreen> {
  DateTime? _tglLahir;
  Timer? _timer;
  Map<String, int> _umur = {};

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _tglLahir = picked);
      _timer?.cancel();
      _hitung();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _hitung());
    }
  }

  void _hitung() {
    if (_tglLahir == null) return;
    final now = DateTime.now();
    int years = now.year - _tglLahir!.year;
    int months = now.month - _tglLahir!.month;
    int days = now.day - _tglLahir!.day;
    int hours = now.hour - _tglLahir!.hour;
    int minutes = now.minute - _tglLahir!.minute;
    int seconds = now.second - _tglLahir!.second;

    if (seconds < 0) { seconds += 60; minutes--; }
    if (minutes < 0) { minutes += 60; hours--; }
    if (hours < 0) { hours += 24; days--; }
    if (days < 0) {
      final prevMonth = DateTime(now.year, now.month, 0);
      days += prevMonth.day;
      months--;
    }
    if (months < 0) { months += 12; years--; }

    setState(() {
      _umur = {
        'tahun': years, 'bulan': months, 'hari': days,
        'jam': hours, 'menit': minutes, 'detik': seconds,
      };
    });
  }

  Widget _kotakUmur(String label, int value) {
    return Expanded(
      child: Card(
        color: const Color(0xFFE1F5FE),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text('$value', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konversi Umur Detail')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                title: Text(_tglLahir == null
                    ? 'Pilih Tanggal Lahir'
                    : 'Lahir: ${DateFormat('dd MMMM yyyy').format(_tglLahir!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pilihTanggal,
              ),
            ),
            const SizedBox(height: 24),
            if (_umur.isNotEmpty) ...[
              Row(children: [
                _kotakUmur('Tahun', _umur['tahun']!),
                const SizedBox(width: 8),
                _kotakUmur('Bulan', _umur['bulan']!),
                const SizedBox(width: 8),
                _kotakUmur('Hari', _umur['hari']!),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                _kotakUmur('Jam', _umur['jam']!),
                const SizedBox(width: 8),
                _kotakUmur('Menit', _umur['menit']!),
                const SizedBox(width: 8),
                _kotakUmur('Detik', _umur['detik']!),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}
