import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/empty_state.dart';

/// Layar [StopwatchScreen] menyediakan fitur pencatat waktu (Stopwatch) & putaran waktu (Lap).
///
/// Logika Tombol Terpadu:
/// 1. **Tombol Utama (Start/Pause)**:
///    - Status Berhenti/Jeda -> Menampilkan tombol "Mulai" (Hijau).
///    - Status Berjalan -> Menampilkan tombol "Jeda" (Oranye/Kuning).
/// 2. **Tombol Sekunder (Lap/Reset Terpadu)**:
///    - Saat Stopwatch Berjalan -> Tombol berubah menjadi "Lap" (Mencatat putaran).
///    - Saat Stopwatch Dijeda (Pause) -> Tombol berubah menjadi "Reset" (Mengatur ulang waktu).
///    - Saat Stopwatch Belum Berjalan (00:00.00) -> Tombol dalam status nonaktif (Disabled).
class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});

  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timerTicker;
  final List<String> _lapList = [];

  @override
  void dispose() {
    // Membersihkan timer agar tidak terjadi kebocoran memori (Memory Leak)
    _timerTicker?.cancel();
    super.dispose();
  }

  /// Memulai stopwatch
  void _start() {
    _stopwatch.start();
    // Ticker berjalan setiap 30 milidetik agar tampilan milidetik sangat mulus
    _timerTicker = Timer.periodic(
      const Duration(milliseconds: 30),
      (_) => setState(() {}),
    );
    setState(() {});
  }

  /// Menjeda (pause) stopwatch
  void _pause() {
    _stopwatch.stop();
    _timerTicker?.cancel();
    setState(() {});
  }

  /// Mengatur ulang (reset) stopwatch ke 00:00.00
  void _reset() {
    _stopwatch.reset();
    _timerTicker?.cancel();
    _lapList.clear();
    setState(() {});
  }

  /// Merekam putaran waktu (Lap)
  void _lap() {
    setState(() {
      _lapList.insert(0, _formatWaktu(_stopwatch.elapsedMilliseconds));
    });
  }

  /// Format milidetik menjadi teks format menit:detik.milidetik (contoh: "02:15.42")
  String _formatWaktu(int ms) {
    final d = Duration(milliseconds: ms);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    final millis = twoDigits((d.inMilliseconds.remainder(1000) ~/ 10));
    return '$minutes:$seconds.$millis';
  }

  @override
  Widget build(BuildContext context) {
    final bool isRunning = _stopwatch.isRunning;
    final bool hasElapsed = _stopwatch.elapsedMilliseconds > 0;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Stopwatch Minum Air'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'Gunakan untuk mengukur interval jeda minum atau durasi olahraga',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // 1. Tampilan Waktu Digital Utama
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _formatWaktu(_stopwatch.elapsedMilliseconds),
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Baris Dua Tombol Kontrol Terpadu
            Row(
              children: [
                // A. Tombol Gabungan Lap / Reset (Sisi Kiri)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isRunning
                        ? _lap // Saat berjalan -> Aksi Lap
                        : (hasElapsed ? _reset : null), // Saat jeda & ada waktu -> Aksi Reset
                    icon: Icon(isRunning ? Icons.flag_outlined : Icons.refresh),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRunning
                          ? AppColors.primary
                          : (hasElapsed ? AppColors.danger : Colors.grey.shade300),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade200,
                      disabledForegroundColor: Colors.grey.shade500,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: (isRunning || hasElapsed) ? 2 : 0,
                    ),
                    label: Text(
                      isRunning
                          ? 'Lap'
                          : (hasElapsed ? 'Reset' : 'Lap'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // B. Tombol Utama Mulai / Jeda (Sisi Kanan)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isRunning ? _pause : _start,
                    icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRunning ? AppColors.warning : AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    label: Text(
                      isRunning ? 'Jeda' : (hasElapsed ? 'Lanjut' : 'Mulai'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Daftar Riwayat Lap
            Expanded(
              child: _lapList.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.timer_outlined,
                      title: 'Belum ada putaran waktu (Lap)',
                      subtitle:
                          'Tekan tombol "Lap" saat stopwatch sedang berjalan untuk merekam catatan putaran waktu.',
                    )
                  : ListView.builder(
                      itemCount: _lapList.length,
                      itemBuilder: (context, i) {
                        final lapIndex = _lapList.length - i;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 1,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              child: Text(
                                '#$lapIndex',
                                style: const TextStyle(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              'Lap $lapIndex',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            trailing: Text(
                              _lapList[i],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
