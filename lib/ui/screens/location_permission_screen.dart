import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../data/services/location_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen>
    with SingleTickerProviderStateMixin {
  bool _isRequesting = false;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.94, end: 1.04).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateNext() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  Future<void> _handleRequestPermission(LocationService service) async {
    setState(() => _isRequesting = true);

    final bool isGpsEnabled = await Geolocator.isLocationServiceEnabled();
    if (!mounted) return;
    if (!isGpsEnabled) {
      setState(() => _isRequesting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('GPS mati. Nyalakan GPS lalu coba lagi.'),
          duration: Duration(seconds: 2),
        ),
      );
      await service.openLocationSettings();
      return;
    }

    final permission = await service.requestPermission();
    if (!mounted) return;
    setState(() => _isRequesting = false);

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      _navigateNext();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin lokasi belum diberikan.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleSkip() {
    _navigateNext();
  }

  @override
  Widget build(BuildContext context) {
    final locationService = context.read<LocationService>();
    final bool disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s24,
            vertical: AppSpacing.s16,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Ikon lokasi dengan animasi denyut pelan
              Center(
                child: disableAnimations
                    ? Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          size: 44,
                          color: AppColors.primary,
                        ),
                      )
                    : AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseScale.value,
                            child: Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: AppColors.primaryTint,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.2),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                size: 44,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: AppSpacing.s24),

              // Judul
              const Text(
                'Aktifkan lokasi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s12),

              const Text(
                'SpotNgafe butuh lokasimu untuk menampilkan rekomendasi kafe terdekat di Malang.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s24),

              // Tiga poin singkat berikon
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: Column(
                    children: [
                      _buildPrivacyPoint(
                        icon: Icons.phone_android,
                        text: 'Jarak dihitung di HP-mu',
                      ),
                      const Divider(
                          height: AppSpacing.s16, color: AppColors.border),
                      _buildPrivacyPoint(
                        icon: Icons.shield_outlined,
                        text: 'Lokasi tidak disimpan',
                      ),
                      const Divider(
                          height: AppSpacing.s16, color: AppColors.border),
                      _buildPrivacyPoint(
                        icon: Icons.check_circle_outline,
                        text: 'Bisa dilewati',
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Tombol utama: Izinkan Lokasi
              Semantics(
                button: true,
                label: 'Izinkan akses lokasi',
                child: ElevatedButton(
                  onPressed: _isRequesting
                      ? null
                      : () => _handleRequestPermission(locationService),
                  child: _isRequesting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Izinkan Lokasi'),
                ),
              ),
              const SizedBox(height: AppSpacing.s12),

              // Tombol sekunder: Buka Pengaturan
              Semantics(
                button: true,
                label: 'Buka pengaturan perangkat',
                child: OutlinedButton(
                  onPressed: () => locationService.openAppSettings(),
                  child: const Text('Buka Pengaturan'),
                ),
              ),
              const SizedBox(height: AppSpacing.s12),

              // Tombol teks: Lewati dulu
              Semantics(
                button: true,
                label: 'Lewati pengaturan lokasi',
                child: TextButton(
                  onPressed: _handleSkip,
                  child: const Text('Lewati dulu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyPoint({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: AppColors.primaryTint,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.s12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
