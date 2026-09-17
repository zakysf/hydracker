import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'stopwatch_screen.dart';
import 'bantuan_screen.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});
  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _index = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    StopwatchScreen(),
    BantuanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.timer), label: 'Stopwatch'),
          NavigationDestination(icon: Icon(Icons.help), label: 'Bantuan'),
        ],
      ),
    );
  }
}
