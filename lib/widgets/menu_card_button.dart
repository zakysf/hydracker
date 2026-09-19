import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Komponen UI [MenuCardButton] untuk tombol menu beranda.
///
/// Memiliki tampilan kartu putih berbayang halus dengan ikon primer di sebelah kiri
/// dan teks judul menu di sebelah kanan.
class MenuCardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const MenuCardButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            backgroundColor: AppColors.cardBackground,
            foregroundColor: AppColors.primary,
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(icon, color: AppColors.primary),
          label: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          onPressed: onTap,
        ),
      ),
    );
  }
}
