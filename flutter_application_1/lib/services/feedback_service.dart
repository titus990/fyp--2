import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/feedback_model.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Submit new feedback
  Future<void> submitFeedback({
    required String moduleType,
    required String moduleName,
    required double rating,
    required String comment,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final userName = user.email?.split('@')[0] ?? 'Anonymous';

    final feedbackData = FeedbackModel(
      id: '', // Will be set by Firestore
      userId: user.uid,
      userName: userName,
      moduleType: moduleType,
      moduleName: moduleName,
      rating: rating,
      comment: comment,
      timestamp: DateTime.now(),
      isEdited: false,
    );

    await _firestore.collection('feedback').add(feedbackData.toMap());
  }

  // Update existing feedback
  Future<void> updateFeedback({
    required String feedbackId,
    required double rating,
    required String comment,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('feedback').doc(feedbackId).update({
      'rating': rating,
      'comment': comment,
      'isEdited': true,
    });
  }

  // Delete feedback
  Future<void> deleteFeedback(String feedbackId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('feedback').doc(feedbackId).delete();
  }

  // Get all feedback for a specific module
  Stream<List<FeedbackModel>> getFeedbackForModule({
    required String moduleType,
    required String moduleName,
  }) {
    return _firestore
        .collection('feedback')
        .where('moduleType', isEqualTo: moduleType)
        .where('moduleName', isEqualTo: moduleName)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromFirestore(doc))
            .toList());
  }

  // Get feedback submitted by current user for a specific module
  Future<FeedbackModel?> getUserFeedbackForModule({
    required String moduleType,
    required String moduleName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore
        .collection('feedback')
        .where('userId', isEqualTo: user.uid)
        .where('moduleType', isEqualTo: moduleType)
        .where('moduleName', isEqualTo: moduleName)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return FeedbackModel.fromFirestore(snapshot.docs.first);
  }

  // Get average rating for a module
  Future<double> getAverageRating({
    required String moduleType,
    required String moduleName,
  }) async {
    final snapshot = await _firestore
        .collection('feedback')
        .where('moduleType', isEqualTo: moduleType)
        .where('moduleName', isEqualTo: moduleName)
        .get();

    if (snapshot.docs.isEmpty) return 0.0;

    double totalRating = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      totalRating += (data['rating'] ?? 0).toDouble();
    }

    return totalRating / snapshot.docs.length;
  }

  // Get feedback count for a module
  Future<int> getFeedbackCount({
    required String moduleType,
    required String moduleName,
  }) async {
    final snapshot = await _firestore
        .collection('feedback')
        .where('moduleType', isEqualTo: moduleType)
        .where('moduleName', isEqualTo: moduleName)
        .get();

    return snapshot.docs.length;
  }

  // Get rating distribution (count of each star rating)
  Future<Map<int, int>> getRatingDistribution({
    required String moduleType,
    required String moduleName,
  }) async {
    final snapshot = await _firestore
        .collection('feedback')
        .where('moduleType', isEqualTo: moduleType)
        .where('moduleName', isEqualTo: moduleName)
        .get();

    Map<int, int> distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final rating = (data['rating'] ?? 0).toDouble().round();
      if (rating >= 1 && rating <= 5) {
        distribution[rating] = (distribution[rating] ?? 0) + 1;
      }
    }

    return distribution;
  }
}
