import '../data/models/cafe.dart';

enum PriceFilterOption {
  all('Semua'),
  under20k('Di bawah Rp20 rb'),
  between20kAnd40k('Rp20-40 rb'),
  above40k('Di atas Rp40 rb');

  final String label;
  const PriceFilterOption(this.label);
}

class CafeFilterCriteria {
  final double? radiusKm; // 1, 3, 5, 10 km atau null jika tidak dibatasi
  final bool wifiOnly;
  final bool outletOnly;
  final PriceFilterOption priceOption;

  const CafeFilterCriteria({
    this.radiusKm,
    this.wifiOnly = false,
    this.outletOnly = false,
    this.priceOption = PriceFilterOption.all,
  });

  CafeFilterCriteria copyWith({
    double? radiusKm,
    bool clearRadius = false,
    bool? wifiOnly,
    bool? outletOnly,
    PriceFilterOption? priceOption,
  }) {
    return CafeFilterCriteria(
      radiusKm: clearRadius ? null : (radiusKm ?? this.radiusKm),
      wifiOnly: wifiOnly ?? this.wifiOnly,
      outletOnly: outletOnly ?? this.outletOnly,
      priceOption: priceOption ?? this.priceOption,
    );
  }

  bool get isDefault =>
      radiusKm == null &&
      !wifiOnly &&
      !outletOnly &&
      priceOption == PriceFilterOption.all;
}

class CafeFilter {
  /// Menerapkan kriteria filter pada kafe.
  /// Parameter `distanceMap` memetakan ID kafe ke jarak dalam km (jika lokasi tersedia).
  static List<Cafe> apply({
    required List<Cafe> cafes,
    required CafeFilterCriteria criteria,
    required bool isLocationAvailable,
    Map<String, double>? distanceMap,
  }) {
    return cafes.where((cafe) {
      // 1. Filter Radius (hanya berlaku bila lokasi tersedia dan radius diatur)
      if (isLocationAvailable && criteria.radiusKm != null) {
        final double? dist = distanceMap?[cafe.id];
        if (dist == null || dist > criteria.radiusKm!) {
          return false;
        }
      }

      // 2. Filter Wi-Fi
      if (criteria.wifiOnly && !cafe.hasWifi) {
        return false;
      }

      // 3. Filter Colokan
      if (criteria.outletOnly && !cafe.hasOutlet) {
        return false;
      }

      // 4. Filter Harga (dibandingkan dengan priceMin kafe)
      switch (criteria.priceOption) {
        case PriceFilterOption.under20k:
          if (cafe.priceMin >= 20000) return false;
          break;
        case PriceFilterOption.between20kAnd40k:
          if (cafe.priceMin < 20000 || cafe.priceMin > 40000) return false;
          break;
        case PriceFilterOption.above40k:
          if (cafe.priceMin <= 40000) return false;
          break;
        case PriceFilterOption.all:
          break;
      }

      return true;
    }).toList();
  }
}
