import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user.dart' as ProfileUser;

class UserPreferences {
  static Future<ProfileUser.User> fetchMyUser() async {
    // Get the current user's ID
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Fetch the user document from Firestore
    final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    // Check if user data exists
    if (!userSnapshot.exists) {
      throw Exception("User not found");
    }

    // Map the Firestore data to user data
    final userData = userSnapshot.data() as Map<String, dynamic>;

    // Create a User object using the data from Firestore
    final user = ProfileUser.User(
      uid: userId,
      name: userData['displayName'] ?? 'Unknown',
      email: userData['email'],
      about: userData['about'] ?? 'No about information provided',
      imagePath: userData['picture'],
      emergency: userData['emergency'] ?? false,
      latitude: (userData['latitude'] ?? 0.0).toDouble(),
      longitude: (userData['longitude'] ?? 0.0).toDouble(),
      departmentCode: userData['departmentCode'],
      deviceToken: userData['deviceToken'],
      role: userData['role'],
      dateofJoin: userData['dateofJoin'],
      phone: userData['contact']?? 'phone',
    );
    return user;
  }
}
