import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Services/notification_services.dart';
import 'auth_service.dart';

class FacultySignUpController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  var nameTouched = false.obs;
  var emailTouched = false.obs;
  var contactTouched = false.obs;
  var passwordTouched = false.obs;
  var confirmPasswordTouched = false.obs;

  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;

  var nameError = ''.obs;
  var emailError = ''.obs;
  var contactError = ''.obs;
  var passwordError = ''.obs;
  var confirmPasswordError = ''.obs;

  var isSignUpFormValid = false.obs;

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

  void setPasswordTouched(bool touched) {
    passwordTouched.value = touched;
    validateForm();
  }

  void setConfirmPasswordTouched(bool touched) {
    confirmPasswordTouched.value = touched;
    validateForm();
  }


  bool isValidUonEmail(String email) {
    final regex = RegExp(r'^.*@uon\.edu\.pk$');
    return regex.hasMatch(email);
  }

  bool isValidContact(String contact) {
    final regex = RegExp(r'^\+923\d{9}$');
    return regex.hasMatch(contact);
  }


  void validateForm() {
    // Validate name
    if (nameTouched.value) {
      if (nameController.text.length > 2) {
        nameError.value = '';
      } else {
        nameError.value = 'Please enter your name';
      }
    }

    // Validate email
    if (emailTouched.value) {
      if (isValidUonEmail(emailController.text)) {
        emailError.value = '';
      } else {
        emailError.value = 'Please enter a valid email (e.g., 20uon0567@uon.edu.pk)';
      }
    }

    // Validate contact
    if (contactTouched.value) {
      if (isValidContact(contactController.text)) {
        contactError.value = '';
      } else {
        contactError.value = 'Please enter a valid contact number';
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

  Future<void> signUp(NotificationServices notificationServices) async {
    if (isSignUpFormValid.value) {
      await AuthService().signUp(
        UserRole.faculty,
        nameController.text,
        emailController.text,
        passwordController.text,
        'https://www.shareicon.net/data/512x512/2016/09/15/829459_man_512x512.png',
        false,
        0.0,
        0.0,
        notificationServices,
        contact: contactController.text,
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    departmentController.dispose();
    emailController.dispose();
    contactController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
