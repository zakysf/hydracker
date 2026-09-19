import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  double _targetMl = 2000.0;
  bool _isLoading = true;

  final List<String> _jenisList = [
    'Air Putih',
    'Teh',
    'Kopi',
    'Jus',
    'Susu',
    'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _userId = await Session.getUserId();
    final savedTarget = await Session.getTargetAir();
    if (mounted) {
      setState(() => _targetMl = (savedTarget > 0 && !savedTarget.isNaN) ? savedTarget : 2000.0);
    }

    if (_userId != null) {
      try {
        final user = await DBHelper().getUserById(_userId!);
        if (user != null && user['targetAir'] != null) {
          final targetRaw = user['targetAir'];
          final target = (targetRaw is num)
              ? targetRaw.toDouble()
              : (double.tryParse(targetRaw.toString()) ?? 2000.0);
          if (target > 0 && !target.isNaN) {
            await Session.setTargetAir(target);
            if (mounted) setState(() => _targetMl = target);
          }
        }
      } catch (e) {
        debugPrint('Error fetching user target: $e');
      }
    }
    await _load();
  }

  Future<void> _load() async {
    if (_userId == null) return;
    setState(() => _isLoading = true);
    try {
      final data = await DBHelper().getKonsumsiByUser(_userId!);
      if (mounted) {
        setState(() {
          _list = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Menghitung total konsumsi khusus HARI INI secara aman
  double get _totalHariIniMl {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _list.where((e) => e['tanggal'] == today).fold(0.0, (sum, e) {
      final vol = e['volume'];
      final val = (vol is num)
          ? vol.toDouble()
          : (double.tryParse(vol?.toString() ?? '') ?? 0.0);
      return sum + (val.isNaN ? 0.0 : val);
    });
  }

  Future<void> _showForm({Map<String, dynamic>? item}) async {
    final formKey = GlobalKey<FormState>();
    String jenis = item?['jenis'] ?? _jenisList[0];
    final volumeCtrl = TextEditingController(
        text: item != null ? item['volume']?.toString() ?? '' : '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: StatefulBuilder(
            builder: (ctx, setModalState) => Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item == null ? 'Tambah Konsumsi' : 'Edit Konsumsi',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: jenis,
                    items: _jenisList
                        .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                        .toList(),
                    onChanged: (v) => setModalState(() => jenis = v!),
                    decoration: const InputDecoration(
                      labelText: 'Jenis Minuman',
                      prefixIcon: Icon(Icons.local_drink),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: volumeCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      LengthLimitingTextInputFormatter(5), // Maksimal 5 digit (misal: 1500)
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Volume (ml)',
                      hintText: 'Rentang: 10 - 5.000 ml (Contoh: 250)',
                      prefixIcon: Icon(Icons.water),
                      border: OutlineInputBorder(),
                      helperText: 'Rentang volume wajar per minum: 10 - 5.000 ml',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Volume minuman wajib diisi';
                      }
                      final val = double.tryParse(v);
                      if (val == null || val.isNaN) {
                        return 'Masukkan format angka yang valid';
                      }
                      if (val < 10) {
                        return 'Volume minimal 10 ml';
                      }
                      if (val > 5000) {
                        return 'Volume maksimal 5.000 ml (5 Liter) per catatan';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final vol = double.parse(volumeCtrl.text.trim());
                      final now = DateTime.now();
                      final data = {
                        'userId': _userId,
                        'jenis': jenis,
                        'volume': vol,
                        'tanggal': DateFormat('yyyy-MM-dd').format(now),
                        'waktu': DateFormat('HH:mm').format(now),
                      };

                      try {
                        if (item == null) {
                          await DBHelper().tambahKonsumsi(data);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Catatan konsumsi berhasil ditambahkan'),
                                  backgroundColor: Colors.green),
                            );
                          }
                        } else {
                          final id = int.parse(item['id'].toString());
                          await DBHelper().updateKonsumsi(id, data);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Catatan konsumsi berhasil diperbarui'),
                                  backgroundColor: Colors.green),
                            );
                          }
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                        _load();
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Gagal menyimpan: $e'),
                                backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(item == null ? 'Tambah' : 'Simpan Perubahan'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _konfirmasiHapus(int id, String info) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: Text('Apakah Anda yakin ingin menghapus catatan "$info"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (setuju == true) {
      await _hapus(id);
    }
  }

  Future<void> _hapus(int id) async {
    try {
      await DBHelper().deleteKonsumsi(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catatan konsumsi berhasil dihapus'),
            backgroundColor: Colors.blueGrey,
          ),
        );
      }
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus catatan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = (_totalHariIniMl.isNaN || _totalHariIniMl.isInfinite || _totalHariIniMl < 0)
        ? 0.0
        : _totalHariIniMl;
    final target = (_targetMl.isNaN || _targetMl.isInfinite || _targetMl <= 0)
        ? 2000.0
        : _targetMl;

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
      appBar: AppBar(title: const Text('Catatan Konsumsi Air')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Tracking Card Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF0288D1),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sudah Diminum',
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
                        Text(
                          '${total.toStringAsFixed(0)} ml',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Target Harian',
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
                        Text(
                          '${target.toStringAsFixed(0)} ml',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0 ? Colors.lightGreenAccent : Colors.cyanAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$persentase% Tercapai',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      sisa <= 0
                          ? '🎉 Target Tercapai!'
                          : 'Sisa ${sisa.toStringAsFixed(0)} ml lagi',
                      style: TextStyle(
                        color: sisa <= 0 ? Colors.lightGreenAccent : Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _list.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada catatan hari ini.\nTekan tombol + untuk menambah.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _list.length,
                        padding: const EdgeInsets.only(top: 10, bottom: 80),
                        itemBuilder: (context, i) {
                          final item = _list[i];
                          final id = int.parse(item['id'].toString());
                          final volRaw = item['volume'];
                          final vol = (volRaw is num)
                              ? volRaw.toDouble()
                              : (double.tryParse(volRaw?.toString() ?? '') ?? 0.0);
                          final info = '${item['jenis']} - ${vol.toStringAsFixed(0)} ml';

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFE1F5FE),
                                child: Icon(Icons.local_drink,
                                    color: Color(0xFF0288D1)),
                              ),
                              title: Text(info,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              subtitle:
                                  Text('${item['tanggal']} • ${item['waktu']}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    tooltip: 'Edit',
                                    onPressed: () => _showForm(item: item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    tooltip: 'Hapus',
                                    onPressed: () =>
                                        _konfirmasiHapus(id, info),
                                  ),
                                ],
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
