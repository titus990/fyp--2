import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String userId;
  final String userName;
  final String moduleType;
  final String moduleName;
  final double rating;
  final String comment;
  final DateTime timestamp;
  final bool isEdited;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.moduleType,
    required this.moduleName,
    required this.rating,
    required this.comment,
    required this.timestamp,
    this.isEdited = false,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'moduleType': moduleType,
      'moduleName': moduleName,
      'rating': rating,
      'comment': comment,
      'timestamp': Timestamp.fromDate(timestamp),
      'isEdited': isEdited,
    };
  }

  // Create from Firestore document
  factory FeedbackModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedbackModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      moduleType: data['moduleType'] ?? '',
      moduleName: data['moduleName'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isEdited: data['isEdited'] ?? false,
    );
  }

  // Create a copy with updated fields
  FeedbackModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? moduleType,
    String? moduleName,
    double? rating,
    String? comment,
    DateTime? timestamp,
    bool? isEdited,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      moduleType: moduleType ?? this.moduleType,
      moduleName: moduleName ?? this.moduleName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      timestamp: timestamp ?? this.timestamp,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}
