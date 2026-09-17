import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class AnggotaScreen extends StatefulWidget {
  const AnggotaScreen({super.key});
  @override
  State<AnggotaScreen> createState() => _AnggotaScreenState();
}

class _AnggotaScreenState extends State<AnggotaScreen> {
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DBHelper().getAllUsers();
    setState(() => _users = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Anggota')),
      body: _users.isEmpty
          ? const Center(child: Text('Belum ada anggota terdaftar'))
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, i) {
                final u = _users[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(u['nama'] ?? '-'),
                    subtitle: Text(
                        'Username: ${u['username']}\nBB: ${u['berat']} kg, TB: ${u['tinggi']} cm'),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
