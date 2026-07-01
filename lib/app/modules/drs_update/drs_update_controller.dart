import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skylark/app/core/values/app_constants.dart';
import 'package:skylark/app/data/services/api_service.dart';
import 'package:skylark/app/data/services/storage_service.dart';
import 'package:skylark/app/routes/app_routes.dart';

class DrsUpdateController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  var isLoading = false.obs;
  final RxList<dynamic> drsList = <dynamic>[].obs;

  // Filter variables
  var fromDate = Rxn<DateTime>();
  var toDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    toDate.value = now;
    fromDate.value = now.subtract(const Duration(days: 7));
    
    fetchDrsList();
  }

  Future<void> fetchDrsList() async {
    try {
      isLoading.value = true;
      final user = _storageService.getUser();
      final location = _storageService.getLocation();

      final String fromDateStr = DateFormat('dd MMM yyyy').format(fromDate.value ?? DateTime.now().subtract(const Duration(days: 7)));
      final String toDateStr = DateFormat('dd MMM yyyy').format(toDate.value ?? DateTime.now());

      final body = {
        "baseLocationCode": location?.locCode ?? "",
        "dateFrom": fromDateStr,
        "dateTo": toDateStr,
        "baseCompanyCode": user?.baseCompanyCode ?? ""
      };

      final response = await _apiService.post(
        AppConstants.drsListUrl,
        data: body,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData['data'] != null && responseData['data'] is Map) {
          final dataMap = responseData['data'] as Map;
          if (dataMap['drsLists'] != null && dataMap['drsLists'] is List) {
            drsList.assignAll(dataMap['drsLists']);
          } else {
            drsList.clear();
          }
        } else if (responseData['data'] != null && responseData['data'] is List) {
          drsList.assignAll(responseData['data']);
        } else {
          drsList.clear();
        }
      }
    } catch (e) {
      debugPrint("Error fetching DRS list: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void onDrsSelected(Map<String, dynamic> drs) {
    Get.toNamed(AppRoutes.drsUpdateDetail, arguments: {'pdcno': drs['pdcno']});
  }
}
