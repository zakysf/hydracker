import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/db_helper.dart';
import '../utils/session.dart';

class KonsumsiScreen extends StatefulWidget {
  const KonsumsiScreen({super.key});
  @override
  State<KonsumsiScreen> createState() => _KonsumsiScreenState();
}

class _KonsumsiScreenState extends State<KonsumsiScreen> {
  List<Map<String, dynamic>> _list = [];
  int? _userId;

  final List<String> _jenisList = ['Air Putih', 'Teh', 'Kopi', 'Jus', 'Susu', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _userId = await Session.getUserId();
    _load();
  }

  Future<void> _load() async {
    if (_userId == null) return;
    final data = await DBHelper().getKonsumsiByUser(_userId!);
    setState(() => _list = data);
  }

  double get _totalMl =>
      _list.fold(0.0, (sum, e) => sum + (e['volume'] as num).toDouble());

  Future<void> _showForm({Map<String, dynamic>? item}) async {
    String jenis = item?['jenis'] ?? _jenisList[0];
    final volumeCtrl = TextEditingController(
        text: item != null ? item['volume'].toString() : '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: StatefulBuilder(
            builder: (ctx, setModalState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(item == null ? 'Tambah Konsumsi' : 'Edit Konsumsi',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: jenis,
                  items: _jenisList
                      .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                      .toList(),
                  onChanged: (v) => setModalState(() => jenis = v!),
                  decoration: const InputDecoration(labelText: 'Jenis Minuman', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: volumeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Volume (ml)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final vol = double.tryParse(volumeCtrl.text);
                    if (vol == null || vol <= 0) return;
                    final now = DateTime.now();
                    final data = {
                      'userId': _userId,
                      'jenis': jenis,
                      'volume': vol,
                      'tanggal': DateFormat('yyyy-MM-dd').format(now),
                      'waktu': DateFormat('HH:mm').format(now),
                    };
                    if (item == null) {
                      await DBHelper().tambahKonsumsi(data);
                    } else {
                      await DBHelper().updateKonsumsi(item['id'], data);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                    _load();
                  },
                  child: const Text('Simpan'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _hapus(int id) async {
    await DBHelper().deleteKonsumsi(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catatan Konsumsi Air')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF0288D1),
            child: Column(
              children: [
                const Text('Total Hari Ini', style: TextStyle(color: Colors.white70)),
                Text('${_totalMl.toStringAsFixed(0)} ml',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: _list.isEmpty
                ? const Center(child: Text('Belum ada catatan. Tekan + untuk menambah.'))
                : ListView.builder(
                    itemCount: _list.length,
                    itemBuilder: (context, i) {
                      final item = _list[i];
                      return Dismissible(
                        key: ValueKey(item['id']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => _hapus(item['id']),
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          child: ListTile(
                            leading: const Icon(Icons.local_drink, color: Color(0xFF0288D1)),
                            title: Text('${item['jenis']} - ${item['volume']} ml'),
                            subtitle: Text('${item['tanggal']} • ${item['waktu']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showForm(item: item),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
