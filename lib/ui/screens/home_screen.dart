import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/geo/haversine.dart';
import '../../data/models/cafe.dart';
import '../../data/models/crowd_report.dart';
import '../../data/repositories/cafe_repository.dart';
import '../../data/services/location_service.dart';
import '../../domain/cafe_filter.dart';
import '../../domain/crowd_aggregator.dart';
import '../theme/app_theme.dart';
import '../widgets/cafe_card.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/shimmer_box.dart';
import 'cafe_detail_screen.dart';
import 'location_permission_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Cafe> _allCafes = [];
  final Map<String, double> _distanceMap = {};
  Map<String, CrowdSummary?> _crowdSummaryMap = {};
  UserLocation? _userLocation;
  bool _isLocationAvailable = false;

  CafeFilterCriteria _filterCriteria = const CafeFilterCriteria();

  int get _activeFilterCount {
    int count = 0;
    if (_filterCriteria.radiusKm != null) count++;
    if (_filterCriteria.wifiOnly) count++;
    if (_filterCriteria.outletOnly) count++;
    if (_filterCriteria.priceOption != PriceFilterOption.all) count++;
    return count;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final locationService = context.read<LocationService>();
    final cafeRepository = context.read<CafeRepository>();

    try {
      // 1. Cek lokasi pengguna di perangkat
      final location = await locationService.getCurrentLocation();
      _userLocation = location;
      _isLocationAvailable = location != null;

      // 2. Ambil daftar kafe dari repositori
      final cafes = await cafeRepository.getCafes();
      _allCafes = List.of(cafes);

      // 3. Jika lokasi tersedia, hitung jarak Haversine di perangkat
      _distanceMap.clear();
      if (_isLocationAvailable && _userLocation != null) {
        for (final cafe in _allCafes) {
          final double dist = calculateHaversineDistance(
            lat1: _userLocation!.latitude,
            lon1: _userLocation!.longitude,
            lat2: cafe.latitude,
            lon2: cafe.longitude,
          );
          _distanceMap[cafe.id] = dist;
        }

        // Urutkan kafe dari yang terdekat
        _allCafes.sort((a, b) {
          final distA = _distanceMap[a.id] ?? double.infinity;
          final distB = _distanceMap[b.id] ?? double.infinity;
          return distA.compareTo(distB);
        });
      }

      // 4. Ambil ringkasan kepadatan untuk setiap kafe dengan Future.wait
      final List<List<CrowdReport>> allReports = await Future.wait(
        _allCafes.map((cafe) => cafeRepository.getReportsForCafe(cafe.id)),
      );
      final Map<String, CrowdSummary?> summaries = {};
      for (int i = 0; i < _allCafes.length; i++) {
        summaries[_allCafes[i].id] =
            CrowdAggregator.aggregateReports(allReports[i]);
      }
      _crowdSummaryMap = summaries;

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data kafe. Periksa koneksi internetmu.';
      });
    }
  }

  Future<void> _openFilter() async {
    final updated = await FilterSheet.show(
      context: context,
      currentCriteria: _filterCriteria,
      isLocationAvailable: _isLocationAvailable,
      allCafes: _allCafes,
      distanceMap: _distanceMap,
    );

    if (updated != null) {
      setState(() {
        _filterCriteria = updated;
      });
    }
  }

  void _resetFilter() {
    setState(() {
      _filterCriteria = const CafeFilterCriteria();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredCafes = CafeFilter.apply(
      cafes: _allCafes,
      criteria: _filterCriteria,
      isLocationAvailable: _isLocationAvailable,
      distanceMap: _distanceMap,
    );

    final int filterBadgeCount = _activeFilterCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SpotNgafe'),
        actions: [
          Semantics(
            button: true,
            label: filterBadgeCount > 0
                ? 'Buka filter, ada $filterBadgeCount filter aktif'
                : 'Buka filter kafe',
            child: IconButton(
              tooltip: 'Filter',
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.tune),
                  if (filterBadgeCount > 0)
                    Positioned(
                      right: -3,
                      top: -3,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          filterBadgeCount.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: _openFilter,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadData,
          child: _buildBody(filteredCafes),
        ),
      ),
    );
  }

  Widget _buildBody(List<Cafe> filteredCafes) {
    if (_isLoading) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: const [
          ShimmerCafeCard(),
          SizedBox(height: AppSpacing.s12),
          ShimmerCafeCard(),
          SizedBox(height: AppSpacing.s12),
          ShimmerCafeCard(),
          SizedBox(height: AppSpacing.s12),
          ShimmerCafeCard(),
        ],
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.primaryTint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              const Text(
                'Koneksi Bermasalah',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s24),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Coba Lagi'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_allCafes.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada kafe untuk ditampilkan',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final bool disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.s16),
      children: [
        // Banner bila lokasi tidak tersedia
        if (!_isLocationAvailable) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.uniformRadius),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTint,
                    borderRadius: BorderRadius.circular(AppTheme.uniformRadius),
                  ),
                  child: const Icon(
                    Icons.location_off_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                const Expanded(
                  child: Text(
                    'Aktifkan lokasi untuk melihat kafe terdekat',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => const LocationPermissionScreen(),
                          ),
                        )
                        .then((_) => _loadData());
                  },
                  child: const Text(
                    'Aktifkan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
        ],

        // Header besar "Kafe terdekat" dengan keterangan kecil
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isLocationAvailable ? 'Kafe terdekat' : 'Daftar Kafe di Malang',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              _isLocationAvailable
                  ? 'Rekomendasi kafe ternyaman di sekitarmu untuk nugas'
                  : 'Aktifkan lokasi untuk mengurutkan berdasarkan jarak',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s12),

        // Baris Chip Filter Cepat (Wi-Fi, Colokan)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('Ada Wi-Fi'),
                avatar: Icon(
                  Icons.wifi,
                  size: 16,
                  color: _filterCriteria.wifiOnly
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
                selected: _filterCriteria.wifiOnly,
                onSelected: (val) {
                  setState(() {
                    _filterCriteria = _filterCriteria.copyWith(wifiOnly: val);
                  });
                },
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _filterCriteria.wifiOnly
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.uniformRadius),
                  side: BorderSide(
                    color: _filterCriteria.wifiOnly
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              FilterChip(
                label: const Text('Ada Colokan'),
                avatar: Icon(
                  Icons.power,
                  size: 16,
                  color: _filterCriteria.outletOnly
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
                selected: _filterCriteria.outletOnly,
                onSelected: (val) {
                  setState(() {
                    _filterCriteria = _filterCriteria.copyWith(outletOnly: val);
                  });
                },
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _filterCriteria.outletOnly
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.uniformRadius),
                  side: BorderSide(
                    color: _filterCriteria.outletOnly
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Chip Ringkasan Filter Aktif (bisa dihapus satu per satu)
        if (!_filterCriteria.isDefault) ...[
          const SizedBox(height: AppSpacing.s8),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s4,
            children: [
              if (_filterCriteria.radiusKm != null)
                InputChip(
                  label: Text('Radius ${_filterCriteria.radiusKm!.toInt()} km'),
                  onDeleted: () {
                    setState(() {
                      _filterCriteria =
                          _filterCriteria.copyWith(clearRadius: true);
                    });
                  },
                  deleteIconColor: AppColors.primary,
                  backgroundColor: AppColors.primaryTint,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.uniformRadius),
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              if (_filterCriteria.priceOption != PriceFilterOption.all)
                InputChip(
                  label: Text(_filterCriteria.priceOption.label),
                  onDeleted: () {
                    setState(() {
                      _filterCriteria = _filterCriteria.copyWith(
                        priceOption: PriceFilterOption.all,
                      );
                    });
                  },
                  deleteIconColor: AppColors.primary,
                  backgroundColor: AppColors.primaryTint,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.uniformRadius),
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ),
            ],
          ),
        ],

        const SizedBox(height: AppSpacing.s12),

        // Hasil filter kosong
        if (filteredCafes.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48.0),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryTint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_off_outlined,
                    size: 36,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                const Text(
                  'Tidak ada kafe yang sesuai filter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                const Text(
                  'Coba longgarkan pilihan radius atau harga',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                SizedBox(
                  width: 150,
                  child: OutlinedButton(
                    onPressed: _resetFilter,
                    child: const Text('Reset filter'),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Daftar kartu kafe muncul bertahap (fade + slide, jeda 40 ms per kartu, batasi 8 kartu pertama)
          ...List.generate(filteredCafes.length, (index) {
            final cafe = filteredCafes[index];
            final double? distance =
                _isLocationAvailable ? _distanceMap[cafe.id] : null;
            final crowdSummary = _crowdSummaryMap[cafe.id];

            final cardWidget = CafeCard(
              cafe: cafe,
              distanceKm: distance,
              crowdSummary: crowdSummary,
              onTap: () async {
                final bool? hasNewReport =
                    await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => CafeDetailScreen(
                      cafe: cafe,
                      distanceKm: distance,
                    ),
                  ),
                );
                // Refresh status kepadatan hanya bila ada laporan baru
                if (hasNewReport == true) {
                  _loadData();
                }
              },
            );

            // Terapkan animasi bertahap untuk 8 kartu pertama
            if (!disableAnimations && index < 8) {
              final int delayMs = index * 40;
              return TweenAnimationBuilder<double>(
                key: ValueKey('stagger_${cafe.id}'),
                duration: Duration(milliseconds: 300 + delayMs),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1.0 - value) * 16),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                  child: cardWidget,
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s12),
              child: cardWidget,
            );
          }),
        ],
      ],
    );
  }
}
