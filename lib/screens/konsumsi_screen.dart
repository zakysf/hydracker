import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../db/db_helper.dart';
import '../models/konsumsi_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/session.dart';
import '../utils/ui_helper.dart';
import '../widgets/empty_state.dart';
import '../widgets/hydration_card.dart';

/// Layar [KonsumsiScreen] menyediakan fitur CRUD (Create, Read, Update, Delete)
/// lengkap untuk riwayat konsumsi air minum pengguna.
class KonsumsiScreen extends StatefulWidget {
  const KonsumsiScreen({super.key});

  @override
  State<KonsumsiScreen> createState() => _KonsumsiScreenState();
}

class _KonsumsiScreenState extends State<KonsumsiScreen> {
  List<KonsumsiModel> _konsumsiList = [];
  int? _userId;
  double _targetMl = AppConstants.defaultTargetAirMl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  /// Inisialisasi awal: mengambil ID user dari session dan memuat daftar konsumsi
  Future<void> _initData() async {
    _userId = await Session.getUserId();
    final savedTarget = await Session.getTargetAir();

    if (mounted) {
      setState(() => _targetMl = savedTarget);
    }

    if (_userId != null) {
      try {
        final user = await DBHelper().getUserById(_userId!);
        if (user != null && user.targetAir > 0) {
          await Session.setTargetAir(user.targetAir);
          if (mounted) setState(() => _targetMl = user.targetAir);
        }
      } catch (e) {
        debugPrint('Gagal sinkronisasi target di KonsumsiScreen: $e');
      }
    }
    await _loadRiwayat();
  }

