import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumService {
  PremiumService._();
  static final PremiumService instance = PremiumService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cache premium status to avoid repeated Firestore calls
  bool? _cachedPremiumStatus;
  String? _cachedUserId;

  /// Check if the current user has premium access
  /// Returns true if user is premium, false otherwise
  /// Caches the result to minimize Firestore reads
  Future<bool> isPremiumUser() async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) {
        debugPrint('🔒 No user logged in, premium status: false');
        return false;
      }

      // Return cached value if available for the same user
      if (_cachedUserId == user.uid && _cachedPremiumStatus != null) {
        debugPrint('✅ Using cached premium status: $_cachedPremiumStatus');
        return _cachedPremiumStatus!;
      }

      // Fetch from Firestore
      debugPrint('🔍 Fetching premium status from Firestore for user: ${user.uid}');
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      // Check local storage as backup first (if backend update is slow/failed)
      final localPremium = await _checkLocalPremiumStatus();
      if (localPremium) {
        debugPrint('✅ Found valid local premium status, using it as primary source');
        _cachedPremiumStatus = true;
        _cachedUserId = user.uid;
        return true;
      }

      if (!doc.exists) {
        debugPrint('⚠️ User document does not exist, creating with isPremium: false');
        // Create user document with default values
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email ?? '',
          'isPremium': false,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        _cachedPremiumStatus = false;
        _cachedUserId = user.uid;
        return false;
      }

      final data = doc.data();
      final isPremium = data?['isPremium'] ?? false;

      // Check if premium has expired (if premiumExpiresAt is set)
      final premiumExpiresAt = data?['premiumExpiresAt'] as Timestamp?;
      if (premiumExpiresAt != null) {
        final expiryDate = premiumExpiresAt.toDate();
        if (DateTime.now().isAfter(expiryDate)) {
          debugPrint('⏰ Premium subscription expired on $expiryDate');
          _cachedPremiumStatus = false;
          _cachedUserId = user.uid;
          return false;
        }
      }

      debugPrint('✅ Premium status: $isPremium');
      _cachedPremiumStatus = isPremium;
      _cachedUserId = user.uid;
      
      // Sync with local storage
      if (isPremium) {
        _savePremiumLocally(true);
      }
      
      return isPremium;
    } catch (e) {
      debugPrint('❌ Error checking premium status: $e');
      
      // Fallback to local storage on error
      if (_cachedUserId != null) {
        return await _checkLocalPremiumStatus();
      }
      
      return false; // Default to non-premium on error
    }
  }

  Future<bool> _checkLocalPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isPremium = prefs.getBool('is_premium') ?? false;
      debugPrint('📦 Local storage premium status: $isPremium');
      return isPremium;
    } catch (e) {
      debugPrint('❌ Error checking local storage: $e');
      return false;
    }
  }
  
  Future<void> _savePremiumLocally(bool isPremium) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_premium', isPremium);
      debugPrint('💾 Saved premium status locally: $isPremium');
    } catch (e) {
      debugPrint('❌ Error saving to local storage: $e');
    }
  }


  /// Listen to real-time premium status changes
  /// Returns a stream that emits true/false when premium status changes
  Stream<bool> premiumStatusStream() {
    final user = _auth.currentUser;
    
    if (user == null) {
      return Stream.value(false);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return false;
      }

      final data = snapshot.data();
      final isPremium = data?['isPremium'] ?? false;

      // Check expiry
      final premiumExpiresAt = data?['premiumExpiresAt'] as Timestamp?;
      if (premiumExpiresAt != null) {
        final expiryDate = premiumExpiresAt.toDate();
        if (DateTime.now().isAfter(expiryDate)) {
          return false;
        }
      }

      // Update cache
      _cachedPremiumStatus = isPremium;
      _cachedUserId = user.uid;

      return isPremium;
    });
  }

  /// Clear the cached premium status
  /// Useful when user logs out or when you want to force a refresh
  void clearCache() {
    debugPrint('🗑️ Clearing premium status cache');
    _cachedPremiumStatus = null;
    _cachedUserId = null;
  }

  /// Force refresh premium status from Firestore
  Future<bool> refreshPremiumStatus() async {
    clearCache();
    return await isPremiumUser();
  }

  /// Optimistically set premium status (e.g., after successful payment)
  /// This allows immediate access while the backend updates Firestore
  Future<void> setPremiumStatusOptimistically(bool status) async {
    debugPrint('🚀 Optimistically setting premium status to: $status');
    _cachedPremiumStatus = status;
    final user = _auth.currentUser;
    if (user != null) {
      _cachedUserId = user.uid;
    }
    
    // Save to local storage for persistence across restarts
    await _savePremiumLocally(status);
  }
}
