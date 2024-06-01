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
  var departmentTouched = false.obs;
  var emailTouched = false.obs;
  var contactTouched = false.obs;
  var passwordTouched = false.obs;
  var confirmPasswordTouched = false.obs;

  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;

  var nameError = ''.obs;
  var departmentError = ''.obs;
  var emailError = ''.obs;
  var contactError = ''.obs;
  var passwordError = ''.obs;
  var confirmPasswordError = ''.obs;

  var isSignUpFormValid = false.obs;

  void setNameTouched(bool touched) {
    nameTouched.value = touched;
    validateName();
  }

  void setDepartmentTouched(bool touched) {
    departmentTouched.value = touched;
    validateDepartment();
  }

  void setEmailTouched(bool touched) {
    emailTouched.value = touched;
    validateEmail();
  }

  void setContactTouched(bool touched) {
    contactTouched.value = touched;
    validateContact();
  }

  void setPasswordTouched(bool touched) {
    passwordTouched.value = touched;
    validatePassword();
  }

  void setConfirmPasswordTouched(bool touched) {
    confirmPasswordTouched.value = touched;
    validateConfirmPassword();
  }

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.toggle();
  }


  void validateName() {
    if (nameController.text.isEmpty) {
      nameError.value = 'Name cannot be empty';
    } else {
      nameError.value = '';
    }
    validateForm();
  }

  void validateDepartment() {
    if (departmentController.text.isEmpty) {
      departmentError.value = 'Department cannot be empty';
    } else {
      departmentError.value = '';
    }
    validateForm();
  }

  void validateEmail() {
    if (emailController.text.isEmpty) {
      emailError.value = 'Email cannot be empty';
    } else if (!GetUtils.isEmail(emailController.text)) {
      emailError.value = 'Enter a valid email address';
    } else {
      emailError.value = '';
    }
    validateForm();
  }

  void validateContact() {
    if (contactController.text.isEmpty) {
      contactError.value = 'Contact cannot be empty';
    } else {
      contactError.value = '';
    }
    validateForm();
  }

  void validatePassword() {
    if (passwordController.text.isEmpty) {
      passwordError.value = 'Password cannot be empty';
    } else {
      passwordError.value = '';
    }
    validateForm();
  }

  void validateConfirmPassword() {
    if (confirmPasswordController.text.isEmpty) {
      confirmPasswordError.value = 'Confirm Password cannot be empty';
    } else if (confirmPasswordController.text != passwordController.text) {
      confirmPasswordError.value = 'Passwords do not match';
    } else {
      confirmPasswordError.value = '';
    }
    validateForm();
  }

  void validateForm() {
    if (nameError.value.isEmpty &&
        departmentError.value.isEmpty &&
        emailError.value.isEmpty &&
        contactError.value.isEmpty &&
        passwordError.value.isEmpty &&
        confirmPasswordError.value.isEmpty &&
        nameController.text.isNotEmpty &&
        departmentController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        contactController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty) {
      isSignUpFormValid.value = true;
    } else {
      isSignUpFormValid.value = false;
    }
  }

  Future<void> signUp(NotificationServices notificationServices) async {
    if (isSignUpFormValid.value) {
      await AuthService().signUp(
        UserRole.faculty,
        nameController.text,
        emailController.text,
        passwordController.text,
        notificationServices,
        contact: contactController.text,
        department: departmentController.text,
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
