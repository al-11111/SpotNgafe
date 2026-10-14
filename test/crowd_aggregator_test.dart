import 'package:flutter_test/flutter_test.dart';
import 'package:spot_ngafe/data/models/crowd_report.dart';
import 'package:spot_ngafe/domain/crowd_aggregator.dart';

void main() {
  group('Crowd Aggregator & Cooldown Logic', () {
    final DateTime baseTime = DateTime(2026, 10, 13, 14, 0, 0);

    test('Kosong menghasilkan null', () {
      final summary = CrowdAggregator.aggregateReports([], now: baseTime);
      expect(summary, isNull);
    });

    test('Laporan lewat 2 jam diabaikan', () {
      final oldReport = CrowdReport(
        id: '1',
        cafeId: 'cafe_1',
        userId: 'u1',
        status: 'Penuh',
        createdAt: baseTime.subtract(const Duration(hours: 2, minutes: 1)),
      );

      final summary = CrowdAggregator.aggregateReports(
        [oldReport],
        now: baseTime,
      );

      expect(summary, isNull);
    });

    test('Laporan dengan timestamp masa depan tetap dihitung', () {
      final futureReport = CrowdReport(
        id: '1',
        cafeId: 'cafe_1',
        userId: 'u1',
        status: 'Penuh',
        createdAt: baseTime.add(const Duration(minutes: 5)),
      );

      final summary = CrowdAggregator.aggregateReports(
        [futureReport],
        now: baseTime,
      );

      expect(summary, isNotNull);
      expect(summary!.status, equals('Penuh'));
    });

    test('Suara terbanyak menang dalam jendela 2 jam', () {
      final reports = [
        CrowdReport(
          id: '1',
          cafeId: 'cafe_1',
          userId: 'u1',
          status: 'Sepi',
          createdAt: baseTime.subtract(const Duration(minutes: 50)),
        ),
        CrowdReport(
          id: '2',
          cafeId: 'cafe_1',
          userId: 'u2',
          status: 'Sepi',
          createdAt: baseTime.subtract(const Duration(minutes: 40)),
        ),
        CrowdReport(
          id: '3',
          cafeId: 'cafe_1',
          userId: 'u3',
          status: 'Sedang',
          createdAt: baseTime.subtract(const Duration(minutes: 10)),
        ),
      ];

      final summary = CrowdAggregator.aggregateReports(reports, now: baseTime);
      expect(summary, isNotNull);
      expect(summary!.status, equals('Sepi'));
      expect(summary.totalReports, equals(3));
    });

    test('Kondisi seri memilih status dari laporan paling baru', () {
      final reports = [
        CrowdReport(
          id: '1',
          cafeId: 'cafe_1',
          userId: 'u1',
          status: 'Sepi',
          createdAt: baseTime.subtract(const Duration(minutes: 30)),
        ),
        CrowdReport(
          id: '2',
          cafeId: 'cafe_1',
          userId: 'u2',
          status: 'Sedang',
          createdAt: baseTime.subtract(const Duration(minutes: 10)),
        ),
      ];

      final summary = CrowdAggregator.aggregateReports(reports, now: baseTime);
      expect(summary, isNotNull);
      // 'Sedang' lebih baru dibanding 'Sepi', sehingga 'Sedang' yang menang
      expect(summary!.status, equals('Sedang'));
    });

    test(
        'Anti-spam cooldown 30 menit menolak laporan berulang sebelum 30 menit',
        () {
      final userReports = [
        CrowdReport(
          id: '1',
          cafeId: 'cafe_1',
          userId: 'u1',
          status: 'Sedang',
          createdAt: baseTime.subtract(const Duration(minutes: 12)),
        ),
      ];

      final cooldown = CrowdAggregator.checkCooldown(
        userReportsForCafe: userReports,
        now: baseTime,
      );

      expect(cooldown.canReport, isFalse);
      expect(cooldown.remainingMinutes, equals(18));
    });

    test(
        'Anti-spam cooldown 30 menit mengizinkan laporan setelah lewat 30 menit',
        () {
      final userReports = [
        CrowdReport(
          id: '1',
          cafeId: 'cafe_1',
          userId: 'u1',
          status: 'Sedang',
          createdAt: baseTime.subtract(const Duration(minutes: 31)),
        ),
      ];

      final cooldown = CrowdAggregator.checkCooldown(
        userReportsForCafe: userReports,
        now: baseTime,
      );

      expect(cooldown.canReport, isTrue);
      expect(cooldown.remainingDuration, equals(Duration.zero));
    });
  });
}
