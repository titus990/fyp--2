import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveProgress(
    String userId,
    String activityName,
    Map<String, dynamic> stats,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final userDocRef = _firestore.collection('users').doc(userId);
      final historyDocRef = userDocRef.collection('history').doc('${activityName}_$timestamp');

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userDocRef);
        
        // 1. Create user doc if not exists
        if (!userDoc.exists) {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null && currentUser.uid == userId) {
            transaction.set(userDocRef, {
              'email': currentUser.email,
              'role': 'client',
              'displayName': currentUser.displayName ?? 'Fighter',
              'createdAt': FieldValue.serverTimestamp(),
              'stats': {
                'totalWorkouts': 0,
                'totalMinutes': 0,
                'streak': 0,
                'lastWorkoutDate': null,
              },
              'achievements': {},
              'level': 'Beginner',
              'xp': 0,
            });
          }
        }

        // 2. Save history entry
        transaction.set(historyDocRef, {
          'activityName': activityName,
          'timestamp': FieldValue.serverTimestamp(),
          'stats': stats,
        });

        // 3. Update User Aggregates
        if (userDoc.exists) {
          final userData = userDoc.data() ?? {};
          final currentStats = Map<String, dynamic>.from(userData['stats'] ?? {});
          
          int totalWorkouts = (currentStats['totalWorkouts'] ?? 0) + 1;
          int totalMinutes = (currentStats['totalMinutes'] ?? 0);
          
          // Parse duration from stats if available (e.g., "45 MIN" or 300 seconds)
          if (stats.containsKey('duration')) {
             // Simple parsing logic, improved in production
             final durationVal = stats['duration'];
             if (durationVal is int) {
               totalMinutes += (durationVal / 60).round();
             } else if (durationVal is String) {
               // Try to parse "45 MIN"
               final parts = durationVal.split(' ');
               if (parts.isNotEmpty) {
                 final parsed = int.tryParse(parts[0]);
                 if (parsed != null) totalMinutes += parsed;
               }
             }
          }

          // Streak Logic
          int streak = currentStats['streak'] ?? 0;
          Timestamp? lastDateTs = currentStats['lastWorkoutDate'];
          DateTime? lastDate = lastDateTs?.toDate();
          final now = DateTime.now();
          
          if (lastDate != null) {
            final difference = DateTime(now.year, now.month, now.day)
                .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
                .inDays;
            
            if (difference == 1) {
              streak += 1; // Consecutive day
            } else if (difference > 1) {
              streak = 1; // Streak broken
            }
            // If difference == 0, same day, streak doesn't change
          } else {
             streak = 1; // First workout
          }

          // Leveling Logic (Simple XP based on workouts)
          int currentXp = (userData['xp'] ?? 0) + 10; // +10 XP per workout
          String level = userData['level'] ?? 'Beginner';
          if (currentXp > 100) level = 'Intermediate';
          if (currentXp > 500) level = 'Pro';

          // Achievements
          Map<String, bool> achievements = Map<String, bool>.from(userData['achievements'] ?? {});
          if (totalWorkouts >= 1) achievements['first_punch'] = true;
          if (totalWorkouts >= 10) achievements['10_workouts'] = true;
          if (streak >= 7) achievements['7_day_streak'] = true;

          transaction.set(userDocRef, {
            'stats': {
              'totalWorkouts': totalWorkouts,
              'totalMinutes': totalMinutes,
              'streak': streak,
              'lastWorkoutDate': FieldValue.serverTimestamp(),
            },
            'xp': currentXp,
            'level': level,
            'achievements': achievements,
            'lastActive': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      });
      
      print('Progress saved and stats updated for $activityName');
    } catch (e) {
      print('Error saving progress: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getUserProgress(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
