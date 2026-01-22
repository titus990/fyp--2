import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String level;
  final int xp;
  final Map<String, dynamic> stats;
  final Map<String, bool> achievements;
  final DateTime? createdAt;
  final DateTime? lastActive;
  final bool isPremium;
  final DateTime? premiumExpiresAt;

  UserProfile({
    required this.uid,
    required this.email,
    this.displayName = 'Fighter',
    this.photoUrl,
    this.level = 'Beginner',
    this.xp = 0,
    this.stats = const {
      'totalWorkouts': 0,
      'totalMinutes': 0,
      'streak': 0,
      'lastWorkoutDate': null,
    },
    this.achievements = const {},
    this.createdAt,
    this.lastActive,
    this.isPremium = false,
    this.premiumExpiresAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'Fighter',
      photoUrl: data['photoUrl'],
      level: data['level'] ?? 'Beginner',
      xp: data['xp'] ?? 0,
      stats: Map<String, dynamic>.from(data['stats'] ?? {}),
      achievements: Map<String, bool>.from(data['achievements'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate(),
      isPremium: data['isPremium'] ?? false,
      premiumExpiresAt: (data['premiumExpiresAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'level': level,
      'xp': xp,
      'stats': stats,
      'achievements': achievements,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
      'isPremium': isPremium,
      'premiumExpiresAt': premiumExpiresAt != null ? Timestamp.fromDate(premiumExpiresAt!) : null,
    };
  }
}
