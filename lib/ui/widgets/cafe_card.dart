import 'package:flutter/material.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/cafe.dart';
import '../../domain/crowd_aggregator.dart';
import '../theme/app_theme.dart';
import 'cafe_leading.dart';
import 'crowd_chip.dart';

class CafeCard extends StatefulWidget {
  final Cafe cafe;
  final double? distanceKm;
  final CrowdSummary? crowdSummary;
  final VoidCallback onTap;

  const CafeCard({
    super.key,
    required this.cafe,
    required this.distanceKm,
    required this.crowdSummary,
    required this.onTap,
  });

  @override
  State<CafeCard> createState() => _CafeCardState();
}

class _CafeCardState extends State<CafeCard> {
  bool _isPressed = false;

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Sepi':
        return AppColors.statusSepiText;
      case 'Sedang':
        return AppColors.statusSedangText;
      case 'Penuh':
        return AppColors.statusPenuhText;
      default:
        return AppColors.statusNoneText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final Color statusColor = _getStatusColor(widget.crowdSummary?.status);

    return Semantics(
      button: true,
      label:
          'Kafe ${widget.cafe.name}, jarak ${formatDistance(widget.distanceKm)}, status ${widget.crowdSummary?.status ?? "Belum ada laporan terbaru"}',
      child: AnimatedScale(
        scale: disableAnimations ? 1.0 : (_isPressed ? 0.98 : 1.0),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (highlighted) {
              if (mounted) {
                setState(() => _isPressed = highlighted);
              }
            },
            borderRadius: BorderRadius.circular(AppTheme.uniformRadius),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Strip tipis berwarna status di sisi kiri kartu
                  Container(
                    width: 5,
                    color: statusColor,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Baris atas: Kotak inisial, Nama kafe (Hero), dan Kapsul jarak
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CafeLeading(cafe: widget.cafe),
                              const SizedBox(width: AppSpacing.s12),
                              Expanded(
                                child: Hero(
                                  tag: 'cafe_title_${widget.cafe.id}',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      widget.cafe.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (widget.distanceKm != null) ...[
                                const SizedBox(width: AppSpacing.s8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryTint,
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.uniformRadius,
                                    ),
                                    border: Border.all(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.15),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.near_me_outlined,
                                        size: 12,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        formatDistance(widget.distanceKm),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s12),

                          // Alamat singkat
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.cafe.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Kisaran harga
                          Row(
                            children: [
                              const Icon(
                                Icons.payments_outlined,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                formatPriceRange(
                                  widget.cafe.priceMin,
                                  widget.cafe.priceMax,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s12),

                          // Baris fasilitas (Wi-Fi, Colokan)
                          Row(
                            children: [
                              if (widget.cafe.hasWifi) ...[
                                _buildFeatureBadge(
                                  icon: Icons.wifi,
                                  label: 'Wi-Fi',
                                ),
                                const SizedBox(width: 6),
                              ],
                              if (widget.cafe.hasOutlet) ...[
                                _buildFeatureBadge(
                                  icon: Icons.power,
                                  label: 'Colokan',
                                ),
                                const SizedBox(width: 6),
                              ],
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s12),

                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.border,
                          ),
                          const SizedBox(height: AppSpacing.s8),

                          // Status Kepadatan dan Waktu Laporan
                          Row(
                            children: [
                              CrowdChip(summary: widget.crowdSummary),
                              const Spacer(),
                              if (widget.crowdSummary != null)
                                Text(
                                  formatTimeAgo(
                                    widget.crowdSummary!.latestReportTime,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureBadge({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppTheme.uniformRadius),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
