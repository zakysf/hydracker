import 'package:flutter/material.dart';
import '../utils/session.dart';
import 'anggota_screen.dart';
import 'kalkulator_screen.dart';
import 'konsumsi_screen.dart';
import 'hijriah_screen.dart';
import 'umur_screen.dart';
import 'kalender_lokal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _nama = '';

  @override
  void initState() {
    super.initState();
    _loadNama();
  }

  Future<void> _loadNama() async {
    final n = await Session.getNama();
    setState(() => _nama = n ?? '');
  }

  Widget _menuButton(BuildContext context, IconData icon, String label, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0288D1),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: Icon(icon),
          label: Align(
            alignment: Alignment.centerLeft,
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HydroTrack'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Halo, $_nama 👋',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text('Tetap terhidrasi hari ini!', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _menuButton(context, Icons.group, 'Daftar Anggota', const AnggotaScreen()),
                    _menuButton(context, Icons.calculate, 'Kalkulator Kebutuhan Air', const KalkulatorScreen()),
                    _menuButton(context, Icons.local_drink, 'Catatan Konsumsi Air (CRUD)', const KonsumsiScreen()),
                    _menuButton(context, Icons.calendar_month, 'Konversi Tanggal Hijriah', const HijriahScreen()),
                    _menuButton(context, Icons.cake, 'Konversi Umur Detail', const UmurScreen()),
                    _menuButton(context, Icons.auto_awesome, 'Weton & Kalender Saka Bali', const KalenderLokalScreen()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
