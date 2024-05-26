

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Services/notification_services.dart';


class AuthService {
  static const _isLoggedInKey = 'isLoggedIn';

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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUpStudent(String name, String rollNo, String email, String contact, String department, String batch, String semester, String password, NotificationServices notificationServices) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        await _completeStudentRegistration(user, name, rollNo, email, contact, department, batch, semester, notificationServices);
        print('Student signed up');
        return user;
      } else {
        print('Student sign up failed');
      }
    } catch (e) {
      print('Failed to sign up: $e');
    }

    return null;
  }

  Future<void> _completeStudentRegistration(User user, String name, String rollNo, String email, String contact, String department, String batch, String semester, NotificationServices notificationServices) async {
    String deviceToken = await notificationServices.getDeviceToken();
    await _firestore.collection('students').doc(user.uid).set({
      'name': name,
      'rollNo': rollNo,
      'email': email,
      'contact': contact,
      'department': department,
      'batch': batch,
      'semester': semester,
      'status': 'unavailable',
      'deviceToken': deviceToken,
      'uid' : user.uid,
    });
  }

  Future<User?> signUpHOD(String name, String department, String email, String contact, String password, NotificationServices notificationServices) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        await _completeHODRegistration(user, name, department, email, contact, notificationServices);
        print('HOD signed up');
        return user;
      } else {
        print('HOD sign up failed');
      }
    } catch (e) {
      print('Failed to sign up: $e');
    }

    return null;
  }

  Future<void> _completeHODRegistration(User user, String name, String department, String email, String contact, NotificationServices notificationServices) async {
    String deviceToken = await notificationServices.getDeviceToken();
    await _firestore.collection('hods').doc(user.uid).set({
      'name': name,
      'department': department,
      'email': email,
      'contact': contact,
      'status': 'pending', // Assuming HODs need admin approval
      'deviceToken': deviceToken,
      'uid' : user.uid,
    });
  }

  Future<User?> signUpFaculty(String name, String department, String email, String contact, String password, NotificationServices notificationServices) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        await _completeFacultyRegistration(user, name, department, email, contact, notificationServices);
        print('Faculty member signed up');
        return user;
      } else {
        print('Faculty member sign up failed');
      }
    } catch (e) {
      print('Failed to sign up: $e');
    }

    return null;
  }

  Future<void> _completeFacultyRegistration(User user, String name, String department, String email, String contact, NotificationServices notificationServices) async {
    String deviceToken = await notificationServices.getDeviceToken();
    await _firestore.collection('faculty').doc(user.uid).set({
      'name': name,
      'department': department,
      'email': email,
      'contact': contact,
      'status': 'pending', // Assuming faculty members need admin approval
      'deviceToken': deviceToken,
      'uid' : user.uid,
    });
  }
}
