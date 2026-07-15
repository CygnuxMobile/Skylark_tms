import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:skylark/app/core/values/app_constants.dart';
import 'package:skylark/app/core/widgets/custom_snackbar.dart';
import 'package:skylark/app/data/models/location_model.dart';
import 'package:skylark/app/data/models/login_response_model.dart';
import 'package:skylark/app/data/services/api_service.dart';
import 'package:skylark/app/data/services/storage_service.dart';
import 'package:skylark/app/routes/app_routes.dart';

class DashboardController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final ApiService _apiService = Get.find<ApiService>();
  
  var userData = Rxn<LoginData>();
  final RxList<LocationModel> locations = <LocationModel>[].obs;
  var selectedLocation = Rxn<LocationModel>();
  var isLoadingLocations = false.obs;
  var menuAccess = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    getUserData();
    getLocationMasterData();
    fetchMenuAccess();
  }

  void getUserData() {
    userData.value = _storageService.getUser();
  }

  Future<void> getLocationMasterData() async {
    try {
      isLoadingLocations.value = true;
      final userId = userData.value?.userId ?? "";
      final response = await _apiService.get(AppConstants.getLocationMasterDataUrl, queryParameters: {'UserID': userId});
      
      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data = [];
        if (response.data is List) {
          data = response.data;
        } else if (response.data['data'] is List) {
          data = response.data['data'];
        }
        
        locations.assignAll(data.map((e) => LocationModel.fromJson(e)).toList());
        
        if (locations.length == 1) {
          onLocationChanged(locations[0]);
        } else {
          final savedLocation = _storageService.getLocation();
          if (savedLocation != null) {
            final match = locations.firstWhereOrNull((loc) => loc.locCode == savedLocation.locCode);
            if (match != null) {
              selectedLocation.value = match;
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching locations: $e");
    } finally {
      isLoadingLocations.value = false;
    }
  }



  void onLocationChanged(LocationModel? value) {
    selectedLocation.value = value;
    if (value != null) {
      _storageService.saveLocation(value);
    }
  }

  Future<void> fetchMenuAccess() async {
    try {
      final userId = userData.value?.userId ?? "";
      if (userId.isNotEmpty) {
        final response = await _apiService.post(
          AppConstants.menuAccessUrl,
          data: {"userID": userId},
        );

        if (response.statusCode == 200 && response.data != null) {
          final List<dynamic> menuData = response.data['data'] ?? [];
          await _storageService.saveMenuAccess(menuData);
          menuAccess.assignAll(menuData);
        }
      }
    } catch (e) {
      print('Error fetching menu access: $e');
    }
  }

  bool hasMenuAccess(String menuName) {
    if (menuAccess.isEmpty) {
      final saved = _storageService.getMenuAccess();
      if (saved.isNotEmpty) {
        menuAccess.assignAll(saved);
      } else {
        return true;
      }
    }
    
    return menuAccess.any((element) {
      final String apiMenuName = (element['menuName'] ?? "").toString().toLowerCase().trim();
      final String targetMenuName = menuName.toLowerCase().trim();
      
      if (apiMenuName != targetMenuName) return false;
      
      final dynamic accessValue = element['hasAccess'];
      if (accessValue == null) return false;
      
      if (accessValue is bool) return accessValue;
      if (accessValue is String) {
        final val = accessValue.toLowerCase();
        return val == 'true' || val == '1' || val == 'y';
      }
      if (accessValue is int) return accessValue == 1;
      
      return false;
    });
  }

  void navigateToRoute(String route) {
    if (selectedLocation.value == null) {
      CustomSnackbar.show(
        title: 'Location Required',
        message: 'Please select a location first',
        backgroundColor: Colors.orange,
      );
    } else {
      Get.toNamed(route);
    }
  }

  void logout() async {
    await _storageService.clearStorage();
    Get.offAllNamed(AppRoutes.login);
  }

  void deleteAccount() async {
    final typedUsername = _storageService.getLastTypedUsername();
    final userId = typedUsername ?? userData.value?.userId;
    if (userId != null && userId.isNotEmpty) {
      await _storageService.deleteAccount(userId);
    }
    await _storageService.clearStorage();
    Get.offAllNamed(AppRoutes.login);
    CustomSnackbar.success(message: 'Your account has been deleted successfully.');
  }
}
