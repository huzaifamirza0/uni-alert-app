import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Services/notification_services.dart';
import 'auth_service.dart';

class HODSignUpController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool isSignUpFormValid = false.obs;

  final RxBool nameTouched = false.obs;
  final RxBool emailTouched = false.obs;
  final RxBool contactTouched = false.obs;
  final RxBool departmentTouched = false.obs;
  final RxBool passwordTouched = false.obs;
  final RxBool confirmPasswordTouched = false.obs;

  final RxString nameError = ''.obs;
  final RxString emailError = ''.obs;
  final RxString contactError = ''.obs;
  final RxString departmentError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString confirmPasswordError = ''.obs;

  void validateForm() {
    // Validate name
    if (nameTouched.value) {
      if (nameController.text.isNotEmpty) {
        nameError.value = '';
      } else {
        nameError.value = 'Please enter your name';
      }
    }

    // Validate email
    if (emailTouched.value) {
      if (EmailValidator.validate(emailController.text)) {
        emailError.value = '';
      } else {
        emailError.value = 'Please enter a valid email';
      }
    }

    // Validate contact
    if (contactTouched.value) {
      if (contactController.text.length >= 9) {
        contactError.value = '';
      } else {
        contactError.value = 'Please enter a valid contact number';
      }
    }

    // Validate department
    if (departmentTouched.value) {
      if (departmentController.text.isNotEmpty) {
        departmentError.value = '';
      } else {
        departmentError.value = 'Please enter your department';
      }
    }

    // Validate password
    if (passwordTouched.value) {
      if (passwordController.text.length < 6) {
        passwordError.value = 'Password must be at least 6 characters long';
      } else {
        passwordError.value = '';
      }
    }

    // Validate confirm password
    if (confirmPasswordTouched.value) {
      if (confirmPasswordController.text != passwordController.text) {
        confirmPasswordError.value = 'Passwords do not match';
      } else {
        confirmPasswordError.value = '';
      }
    }

    // Check if all fields are valid
    isSignUpFormValid.value = nameTouched.value &&
        emailTouched.value &&
        contactTouched.value &&
        passwordTouched.value &&
        confirmPasswordTouched.value &&
        nameError.value.isEmpty &&
        emailError.value.isEmpty &&
        contactError.value.isEmpty &&
        passwordError.value.isEmpty &&
        confirmPasswordError.value.isEmpty;
  }

  void signUp(NotificationServices notificationServices) async {
    if (isSignUpFormValid.value) {
      User? user = await AuthService().signUp(
        UserRole.hod,
        nameController.text,
        emailController.text,
        passwordController.text,
        notificationServices,
        contact: contactController.text,
        //departmentCode: departmentController.text,
      );
      if (user != null) {
        // Handle successful sign-up
        await AuthService.setLoggedIn(true);
        print('HOD sign-up successful!');
      } else {
        // Handle sign-up failure
        print('HOD sign-up failed');
      }
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.toggle();
  }

  void setNameTouched(bool touched) {
    nameTouched.value = touched;
    validateForm();
  }

  void setEmailTouched(bool touched) {
    emailTouched.value = touched;
    validateForm();
  }

  void setContactTouched(bool touched) {
    contactTouched.value = touched;
    validateForm();
  }

  void setDepartmentTouched(bool touched) {
    departmentTouched.value = touched;
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
