import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:notification_app/MainNavBar/main_navbar.dart';
import '../../../Services/notification_services.dart';
import 'AuthServices/auth_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String verificationId;
  final User? user;
  final UserRole role;
  final String name;
  final String email;
  final String deviceToken;
  final String? rollNo;
  final String? contact;
  final String? departmentCode;
  final String? batch;
  final String? description;

  OTPVerificationScreen({
    required this.verificationId,
    this.user,
    required this.role,
    required this.name,
    required this.email,
    required this.deviceToken,
    this.rollNo,
    this.contact,
    this.departmentCode,
    this.batch,
    this.description,
  });

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();

  void _verifyOtp() async {
    String otp = _otpController.text.trim();

    if (otp.isNotEmpty) {
      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId,
          smsCode: otp,
        );
        await widget.user!.linkWithCredential(credential);

        await _authService.completeRegistration(
          widget.user!,
          widget.role,
          widget.name,
          widget.email,
          widget.deviceToken,
          rollNo: widget.rollNo,
          contact: widget.contact,
          departmentCode: widget.departmentCode,
          batch: widget.batch,
          description: widget.description,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP verified successfully')),
        );
        Get.offAll(() => NavBar());
      } catch (e) {
        // Handle OTP verification failure
        print('OTP verification failed: $e');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to verify OTP: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      // Handle empty OTP field
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter OTP'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyOtp,
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
