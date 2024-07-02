// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../Components/CustomButton.dart';
// import '../../../Components/text_fields.dart';
// import '../AuthServices/adminOffice_controllers_auth.dart';
//
// class AdminOfficeSignUpScreen extends StatelessWidget {
//   final AdminOfficeSignUpController signUpController = Get.put(AdminOfficeSignUpController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Admin Office Sign Up'),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 20),
//               Obx(() => CustomTextField(
//                 controller: signUpController.nameController,
//                 labelText: 'Office Name',
//                 preIcon: const Icon(Icons.person, color: Colors.lightGreen,),
//                 errorText: signUpController.nameTouched.value
//                     ? signUpController.nameError.value.isNotEmpty
//                     ? signUpController.nameError.value
//                     : null
//                     : null,
//                 onChanged: (_) => signUpController.setNameTouched(true),
//               )),
//               const SizedBox(height: 12),
//               Obx(() => CustomTextField(
//                 controller: signUpController.emailController,
//                 labelText: 'Email',
//                 preIcon: const Icon(Icons.email, color: Colors.lightGreen,),
//                 errorText: signUpController.emailTouched.value
//                     ? signUpController.emailError.value.isNotEmpty
//                     ? signUpController.emailError.value
//                     : null
//                     : null,
//                 onChanged: (_) => signUpController.setEmailTouched(true),
//               )),
//               const SizedBox(height: 12),
//               Obx(() => CustomTextField(
//                 controller: signUpController.phoneController,
//                 labelText: 'Phone Number',
//                 preIcon: const Icon(Icons.phone, color: Colors.lightGreen,),
//                 errorText: signUpController.phoneTouched.value
//                     ? signUpController.phoneError.value.isNotEmpty
//                     ? signUpController.phoneError.value
//                     : null
//                     : null,
//                 onChanged: (_) => signUpController.setPhoneTouched(true),
//               )),
//               const SizedBox(height: 12),
//               Obx(() => CustomTextField(
//                 controller: signUpController.officeDescriptionController,
//                 labelText: 'Office Description',
//                 preIcon: const Icon(Icons.description, color: Colors.lightGreen,),
//                 errorText: signUpController.officeDescriptionTouched.value
//                     ? signUpController.officeDescriptionError.value.isNotEmpty
//                     ? signUpController.officeDescriptionError.value
//                     : null
//                     : null,
//                 onChanged: (_) => signUpController.setOfficeDescriptionTouched(true),
//               )),
//               const SizedBox(height: 12),
//               Obx(() => CustomTextField(
//                 controller: signUpController.passwordController,
//                 labelText: 'Password',
//                 preIcon: const Icon(Icons.lock, color: Colors.lightGreen,),
//                 errorText: signUpController.passwordTouched.value
//                     ? signUpController.passwordError.value.isNotEmpty
//                     ? signUpController.passwordError.value
//                     : null
//                     : null,
//                 obscureText: signUpController.obscurePassword.value,
//                 onPressed: signUpController.togglePasswordVisibility,
//                 onChanged: (_) => signUpController.setPasswordTouched(true),
//               )),
//               const SizedBox(height: 12),
//               Obx(() => CustomTextField(
//                 controller: signUpController.confirmPasswordController,
//                 labelText: 'Confirm Password',
//                 preIcon: const Icon(Icons.lock, color: Colors.lightGreen,),
//                 errorText: signUpController.confirmPasswordTouched.value
//                     ? signUpController.confirmPasswordError.value.isNotEmpty
//                     ? signUpController.confirmPasswordError.value
//                     : null
//                     : null,
//                 obscureText: signUpController.obscureConfirmPassword.value,
//                 onPressed: signUpController.toggleConfirmPasswordVisibility,
//                 onChanged: (_) => signUpController.setConfirmPasswordTouched(true),
//               )),
//
//               const SizedBox(height: 24),
//               Obx(() => SizedBox(
//                 height: 50,
//                 width: MediaQuery.of(context).size.width,
//                 child: CustomButton(
//                   color: Colors.lightGreen,
//                   onPressed: signUpController.isSignUpFormValid.value
//                       ? signUpController.signUp
//                       : null,
//                   text: 'Sign Up',
//                 ),
//               )),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