  /// Memuat riwayat konsumsi air dari Supabase
  Future<void> _loadRiwayat() async {
    if (_userId == null) return;
    setState(() => _isLoading = true);

    try {
      final data = await DBHelper().getKonsumsiByUser(_userId!);
      if (mounted) {
        setState(() {
          _konsumsiList = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        UIHelper.showErrorSnackBar(context, 'Gagal memuat riwayat konsumsi: $e');
      }
    }
  }

  /// Menghitung akumulasi volume air yang diminum khusus HARI INI
  double get _totalHariIniMl {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _konsumsiList
        .where((item) => item.tanggal == today)
        .fold(0.0, (sum, item) => sum + item.volume);
  }

  /// Menampilkan Form Bottom Sheet untuk Tambah (Create) atau Edit (Update) Catatan
  Future<void> _showFormModal({KonsumsiModel? itemToEdit}) async {
    final formKey = GlobalKey<FormState>();
    String selectedJenis = itemToEdit?.jenis ?? AppConstants.jenisMinumanList[0];
    final volumeCtrl = TextEditingController(
      text: itemToEdit != null ? itemToEdit.volume.toStringAsFixed(0) : '',
    );

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
                  // Header Judul Form Modal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        itemToEdit == null ? 'Tambah Catatan Minum' : 'Edit Catatan Minum',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Dropdown Pilihan Jenis Minuman
                  DropdownButtonFormField<String>(
                    initialValue: selectedJenis,
                    items: AppConstants.jenisMinumanList
                        .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                        .toList(),
                    onChanged: (v) => setModalState(() => selectedJenis = v!),
                    decoration: InputDecoration(
                      labelText: 'Jenis Minuman',
                      prefixIcon: const Icon(Icons.local_drink, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Input Volume Minuman (ml)
                  TextFormField(
                    controller: volumeCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      LengthLimitingTextInputFormatter(5),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Volume Air (ml)',
                      hintText: 'Contoh: 250 (10 - 5.000 ml)',
                      prefixIcon: const Icon(Icons.water, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      helperText: 'Rentang per minum yang wajar: 10 - 5.000 ml',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Volume minuman wajib diisi';
                      }
                      final val = double.tryParse(v);
                      if (val == null || val.isNaN) {
                        return 'Masukkan format angka yang valid';
                      }
                      if (val < AppConstants.minVolumeMinum) {
                        return 'Volume minimal ${AppConstants.minVolumeMinum.toStringAsFixed(0)} ml';
                      }
                      if (val > AppConstants.maxVolumeMinum) {
                        return 'Volume maksimal ${AppConstants.maxVolumeMinum.toStringAsFixed(0)} ml per catatan';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Tombol Simpan
                  ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final vol = double.parse(volumeCtrl.text.trim());
                      final now = DateTime.now();

                      final newKonsumsi = KonsumsiModel(
                        userId: _userId ?? 0,
                        jenis: selectedJenis,
                        volume: vol,
                        tanggal: itemToEdit?.tanggal ?? DateFormat('yyyy-MM-dd').format(now),
                        waktu: itemToEdit?.waktu ?? DateFormat('HH:mm').format(now),
                      );

                      try {
                        if (itemToEdit == null) {
                          // Operasi CREATE
                          await DBHelper().tambahKonsumsi(newKonsumsi);
                          if (mounted) {
                            UIHelper.showSuccessSnackBar(
                              context,
                              'Catatan minum ${vol.toStringAsFixed(0)} ml berhasil ditambahkan!',
                            );
                          }
                        } else {
                          // Operasi UPDATE
                          await DBHelper().updateKonsumsi(itemToEdit.id!, newKonsumsi);
                          if (mounted) {
                            UIHelper.showSuccessSnackBar(
                              context,
                              'Catatan minum berhasil diperbarui!',
                            );
                          }
                        }

                        if (ctx.mounted) Navigator.pop(ctx);
                        _loadRiwayat();
                      } catch (e) {
                        if (mounted) {
                          UIHelper.showErrorSnackBar(context, 'Gagal menyimpan catatan: $e');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      itemToEdit == null ? 'Tambah Catatan' : 'Simpan Perubahan',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Menghapus catatan dengan dialog konfirmasi terlebih dahulu
  Future<void> _hapusCatatan(KonsumsiModel item) async {
    final bool setuju = await UIHelper.showConfirmDialog(
      context,
      title: 'Hapus Catatan',
      message: 'Apakah Anda yakin ingin menghapus catatan "${item.infoRingkas}"?',
      confirmLabel: 'Hapus',
      confirmColor: AppColors.danger,
    );

    if (setuju && item.id != null) {
      try {
        await DBHelper().deleteKonsumsi(item.id!);
        if (mounted) {
          UIHelper.showInfoSnackBar(context, 'Catatan berhasil dihapus');
        }
        _loadRiwayat();
      } catch (e) {
        if (mounted) {
          UIHelper.showErrorSnackBar(context, 'Gagal menghapus catatan: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Catatan Konsumsi Air'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showFormModal(),
        icon: const Icon(Icons.add),
        label: const Text('Catat Minum', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // 1. KARTU STATUS PROGRESS HIDRASI (Reusable Widget)
          HydrationCard(
            totalHariIniMl: _totalHariIniMl,
            targetMl: _targetMl,
            showActionButton: false,
            isHeaderStyle: true,
          ),

          // 2. DAFTAR RIWAYAT KONSUMSI AIR
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _konsumsiList.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.local_drink_outlined,
                        title: 'Belum ada catatan konsumsi air',
                        subtitle: 'Tekan tombol "Catat Minum" di bawah untuk mulai merekam hidrasimu hari ini.',
                      )
                    : ListView.builder(
                        itemCount: _konsumsiList.length,
                        padding: const EdgeInsets.only(top: 12, bottom: 85),
                        itemBuilder: (context, index) {
                          final item = _konsumsiList[index];

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 1,
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.primaryLight,
                                child: Icon(Icons.local_drink, color: AppColors.primary),
                              ),
                              title: Text(
                                item.infoRingkas,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('${item.tanggal} • ${item.waktu} WIB'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                    tooltip: 'Edit',
                                    onPressed: () => _showFormModal(itemToEdit: item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: AppColors.danger, size: 20),
                                    tooltip: 'Hapus',
                                    onPressed: () => _hapusCatatan(item),
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
