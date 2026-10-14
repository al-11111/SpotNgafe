import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/cafe_repository.dart';
import 'data/repositories/firestore_cafe_repository.dart';
import 'data/repositories/seed_cafe_repository.dart';
import 'data/services/auth_service.dart';
import 'data/services/location_service.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/theme/app_theme.dart';

/// Ubah menjadi true bila google-services.json sudah dikonfigurasi via FlutterFire.
/// Secara default false agar aplikasi dapat langsung didemokan dengan SeedCafeRepository.
const bool useFirebase = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  CafeRepository cafeRepository;
  if (useFirebase) {
    try {
      await Firebase.initializeApp();
      cafeRepository = FirestoreCafeRepository();
    } catch (_) {
      // Fallback ke seed repository jika inisialisasi Firebase gagal
      cafeRepository = SeedCafeRepository();
    }
  } else {
    cafeRepository = SeedCafeRepository();
  }

  final authService = AuthService(useFirebase: useFirebase);
  final locationService = LocationService();

  runApp(
    MultiProvider(
      providers: [
        Provider<CafeRepository>.value(value: cafeRepository),
        Provider<AuthService>.value(value: authService),
        Provider<LocationService>.value(value: locationService),
      ],
      child: const SpotNgafeApp(),
    ),
  );
}

class SpotNgafeApp extends StatelessWidget {
  const SpotNgafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final locationService = context.read<LocationService>();

    return MaterialApp(
      title: 'SpotNgafe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: SplashScreen(
        authService: authService,
        locationService: locationService,
      ),
    );
  }
}
