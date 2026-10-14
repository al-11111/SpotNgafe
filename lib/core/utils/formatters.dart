/// Format jarak dalam kilometer atau meter.
String formatDistance(double? distanceKm) {
  if (distanceKm == null) {
    return 'Jarak tidak tersedia';
  }
  if (distanceKm < 1.0) {
    final int meters = (distanceKm * 1000).round();
    return '$meters m';
  }
  return '${distanceKm.toStringAsFixed(1)} km';
}

/// Format kisaran harga dalam ribuan rupiah, misal Rp15 rb - Rp35 rb.
String formatPriceRange(int priceMin, int priceMax) {
  final int minThousand = priceMin ~/ 1000;
  final int maxThousand = priceMax ~/ 1000;
  if (minThousand == maxThousand) {
    return 'Rp$minThousand rb';
  }
  return 'Rp$minThousand - Rp$maxThousand rb';
}

/// Format selisih waktu menjadi representasi teks berbahasa Indonesia santai.
String formatTimeAgo(DateTime? dateTime, {DateTime? now}) {
  if (dateTime == null) {
    return 'Belum ada waktu';
  }
  final DateTime current = now ?? DateTime.now();
  final Duration diff = current.difference(dateTime);

  if (diff.isNegative) {
    return 'baru saja';
  }

  if (diff.inSeconds < 60) {
    return 'baru saja';
  } else if (diff.inMinutes < 60) {
    return '${diff.inMinutes} menit lalu';
  } else if (diff.inHours < 24) {
    return '${diff.inHours} jam lalu';
  } else {
    return '${diff.inDays} hari lalu';
  }
}
