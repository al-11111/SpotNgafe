import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = AppTheme.uniformRadius,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    if (disableAnimations) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: const Color(0xFFEBE9E2),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value;
        final Color color = Color.lerp(
          const Color(0xFFECEAE3),
          const Color(0xFFF7F6F2),
          t,
        )!;

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

class ShimmerCafeCard extends StatelessWidget {
  const ShimmerCafeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerBox(
                  width: 44,
                  height: 44,
                  borderRadius: AppTheme.uniformRadius,
                ),
                SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 140, height: 16),
                      SizedBox(height: AppSpacing.s8),
                      ShimmerBox(width: 90, height: 12),
                    ],
                  ),
                ),
                ShimmerBox(width: 50, height: 22),
              ],
            ),
            SizedBox(height: AppSpacing.s12),
            ShimmerBox(height: 14),
            SizedBox(height: AppSpacing.s8),
            ShimmerBox(width: 160, height: 14),
            SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                ShimmerBox(width: 60, height: 24),
                SizedBox(width: AppSpacing.s8),
                ShimmerBox(width: 70, height: 24),
                Spacer(),
                ShimmerBox(width: 80, height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
