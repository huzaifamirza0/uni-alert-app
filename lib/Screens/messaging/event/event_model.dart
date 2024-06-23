import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String creatorId;
  final String name;
  final String description;
  final DateTime date;
  final String imageUrl;
  final String createdBy;

  Event({
    required this.id,
    required this.creatorId,
    required this.name,
    required this.description,
    required this.date,
    required this.imageUrl,
    required this.createdBy,
  });

  factory Event.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      creatorId: data['creatorId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      imageUrl: data['image'],
      createdBy: data['createdBy'] ?? '',
    );
  }
}
