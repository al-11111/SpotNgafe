import 'package:flutter/material.dart';
import '../../domain/crowd_aggregator.dart';
import '../theme/app_theme.dart';

class CrowdChip extends StatelessWidget {
  final CrowdSummary? summary;
  final bool isLarge;

  const CrowdChip({
    super.key,
    required this.summary,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final String status = summary?.status ?? '';
    Color textColor;
    Color bgColor;
    String label;

    switch (status) {
      case 'Sepi':
        textColor = AppColors.statusSepiText;
        bgColor = AppColors.statusSepiBg;
        label = 'Sepi';
        break;
      case 'Sedang':
        textColor = AppColors.statusSedangText;
        bgColor = AppColors.statusSedangBg;
        label = 'Sedang';
        break;
      case 'Penuh':
        textColor = AppColors.statusPenuhText;
        bgColor = AppColors.statusPenuhBg;
        label = 'Penuh';
        break;
      default:
        textColor = AppColors.statusNoneText;
        bgColor = AppColors.statusNoneBg;
        label = 'Belum ada laporan terbaru';
        break;
    }

    final double dotSize = isLarge ? 10.0 : 8.0;
    final double fontSize = isLarge ? 14.0 : 12.0;
    final EdgeInsets padding = isLarge
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 6);

    return Semantics(
      label: 'Status kepadatan: $label',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: padding,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.uniformRadius),
          border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
