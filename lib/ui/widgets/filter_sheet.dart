import 'package:flutter/material.dart';
import '../../data/models/cafe.dart';
import '../../domain/cafe_filter.dart';
import '../theme/app_theme.dart';

class FilterSheet extends StatefulWidget {
  final CafeFilterCriteria initialCriteria;
  final bool isLocationAvailable;
  final List<Cafe>? allCafes;
  final Map<String, double>? distanceMap;

  const FilterSheet({
    super.key,
    required this.initialCriteria,
    required this.isLocationAvailable,
    this.allCafes,
    this.distanceMap,
  });

  static Future<CafeFilterCriteria?> show({
    required BuildContext context,
    required CafeFilterCriteria currentCriteria,
    required bool isLocationAvailable,
    List<Cafe>? allCafes,
    Map<String, double>? distanceMap,
  }) {
    return showModalBottomSheet<CafeFilterCriteria>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.uniformRadius),
        ),
      ),
      builder: (context) {
        return FilterSheet(
          initialCriteria: currentCriteria,
          isLocationAvailable: isLocationAvailable,
          allCafes: allCafes,
          distanceMap: distanceMap,
        );
      },
    );
  }

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  double? _selectedRadius;
  late bool _wifiOnly;
  late bool _outletOnly;
  late PriceFilterOption _priceOption;

  final List<double> _radiusOptions = [1.0, 3.0, 5.0, 10.0];

  @override
  void initState() {
    super.initState();
    _selectedRadius = widget.initialCriteria.radiusKm;
    _wifiOnly = widget.initialCriteria.wifiOnly;
    _outletOnly = widget.initialCriteria.outletOnly;
    _priceOption = widget.initialCriteria.priceOption;
  }

  int get _matchingCount {
    if (widget.allCafes == null) return 0;
    final current = CafeFilterCriteria(
      radiusKm: widget.isLocationAvailable ? _selectedRadius : null,
      wifiOnly: _wifiOnly,
      outletOnly: _outletOnly,
      priceOption: _priceOption,
    );
    return CafeFilter.apply(
      cafes: widget.allCafes!,
      criteria: current,
      isLocationAvailable: widget.isLocationAvailable,
      distanceMap: widget.distanceMap,
    ).length;
  }

  void _reset() {
    setState(() {
      _selectedRadius = null;
      _wifiOnly = false;
      _outletOnly = false;
      _priceOption = PriceFilterOption.all;
    });
  }

  void _apply() {
    final updatedCriteria = CafeFilterCriteria(
      radiusKm: widget.isLocationAvailable ? _selectedRadius : null,
      wifiOnly: _wifiOnly,
      outletOnly: _outletOnly,
      priceOption: _priceOption,
    );
    Navigator.of(context).pop(updatedCriteria);
  }

  @override
  Widget build(BuildContext context) {
    final int count = _matchingCount;
    final String applyLabel =
        widget.allCafes != null ? 'Tampilkan $count kafe' : 'Terapkan';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s16,
          AppSpacing.s12,
          AppSpacing.s16,
          AppSpacing.s16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Garis handle sheet
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

              // Judul Sheet
              const Text(
                'Filter Kafe',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),

              // 1. Kartu Radius
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.near_me_outlined,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: AppSpacing.s8),
                          Text(
                            'Radius Jarak',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      if (!widget.isLocationAvailable) ...[
                        const SizedBox(height: AppSpacing.s4),
                        const Text(
                          'Radius dinonaktifkan karena lokasi tidak aktif',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.s12),
                      Wrap(
                        spacing: AppSpacing.s8,
                        runSpacing: AppSpacing.s8,
                        children: [
                          _buildAnimatedFilterChip(
                            label: 'Semua',
                            selected: _selectedRadius == null,
                            enabled: widget.isLocationAvailable,
                            onSelected: (val) {
                              if (val) setState(() => _selectedRadius = null);
                            },
                          ),
                          ..._radiusOptions.map((radius) {
                            return _buildAnimatedFilterChip(
                              label: '${radius.toInt()} km',
                              selected: _selectedRadius == radius,
                              enabled: widget.isLocationAvailable,
                              onSelected: (val) {
                                setState(() {
                                  _selectedRadius = val ? radius : null;
                                });
                              },
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s12),

              // 2. Kartu Fasilitas: Switch Wi-Fi & Colokan
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.tune,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: AppSpacing.s8),
                          Text(
                            'Fasilitas',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Hanya yang ada Wi-Fi',
                          style: TextStyle(fontSize: 14),
                        ),
                        value: _wifiOnly,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() => _wifiOnly = val);
                        },
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Hanya yang ada Colokan',
                          style: TextStyle(fontSize: 14),
                        ),
                        value: _outletOnly,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() => _outletOnly = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s12),

              // 3. Kartu Pilihan Harga
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: AppSpacing.s8),
                          Text(
                            'Kisaran Harga Termurah',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      Wrap(
                        spacing: AppSpacing.s8,
                        runSpacing: AppSpacing.s8,
                        children: PriceFilterOption.values.map((option) {
                          final bool isSelected = _priceOption == option;
                          return _buildAnimatedFilterChip(
                            label: option.label,
                            selected: isSelected,
                            enabled: true,
                            onSelected: (val) {
                              if (val) {
                                setState(() => _priceOption = option);
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s24),

              // Tombol Reset dan Terapkan
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: _reset,
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _apply,
                      child: Text(applyLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedFilterChip({
    required String label,
    required bool selected,
    required bool enabled,
    required ValueChanged<bool> onSelected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: enabled ? onSelected : null,
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.background,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected && enabled ? Colors.white : AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.uniformRadius),
          side: BorderSide(
            color: selected && enabled ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
      ),
    );
  }
}
