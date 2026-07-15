import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/data/services/storage_service.dart' as skylark_storage;

class RegistrationController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isLoading = false.obs;
  final countryCode = '+91'.obs;

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter First Name';
    }
    return null;
  }

  String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter Last Name';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter Email Address';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid Email Address';
    }
    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter Mobile Number';
    }
    if (value.length != 10) {
      return 'Mobile Number must be 10 digits';
    }
    if (!GetUtils.isNumericOnly(value)) {
      return 'Please enter a valid Mobile Number';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter Password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm Password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> register() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        // Save to SharedPreferences
        final storage = Get.find<skylark_storage.StorageService>();
        await storage.saveRegistrationData({
          'firstName': firstNameController.text.trim(),
          'lastName': lastNameController.text.trim(),
          'email': emailController.text.trim(),
          'countryCode': countryCode.value,
          'mobile': mobileController.text.trim(),
          'password': passwordController.text, // added for fake login
        });
        
        // Simulate API call loader for 3 seconds
        await Future.delayed(const Duration(seconds: 3));
        
        Get.defaultDialog(
          title: "Registration Submitted",
          titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          middleText: "We will verify your account soon, please wait until 48 hours.",
          middleTextStyle: const TextStyle(fontSize: 16),
          barrierDismissible: false,
          confirm: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Get.back(); // close dialog
              Get.back(); // go back to login screen
            },
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          ),
        );
      } finally {
        isLoading.value = false;
      }
    }
  }
}
