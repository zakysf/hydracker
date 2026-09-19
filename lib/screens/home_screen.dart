import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../utils/session.dart';
import 'anggota_screen.dart';
import 'kalkulator_screen.dart';
import 'konsumsi_screen.dart';
import 'hijriah_screen.dart';
import 'umur_screen.dart';
import 'kalender_lokal_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _nama = '';
  double _targetAir = 2000.0;
  double _totalHariIni = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final n = await Session.getNama();
    final uid = await Session.getUserId();
    final savedTarget = await Session.getTargetAir();

    double total = 0.0;
    double target = (savedTarget > 0 && !savedTarget.isNaN) ? savedTarget : 2000.0;

    if (uid != null) {
      try {
        final user = await DBHelper().getUserById(uid);
        if (user != null && user['targetAir'] != null) {
          final targetRaw = user['targetAir'];
          final t = (targetRaw is num)
              ? targetRaw.toDouble()
              : (double.tryParse(targetRaw.toString()) ?? 2000.0);
          if (t > 0 && !t.isNaN) {
            target = t;
            await Session.setTargetAir(t);
          }
        }

        final listHariIni = await DBHelper().getKonsumsiHariIni(uid);
        total = listHariIni.fold(0.0, (sum, e) {
          final vol = e['volume'];
          final val = (vol is num)
              ? vol.toDouble()
              : (double.tryParse(vol?.toString() ?? '') ?? 0.0);
          return sum + (val.isNaN ? 0.0 : val);
        });
      } catch (e) {
        debugPrint('Error loading home data: $e');
      }
    }

    if (mounted) {
      setState(() {
        _nama = n ?? '';
        _targetAir = (target > 0 && !target.isNaN) ? target : 2000.0;
        _totalHariIni = (total >= 0 && !total.isNaN) ? total : 0.0;
      });
    }
  }

  Future<void> _logout() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Akun'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      await Session.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _navigateTo(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    _loadData(); // Refresh target & progress setelah kembali dari halaman lain
  }

  Widget _menuButton(
      BuildContext context, IconData icon, String label, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0288D1),
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(icon, color: const Color(0xFF0288D1)),
          label: Align(
            alignment: Alignment.centerLeft,
            child: Text(label, style: const TextStyle(fontSize: 15)),
          ),
          onPressed: () => _navigateTo(page),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = (_totalHariIni.isNaN || _totalHariIni.isInfinite || _totalHariIni < 0)
        ? 0.0
        : _totalHariIni;
    final target = (_targetAir.isNaN || _targetAir.isInfinite || _targetAir <= 0)
        ? 2000.0
        : _targetAir;

    double progress = 0.0;
    int persentase = 0;
    if (target > 0) {
      final ratio = total / target;
      if (!ratio.isNaN && !ratio.isInfinite) {
        progress = ratio.clamp(0.0, 1.0);
        persentase = (ratio * 100).round();
      }
    }

    final sisa = (target - total) > 0 ? (target - total) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HydroTrack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan Data',
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout / Keluar',
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Card Profil User
                Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          backgroundColor: Color(0xFFE1F5FE),
                          child: Icon(Icons.person,
                              size: 32, color: Color(0xFF0288D1)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo, $_nama 👋',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Tetap terhidrasi hari ini!',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            foregroundColor: Colors.red,
                            backgroundColor: Colors.red.shade50,
                          ),
                          icon: const Icon(Icons.logout, size: 20),
                          tooltip: 'Logout',
                          onPressed: _logout,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 2. STATUS CARD HIDRASI (STATUS BAR PROGRESS TRACKER)
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0288D1), Color(0xFF26C6DA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.water_drop, color: Colors.white, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'Status Hidrasi Hari Ini',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$persentase%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Sudah Diminum',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                                Text(
                                  '${total.toStringAsFixed(0)} ml',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Target Minum',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                                Text(
                                  '${target.toStringAsFixed(0)} ml',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Linear Status Bar Indicator
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 12,
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress >= 1.0
                                  ? Colors.lightGreenAccent
                                  : Colors.amberAccent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              progress >= 1.0
                                  ? '🎉 Target Hari Ini Tercapai!'
                                  : 'Sisa ${sisa.toStringAsFixed(0)} ml untuk capai target',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            InkWell(
                              onTap: () =>
                                  _navigateTo(const KalkulatorScreen()),
                              child: const Text(
                                'Ubah Target ⚙️',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0288D1),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text(
                              'Catat Minum Sekarang',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: () =>
                                _navigateTo(const KonsumsiScreen()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 3. MENU UTAMA
                const Text(
                  'Menu Utama',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _menuButton(context, Icons.group, 'Daftar Anggota',
                    const AnggotaScreen()),
                _menuButton(context, Icons.calculate,
                    'Kalkulator Kebutuhan Air', const KalkulatorScreen()),
                _menuButton(context, Icons.local_drink,
                    'Catatan Konsumsi Air (CRUD)', const KonsumsiScreen()),
                _menuButton(context, Icons.calendar_month,
                    'Konversi Tanggal Hijriah', const HijriahScreen()),
                _menuButton(context, Icons.cake, 'Konversi Umur Detail',
                    const UmurScreen()),
                _menuButton(context, Icons.auto_awesome,
                    'Weton & Kalender Saka Bali', const KalenderLokalScreen()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
