import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String name;
  final String email;
  final String? about;
  final String phone;
  final String imagePath;
  final bool emergency;
  final double latitude;
  final double longitude;
  final String? departmentCode;
  final String? deviceToken;
  final String? role;
  final String? status;

  const User({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.about,
    required this.imagePath,
    required this.emergency,
    required this.latitude,
    required this.longitude,
    this.departmentCode,
    this.deviceToken,
    this.role,
    this.status,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return User(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      about: data['about'],
      imagePath: data['imagePath'],
      emergency: data['emergency'] ?? false,
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      departmentCode: data['departmentCode'],
      deviceToken: data['deviceToken'],
      role: data['role'],
      status: data['status'],
      phone: data['contact'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'about': about,
      'imagePath': imagePath,
      'emergency': emergency,
      'latitude': latitude,
      'longitude': longitude,
      'departmentCode': departmentCode,
      'deviceToken': deviceToken,
      'role': role,
      'status': status,
      'contact': phone,
    };
  }
}
