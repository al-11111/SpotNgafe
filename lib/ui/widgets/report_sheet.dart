import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/crowd_report.dart';
import '../../data/repositories/cafe_repository.dart';
import '../../domain/crowd_aggregator.dart';
import '../theme/app_theme.dart';
import 'animated_check.dart';

class ReportSheet extends StatefulWidget {
  final String cafeId;
  final String userId;
  final CafeRepository repository;

  const ReportSheet({
    super.key,
    required this.cafeId,
    required this.userId,
    required this.repository,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String cafeId,
    required String userId,
    required CafeRepository repository,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.uniformRadius),
        ),
      ),
      builder: (context) {
        return ReportSheet(
          cafeId: cafeId,
          userId: userId,
          repository: repository,
        );
      },
    );
  }

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  bool _isSubmitting = false;
  bool _isSuccess = false;
  String? _errorMessage;
  String? _pressedStatus;

  Future<void> _handleReport(String status) async {
    HapticFeedback.lightImpact();

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // 1. Cek anti-spam: ambil laporan pengguna untuk kafe ini
      final userReports = await widget.repository.getUserReportsForCafe(
        widget.cafeId,
        widget.userId,
      );

      final CooldownResult cooldown = CrowdAggregator.checkCooldown(
        userReportsForCafe: userReports,
      );

      if (!cooldown.canReport) {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
          _errorMessage =
              'Kamu sudah melapor. Tunggu ${cooldown.remainingMinutes} menit lagi untuk kafe ini.';
        });
        return;
      }

      // 2. Buat dokumen laporan baru dengan ID otomatis
      final newReport = CrowdReport(
        id: '',
        cafeId: widget.cafeId,
        userId: widget.userId,
        status: status,
        createdAt: DateTime.now(),
      );

      await widget.repository.submitReport(newReport);

      final navigator = Navigator.of(context);

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _isSuccess = true;
      });

      // Tunggu tanda centang beranimasi ~700 ms lalu tutup otomatis
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) {
        navigator.pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Gagal mengirim laporan. Silakan coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<bool>(
      canPop: !_isSuccess,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isSuccess) {
          Navigator.of(context).pop(true);
        }
      },
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s16,
            AppSpacing.s12,
            AppSpacing.s16,
            AppSpacing.s16,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isSuccess
                ? const AnimatedCheck(message: 'Laporan terkirim')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),

                      // Judul
                      const Text(
                        'Seberapa ramai kafe ini sekarang?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),

                      // Keterangan cooldown
                      const Text(
                        'Satu laporan per kafe setiap 30 menit',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),

                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.s12),
                          decoration: BoxDecoration(
                            color: AppColors.statusPenuhBg,
                            borderRadius:
                                BorderRadius.circular(AppTheme.uniformRadius),
                            border: Border.all(
                              color: AppColors.statusPenuhText,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.statusPenuhText,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s16),
                      ],

                      if (_isSubmitting)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 28),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else ...[
                        // Tiga kartu pilihan besar
                        _buildCrowdCard(
                          status: 'Sepi',
                          description: 'Banyak meja kosong, sangat tenang',
                          icon: Icons.chair_outlined,
                          textColor: AppColors.statusSepiText,
                          bgColor: AppColors.statusSepiBg,
                        ),
                        const SizedBox(height: AppSpacing.s12),

                        _buildCrowdCard(
                          status: 'Sedang',
                          description: 'Cukup ramai, masih ada beberapa meja',
                          icon: Icons.group_outlined,
                          textColor: AppColors.statusSedangText,
                          bgColor: AppColors.statusSedangBg,
                        ),
                        const SizedBox(height: AppSpacing.s12),

                        _buildCrowdCard(
                          status: 'Penuh',
                          description: 'Hampir atau tidak ada meja tersisa',
                          icon: Icons.groups_outlined,
                          textColor: AppColors.statusPenuhText,
                          bgColor: AppColors.statusPenuhBg,
                        ),
                        const SizedBox(height: AppSpacing.s16),

                        // Tombol Batal
                        Semantics(
                          button: true,
                          label: 'Batal melapor',
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Batal'),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCrowdCard({
    required String status,
    required String description,
    required IconData icon,
    required Color textColor,
    required Color bgColor,
  }) {
    final bool isHighlighted = _pressedStatus == status;
    final bool disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Semantics(
      button: true,
      label: 'Lapor status $status: $description',
      child: AnimatedScale(
        scale: disableAnimations ? 1.0 : (isHighlighted ? 0.98 : 1.0),
        duration: const Duration(milliseconds: 100),
        child: InkWell(
          onTap: () => _handleReport(status),
          onHighlightChanged: (highlighted) {
            setState(() {
              _pressedStatus = highlighted ? status : null;
            });
          },
          borderRadius: BorderRadius.circular(AppTheme.uniformRadius),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppTheme.uniformRadius),
              border: Border.all(color: textColor, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: textColor, size: 22),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 14, color: textColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
