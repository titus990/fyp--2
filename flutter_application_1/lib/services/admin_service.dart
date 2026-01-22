import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
  
    if (user.email == 'admin@gmail.com') {
       final userRef = _firestore.collection('users').doc(user.uid);
       final userDoc = await userRef.get();
       
       if (!userDoc.exists || userDoc.data()?['role'] != 'admin') {
         await userRef.set({
           'email': user.email,
           'role': 'admin',
           'updatedAt': FieldValue.serverTimestamp(),
         }, SetOptions(merge: true));
       }
       return true;
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc.exists && userDoc.data()?['role'] == 'admin';
  }

  Future<String> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return 'client';

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc.data()?['role'] ?? 'client';
  }

  Future<void> setUserRole(String userId, String role) async {
    await _firestore.collection('users').doc(userId).set({
      'role': role,
      'email': _auth.currentUser?.email,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> makeCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user != null) {
      await setUserRole(user.uid, 'admin');
    }
  }

  Future<void> updateLastActive() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'lastActive': FieldValue.serverTimestamp(),
        'email': user.email,
      }, SetOptions(merge: true));
    }
  }

  Stream<QuerySnapshot> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getActiveUsers() {
    final yesterday = DateTime.now().subtract(const Duration(hours: 24));
    return _firestore
        .collection('users')
        .where('lastActive', isGreaterThan: yesterday)
        .snapshots();
  }

  Future<void> updateUserDetails(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  Future<void> deleteUser(String userId) async {
    final history = await _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .get();
    for (var doc in history.docs) {
      await doc.reference.delete();
    }

    await _firestore.collection('users').doc(userId).delete();
  }
}
