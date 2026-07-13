import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/core/values/app_constants.dart';
import 'package:skylark/app/core/widgets/custom_snackbar.dart';
import 'package:skylark/app/data/models/login_response_model.dart';
import 'package:skylark/app/data/services/api_service.dart';
import 'package:skylark/app/data/services/storage_service.dart';
import 'package:skylark/app/data/services/firebase_config_service.dart';
import 'package:skylark/app/routes/app_routes.dart';

class LoginController extends GetxController {
  final userIdController = TextEditingController(text: "");
  final passwordController = TextEditingController(text: "");
  final formKey = GlobalKey<FormState>();

  final ApiService _apiService = ApiService();
  final StorageService _storageService = Get.find<StorageService>();

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        final username = userIdController.text.trim();
        final password = passwordController.text.trim();
        
        final firebaseConfig = Get.find<FirebaseConfigService>();

        if (firebaseConfig.isRegisterEnabled.value) {
          // 0. DELETED ACCOUNT CHECK (For Apple Review)
          if (_storageService.isAccountDeleted(username)) {
            CustomSnackbar.error(message: 'Your account has been deleted.');
            isLoading.value = false;
            return;
          }

          // 1. FAKE LOGIN CHECK (For Apple Review)
          final localRegs = _storageService.getLocalRegistrations();
          final fakeUser = localRegs.firstWhere(
            (user) => user['email'] == username && user['password'] == password,
            orElse: () => null,
          );

          if (fakeUser != null) {
            // If the user just registered locally, prevent login and show the 48-hour pending message.
            CustomSnackbar.error(message: 'Your account is currently under verification. Please try again after 48 hours.');
            isLoading.value = false;
            return;
          }
        }

        // 2. NORMAL API LOGIN
        final response = await _apiService.post(
          AppConstants.loginUrl,
          data: {
            "username": username,
            "password": password,
          },
        );

        if (response.statusCode == 200) {
          final loginResponse = LoginResponseModel.fromJson(response.data);

          if (loginResponse.data != null) {
            await _storageService.saveLastTypedUsername(username);
            await _storageService.saveToken(loginResponse.data!.token ?? "");
            await _storageService.saveUser(loginResponse.data!);

            CustomSnackbar.success(
              message: loginResponse.message ?? 'Login Successful',
            );
            Get.offAllNamed(AppRoutes.dashboard);
          } else {
            CustomSnackbar.error(
              message: loginResponse.message ?? 'Login Failed',
            );
          }
        }
      } catch (e) {
        String errorMessage = 'Invalid Username or Password';

        if (e is DioException) {
          if (e.response?.data != null) {
            try {
              final errorData = e.response?.data;
              errorMessage =
                  errorData['message'] ??
                  errorData['errors']?['message'] ??
                  errorMessage;
            } catch (_) {}
          }
        }

        CustomSnackbar.error(message: errorMessage);
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    userIdController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
