import '../data/models/crowd_report.dart';

class CrowdSummary {
  final String status;
  final DateTime latestReportTime;
  final int totalReports;

  const CrowdSummary({
    required this.status,
    required this.latestReportTime,
    required this.totalReports,
  });
}

class CooldownResult {
  final bool canReport;
  final Duration remainingDuration;

  const CooldownResult({
    required this.canReport,
    required this.remainingDuration,
  });

  int get remainingMinutes {
    final int mins = (remainingDuration.inSeconds / 60).ceil();
    return mins > 0 ? mins : 1;
  }
}

class CrowdAggregator {
  static const Duration validWindow = Duration(hours: 2);
  static const Duration cooldownDuration = Duration(minutes: 30);

  /// Menghitung agregasi status kepadatan dari daftar laporan suatu kafe.
  /// Hanya mempertimbangkan laporan dalam 2 jam terakhir dari `now`.
  /// Mengembalikan null jika tidak ada laporan valid dalam 2 jam terakhir.
  /// Status dengan jumlah laporan terbanyak menang.
  /// Bila seri, status dengan laporan terbaru yang menang.
  static CrowdSummary? aggregateReports(
    List<CrowdReport> reports, {
    DateTime? now,
  }) {
    final DateTime currentTime = now ?? DateTime.now();
    final DateTime cutoffTime = currentTime.subtract(validWindow);

    final List<CrowdReport> validReports = reports.where((report) {
      return !report.createdAt.isBefore(cutoffTime);
    }).toList();

    if (validReports.isEmpty) {
      return null;
    }

    // Urutkan laporan dari yang terlama ke yang terbaru
    validReports.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final Map<String, int> counts = {
      'Sepi': 0,
      'Sedang': 0,
      'Penuh': 0,
    };

    final Map<String, DateTime> latestPerStatus = {};

    for (final report in validReports) {
      if (counts.containsKey(report.status)) {
        counts[report.status] = counts[report.status]! + 1;
        latestPerStatus[report.status] = report.createdAt;
      }
    }

    int maxCount = 0;
    for (final count in counts.values) {
      if (count > maxCount) {
        maxCount = count;
      }
    }

    if (maxCount == 0) {
      return null;
    }

    // Ambil status yang memiliki jumlah terbanyak
    final List<String> topStatuses = counts.entries
        .where((entry) => entry.value == maxCount)
        .map((entry) => entry.key)
        .toList();

    String winningStatus;
    if (topStatuses.length == 1) {
      winningStatus = topStatuses.first;
    } else {
      // Terjadi seri: pilih status yang memiliki laporan paling baru
      topStatuses.sort((a, b) {
        final DateTime timeA = latestPerStatus[a] ?? DateTime(1970);
        final DateTime timeB = latestPerStatus[b] ?? DateTime(1970);
        return timeB.compareTo(timeA); // descending: terbaru di depan
      });
      winningStatus = topStatuses.first;
    }

    // Waktu laporan terbaru secara keseluruhan dalam jendela 2 jam
    final DateTime overallLatest = validReports.last.createdAt;

    return CrowdSummary(
      status: winningStatus,
      latestReportTime: overallLatest,
      totalReports: validReports.length,
    );
  }

  /// Memeriksa apakah pengguna masih dalam masa cooldown 30 menit
  /// untuk kafe tertentu.
  static CooldownResult checkCooldown({
    required List<CrowdReport> userReportsForCafe,
    DateTime? now,
  }) {
    if (userReportsForCafe.isEmpty) {
      return const CooldownResult(
        canReport: true,
        remainingDuration: Duration.zero,
      );
    }

    final DateTime currentTime = now ?? DateTime.now();

    // Cari laporan terakhir dari pengguna untuk kafe ini
    DateTime latestReportTime = userReportsForCafe.first.createdAt;
    for (final report in userReportsForCafe) {
      if (report.createdAt.isAfter(latestReportTime)) {
        latestReportTime = report.createdAt;
      }
    }

    final Duration elapsed = currentTime.difference(latestReportTime);
    if (elapsed < cooldownDuration) {
      return CooldownResult(
        canReport: false,
        remainingDuration: cooldownDuration - elapsed,
      );
    }

    return const CooldownResult(
      canReport: true,
      remainingDuration: Duration.zero,
    );
  }
}
