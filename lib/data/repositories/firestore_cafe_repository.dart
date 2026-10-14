import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cafe.dart';
import '../models/crowd_report.dart';
import 'cafe_repository.dart';

class FirestoreCafeRepository implements CafeRepository {
  final FirebaseFirestore _firestore;

  FirestoreCafeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Cafe>> getCafes() async {
    final QuerySnapshot snapshot = await _firestore.collection('cafes').get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Cafe.fromMap(data, doc.id);
    }).toList();
  }

  @override
  Future<List<CrowdReport>> getReportsForCafe(String cafeId) async {
    final QuerySnapshot snapshot = await _firestore
        .collection('reports')
        .where('cafeId', isEqualTo: cafeId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return CrowdReport.fromMap(data, doc.id);
    }).toList();
  }

  @override
  Future<void> submitReport(CrowdReport report) async {
    await _firestore.collection('reports').add({
      'cafeId': report.cafeId,
      'userId': report.userId,
      'status': report.status,
      'createdAt': FieldValue.serverTimestamp(),
    }).timeout(const Duration(seconds: 10));
  }

  @override
  Future<List<CrowdReport>> getUserReportsForCafe(
    String cafeId,
    String userId,
  ) async {
    final QuerySnapshot snapshot = await _firestore
        .collection('reports')
        .where('cafeId', isEqualTo: cafeId)
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return CrowdReport.fromMap(data, doc.id);
    }).toList();
  }
}
