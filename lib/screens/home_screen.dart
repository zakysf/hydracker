import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/session.dart';
import '../utils/ui_helper.dart';
import '../widgets/hydration_card.dart';
import '../widgets/menu_card_button.dart';
import 'anggota_screen.dart';
import 'hijriah_screen.dart';
import 'kalender_lokal_screen.dart';
import 'kalkulator_screen.dart';
import 'konsumsi_screen.dart';
import 'login_screen.dart';
import 'umur_screen.dart';

/// Layar [HomeScreen] merupakan dashboard utama aplikasi Hydracker.
///
/// Fitur Utama:
/// 1. Profil Pengguna yang sedang aktif login.
/// 2. Kartu Status Hidrasi Hari Ini ([HydrationCard]).
/// 3. Navigasi Cepat ke menu fitur utama (Daftar Anggota, Kalkulator, Catatan Konsumsi, Hijriah, Umur, Weton).
/// Catatan: Menu Stopwatch dan Bantuan telah diposisikan di navigasi bar bawah ([MainNav]).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _namaUser = '';
  double _targetAirMl = AppConstants.defaultTargetAirMl;
  double _totalHariIniMl = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Memuat data saat layar pertama kali dibuka
    _loadData();
  }

  /// Memuat profil user, target minum, dan total konsumsi hari ini dari Supabase / Session
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final nama = await Session.getNama();
      final userId = await Session.getUserId();
      final savedTarget = await Session.getTargetAir();

      double total = 0.0;
      double target = savedTarget;

      if (userId != null) {
        // Ambil data user dari Supabase untuk sinkronisasi target terbaru
        final user = await DBHelper().getUserById(userId);
        if (user != null && user.targetAir > 0) {
          target = user.targetAir;
          await Session.setTargetAir(target);
        }

        // Ambil riwayat konsumsi air khusus hari ini
        final listHariIni = await DBHelper().getKonsumsiHariIni(userId);
        total = listHariIni.fold(0.0, (sum, item) => sum + item.volume);
      }

      if (mounted) {
        setState(() {
          _namaUser = nama ?? '';
          _targetAirMl = target;
          _totalHariIniMl = total;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint('Error memuat data HomeScreen: $e');
      }
    }
  }

  /// Menangani proses logout akun dengan dialog konfirmasi
  Future<void> _logout() async {
    final bool konfirmasi = await UIHelper.showConfirmDialog(
      context,
      title: 'Keluar dari Akun',
      message: 'Apakah Anda yakin ingin logout dari Hydracker?',
      confirmLabel: 'Logout',
      confirmColor: AppColors.danger,
    );

    if (konfirmasi) {
      await Session.logout();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  /// Navigasi ke halaman sub-fitur dan otomatis merefresh data saat kembali
  Future<void> _navigateTo(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    // Refresh data setelah kembali dari halaman lain (misal: setelah catat minum / ubah target)
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Hydracker'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan Data',
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Bar indikator loading halus saat data sedang disegarkan
            if (_isLoading)
              const LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: AppColors.primaryLight,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. KARTU HEADER PROFIL USER
                      Card(
                        color: AppColors.cardBackground,
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
                                backgroundColor: AppColors.primaryLight,
                                child: Icon(Icons.person,
                                    size: 32, color: AppColors.primary),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Halo, $_namaUser 👋',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Tetap terhidrasi sepanjang hari!',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton.filledTonal(
                                style: IconButton.styleFrom(
                                  foregroundColor: AppColors.danger,
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

                      // 2. KARTU STATUS HIDRASI HARIAN (Reusable Widget)
                      HydrationCard(
                        totalHariIniMl: _totalHariIniMl,
                        targetMl: _targetAirMl,
                        showActionButton: true,
                        onCatatMinum: () => _navigateTo(const KonsumsiScreen()),
                        onUbahTarget: () =>
                            _navigateTo(const KalkulatorScreen()),
                      ),
                      const SizedBox(height: 18),

                      // 3. DAFTAR MENU UTAMA FITUR
                      const Text(
                        'Menu Utama Fitur',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      MenuCardButton(
                        icon: Icons.group,
                        label: 'Daftar Anggota',
                        onTap: () => _navigateTo(const AnggotaScreen()),
                      ),
                      MenuCardButton(
                        icon: Icons.calculate,
                        label: 'Kalkulator Kebutuhan Air',
                        onTap: () => _navigateTo(const KalkulatorScreen()),
                      ),
                      MenuCardButton(
                        icon: Icons.local_drink,
                        label: 'Catatan Konsumsi Air',
                        onTap: () => _navigateTo(const KonsumsiScreen()),
                      ),
                      MenuCardButton(
                        icon: Icons.calendar_month,
                        label: 'Konversi Tanggal Hijriah',
                        onTap: () => _navigateTo(const HijriahScreen()),
                      ),
                      MenuCardButton(
                        icon: Icons.cake,
                        label: 'Konversi Umur Detail',
                        onTap: () => _navigateTo(const UmurScreen()),
                      ),
                      MenuCardButton(
                        icon: Icons.auto_awesome,
                        label: 'Weton & Kalender Saka Bali',
                        onTap: () => _navigateTo(const KalenderLokalScreen()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
