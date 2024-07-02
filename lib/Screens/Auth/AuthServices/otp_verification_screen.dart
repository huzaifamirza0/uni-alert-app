// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';
// import 'package:sms_autofill/sms_autofill.dart';
// import 'package:notification_app/MainNavBar/main_navbar.dart';
// import 'AuthServices/auth_service.dart';
//
// class OTPVerificationScreen extends StatefulWidget {
//   final String verificationId;
//   final User? user;
//   final UserRole role;
//   final String name;
//   final String email;
//   final String deviceToken;
//   final String picture;
//   final bool emergency;
//   final double latitude;
//   final double longitude;
//   final String? rollNo;
//   final String? contact;
//
//   OTPVerificationScreen({
//     required this.verificationId,
//     this.user,
//     required this.picture,
//     required this.emergency,
//     required this.latitude,
//     required this.longitude,
//     required this.role,
//     required this.name,
//     required this.email,
//     required this.deviceToken,
//     this.rollNo,
//     this.contact,
//   });
//
//   @override
//   _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
// }
//
// class _OTPVerificationScreenState extends State<OTPVerificationScreen> with CodeAutoFill {
//   final AuthService _authService = AuthService();
//   String _otpCode = "";
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     listenForCode();
//   }
//
//   @override
//   void codeUpdated() {
//     Future.microtask(() {
//       setState(() {
//         _otpCode = code!;
//       });
//       _verifyOtp();
//     });
//   }
//
//   @override
//   void dispose() {
//     cancel();
//     super.dispose();
//   }
//
//   void _verifyOtp() async {
//     String otp = _otpCode.trim();
//
//     if (otp.isNotEmpty) {
//       setState(() {
//         _isLoading = true;
//       });
//       try {
//         PhoneAuthCredential credential = PhoneAuthProvider.credential(
//           verificationId: widget.verificationId,
//           smsCode: otp,
//         );
//         await widget.user!.linkWithCredential(credential);
//
//         await _authService.completeRegistration(
//           widget.user!,
//           widget.role,
//           widget.name,
//           widget.email,
//           widget.picture,
//           widget.emergency,
//           widget.latitude,
//           widget.longitude,
//           widget.deviceToken,
//           rollNo: widget.rollNo,
//           contact: widget.contact,
//         );
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('OTP verified successfully')),
//         );
//         await AuthService.setLoggedIn(true);
//         Get.offAll(() => NavBar());
//       } catch (e) {
//         print('OTP verification failed: $e');
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Error'),
//             content: Text('Failed to verify OTP: $e'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//         );
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter OTP')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         title: const Text('OTP Verification'),
//       ),
//       body: _isLoading ? _buildLoading() : _buildOTPForm(context),
//     );
//   }
//
//   Widget _buildLoading() {
//     return Center(
//       child: CircularProgressIndicator(),
//     );
//   }
//
//   Widget _buildOTPForm(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: <Widget>[
//           const SizedBox(height: 30),
//           const Text('Enter OTP', style: TextStyle(color: Colors.black)),
//           const Text(
//             'We have just sent you a 6 digit code via your phone number.',
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 30),
//           PinFieldAutoFill(
//             codeLength: 6,
//             onCodeChanged: (code) {
//               if (code != null && code.length == 6) {
//                 Future.microtask(() {
//                   setState(() {
//                     _otpCode = code;
//                   });
//                   _verifyOtp();
//                 });
//               }
//             },
//             onCodeSubmitted: (code) {
//               _verifyOtp();
//             },
//           ),
//           const SizedBox(height: 50),
//         ],
//       ),
//     );
//   }
// }