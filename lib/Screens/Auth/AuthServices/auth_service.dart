import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Services/notification_services.dart';

enum UserRole { student, hod, faculty, adminOffice }

class AuthService {
  static const _isLoggedInKey = 'isLoggedIn';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  static Future<void> clearLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
  }

  Future<User?> signUp(
      UserRole role,
      String name,
      String email,
      String password,
      NotificationServices notificationServices, {
        String? rollNo,
        String? contact,
        String? department,
        String? batch,
        String? semester,
        String? description,
      }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        String deviceToken = await notificationServices.getDeviceToken();

        await _completeRegistration(
          user,
          role,
          name,
          email,
          deviceToken,
          rollNo: rollNo,
          contact: contact,
          department: department,
          batch: batch,
          semester: semester,
          description: description,
        );
        print('${role.toString().split('.').last} signed up');
        return user;
      } else {
        print('${role.toString().split('.').last} sign up failed');
      }
    } catch (e) {
      print('Failed to sign up: $e');
    }

    return null;
  }

  Future<void> _completeRegistration(
      User user,
      UserRole role,
      String name,
      String email,
      String deviceToken, {
        String? rollNo,
        String? contact,
        String? department,
        String? batch,
        String? semester,
        String? description,
      }) async {
    Map<String, dynamic> userData = {
      'name': name,
      'email': email,
      'deviceToken': deviceToken,
      'uid': user.uid,
    };

    switch (role) {
      case UserRole.student:
        userData.addAll({
          'rollNo': rollNo,
          'contact': contact,
          'department': department,
          'batch': batch,
          'semester': semester,
          'status': 'unavailable',
        });
        await _firestore.collection('students').doc(user.uid).set(userData);
        break;

      case UserRole.hod:
        userData.addAll({
          'department': department,
          'contact': contact,
          'status': 'pending',
        });
        await _firestore.collection('hods').doc(user.uid).set(userData);
        break;

      case UserRole.faculty:
        userData.addAll({
          'department': department,
          'contact': contact,
          'status': 'pending',
        });
        await _firestore.collection('faculty').doc(user.uid).set(userData);
        break;

      case UserRole.adminOffice:
        userData.addAll({
          'contact': contact,
          'status': 'active',
          'description': description,
        });
        await _firestore.collection('adminOffices').doc(user.uid).set(userData);
        break;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Fetch user data from Firestore
        DocumentSnapshot studentDoc = await _firestore.collection('students').doc(user.uid).get();
        DocumentSnapshot hodDoc = await _firestore.collection('hods').doc(user.uid).get();
        DocumentSnapshot facultyDoc = await _firestore.collection('faculty').doc(user.uid).get();
        DocumentSnapshot adminOfficeDoc = await _firestore.collection('adminOffices').doc(user.uid).get();

        // Determine the role
        if (studentDoc.exists) {
          print('Student signed in');
        } else if (hodDoc.exists) {
          print('HOD signed in');
        } else if (facultyDoc.exists) {
          print('Faculty signed in');
        } else if (adminOfficeDoc.exists) {
          print('Admin Office signed in');
        } else {
          print('Unknown role');
        }

        await setLoggedIn(true);
        return user;
      }
    } catch (e) {
      print('Failed to sign in: $e');
    }
    return null;
  }

  Future<void> subscribeToOffice(String studentId, String officeId) async {
    try {
      await _firestore.collection('subscriptions').add({
        'studentId': studentId,
        'officeId': officeId,
        'subscriptionDate': Timestamp.now(),
      });
      print('Subscribed to office successfully');
    } catch (e) {
      print('Failed to subscribe: $e');
    }
  }
}
