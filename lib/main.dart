import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/main_nav.dart';
import 'utils/session.dart';

void main() {
  runApp(const HydroTrackApp());
}

class HydroTrackApp extends StatelessWidget {
  const HydroTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HydroTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF0F8FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0288D1),
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0288D1)),
        useMaterial3: true,
      ),
      home: const SplashDecider(),
    );
  }
}

class SplashDecider extends StatefulWidget {
  const SplashDecider({super.key});
  @override
  State<SplashDecider> createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<SplashDecider> {
  @override
  void initState() {
    super.initState();
    _cekSesi();
  }

  Future<void> _cekSesi() async {
    bool login = await Session.isLogin();
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => login ? const MainNav() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0288D1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop, color: Colors.white, size: 80),
            SizedBox(height: 16),
            Text('HydroTrack',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
