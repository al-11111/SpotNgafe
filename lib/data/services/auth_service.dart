import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final bool useFirebase;
  String? _cachedUserId;

  AuthService({required this.useFirebase});

  String? get currentUserId => _cachedUserId;

  Future<String> signInAnonymously() async {
    if (!useFirebase) {
      // UID lokal sementara saat berjalan dalam mode Seed / demo
      _cachedUserId ??= 'anon_local_${DateTime.now().millisecondsSinceEpoch}';
      return _cachedUserId!;
    }

    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      final String? uid = userCredential.user?.uid;
      if (uid == null || uid.isEmpty) {
        throw Exception('Gagal mendapatkan identitas anonim dari server');
      }
      _cachedUserId = uid;
      return uid;
    } catch (e) {
      throw Exception('Gagal masuk secara anonim: $e');
    }
  }
}
