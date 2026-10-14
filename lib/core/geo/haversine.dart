import 'dart:math' as math;

/// Menghitung jarak lingkaran besar antara dua koordinat geografis
/// menggunakan rumus Haversine.
/// Radius bumi R = 6371.0 kilometer.
/// Nilai a diklem ke rentang 0.0 hingga 1.0 untuk mencegah ketidaktelitian floating point.
double calculateHaversineDistance({
  required double lat1,
  required double lon1,
  required double lat2,
  required double lon2,
}) {
  const double earthRadiusKm = 6371.0;

  final double dLat = _degToRad(lat2 - lat1);
  final double dLon = _degToRad(lon2 - lon1);

  final double lat1Rad = _degToRad(lat1);
  final double lat2Rad = _degToRad(lat2);

  final double sinDLat2 = math.sin(dLat / 2);
  final double sinDLon2 = math.sin(dLon / 2);

  final double a = sinDLat2 * sinDLat2 +
      math.cos(lat1Rad) * math.cos(lat2Rad) * sinDLon2 * sinDLon2;

  final double clampedA = a.clamp(0.0, 1.0);
  final double c = 2 * math.asin(math.sqrt(clampedA));

  return earthRadiusKm * c;
}

double _degToRad(double deg) {
  return deg * (math.pi / 180.0);
}
