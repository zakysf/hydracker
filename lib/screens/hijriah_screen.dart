import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

class HijriahScreen extends StatefulWidget {
  const HijriahScreen({super.key});
  @override
  State<HijriahScreen> createState() => _HijriahScreenState();
}

class _HijriahScreenState extends State<HijriahScreen> {
  DateTime _tanggal = DateTime.now();
  late HijriCalendar _hijri;

  @override
  void initState() {
    super.initState();
    _konversi();
  }

  void _konversi() {
    _hijri = HijriCalendar.fromDate(_tanggal);
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _tanggal = picked;
        _konversi();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konversi Tanggal Hijriah')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                title: Text('Tanggal Masehi: ${DateFormat('dd MMMM yyyy').format(_tanggal)}'),
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
                    const Icon(Icons.mosque, size: 40, color: Color(0xFF0288D1)),
                    const SizedBox(height: 12),
                    Text(
                      '${_hijri.hDay} ${_hijri.longMonthName} ${_hijri.hYear} H',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
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
