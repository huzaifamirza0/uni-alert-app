import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notification_app/MainNavBar/main_navbar.dart';
import 'package:notification_app/Screens/splash/splash_slides.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Services/notification_services.dart';

enum UserRole { student, hod, faculty, adminOfficer }

class AuthService {
  static const _isLoggedInKey = 'isLoggedIn';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

  Future<User?> signUpWithGoogle(
      UserRole role,
      bool emergency,
      double latitude,
      double longitude,
      NotificationServices notificationServices,
      Timestamp dateofJoin,
      {
        String? rollNo,
        String? contact,
      }) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // The user canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        if (!user.email!.endsWith('@uon.edu.pk') || !isValidUonEmail(user.email!)) {
          await _auth.signOut();
          Get.snackbar('Error', 'Invalid email domain. Please use a UON email.');
          return null; // Invalid email domain
        }

        // Check if user already exists in Firestore
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          Get.snackbar('Error', 'Email already registered. Please sign in.');
          return null; // User already exists
        }

        await user.sendEmailVerification();
        String deviceToken = await notificationServices.getDeviceToken() ?? '';

        final userData = {
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'picture': user.photoURL,
          'role': role.toString().split('.').last,
          'deviceToken': deviceToken,
          'emergency': emergency,
          'latitude': latitude,
          'longitude': longitude,
          'dateofJoin': dateofJoin
        };

        if (rollNo != null) {
          userData['rollNo'] = rollNo;
        }

        if (contact != null) {
          userData['contact'] = contact;
        }

        await _firestore.collection('users').doc(user.uid).set(userData);
        await setLoggedIn(true);
        return user;
      }
    } catch (e) {
      print('Error signing up with Google: $e');
    }
    return null;
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return; // The user canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        if (!user.email!.endsWith('@uon.edu.pk') || !isValidUonEmail(user.email!)) {
          await _auth.signOut();
          Get.snackbar('Error', 'Invalid email domain. Please use a UON email.');
          return; // Invalid email domain
        }

        await user.sendEmailVerification();
        await setLoggedIn(true);
        Get.offAll(NavBar());
      }
    } catch (e) {
      print('Error signing in with Google: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await clearLoggedIn();
  }

  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
        await clearLoggedIn();
        Get.offAll(() => SliderScreen());
      }
    } catch (e) {
      print('Error deleting account: $e');
    }
  }

  bool isValidUonEmail(String email) {
    final emailPattern = r'^[a-zA-Z0-9._%+-]+@uon.edu.pk$';
    final regex = RegExp(emailPattern);
    return regex.hasMatch(email);
  }
}
