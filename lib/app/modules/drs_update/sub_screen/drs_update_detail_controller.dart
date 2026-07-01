import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/values/app_constants.dart';
import 'package:skylark/app/data/models/drs_update_model.dart';
import 'package:skylark/app/data/services/api_service.dart';
import 'package:skylark/app/data/services/storage_service.dart';

import 'package:skylark/app/modules/drs_update/drs_update_controller.dart';

class DrsUpdateDetailController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  final formKey = GlobalKey<FormState>();

  var isLoading = false.obs;
  var drsHeaderData = Rxn<Map<String, dynamic>>();
  final RxList<Map<String, dynamic>> drsDetailList = <Map<String, dynamic>>[].obs;

  final RxList<dynamic> lateReasons = <dynamic>[].obs;
  final RxList<dynamic> undeliveredReasons = <dynamic>[].obs;

  final closeKmController = TextEditingController();

  final Map<int, TextEditingController> deliveredPkgsControllers = {};
  final Map<int, TextEditingController> remarkControllers = {};

  @override
  void onInit() {
    super.onInit();
    fetchReasons();
    if (Get.arguments != null && Get.arguments['pdcno'] != null) {
      fetchDrsDetails(Get.arguments['pdcno']);
    }
  }

  Future<void> fetchReasons() async {
    try {
      final lateRes = await _apiService.get("Master/GetGeneralMasterData", queryParameters: {"CodeType": "LATE_D"});
      if (lateRes.statusCode == 200 && lateRes.data['data'] != null) {
        lateReasons.assignAll(lateRes.data['data']);
      }

      final undelRes = await _apiService.get("Master/GetGeneralMasterData", queryParameters: {"CodeType": "UNDELY"});
      if (undelRes.statusCode == 200 && undelRes.data['data'] != null) {
        undeliveredReasons.assignAll(undelRes.data['data']);
      }
    } catch (e) {
      debugPrint("Error fetching reasons: $e");
    }
  }

  Future<void> fetchDrsDetails(String drsId) async {
    try {
      isLoading.value = true;
      final location = _storageService.getLocation();
      final body = {"drsId": drsId, "baseLocationCode": location?.locCode ?? ""};

      final response = await _apiService.post(AppConstants.updateDrsDetailsUrl, data: body);

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data['data'];
        if (responseData != null) {
          drsHeaderData.value = responseData;
          closeKmController.text = ((responseData['start_KM'] ?? 0) + 5).toString();
          
          if (responseData['drsDetail'] != null && responseData['drsDetail'] is List) {
            deliveredPkgsControllers.clear();
            remarkControllers.clear();
            final details = List<Map<String, dynamic>>.from(responseData['drsDetail']).map((e) {
              e['pkgsdelivered'] = e['pkgsdelivered'] ?? e['pkgs_Arrived'];
              e['remark'] = e['remark'] ?? "";
              e['hDcboReason'] = "";
              e['cboLateReason'] = ""; 
              e['isChecked'] = false;
              return e;
            }).toList();
            drsDetailList.assignAll(details);
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching DRS details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void updateDocketData(int index, {int? pkgs, String? remark, String? lateReason, String? undelReason, bool? isChecked}) {
    var detail = Map<String, dynamic>.from(drsDetailList[index]);
    final arrivedPkgs = (detail['pkgs_Arrived'] ?? 0) as int;

    if (pkgs != null) {
      int validatedPkgs = pkgs;
      if (validatedPkgs < 0) {
        validatedPkgs = 0;
      } else if (validatedPkgs > arrivedPkgs) {
        validatedPkgs = arrivedPkgs;
      }
      
      detail['pkgsdelivered'] = validatedPkgs;
      
      final controller = deliveredPkgsControllers[index];
      if (controller != null && controller.text != validatedPkgs.toString()) {
        controller.text = validatedPkgs.toString();
        controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
      }
    }

    if (remark != null) detail['remark'] = remark;
    if (lateReason != null) detail['hDcboReason'] = lateReason;
    if (undelReason != null) detail['cboLateReason'] = undelReason;
    if (isChecked != null) detail['isChecked'] = isChecked;
    drsDetailList[index] = detail;
  }

  TextEditingController getDeliveredPkgsController(int index, String initialValue) {
    return deliveredPkgsControllers.putIfAbsent(index, () => TextEditingController(text: initialValue));
  }

  TextEditingController getRemarkController(int index, String initialValue) {
    return remarkControllers.putIfAbsent(index, () => TextEditingController(text: initialValue));
  }

  Future<void> submitUpdate() async {
    final selectedDockets = drsDetailList.where((e) => e['isChecked'] == true).toList();
    
    if (selectedDockets.isEmpty) {
      Get.snackbar("Error", "Please select at least one docket", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;
      final header = drsHeaderData.value;
      final user = _storageService.getUser();

      final drsSummary = DrsUpdateSummary(
        pdcno: header!['pdcno'],
        pdCDt: _formatDate(header['pdC_Dt']),
        deliveryBy: header['deliveryBy'] ?? "",
        bAVendorCode: header['bA_Vendor_Code'] ?? "",
        staff: header['staff'] ?? "",
        driverName: header['driverName'] ?? ".",
        vehno: header['vehno'] ?? "",
        startKm: (header['start_KM'] ?? 0).toDouble(),
        totalDocketsInDrs: (header['total_Dockets_In_DRS'] ?? 0).toInt(),
        closeKm: double.tryParse(closeKmController.text) ?? 0,
        pdCUpdated: "Yes",
        fromDate: _formatDate(header['pdC_Dt']),
        toDate: _formatDate(header['pdC_Dt']),
        drsNoList: header['pdcno'],
        dockno: selectedDockets[0]['dockno'],
        dockdt: _formatDate(selectedDockets[0]['booking_Date']),
        drs: header['pdcno'],
        drSDt: _formatDate(header['pdC_Dt']),
        autoNo: (header['autoNo'] ?? 0).toInt(),
        loadingBy: "",
        rateType: "0",
        loadingCharge: 0,
        rate: 0,
        maxLimit: 0,
        vendorCode: (header['bA_Vendor_Code'] ?? "").toString().split(':').first.trim(),
        vendorName: header['bA_Vendor_Code'] ?? "",
        isMonthly: false,
        hdnRate: 0,
        isMathadi: false,
        mathadiSlipNo: "",
        mathadiDate: "",
        mathadiAmt: 0,
        pkgsno: (header['pkgsno'] ?? 0).toInt(),
        actuwt: 0,
        drsDate: _formatDate(header['pdC_Dt']),
        frtAmt: 0,
        othAmt: 0,
        finAmt: 0,
      );

      final updateDRSLits = selectedDockets.map((item) {
        return DrsUpdateDetail(
          autoNo: (item['autoNo'] ?? 0).toInt(),
          dockno: item['dockno'],
          docksf: item['docksf'] ?? ".",
          bookingDate: _formatDate(item['booking_Date']),
          orgncd: item['orgncd'],
          destcd: item['destcd'],
          payBasis: item['payBasis'],
          csgncd: item['csgncd'],
          csgnnm: item['csgnnm'],
          csgecd: item['csgecd'],
          csgenm: item['csgenm'],
          pkgsArrived: (item['pkgs_Arrived'] ?? 0).toInt(),
          pkgsBooked: (item['pkgs_Booked'] ?? 0).toInt(),
          pkgsPending: (item['pkgs_Pending'] ?? 0).toInt(),
          bookedWt: (item['booked_Wt'] ?? 0).toDouble(),
          wtArrived: (item['wt_Arrived'] ?? 0).toDouble(),
          commDelyDt: _formatDate(item['comm_Dely_Dt']),
          freight: (item['freight'] ?? 0).toDouble(),
          docketTotal: (item['docket_Total'] ?? 0).toDouble(),
          serviceTax: (item['service_Tax'] ?? 0).toDouble(),
          delyLocation: item['delyLocation'] ?? "",
          currLoc: item['curr_loc'] ?? "",
          payBasCode: item['payBasCode'] ?? "",
          dockDt: _formatDate(item['dockDt']),
          coDDod: item['coD_DOD'] ?? "N",
          coddodAmount: (item['coddodAmount'] ?? 0).toDouble(),
          cdeldTDdmmyyyy: item['cdeldT_ddmmyyyy'] ?? "",
          dockDtDdmmyyyy: item['dockDt_ddmmyyyy'] ?? "",
          dlypdcno: item['dlypdcno'] ?? "",
          coddod: item['coddod'] ?? false,
          pkgsdelivered: item['pkgsdelivered'],
          remark: item['remark'],
          otp: item['otp'] ?? "",
          delydate: _formatDate(DateTime.now()),
          delytime: DateFormat('HH:mm').format(DateTime.now()),
          delyperson: user?.userId ?? "",
          cboReason: "",
          coddodcollected: 0,
          coddodno: 0,
          cboLateReason: item['cboLateReason'],
          hDcboReason: item['hDcboReason'],
          isChecked: true,
          pkgQty: (item['pkgQty'] ?? 0).toInt(),
          actQty: (item['actQty'] ?? 0).toInt(),
          rate: 0,
          maxLimit: 0,
          newRate: 0,
          ratetype: "",
          isEnabled: true,
          isEnabledBadPodoption: true,
          backPod: "",
          frontPod: "",
        );
      }).toList();

      final requestBody = DrsUpdateRequestModel(
        drsSummary: drsSummary,
        updateDRSLits: updateDRSLits,
        loadingCharge: 0,
        baseUserName: user?.userId ?? "",
      );

      final response = await _apiService.post(AppConstants.updateDrsUrl, data: requestBody.toJson());

      if (response.statusCode == 200 && response.data?['status'] == 200) {
        _showSuccessDialog();
      } else {
        Get.snackbar("Error", response.data?['message'] ?? "Failed to update DRS");
      }
    } catch (e) {
      debugPrint("Error submitting DRS update: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 60),
              ),
              const SizedBox(height: 20),
              const Text('Success!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
              const SizedBox(height: 12),
              const Text('DRS Updated successfully', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () { 
                    Get.back(); 
                    Get.back(); 
                    if (Get.isRegistered<DrsUpdateController>()) {
                      Get.find<DrsUpdateController>().fetchDrsList();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    closeKmController.dispose();
    for (var c in deliveredPkgsControllers.values) {
      c.dispose();
    }
    for (var c in remarkControllers.values) {
      c.dispose();
    }
    super.onClose();
  }

  String _formatDate(dynamic date) {
    if (date == null) return "";
    try {
      if (date is DateTime) {
        return DateFormat('dd MMMM yyyy').format(date);
      }
      String dateStr = date.toString();
      if (dateStr.isEmpty) return "";

      DateTime? dt = DateTime.tryParse(dateStr);
      if (dt == null) {
        try {
          dt = DateFormat("dd MMM yyyy").parse(dateStr);
        } catch (_) {
          try {
            dt = DateFormat("dd-MMM-yyyy").parse(dateStr);
          } catch (_) {
             try {
               dt = DateFormat("dd MMMM yyyy").parse(dateStr);
             } catch(_) {}
          }
        }
      }

      if (dt != null) {
        return DateFormat('dd MMMM yyyy').format(dt);
      }
      return dateStr;
    } catch (e) {
      return date.toString();
    }
  }
}
