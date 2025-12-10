import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

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

  // Get all users stream for Admin Panel
  Stream<QuerySnapshot> getAllUsers() {
    return _firestore.collection('users').orderBy('createdAt', descending: true).snapshots();
  }

  // Update user details (e.g. role, name - though name is usually in profile)
  Future<void> updateUserDetails(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  // Delete user (Firestore only) - Note: Auth deletion requires backend/admin SDK
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }
}
