import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/formatters.dart';
import '../../data/models/cafe.dart';
import '../../data/repositories/cafe_repository.dart';
import '../../data/services/auth_service.dart';
import '../../domain/crowd_aggregator.dart';
import '../theme/app_theme.dart';
import '../widgets/crowd_chip.dart';
import '../widgets/info_tile.dart';
import '../widgets/report_sheet.dart';

class CafeDetailScreen extends StatefulWidget {
  final Cafe cafe;
  final double? distanceKm;

  const CafeDetailScreen({
    super.key,
    required this.cafe,
    required this.distanceKm,
  });

  @override
  State<CafeDetailScreen> createState() => _CafeDetailScreenState();
}

class _CafeDetailScreenState extends State<CafeDetailScreen> {
  bool _isLoading = true;
  CrowdSummary? _crowdSummary;
  bool _hasNewReport = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    final repo = context.read<CafeRepository>();
    try {
      final reports = await repo.getReportsForCafe(widget.cafe.id);
      if (!mounted) return;
      setState(() {
        _crowdSummary = CrowdAggregator.aggregateReports(reports);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openGoogleMaps() async {
    final double lat = widget.cafe.latitude;
    final double lng = widget.cafe.longitude;
    final String name = widget.cafe.name;

    final Uri geoUri = Uri.parse(
      'geo:$lat,$lng?q=$lat,$lng(${Uri.encodeComponent(name)})',
    );
    final Uri webUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    try {
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka peta di perangkat.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _openReportSheet() async {
    final repo = context.read<CafeRepository>();
    final auth = context.read<AuthService>();
    final String? userId = auth.currentUserId;

    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengidentifikasi pengguna. Silakan coba lagi.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final result = await ReportSheet.show(
      context: context,
      cafeId: widget.cafe.id,
      userId: userId,
      repository: repo,
    );

    if (result == true) {
      _hasNewReport = true;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan terkirim'),
          duration: Duration(seconds: 2),
        ),
      );
      _loadReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_hasNewReport);
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // SliverAppBar berlatar tint hijau dengan nama kafe besar (Hero)
            SliverAppBar(
              pinned: true,
              expandedHeight: 120,
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(_hasNewReport),
              ),
              flexibleSpace: FlexibleSpaceBar(
                expandedTitleScale: 1.25,
                titlePadding: const EdgeInsets.only(
                  left: 56,
                  bottom: 14,
                  right: AppSpacing.s16,
                ),
                title: Hero(
                  tag: 'cafe_title_${widget.cafe.id}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      widget.cafe.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                background: Container(color: AppColors.primaryTint),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tepat DUA ubin info sama lebar: Jarak dan Kisaran Harga
                    Row(
                      children: [
                        Expanded(
                          child: InfoTile(
                            icon: Icons.near_me_outlined,
                            label: 'Jarak',
                            value: formatDistance(widget.distanceKm),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(
                          child: InfoTile(
                            icon: Icons.payments_outlined,
                            label: 'Kisaran Harga',
                            value: formatPriceRange(
                              widget.cafe.priceMin,
                              widget.cafe.priceMax,
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s16),

                    // Kartu Alamat, Jam Buka, dan Fasilitas
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.s16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lokasi & Fasilitas',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: AppSpacing.s8),
                                Expanded(
                                  child: Text(
                                    widget.cafe.address,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10.0),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.access_time_outlined,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: AppSpacing.s8),
                                Expanded(
                                  child: Text(
                                    widget.cafe.openHours,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.s16),
                            const Divider(height: 1, color: AppColors.border),
                            const SizedBox(height: AppSpacing.s12),
                            Wrap(
                              spacing: AppSpacing.s8,
                              children: [
                                if (widget.cafe.hasWifi)
                                  _buildFacilityChip(
                                    icon: Icons.wifi,
                                    label: 'Wi-Fi',
                                  ),
                                if (widget.cafe.hasOutlet)
                                  _buildFacilityChip(
                                    icon: Icons.power,
                                    label: 'Colokan',
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),

                    // Kartu Status Kepadatan Menonjol
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.s16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Status Kepadatan Saat Ini',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s12),
                            if (_isLoading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(AppSpacing.s16),
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            else ...[
                              // Chip status besar bertransisi halus
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 350),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                      scale: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: CrowdChip(
                                  key: ValueKey(
                                    _crowdSummary?.status ?? 'none',
                                  ),
                                  summary: _crowdSummary,
                                  isLarge: true,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s12),
                              if (_crowdSummary != null)
                                Text(
                                  'Dilaporkan ${formatTimeAgo(_crowdSummary!.latestReportTime)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              const SizedBox(height: AppSpacing.s4),
                              const Text(
                                'Berdasarkan laporan pengunjung dalam 2 jam terakhir',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s24),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Bar tombol tetap di bawah layar supaya selalu terlihat
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: const Border(
              top: BorderSide(color: AppColors.border, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  button: true,
                  label: 'Buka sheet lapor kepadatan kafe',
                  child: ElevatedButton(
                    onPressed: _openReportSheet,
                    child: const Text('Lapor Kepadatan'),
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                Semantics(
                  button: true,
                  label: 'Buka rute di Google Maps',
                  child: OutlinedButton(
                    onPressed: _openGoogleMaps,
                    child: const Text('Buka di Google Maps'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFacilityChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(AppTheme.uniformRadius),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
