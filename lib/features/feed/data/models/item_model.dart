import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String locationName;
  final String imageUrl;
  final DateTime createdAt;
  final String status;
  final String userId;
  final bool isResolved;
  final bool isMine;

  ItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.locationName,
    required this.imageUrl,
    required this.createdAt,
    required this.status,
    required this.userId,
    required this.isResolved,
    required this.isMine,
  });

  factory ItemModel.fromMap(Map<String, dynamic> map, String docId, String currentUserId) {
    DateTime parsedDate;
    if (map['createdAt'] is Timestamp) {
      parsedDate = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      parsedDate = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    final postUserId = map['userId'] ?? '';

    return ItemModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'ทั่วไป',
      locationName: map['locationName'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: parsedDate,
      status: map['status'] ?? 'ของหาย',
      userId: postUserId,
      isResolved: map['isResolved'] ?? false,
      isMine: postUserId.isNotEmpty && postUserId == currentUserId,
    );
  }

  Map<String, dynamic> toMap(String currentUserId) {
    return {
      'title': title,
      'description': description,
      'category': category,
      'locationName': locationName,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'userId': currentUserId,
      'isResolved': isResolved,
    };
  }
}