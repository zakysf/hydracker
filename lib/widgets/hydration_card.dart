import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Komponen UI [HydrationCard] menampilkan status hidrasi harian pengguna.
///
/// Kartu ini merangkum:
/// - Volume air yang sudah diminum hari ini
/// - Target minum harian
/// - Progress bar visual dengan persentase capaian
/// - Keterangan sisa volume yang harus diminum
/// - Tombol aksi opsional (Catat Minum, Ubah Target)
///
/// Widget ini dapat dipakai ulang (reusable) di `HomeScreen` dan `KonsumsiScreen`,
/// sehingga menghilangkan duplikasi kode perhitungan & tampilan (DRY).
class HydrationCard extends StatelessWidget {
  final double totalHariIniMl;
  final double targetMl;
  final VoidCallback? onCatatMinum;
  final VoidCallback? onUbahTarget;
  final bool showActionButton;
  final bool isHeaderStyle;

  const HydrationCard({
    super.key,
    required this.totalHariIniMl,
    required this.targetMl,
    this.onCatatMinum,
    this.onUbahTarget,
    this.showActionButton = true,
    this.isHeaderStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Sanitasi input angka agar terhindar dari NaN atau Infinite
    final safeTotal = (totalHariIniMl.isNaN || totalHariIniMl.isInfinite || totalHariIniMl < 0)
        ? 0.0
        : totalHariIniMl;

    final safeTarget = (targetMl.isNaN || targetMl.isInfinite || targetMl <= 0)
        ? 2000.0
        : targetMl;

    // 2. Perhitungan rasio progress & persentase capaian
    double progress = 0.0;
    int persentase = 0;
    if (safeTarget > 0) {
      final ratio = safeTotal / safeTarget;
      if (!ratio.isNaN && !ratio.isInfinite) {
        progress = ratio.clamp(0.0, 1.0); // Clamp membatasi nilai antara 0.0 hingga 1.0 untuk ProgressIndicator
        persentase = (ratio * 100).round();
      }
    }

    // 3. Hitung sisa air yang perlu diminum
    final double sisa = (safeTarget - safeTotal) > 0 ? (safeTarget - safeTotal) : 0.0;
    final bool isTargetReached = progress >= 1.0;

    // Konten utama kartu
    Widget cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Baris 1: Ikon + Judul + Label Persentase
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.water_drop, color: AppColors.textWhite, size: 24),
                SizedBox(width: 8),
                Text(
                  'Status Hidrasi Hari Ini',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$persentase%',
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Baris 2: Sudah Diminum vs Target Minum
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sudah Diminum',
                  style: TextStyle(color: AppColors.textWhite70, fontSize: 12),
                ),
                Text(
                  '${safeTotal.toStringAsFixed(0)} ml',
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Target Harian',
                  style: TextStyle(color: AppColors.textWhite70, fontSize: 12),
                ),
                Text(
                  '${safeTarget.toStringAsFixed(0)} ml',
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Baris 3: Linear Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: AppColors.progressBackground,
            valueColor: AlwaysStoppedAnimation<Color>(
              isTargetReached ? AppColors.progressComplete : AppColors.progressIncomplete,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Baris 4: Teks Status Capaian & Tombol Navigasi Ubah Target
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                isTargetReached
                    ? '🎉 Target Hari Ini Tercapai!'
                    : 'Sisa ${sisa.toStringAsFixed(0)} ml untuk capai target',
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onUbahTarget != null)
              InkWell(
                onTap: onUbahTarget,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Ubah Target',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),

        // Baris 5: Tombol Aksi Cepat "Catat Minum Sekarang"
        if (showActionButton && onCatatMinum != null) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 1,
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'Catat Minum Sekarang',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: onCatatMinum,
            ),
          ),
        ],
      ],
    );

    // Jika mode header gaya appbar melengkung (seperti di layar Catatan Konsumsi)
    if (isHeaderStyle) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        child: cardContent,
      );
    }

    // Default mode: Card Gradient melayang (seperti di HomeScreen)
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: cardContent,
      ),
    );
  }
}
