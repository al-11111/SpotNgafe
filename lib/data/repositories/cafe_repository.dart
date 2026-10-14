import '../models/cafe.dart';
import '../models/crowd_report.dart';

abstract class CafeRepository {
  /// Mengambil semua kafe yang terdaftar
  Future<List<Cafe>> getCafes();

  /// Mengambil semua laporan untuk kafe tertentu
  Future<List<CrowdReport>> getReportsForCafe(String cafeId);

  /// Mengirim laporan baru (dokumen baru dengan ID otomatis)
  Future<void> submitReport(CrowdReport report);

  /// Mengambil riwayat laporan pengguna tertentu untuk kafe tertentu
  Future<List<CrowdReport>> getUserReportsForCafe(String cafeId, String userId);
}
