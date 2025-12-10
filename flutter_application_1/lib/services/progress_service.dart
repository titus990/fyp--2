import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save progress for a user
  Future<void> saveProgress(String userId, String activityName, Map<String, dynamic> stats) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      // Use a subcollection 'history' for scalable progress tracking
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('history')
          .doc('${activityName}_$timestamp')
          .set({
        'activityName': activityName,
        'timestamp': FieldValue.serverTimestamp(),
        'stats': stats,
      });
      print('Progress saved for $activityName');
    } catch (e) {
      print('Error saving progress: $e');
      rethrow;
    }
  }

  // Get progress for a user (ordered by latest)
  Stream<QuerySnapshot> getUserProgress(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
