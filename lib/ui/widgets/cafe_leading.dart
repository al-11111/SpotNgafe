import 'package:flutter/material.dart';
import '../../data/models/cafe.dart';
import '../theme/app_theme.dart';

class CafeLeading extends StatelessWidget {
  final Cafe cafe;
  final double size;

  const CafeLeading({
    super.key,
    required this.cafe,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final String initial =
        cafe.name.isNotEmpty ? cafe.name[0].toUpperCase() : 'K';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(AppTheme.uniformRadius),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: (size * 0.41).clamp(14.0, 24.0),
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
