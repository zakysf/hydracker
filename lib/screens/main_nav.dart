import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'bantuan_screen.dart';
import 'home_screen.dart';
import 'stopwatch_screen.dart';

/// Layar [MainNav] adalah container navigasi bawah (Bottom Navigation Bar) utama aplikasi.
///
/// Konsep Flutter & Clean Code untuk Pemula:
/// 1. [NavigationBar]: Widget navigasi Material 3 modern pengganti BottomNavigationBar lama.
/// 2. [IndexedStack] / List Page Index: Mengatur perpindahan tab antar halaman utama tanpa reload state.
/// 3. Halaman yang terdaftar di Tab Navigasi:
///    - Index 0: [HomeScreen] (Dashboard hidrasi dan menu fitur)
///    - Index 1: [StopwatchScreen] (Timer & pengukur interval minum)
///    - Index 2: [BantuanScreen] (Panduan seluruh fitur aplikasi)
class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  // Indeks tab yang sedang aktif (0 = Beranda, 1 = Stopwatch, 2 = Bantuan)
  int _currentIndex = 0;

  // Daftar halaman yang akan ditampilkan sesuai indeks tab
  final List<Widget> _pages = const [
    HomeScreen(),
    StopwatchScreen(),
    BantuanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        indicatorColor: AppColors.primaryLight,
        backgroundColor: Colors.white,
        elevation: 3,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer, color: AppColors.primary),
            label: 'Stopwatch',
          ),
          NavigationDestination(
            icon: Icon(Icons.help_outline),
            selectedIcon: Icon(Icons.help, color: AppColors.primary),
            label: 'Bantuan',
          ),
        ],
      ),
    );
  }
}
