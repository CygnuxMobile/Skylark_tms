import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/values/app_constants.dart';
import 'package:skylark/app/data/services/api_service.dart';
import 'package:skylark/app/data/services/storage_service.dart';
import 'package:skylark/app/routes/app_routes.dart';

class SplashController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final ApiService _apiService = Get.find<ApiService>();

  @override
  void onReady() {
    super.onReady();
    _checkVersionAndNavigate();
  }

  Future<void> _checkVersionAndNavigate() async {
    try {
      final isUpdateRequired = await _checkVersion();
      if (isUpdateRequired) {
        return;
      }
    } catch (e) {
      print('Version check failed: $e');
    }
    _handleNavigation();
  }

  Future<bool> _checkVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      String codeType =
          Platform.isIOS ? 'CustomerIOSVersion' : 'CustomerAPKVersion';

      final response = await _apiService.get(
        AppConstants.getGeneralMasterDataUrl,
        queryParameters: {'CodeType': codeType},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        if (data.isNotEmpty) {
          String requiredVersion = data[0]['codeDesc'] ?? data[0]['codeId']?.toString() ?? "0";

          if (_isUpdateRequired(currentVersion, requiredVersion)) {
            _showUpdateDialog();
            return true;
          }
        }
      }
    } catch (e) {
      print('Error checking version: $e');
    }
    return false;
  }

  bool _isUpdateRequired(String currentVersion, String requiredVersion) {
    try {
      List<String> currentParts = currentVersion.split('.');
      List<String> requiredParts = requiredVersion.split('.');

      int length = currentParts.length > requiredParts.length
          ? currentParts.length
          : requiredParts.length;

      for (int i = 0; i < length; i++) {
        int currentV =
            i < currentParts.length ? int.tryParse(currentParts[i]) ?? 0 : 0;
        int requiredV =
            i < requiredParts.length ? int.tryParse(requiredParts[i]) ?? 0 : 0;

        if (currentV < requiredV) return true;
        if (currentV > requiredV) return false;
      }
    } catch (e) {
      print('Error parsing version strings: $e');
    }
    return false;
  }

  void _showUpdateDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.system_update_rounded,
                    size: 40,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Update Required',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'A new version of the app is available. Please update to continue using the application.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _storageService.clearStorage();

                      final url = Platform.isAndroid
                          ? 'https://play.google.com/store/apps/details?id=com.cygnux.skylarkexp'
                          : 'https://apps.apple.com/app/idYOUR_ID';

                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url),
                            mode: LaunchMode.externalApplication);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'UPDATE NOW',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _handleNavigation() async {
    await Future.delayed(const Duration(seconds: 2));
    if (_storageService.isLoggedIn()) {
      await _fetchMenuAccess();
      Get.offAllNamed(AppRoutes.dashboard);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> _fetchMenuAccess() async {
    try {
      final user = _storageService.getUser();
      if (user != null && user.userId != null) {
        final response = await _apiService.post(
          AppConstants.menuAccessUrl,
          data: {"userID": user.userId},
        );

        if (response.statusCode == 200 && response.data != null) {
          final List<dynamic> menuData = response.data['data'] ?? [];
          await _storageService.saveMenuAccess(menuData);
        }
      }
    } catch (e) {
      print('Error fetching menu access: $e');
    }
  }
}
