import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:notification_app/MainNavBar/main_navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Services/notification_services.dart';
import '../otp_verification_screen.dart';

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
        String? departmentCode,
        String? batch,
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

        // Ensure OTPController is initialized
        Get.put(OTPController());

        // Send OTP to user's phone number
        await _sendOTP(
          contact!,
          user,
          role,
          name,
          email,
          deviceToken,
          rollNo: rollNo,
          contact: contact,
          departmentCode: departmentCode,
          batch: batch,
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

  Future<void> completeRegistration(
      User user,
      UserRole role,
      String name,
      String email,
      String deviceToken, {
        String? rollNo,
        String? contact,
        String? departmentCode,
        String? batch,
        String? description,
      }) async {
    Map<String, dynamic> userData = {
      'name': name,
      'email': email,
      'deviceToken': deviceToken,
      'uid': user.uid,
      'role': role.toString().split('.').last,
    };

    userData.addAll({
      'contact': contact,
    });

    switch (role) {
      case UserRole.student:
        userData.addAll({
          'rollNo': rollNo,
          'departmentCode': departmentCode,
          'batch': batch,
          'status': 'unavailable',
        });
        break;

      case UserRole.hod:
        userData.addAll({
          'status': 'pending',
        });
        break;

      case UserRole.faculty:
        userData.addAll({
          'departmentCode': departmentCode,
          'status': 'pending',
        });
        break;

      case UserRole.adminOffice:
        userData.addAll({
          'status': 'active',
          'description': description,
        });
        break;
    }

    await _firestore.collection('users').doc(user.uid).set(userData);
  }

  Future<void> _sendOTP(
      String phoneNumber,
      User user,
      UserRole role,
      String name,
      String email,
      String deviceToken, {
        String? rollNo,
        String? contact,
        String? departmentCode,
        String? batch,
        String? description,
      }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval or instant verification
        await user.linkWithCredential(credential);
        await completeRegistration(
          user,
          role,
          name,
          email,
          deviceToken,
          rollNo: rollNo,
          contact: contact,
          departmentCode: departmentCode,
          batch: batch,
          description: description,
        );
        Get.offAll(() => NavBar());
      },
      verificationFailed: (FirebaseAuthException e) {
        Get.snackbar('Error', 'Failed to send OTP: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        // Navigate to OTP verification screen
        Get.to(() => OTPVerificationScreen(
          verificationId: verificationId,
          user: user,
          role: role,
          name: name,
          email: email,
          deviceToken: deviceToken,
          rollNo: rollNo,
          contact: contact,
          departmentCode: departmentCode,
          batch: batch,
          description: description,
        ));
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
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
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          print('${userDoc.data()} signed in');
          await setLoggedIn(true);
          return user;
        }
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

class OTPController extends GetxController {
  String verificationId = '';
}
