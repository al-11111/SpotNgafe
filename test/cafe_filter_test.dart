import 'package:flutter_test/flutter_test.dart';
import 'package:spot_ngafe/data/models/cafe.dart';
import 'package:spot_ngafe/domain/cafe_filter.dart';

void main() {
  group('Cafe Filter Rules', () {
    final sampleCafes = [
      const Cafe(
        id: 'c1',
        name: 'Kafe Hemat Suhat',
        address: 'Jl. Suhat No. 1',
        latitude: -7.95,
        longitude: 112.61,
        openHours: '08:00 - 22:00',
        priceMin: 15000,
        priceMax: 25000,
        hasWifi: true,
        hasOutlet: true,
      ),
      const Cafe(
        id: 'c2',
        name: 'Kafe Menengah Dinoyo',
        address: 'Jl. MT Haryono No. 2',
        latitude: -7.96,
        longitude: 112.62,
        openHours: '09:00 - 23:00',
        priceMin: 25000,
        priceMax: 45000,
        hasWifi: false,
        hasOutlet: true,
      ),
      const Cafe(
        id: 'c3',
        name: 'Kafe Mewah Ijen',
        address: 'Jl. Ijen No. 3',
        latitude: -7.97,
        longitude: 112.63,
        openHours: '10:00 - 24:00',
        priceMin: 50000,
        priceMax: 80000,
        hasWifi: true,
        hasOutlet: false,
      ),
    ];

    test('Filter Wi-Fi hanya menampilkan kafe dengan Wi-Fi', () {
      final result = CafeFilter.apply(
        cafes: sampleCafes,
        criteria: const CafeFilterCriteria(wifiOnly: true),
        isLocationAvailable: false,
      );

      expect(result.length, equals(2));
      expect(result.every((c) => c.hasWifi), isTrue);
    });

    test('Filter Colokan hanya menampilkan kafe dengan Colokan', () {
      final result = CafeFilter.apply(
        cafes: sampleCafes,
        criteria: const CafeFilterCriteria(outletOnly: true),
        isLocationAvailable: false,
      );

      expect(result.length, equals(2));
      expect(result.every((c) => c.hasOutlet), isTrue);
    });

    test('Filter Harga di bawah Rp20 rb membandingkan dengan priceMin kafe',
        () {
      final result = CafeFilter.apply(
        cafes: sampleCafes,
        criteria: const CafeFilterCriteria(
          priceOption: PriceFilterOption.under20k,
        ),
        isLocationAvailable: false,
      );

      expect(result.length, equals(1));
      expect(result.first.id, equals('c1'));
    });

    test('Filter Harga Rp20-40 rb membandingkan dengan priceMin kafe', () {
      final result = CafeFilter.apply(
        cafes: sampleCafes,
        criteria: const CafeFilterCriteria(
          priceOption: PriceFilterOption.between20kAnd40k,
        ),
        isLocationAvailable: false,
      );

      expect(result.length, equals(1));
      expect(result.first.id, equals('c2'));
    });

    test('Filter Harga di atas Rp40 rb membandingkan dengan priceMin kafe', () {
      final result = CafeFilter.apply(
        cafes: sampleCafes,
        criteria: const CafeFilterCriteria(
          priceOption: PriceFilterOption.above40k,
        ),
        isLocationAvailable: false,
      );

      expect(result.length, equals(1));
      expect(result.first.id, equals('c3'));
    });

    test('Filter Radius memfilter berdasarkan jarak saat lokasi aktif', () {
      final Map<String, double> distanceMap = {
        'c1': 1.2,
        'c2': 2.8,
        'c3': 6.5,
      };

      final result = CafeFilter.apply(
        cafes: sampleCafes,
        criteria: const CafeFilterCriteria(radiusKm: 3.0),
        isLocationAvailable: true,
        distanceMap: distanceMap,
      );

      expect(result.length, equals(2));
      expect(result.map((c) => c.id), containsAll(['c1', 'c2']));
    });

    test('Filter Radius diabaikan jika lokasi tidak tersedia', () {
      final result = CafeFilter.apply(
        cafes: sampleCafes,
        criteria: const CafeFilterCriteria(radiusKm: 1.0),
        isLocationAvailable: false,
      );

      expect(result.length, equals(3));
    });
  });
}
