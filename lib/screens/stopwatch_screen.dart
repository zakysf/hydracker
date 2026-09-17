import 'dart:async';
import 'package:flutter/material.dart';

class StopwatchScreen extends StatefulWidget {
  const StopwatchScreen({super.key});
  @override
  State<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  final List<String> _laps = [];

  void _start() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) => setState(() {}));
    setState(() {});
  }

  void _pause() {
    _stopwatch.stop();
    _timer?.cancel();
    setState(() {});
  }

  void _reset() {
    _stopwatch.reset();
    _timer?.cancel();
    _laps.clear();
    setState(() {});
  }

  void _lap() {
    setState(() => _laps.insert(0, _format(_stopwatch.elapsedMilliseconds)));
  }

  String _format(int ms) {
    final d = Duration(milliseconds: ms);
    String two(int n) => n.toString().padLeft(2, '0');
    final minutes = two(d.inMinutes.remainder(60));
    final seconds = two(d.inSeconds.remainder(60));
    final milli = two((d.inMilliseconds.remainder(1000) / 10).floor());
    return '$minutes:$seconds.$milli';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final running = _stopwatch.isRunning;
    return Scaffold(
      appBar: AppBar(title: const Text('Stopwatch Minum Air')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text('Gunakan sebagai pengingat interval minum air',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            Text(
              _format(_stopwatch.elapsedMilliseconds),
              style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Color(0xFF0288D1)),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: running ? _pause : _start,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: running ? Colors.orange : Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  ),
                  child: Text(running ? 'Jeda' : 'Mulai', style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: running ? _lap : null,
                  child: const Text('Lap'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _reset,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Reset', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _laps.length,
                itemBuilder: (context, i) => ListTile(
                  leading: CircleAvatar(child: Text('${_laps.length - i}')),
                  title: Text(_laps[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
