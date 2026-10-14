class CrowdReport {
  final String id;
  final String cafeId;
  final String userId;
  final String status;
  final DateTime createdAt;

  const CrowdReport({
    required this.id,
    required this.cafeId,
    required this.userId,
    required this.status,
    required this.createdAt,
  });

  factory CrowdReport.fromMap(Map<String, dynamic> data, String docId) {
    DateTime parsedDate;
    final dynamic rawDate = data['createdAt'];
    if (rawDate == null) {
      parsedDate = DateTime.now();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(rawDate);
    } else {
      // Menangani Timestamp Firestore secara fleksibel tanpa keterikatan keras pada tipe SDK
      try {
        parsedDate = (rawDate as dynamic).toDate() as DateTime;
      } catch (_) {
        parsedDate = DateTime.now();
      }
    }

    return CrowdReport(
      id: docId,
      cafeId: data['cafeId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      status: data['status'] as String? ?? 'Sepi',
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toMap({bool forFirestore = false}) {
    return {
      'cafeId': cafeId,
      'userId': userId,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
