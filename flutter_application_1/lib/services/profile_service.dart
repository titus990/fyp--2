import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<UserProfile?> get currentUserProfile {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(user.uid).set(
            updates,
            SetOptions(merge: true),
          );
    }
  }
  
 
  Future<void> initializeProfileIfMissing() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();
    
    if (doc.exists) {
       final data = doc.data()!;
       if (!data.containsKey('stats')) {
         await docRef.set({
           'stats': {
             'totalWorkouts': 0,
             'totalMinutes': 0,
             'streak': 0,
           },
           'level': 'Beginner',
           'xp': 0,
         }, SetOptions(merge: true));
       }
    }
  }
}
