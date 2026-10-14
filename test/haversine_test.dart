import 'package:flutter_test/flutter_test.dart';
import 'package:spot_ngafe/core/geo/haversine.dart';

void main() {
  group('Haversine Distance Algorithm', () {
    test('Jarak nol ketika kedua titik koordinat sama', () {
      const double lat = -7.9525;
      const double lon = 112.6140;

      final double distance = calculateHaversineDistance(
        lat1: lat,
        lon1: lon,
        lat2: lat,
        lon2: lon,
      );

      expect(distance, closeTo(0.0, 0.0001));
    });

    test('Simetri: jarak A ke B sama dengan B ke A', () {
      const double latA = -7.9825;
      const double lonA = 112.6308;
      const double latB = -7.9525;
      const double lonB = 112.6140;

      final double distAB = calculateHaversineDistance(
        lat1: latA,
        lon1: lonA,
        lat2: latB,
        lon2: lonB,
      );

      final double distBA = calculateHaversineDistance(
        lat1: latB,
        lon1: lonB,
        lat2: latA,
        lon2: lonA,
      );

      expect(distAB, equals(distBA));
    });

    test('Jarak dua titik Malang yang diketahui berada dalam rentang akurat',
        () {
      // Alun-alun Malang (-7.9825, 112.6308) ke Kampus UB Malang (-7.9525, 112.6140)
      // Jarak geografis garis lurus adalah sekitar 3.8 - 3.9 km
      const double latAlunAlun = -7.9825;
      const double lonAlunAlun = 112.6308;
      const double latUB = -7.9525;
      const double lonUB = 112.6140;

      final double distance = calculateHaversineDistance(
        lat1: latAlunAlun,
        lon1: lonAlunAlun,
        lat2: latUB,
        lon2: lonUB,
      );

      expect(distance, greaterThan(3.5));
      expect(distance, lessThan(4.2));
    });

    test('Clamp nilai a mencegah galat floating point pada titik ekstrem', () {
      // Titik kutub utara ke kutub selatan
      final double distance = calculateHaversineDistance(
        lat1: 90.0,
        lon1: 0.0,
        lat2: -90.0,
        lon2: 0.0,
      );

      expect(distance.isNaN, isFalse);
      expect(distance, closeTo(20015.0, 50.0));
    });
  });
}
