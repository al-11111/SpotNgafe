import '../models/cafe.dart';
import '../models/crowd_report.dart';
import 'cafe_repository.dart';

class SeedCafeRepository implements CafeRepository {
  final List<Cafe> _cafes = [
    const Cafe(
      id: 'cafe_1',
      name: 'Retrorika Coffee Bar & Resto',
      address: 'Jl. Borobudur No. 12, Lowokwaru',
      latitude: -7.9525,
      longitude: 112.6140,
      openHours: '09:00 - 23:00',
      priceMin: 18000,
      priceMax: 35000,
      hasWifi: true,
      hasOutlet: true,
    ),
    const Cafe(
      id: 'cafe_2',
      name: 'Kopi Titik Koma Suhat',
      address: 'Jl. Soekarno Hatta No. 45, Lowokwaru',
      latitude: -7.9430,
      longitude: 112.6175,
      openHours: '08:00 - 24:00',
      priceMin: 15000,
      priceMax: 28000,
      hasWifi: true,
      hasOutlet: true,
    ),
    const Cafe(
      id: 'cafe_3',
      name: 'Dialoogi Space & Coffee',
      address: 'Jl. Soekarno Hatta D-505, Mojolangu',
      latitude: -7.9620,
      longitude: 112.6280,
      openHours: '09:00 - 22:00',
      priceMin: 22000,
      priceMax: 45000,
      hasWifi: true,
      hasOutlet: true,
    ),
    const Cafe(
      id: 'cafe_4',
      name: 'Nakoa Cafe Suhat',
      address: 'Jl. MT Haryono No. 116, Dinoyo',
      latitude: -7.9415,
      longitude: 112.6190,
      openHours: '24 Jam',
      priceMin: 12000,
      priceMax: 25000,
      hasWifi: true,
      hasOutlet: true,
    ),
    const Cafe(
      id: 'cafe_5',
      name: 'Toko Kopi Kongca',
      address: 'Jl. Trunojoyo No. 23, Klojen',
      latitude: -7.9820,
      longitude: 112.6310,
      openHours: '07:00 - 21:00',
      priceMin: 10000,
      priceMax: 18000,
      hasWifi: false,
      hasOutlet: true,
    ),
    const Cafe(
      id: 'cafe_6',
      name: 'Lafayette Coffee & Eatery',
      address: 'Jl. Semeru No. 2, Klojen',
      latitude: -7.9730,
      longitude: 112.6250,
      openHours: '08:00 - 22:00',
      priceMin: 25000,
      priceMax: 55000,
      hasWifi: true,
      hasOutlet: true,
    ),
    const Cafe(
      id: 'cafe_7',
      name: 'Gartenhaus Co-working & Coffee',
      address: 'Jl. Kenanga Indah No. 1, Jatimulyo',
      latitude: -7.9380,
      longitude: 112.6120,
      openHours: '10:00 - 23:00',
      priceMin: 20000,
      priceMax: 40000,
      hasWifi: true,
      hasOutlet: true,
    ),
    const Cafe(
      id: 'cafe_8',
      name: 'Oura Cafe & Restaurant',
      address: 'Jl. Pahlawan Trip No. A5, Klojen',
      latitude: -7.9675,
      longitude: 112.6215,
      openHours: '08:00 - 22:00',
      priceMin: 45000,
      priceMax: 85000,
      hasWifi: true,
      hasOutlet: false,
    ),
    const Cafe(
      id: 'cafe_9',
      name: 'Bukit Delight Dinoyo',
      address: 'Jl. Joyo Agung No. 1, Merjosari',
      latitude: -7.9350,
      longitude: 112.5980,
      openHours: '15:00 - 23:00',
      priceMin: 16000,
      priceMax: 32000,
      hasWifi: true,
      hasOutlet: true,
    ),
    const Cafe(
      id: 'cafe_10',
      name: 'Vosco Coffee Sigura-gura',
      address: 'Jl. Bendungan Sigura-gura No. 27',
      latitude: -7.9560,
      longitude: 112.6070,
      openHours: '09:00 - 24:00',
      priceMin: 18000,
      priceMax: 30000,
      hasWifi: true,
      hasOutlet: true,
    ),
  ];

  late final List<CrowdReport> _reports;

  SeedCafeRepository() {
    final DateTime now = DateTime.now();
    _reports = [
      CrowdReport(
        id: 'rep_1',
        cafeId: 'cafe_1',
        userId: 'user_dummy_1',
        status: 'Sedang',
        createdAt: now.subtract(const Duration(minutes: 25)),
      ),
      CrowdReport(
        id: 'rep_2',
        cafeId: 'cafe_1',
        userId: 'user_dummy_2',
        status: 'Sedang',
        createdAt: now.subtract(const Duration(minutes: 10)),
      ),
      CrowdReport(
        id: 'rep_3',
        cafeId: 'cafe_2',
        userId: 'user_dummy_3',
        status: 'Penuh',
        createdAt: now.subtract(const Duration(minutes: 40)),
      ),
      CrowdReport(
        id: 'rep_4',
        cafeId: 'cafe_3',
        userId: 'user_dummy_4',
        status: 'Sepi',
        createdAt: now.subtract(const Duration(minutes: 15)),
      ),
      CrowdReport(
        id: 'rep_5',
        cafeId: 'cafe_4',
        userId: 'user_dummy_5',
        status: 'Penuh',
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
      CrowdReport(
        id: 'rep_6',
        cafeId: 'cafe_7',
        userId: 'user_dummy_6',
        status: 'Sepi',
        createdAt: now.subtract(const Duration(minutes: 50)),
      ),
    ];
  }

  @override
  Future<List<Cafe>> getCafes() async {
    // Simulasi latensi jaringan ringan
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_cafes);
  }

  @override
  Future<List<CrowdReport>> getReportsForCafe(String cafeId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _reports.where((report) => report.cafeId == cafeId).toList();
  }

  @override
  Future<void> submitReport(CrowdReport report) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _reports.add(report);
  }

  @override
  Future<List<CrowdReport>> getUserReportsForCafe(
    String cafeId,
    String userId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _reports
        .where((report) => report.cafeId == cafeId && report.userId == userId)
        .toList();
  }
}
