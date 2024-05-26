import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../MainNavBar/main_navbar.dart';

class SignUpController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool isSignUpFormValid = false.obs;

  final RxBool emailTouched = false.obs;
  final RxBool phoneTouched = false.obs;
  final RxBool passwordTouched = false.obs;
  final RxBool confirmPasswordTouched = false.obs;

  final RxString emailError = ''.obs;
  final RxString phoneError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString confirmPasswordError = ''.obs;

  void validateForm() {
      // Validate email
    if (emailTouched.value) {
      if (EmailValidator.validate(emailController.text)) {
        emailError.value = '';
      } else {
        emailError.value = 'Please enter a valid email';
      }
    }

    // Validate phone number if it has been touched
    if (phoneTouched.value) {
      if (phoneController.text.length >= 9) {
        phoneError.value = '';
      } else {
        phoneError.value = 'Please enter a valid phone number';
      }
    }

    // Validate password if it has been touched
    if (passwordTouched.value) {
      if (passwordController.text.length < 6) {
        passwordError.value = 'Password must be at least 6 characters long';
      } else {
        passwordError.value = '';
      }
    }

    // Validate confirm password if it has been touched
    if (confirmPasswordTouched.value) {
      if (confirmPasswordController.text != passwordController.text) {
        confirmPasswordError.value = 'Passwords do not match';
      } else {
        confirmPasswordError.value = '';
      }
    }

    // Check if all fields are valid
    isSignUpFormValid.value = emailTouched.value &&
        phoneTouched.value &&
        passwordTouched.value &&
        confirmPasswordTouched.value &&
        emailError.value.isEmpty &&
        phoneError.value.isEmpty &&
        passwordError.value.isEmpty &&
        confirmPasswordError.value.isEmpty;

  }

  void signUp() {
    // Your sign-up logic here
    // For demonstration, we'll just print the values
    print('Email: ${emailController.text}');
    print('Phone: ${phoneController.text}');
    print('Password: ${passwordController.text}');

    if (isSignUpFormValid.value) {
      Get.back();
      print('Sign-up successful!');
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.toggle();
  }

  void setEmailTouched(bool touched) {
    emailTouched.value = touched;
    validateForm();
  }

  void setPhoneTouched(bool touched) {
    phoneTouched.value = touched;
    validateForm();
  }

  void setPasswordTouched(bool touched) {
    passwordTouched.value = touched;
    validateForm();
  }

  void setConfirmPasswordTouched(bool touched) {
    confirmPasswordTouched.value = touched;
    validateForm();
  }
}



class SignInController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool isSignInFormValid = false.obs;

  final RxBool emailTouched = false.obs;
  final RxBool passwordTouched = false.obs;

  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;

  void validateForm() {
      // Validate email
    if (emailTouched.value) {
      if (EmailValidator.validate(emailController.text)) {
        emailError.value = '';
      } else {
        emailError.value = 'Please enter a valid email';
      }
    }

    // Validate password if it has been touched
    if (passwordTouched.value) {
      if (passwordController.text.length < 6) {
        passwordError.value = 'Password must be at least 6 characters long';
      } else {
        passwordError.value = '';
      }
    }

    isSignInFormValid.value = emailTouched.value && passwordTouched.value &&
        emailError.value.isEmpty && passwordError.value.isEmpty;
  }

  void signIn() {
    print('Email: ${emailController.text}');
    print('Password: ${passwordController.text}');

    if (isSignInFormValid.value) {
      Get.to(() => NavBar());
      print('Sign-In successful!');
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  void setEmailTouched(bool touched) {
    emailTouched.value = touched;
    validateForm();
  }


  void setPasswordTouched(bool touched) {
    passwordTouched.value = touched;
    validateForm();
  }

}
