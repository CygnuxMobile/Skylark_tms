import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:skylark/app/core/values/app_constants.dart';
import 'package:skylark/app/core/widgets/custom_snackbar.dart';
import 'package:skylark/app/data/models/customer_model.dart';
import 'package:skylark/app/data/models/pincode_model.dart';
import 'package:skylark/app/data/models/from_pincode_details_model.dart';
import 'package:skylark/app/data/models/to_pincode_details_model.dart';
import 'package:skylark/app/data/models/contract_freight_request_model.dart';
import 'package:skylark/app/data/models/docket_submit_request_model.dart';
import 'package:skylark/app/data/services/api_service.dart';
import 'package:skylark/app/data/services/storage_service.dart';

import '../../core/values/app_colors.dart';

class BookingController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final formKey = GlobalKey<FormState>();

  final cnoteController = TextEditingController();
  final ewayBillController = TextEditingController();
  final customerNameController = TextEditingController();
  final originPinController = TextEditingController();
  final destPinController = TextEditingController();
  final consignorController = TextEditingController();
  final consigneeController = TextEditingController();
  final pkgsController = TextEditingController();
  final aWeightController = TextEditingController();
  final invNoController = TextEditingController();
  final invValueController = TextEditingController();
  final ewayBillExpiryController = TextEditingController();
  final ewayBillInvDateController = TextEditingController();
  final invDateController = TextEditingController();
  final cubicWeightController = TextEditingController();
  final pieceController = TextEditingController();

  final walkInNameController = TextEditingController();
  final walkInAddressController = TextEditingController();
  final walkInCityController = TextEditingController();
  final walkInPincodeController = TextEditingController();

  final cnoteFocus = FocusNode();
  final ewayBillFocus = FocusNode();
  final customerFocus = FocusNode();
  final originFocus = FocusNode();
  final destFocus = FocusNode();
  final consigneeFocus = FocusNode();
  final pkgsFocus = FocusNode();
  final aWeightFocus = FocusNode();
  final invNoFocus = FocusNode();
  final invValueFocus = FocusNode();
  final ewayBillExpiryFocus = FocusNode();
  final ewayBillInvDateFocus = FocusNode();
  final invDateFocus = FocusNode();
  final cubicWeightFocus = FocusNode();
  final pieceFocus = FocusNode();
  final lengthFocus = FocusNode();
  final breadthFocus = FocusNode();
  final heightFocus = FocusNode();

  final walkInNameFocus = FocusNode();
  final walkInAddressFocus = FocusNode();
  final walkInCityFocus = FocusNode();
  final walkInPincodeFocus = FocusNode();

  final RxList<Map<String, dynamic>> dimensionsList = <Map<String, dynamic>>[].obs;

  final lengthController = TextEditingController();
  final breadthController = TextEditingController();
  final heightController = TextEditingController();

  var selectedCustomer = Rxn<CustomerModel>();
  var customers = <CustomerModel>[].obs;
  var isLoadingCustomers = false.obs;
  var customerErrorMessage = ''.obs;

  var locations = <PincodeModel>[].obs;
  var fromLocations = <PincodeModel>[].obs;
  var isLoadingLocations = false.obs;
  var isLoadingFromPincodes = false.obs;
  var selectedOrigin = Rxn<PincodeModel>();
  var selectedDest = Rxn<PincodeModel>();
  var selectedOriginDetails = Rxn<FromPincodeDetailsModel>();
  var selectedDestDetails = Rxn<ToPincodeDetailsModel>();

  String _lastFetchedOriginPin = "";
  String _lastFetchedDestPin = "";

  var consignees = <CustomerModel>[].obs;
  var isLoadingConsignees = false.obs;
  var selectedConsignee = Rxn<CustomerModel>();
  var consigneeType = 'Master'.obs; // 'Master' or 'Walk-In'

  var transportModes = <Map<String, dynamic>>[].obs;
  var selectedTransportMode = Rxn<Map<String, dynamic>>();
  var isLoadingTransportModes = false.obs;

  var isLoadingEwayBill = false.obs;
  var ewayBillErrorMessage = ''.obs;
  var isLoadingFreight = false.obs;
  var isLoadingBooking = false.obs;
  var freightErrorMessage = ''.obs;
  var isFieldsReadOnly = false.obs;
  var showDimensions = true.obs;
  var freightData = <String, dynamic>{}.obs;

  var isEwayBillRequired = false.obs;
  var isValidatingCnote = false.obs;
  var isCnoteValid = true.obs;
  var isEwayBillWise = false.obs;
  var cnoteValidationMessage = "".obs;
  var isZeroFreightSubmit = false.obs;
  var pkgsCount = 0.obs;
  var addedEwayBills = <String>[].obs;
  var addedEwayBillDetails = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    ewayBillController.addListener(_onEwayBillChanged);
    cnoteController.addListener(_onCnoteChanged);
    originPinController.addListener(_onPinChanged);
    destPinController.addListener(_onPinChanged);
    invValueController.addListener(_onInvValueChanged);
    pkgsController.addListener(_validatePieceCount);
    lengthController.addListener(_onDimensionFieldChanged);
    breadthController.addListener(_onDimensionFieldChanged);
    heightController.addListener(_onDimensionFieldChanged);
    pieceController.addListener(_onDimensionFieldChanged);

    ever(selectedCustomer, (value) {
      if (value != null) {
        consignorController.text = "${value.custCode ?? ''} - ${value.custName ?? ''}";
        fetchTransportModes(value.custCode ?? '');
      } else {
        transportModes.clear();
        selectedTransportMode.value = null;
      }
    });

    ever(isEwayBillWise, (bool value) {
      if (!value) {
        addedEwayBills.clear();
        addedEwayBillDetails.clear();
        isFieldsReadOnly.value = false;
        invNoController.clear();
        invValueController.clear();
        pkgsController.clear();
        aWeightController.clear();
        
        // Restore consignor if customer is selected
        if (selectedCustomer.value != null) {
          consignorController.text = "${selectedCustomer.value?.custCode ?? ''} - ${selectedCustomer.value?.custName ?? ''}";
        } else {
          consignorController.clear();
        }
        
        consigneeController.clear();
        selectedConsignee.value = null;
      }
    });

    ever(consigneeType, (value) {
      freightErrorMessage.value = '';
      if (value == 'Walk-In' && destPinController.text.isNotEmpty) {
        walkInPincodeController.text = destPinController.text;
      }
    });

    fetchCustomers();
    fetchFromPincodes();
    fetchZeroFreightRule();

    debounce(_dummyRx, (String val) {
      if (val.isNotEmpty) {
        validateDocketSeries(val);
      }
    }, time: 300.milliseconds);
  }

  Future<void> fetchZeroFreightRule() async {
    try {
      final response = await _apiService.get(
        AppConstants.getModuleRulesDataUrl,
        queryParameters: {'CodeType': 'ISZEROFREIGHTSUBMIT'},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        if (data.isNotEmpty) {
          final rule = data[0];
          isZeroFreightSubmit.value = rule['rulE_Y_N'] == 'Y';
        }
      }
    } catch (e) {
      print('Error fetching zero freight rule: $e');
    }
  }

  Future<void> fetchTransportModes(String custCode) async {
    try {
      isLoadingTransportModes.value = true;
      final response = await _apiService.get(
        AppConstants.getTransportModeUrl,
        queryParameters: {
          'Custcode': custCode,
          'Paybas': 'P02',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data = [];
        if (response.data is List) {
          data = response.data;
        } else if (response.data['data'] is List) {
          data = response.data['data'];
        }
        transportModes.assignAll(data.map((e) => Map<String, dynamic>.from(e)).toList());
        
        // Auto-select first if available
        if (transportModes.isNotEmpty) {
          selectedTransportMode.value = transportModes[0];
        }
      }
    } catch (e) {
      print('Error fetching transport modes: $e');
    } finally {
      isLoadingTransportModes.value = false;
    }
  }

  Future<void> fetchPincodes(String query) async {
    try {
      isLoadingLocations.value = true;

      final response = await _apiService.get(
        AppConstants.getPincodeUrl,
        queryParameters: {'search': query.isEmpty ? '%%%' : query},
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data = [];
        if (response.data is List) {
          data = response.data;
        } else if (response.data['data'] is List) {
          data = response.data['data'];
        }
        locations.assignAll(data.map((e) => PincodeModel.fromJson(e)).toList());
      }
    } catch (e) {
      print('Error fetching pincodes: $e');
    } finally {
      isLoadingLocations.value = false;
    }
  }

  Future<void> fetchFromPincodes() async {
    try {
      isLoadingFromPincodes.value = true;
      final storageService = Get.find<StorageService>();
      final location = storageService.getLocation();
      final locCode = location?.locCode ?? '';

      if (locCode.isEmpty) {
        fromLocations.clear();
        return;
      }

      final response = await _apiService.get(
        AppConstants.getFromPincodeUrl,
        queryParameters: {'ORGNCD': locCode},
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data = [];
        if (response.data is List) {
          data = response.data;
        } else if (response.data['data'] is List) {
          data = response.data['data'];
        }
        fromLocations.assignAll(data.map((e) => PincodeModel.fromJson(e)).toList());
      }
    } catch (e) {
      print('Error fetching from pincodes: $e');
    } finally {
      isLoadingFromPincodes.value = false;
    }
  }

  Future<void> fetchPincodesForOrigin(String query) async {
    try {
      isLoadingFromPincodes.value = true;

      final response = await _apiService.get(
        AppConstants.getPincodeUrl,
        queryParameters: {'search': query.isEmpty ? '%%%' : query},
      );

      if (response.statusCode == 200 && response.data != null) {
        List<dynamic> data = [];
        if (response.data is List) {
          data = response.data;
        } else if (response.data['data'] is List) {
          data = response.data['data'];
        }
        fromLocations.assignAll(data.map((e) => PincodeModel.fromJson(e)).toList());
      }
    } catch (e) {
      print('Error searching origin pincodes: $e');
    } finally {
      isLoadingFromPincodes.value = false;
    }
  }

  Future<void> fetchConsignees() async {
    try {
      isLoadingConsignees.value = true;
      final response = await _apiService.get(
        AppConstants.getCustomerListUrl,
        queryParameters: {
          'Search': '%',
          'Location': '%',
          'Paybas': 'P02',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData['data'] != null && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          consignees.assignAll(data.map((json) => CustomerModel.fromJson(json)).toList());
        }
      }
    } catch (e) {
      print('Error fetching consignees: $e');
    } finally {
      isLoadingConsignees.value = false;
    }
  }

  Future<void> fetchCustomers() async {
    try {
      isLoadingCustomers.value = true;
      final storageService = Get.find<StorageService>();
      final location = storageService.getLocation();
      final locCode = location?.locCode ?? '';

      if (locCode.isEmpty) {
        CustomSnackbar.show(
          title: 'Location Required',
          message: 'Please select a location from the dashboard first.',
          backgroundColor: Colors.orange,
        );
        customers.clear();
        return;
      }

      final response = await _apiService.get(
        AppConstants.getCustomerListUrl,
        queryParameters: {
          'Search': '%',
          'Location': locCode,
          'Paybas': 'P02',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;
        if (responseData['data'] == null || (responseData['data'] is List && (responseData['data'] as List).isEmpty)) {
          customers.clear();
          customerErrorMessage.value = "No customers found for this location";
        } else {
          customerErrorMessage.value = '';
          final List<dynamic> data = responseData['data'];
          customers.assignAll(data.map((json) => CustomerModel.fromJson(json)).toList());
        }
      }
    } catch (e) {
      print('Error fetching customers: $e');
      customers.clear();
    } finally {
      isLoadingCustomers.value = false;
    }
  }

  void _onEwayBillChanged() {
    if (ewayBillController.text.length == 12) {
      getEwayBillDetails(ewayBillController.text);
    } else {
      ewayBillErrorMessage.value = '';
    }
  }

  void _onCnoteChanged() {
    final text = cnoteController.text.trim();
    if (text.isEmpty) {
      isCnoteValid.value = true;
      cnoteValidationMessage.value = "";
      isValidatingCnote.value = false;
    }
    _dummyRx.value = text;
  }

  final _dummyRx = "".obs;

  Future<void> validateDocketSeries(String docketNo) async {
    try {
      isValidatingCnote.value = true;
      final storageService = Get.find<StorageService>();
      final user = storageService.getUser();
      final location = storageService.getLocation();

      final response = await _apiService.get(
        AppConstants.validateDocketSeriesUrl,
        queryParameters: {
          'DocketNo': docketNo,
          'LocCode': location?.locCode ?? "",
          'UserId': user?.userId ?? "",
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        if (data.isNotEmpty) {
          final result = data[0];
          final String codeId = result['codeId']?.toString() ?? "0";
          final String codeDesc = result['codeDesc']?.toString() ?? "";

          if (codeId == "1") {
            isCnoteValid.value = true;
            cnoteValidationMessage.value = "Valid Series";
          } else {
            isCnoteValid.value = false;
            cnoteValidationMessage.value = codeDesc.isNotEmpty ? codeDesc : "Invalid Series";
          }
        }
      }
    } catch (e) {
      print('Error validating docket series: $e');
    } finally {
      isValidatingCnote.value = false;
    }
  }

  Future<void> getEwayBillDetails(String ewayBillNo) async {
    if (addedEwayBills.contains(ewayBillNo)) {
      CustomSnackbar.show(
        title: 'Already Added',
        message: 'This E-way bill is already in the list.',
        backgroundColor: Colors.orange,
      );
      return;
    }

    try {
      isLoadingEwayBill.value = true;
      isFieldsReadOnly.value = false;
      ewayBillErrorMessage.value = '';

      final response = await _apiService.post(
        AppConstants.getEwayBillDetailsUrl,
        data: {
          'lsno': ewayBillNo,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        var details = data;
        if (data is Map && data.containsKey('data')) {
          details = data['data'];
        }

        if (details != null && details is Map) {
          if (details['status'] == 1 || details['message'] == 'Party not Exist') {
            final originPin = (details['pincode'] == 0 || details['pincode'] == "0") ? '' : details['pincode']?.toString() ?? '';
            final destPin = (details['toPincode'] == 0 || details['toPincode'] == "0") ? '' : details['toPincode']?.toString() ?? '';

            if (!isEwayBillWise.value) {
              addedEwayBills.clear();
              addedEwayBillDetails.clear();
            }

            // If it's the first E-way bill, set the basic details
            if (addedEwayBills.isEmpty) {
              if (originPin.isNotEmpty) {
                originPinController.text = originPin;
                onOriginSelected(fromLocations.firstWhereOrNull((l) => l.pincode == originPin) ?? PincodeModel(pincode: originPin));
              }
              
              if (destPin.isNotEmpty) {
                destPinController.text = destPin;
                onDestSelected(locations.firstWhereOrNull((l) => l.pincode == destPin) ?? PincodeModel(pincode: destPin));
              }

              final consignorName = details['csgnm']?.toString() ?? '';
              consignorController.text = consignorName;
              
              if (customers.isNotEmpty && consignorName.isNotEmpty) {
                final match = customers.firstWhereOrNull(
                  (c) => c.custName?.toLowerCase() == consignorName.toLowerCase()
                );
                if (match != null) {
                  selectedCustomer.value = match;
                }
              }

              final consigneeName = details['csgenm']?.toString() ?? '';
              consigneeController.text = consigneeName;
              
              // Set Dates
              ewayBillExpiryController.text = details['eWayBillExpiredDate']?.toString() ?? '';
              ewayBillInvDateController.text = details['eWayBillInvoiceDate']?.toString() ?? '';

              if (consigneeName.isNotEmpty) {
                final match = consignees.firstWhereOrNull(
                  (c) => c.custName?.toLowerCase() == consigneeName.toLowerCase()
                );
                if (match != null) {
                  selectedConsignee.value = match;
                  consigneeType.value = 'Master';
                } else {
                  consigneeType.value = 'Walk-In';
                  walkInNameController.text = consigneeName;
                  walkInAddressController.text = details['csgeaddr']?.toString() ?? details['csgeAddress']?.toString() ?? '';
                  walkInCityController.text = details['csgecity']?.toString() ?? details['csgeCity']?.toString() ?? '';
                  walkInPincodeController.text = destPin;
                }
              }
            }

            addedEwayBills.add(ewayBillNo);
            addedEwayBillDetails.add(Map<String, dynamic>.from(details));
            if (isEwayBillWise.value) {
              ewayBillController.clear();
            }

            // Recalculate totals and auto-fill controllers
            _calculateEwayBillTotals();
            
            isFieldsReadOnly.value = true;

            CustomSnackbar.success(
              title: 'Success',
              message: details['message'] == 'Party not Exist' ? 'E-way bill added (Party not found)' : 'E-way bill added successfully',
            );
          } else {
            ewayBillErrorMessage.value = details['message'] ?? 'Invalid E-way bill details';
            CustomSnackbar.show(
              title: 'Error',
              message: ewayBillErrorMessage.value,
              backgroundColor: Colors.orange,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        } else {
          ewayBillErrorMessage.value = 'No details found for this E-way bill number';
          CustomSnackbar.show(
            title: 'Invalid E-way Bill',
            message: ewayBillErrorMessage.value,
            backgroundColor: Colors.orange,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        ewayBillErrorMessage.value = 'Something went wrong. Please try again.';
        CustomSnackbar.error(
          title: 'Error',
          message: ewayBillErrorMessage.value,
        );
      }
    } catch (e) {
      CustomSnackbar.error(
        title: 'Connection Error',
        message: 'Failed to fetch E-way bill details',
      );
    } finally {
      isLoadingEwayBill.value = false;
    }
  }

  void _calculateEwayBillTotals() {
    if (addedEwayBillDetails.isEmpty) {
      isFieldsReadOnly.value = false;
      return;
    }

    List<String> invNos = [];
    List<String> invValues = [];
    int totalPkgs = 0;
    double totalWeight = 0;

    for (var detail in addedEwayBillDetails) {
      // Get Invoice Number and Value from Eway Bill details
      String invNo = detail['invno']?.toString() ?? '';
      String invValue = detail['eWayInvoicevalue']?.toString() ?? '0';
      
      if (invNo.isNotEmpty) invNos.add(invNo);
      if (invValue.isNotEmpty) invValues.add(invValue);
      
      totalPkgs += int.tryParse(detail['totalQty']?.toString() ?? '0') ?? 0;
      totalWeight += double.tryParse(detail['totalWeight']?.toString() ?? '0.0') ?? 0.0;
    }

    invNoController.text = invNos.join(',');
    invValueController.text = invValues.join(',');
    pkgsController.text = totalPkgs.toString();
    aWeightController.text = totalWeight.toStringAsFixed(2);
    
    isFieldsReadOnly.value = true;
    _onInvValueChanged();
  }

  void removeEwayBill(int index) {
    addedEwayBills.removeAt(index);
    addedEwayBillDetails.removeAt(index);
    if (addedEwayBills.isEmpty) {
      isFieldsReadOnly.value = false;
      invValueController.text = '';
      pkgsController.text = '';
      aWeightController.text = '';
      invNoController.text = '';
      consignorController.text = '';
      consigneeController.text = '';
    } else {
      _calculateEwayBillTotals();
    }
  }

  void _onPinChanged() {
    final originPin = originPinController.text.trim();
    final destPin = destPinController.text.trim();

    if (originPin.length == 6) {
      fetchFromPincodeDetails(originPin);
    }
    if (destPin.length == 6) {
      fetchToPincodeDetails(destPin);
      fetchConsigneesByPincode(destPin);
      if (consigneeType.value == 'Walk-In') {
        walkInPincodeController.text = destPin;
      }
    }
  }

  void _onInvValueChanged() {
    String text = invValueController.text;
    double total = 0;
    if (text.contains(',')) {
      total = text.split(',').map((e) => double.tryParse(e.trim()) ?? 0.0).fold(0, (a, b) => a + b);
    } else {
      total = double.tryParse(text) ?? 0;
    }
    isEwayBillRequired.value = total > 50000;
  }

  void _validatePieceCount() {
    pkgsCount.value = int.tryParse(pkgsController.text) ?? 0;
  }

  void _onDimensionFieldChanged() {
    final lText = lengthController.text.trim();
    final bText = breadthController.text.trim();
    final hText = heightController.text.trim();
    final pText = pieceController.text.trim();

    if (lText.isEmpty || bText.isEmpty || hText.isEmpty || pText.isEmpty) return;

    final l = double.tryParse(lText) ?? 0;
    final b = double.tryParse(bText) ?? 0;
    final h = double.tryParse(hText) ?? 0;
    final p = int.tryParse(pText) ?? 0;

    final totalPkgs = pkgsCount.value;
    if (totalPkgs == 0) return;

    int currentPcs = 0;
    for (var dim in dimensionsList) {
      currentPcs += dim['pieces'] as int? ?? 0;
    }

    if (l > 0 && b > 0 && h > 0 && p > 0) {
      if (currentPcs + p == totalPkgs) {
        addDimension(l, b, h, p);
      }
    }
  }

  void _calculateCubicWeight() {
    double totalCubicWeight = 0;
    for (var dim in dimensionsList) {
      final l = dim['voL_L'] as double? ?? 0;
      final b = dim['voL_B'] as double? ?? 0;
      final h = dim['voL_H'] as double? ?? 0;
      final p = dim['pieces'] as int? ?? 0;
      // Typical formula: (L * B * H) / 172.8 * Pieces (or as per company rule)
      // Assuming factor 172.8 for now, can be changed if specified
      totalCubicWeight += (l * b * h * p) / 172.8;
    }
    cubicWeightController.text = totalCubicWeight.toStringAsFixed(2);
  }

  @override
  void onClose() {
    cnoteController.dispose();
    ewayBillController.dispose();
    customerNameController.dispose();
    originPinController.dispose();
    destPinController.dispose();
    consignorController.dispose();
    consigneeController.dispose();
    pkgsController.dispose();
    aWeightController.dispose();
    invNoController.dispose();
    invValueController.dispose();
    ewayBillExpiryController.dispose();
    ewayBillInvDateController.dispose();
    invDateController.dispose();
    cubicWeightController.dispose();
    pieceController.dispose();
    lengthController.dispose();
    breadthController.dispose();
    heightController.dispose();

    walkInNameController.dispose();
    walkInAddressController.dispose();
    walkInCityController.dispose();
    walkInPincodeController.dispose();

    cnoteFocus.dispose();
    ewayBillFocus.dispose();
    customerFocus.dispose();
    originFocus.dispose();
    destFocus.dispose();
    consigneeFocus.dispose();
    pkgsFocus.dispose();
    aWeightFocus.dispose();
    invNoFocus.dispose();
    invValueFocus.dispose();
    ewayBillExpiryFocus.dispose();
    ewayBillInvDateFocus.dispose();
    invDateFocus.dispose();
    cubicWeightFocus.dispose();
    pieceFocus.dispose();
    lengthFocus.dispose();
    breadthFocus.dispose();
    heightFocus.dispose();

    walkInNameFocus.dispose();
    walkInAddressFocus.dispose();
    walkInCityFocus.dispose();
    walkInPincodeFocus.dispose();
    super.onClose();
  }

  void submitBooking() async {
    if (formKey.currentState!.validate()) {
      if (isEwayBillWise.value && addedEwayBills.isNotEmpty) {
        final valCount = invValueController.text.split(',').where((s) => s.trim().isNotEmpty).length;
        final noCount = invNoController.text.split(',').where((s) => s.trim().isNotEmpty).length;
        
        if (valCount != addedEwayBills.length || noCount != addedEwayBills.length) {
          Get.snackbar(
            "Warning", 
            "The number of Invoice Values/Numbers doesn't match the number of E-way bills (${addedEwayBills.length})",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM
          );
          return;
        }
      }

      if (cnoteController.text.isNotEmpty && !isCnoteValid.value) {
        cnoteFocus.requestFocus();
        CustomSnackbar.error(
          title: 'Cnote Error',
          message: cnoteValidationMessage.value.isNotEmpty ? cnoteValidationMessage.value : 'Invalid Cnote Series',
        );
        return;
      }

      if (dimensionsList.isEmpty) {
        CustomSnackbar.error(
          title: 'Dimension Error',
          message: 'Please add at least one dimension entry',
        );
        showDimensions.value = true;
        lengthFocus.requestFocus();
        return;
      }

      final int totalPkgs = int.tryParse(pkgsController.text) ?? 0;
      final int totalDimPieces = dimensionsList.fold(0, (sum, item) => sum + (item['pieces'] as int? ?? 0));
      if (totalDimPieces != totalPkgs) {
        CustomSnackbar.error(
          title: 'Dimension Error',
          message: 'Total pieces in dimensions ($totalDimPieces) must equal total PKGS ($totalPkgs)',
        );
        return;
      }

      if (ewayBillErrorMessage.value.isNotEmpty) {
        ewayBillFocus.requestFocus();
        CustomSnackbar.error(
          title: 'E-way Bill Error',
          message: ewayBillErrorMessage.value,
        );
        return;
      }

      if (consigneeType.value == 'Walk-In') {
        freightErrorMessage.value = '';
        freightData.clear();
        await docketSubmit();
      } else {
        await fetchContractFreight();
        if (freightErrorMessage.value.isNotEmpty) {
          invNoFocus.requestFocus();
        } else {
          await docketSubmit();
        }
      }
    } else {
      if (selectedCustomer.value == null) {
        customerFocus.requestFocus();
      } else if (selectedOrigin.value == null) {
        originFocus.requestFocus();
      } else if (selectedDest.value == null) {
        destFocus.requestFocus();
      } else if (selectedConsignee.value == null && consigneeType.value == 'Master') {
        consigneeFocus.requestFocus();
      } else if (consigneeType.value == 'Walk-In' && walkInNameController.text.isEmpty) {
        walkInNameFocus.requestFocus();
      } else if (consigneeType.value == 'Walk-In' && walkInPincodeController.text.length != 6) {
        walkInPincodeFocus.requestFocus();
      } else if (pkgsController.text.isEmpty) {
        pkgsFocus.requestFocus();
      } else if (aWeightController.text.isEmpty) {
        aWeightFocus.requestFocus();
      } else if (invNoController.text.isEmpty) {
        invNoFocus.requestFocus();
      } else if (invValueController.text.isEmpty) {
        invValueFocus.requestFocus();
      }
    }
  }

  void toggleDimensions() {
    showDimensions.value = !showDimensions.value;
  }

  void editEwayBill() {
    isFieldsReadOnly.value = false;
    if (!isEwayBillWise.value) {
      addedEwayBills.clear();
      addedEwayBillDetails.clear();
    }
  }

  void addDimension(double l, double b, double h, int pieces) {
    final int totalPkgs = int.tryParse(pkgsController.text) ?? 0;
    if (totalPkgs == 0) {
      CustomSnackbar.show(
        title: 'PKGS Required',
        message: 'Please enter total PKGS first',
        backgroundColor: Colors.orange,
      );
      pkgsFocus.requestFocus();
      return;
    }

    final int currentTotalPieces = dimensionsList.fold(0, (sum, item) => sum + (item['pieces'] as int? ?? 0));
    if (currentTotalPieces + pieces > totalPkgs) {
      CustomSnackbar.show(
        title: 'Validation Error',
        message: 'Total pieces cannot exceed PKGS ($totalPkgs). Remaining: ${totalPkgs - currentTotalPieces}',
        backgroundColor: Colors.orange,
      );
      return;
    }

    dimensionsList.add(<String, dynamic>{
      "voL_L": l,
      "voL_B": b,
      "voL_H": h,
      "pieces": pieces,
    });
    lengthController.clear();
    breadthController.clear();
    heightController.clear();
    pieceController.clear();
    _calculateCubicWeight();
    lengthFocus.requestFocus();
  }

  void removeDimension(int index) {
    dimensionsList.removeAt(index);
    _calculateCubicWeight();
  }

  void onOriginSelected(PincodeModel? value) {
    if (value != null && value.pincode == destPinController.text) {
      Future.delayed(const Duration(milliseconds: 300), () {
        CustomSnackbar.show(
          title: 'Selection Error',
          message: 'Origin and Destination pincode cannot be same',
          backgroundColor: Colors.redAccent,
          snackPosition: SnackPosition.BOTTOM,
        );
      });
      return;
    }
    selectedOrigin.value = value;
    if (value != null) {
      originPinController.text = value.pincode ?? '';
      fetchFromPincodeDetails(value.pincode ?? '');
      fetchFromPincodeDetails(value.pincode ?? '');
    }
  }

  Future<void> fetchFromPincodeDetails(String pincode) async {
    if (pincode.length != 6 || pincode == _lastFetchedOriginPin) return;
    try {
      final response = await _apiService.get(
        AppConstants.getFromPincodeDetailsUrl,
        queryParameters: {'FromPincode': pincode},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        if (data.isNotEmpty) {
          _lastFetchedOriginPin = pincode;
          selectedOriginDetails.value = FromPincodeDetailsModel.fromJson(data[0]);
          print('Origin Details Saved: ${selectedOriginDetails.value?.fromCity}');
        }
      }
    } catch (e) {
      print('Error fetching from pincode details: $e');
    }
  }

  void onDestSelected(PincodeModel? value) {
    if (value != null && value.pincode == originPinController.text) {
      Future.delayed(const Duration(milliseconds: 300), () {
        CustomSnackbar.show(
          title: 'Selection Error',
          message: 'Origin and Destination pincode cannot be same',
          backgroundColor: Colors.redAccent,
          snackPosition: SnackPosition.BOTTOM,
        );
      });
      return;
    }
    selectedDest.value = value;
    if (value != null) {
      destPinController.text = value.pincode ?? '';
      fetchToPincodeDetails(value.pincode ?? '');
      fetchConsigneesByPincode(value.pincode ?? '');
      if (consigneeType.value == 'Walk-In') {
        walkInPincodeController.text = value.pincode ?? '';
      }
    }
  }

  Future<void> fetchConsigneesByPincode(String pincode) async {
    try {
      final customerCode = selectedCustomer.value?.custCode ?? '';
      isLoadingConsignees.value = true;

      final response = await _apiService.get(
        AppConstants.getConsigneeUrl,
        queryParameters: {
          'Customer': customerCode,
          'Pincode': pincode,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        consignees.assignAll(data.map((json) => CustomerModel.fromJson(json)).toList());
      }
    } catch (e) {
      print('Error fetching consignees by pincode: $e');
    } finally {
      isLoadingConsignees.value = false;
    }
  }

  Future<void> fetchToPincodeDetails(String pincode) async {
    if (pincode.length != 6 || pincode == _lastFetchedDestPin) return;
    try {
      final customerCode = selectedCustomer.value?.custCode ?? '';

      final response = await _apiService.get(
        AppConstants.getToPincodeDetailsUrl,
        queryParameters: {
          'ToPincode': pincode,
          'Party_Code': customerCode,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        if (data.isNotEmpty) {
          _lastFetchedDestPin = pincode;
          selectedDestDetails.value = ToPincodeDetailsModel.fromJson(data[0]);
          print('Destination Details Saved: ${selectedDestDetails.value?.toCity}');
        }
      }
    } catch (e) {
      print('Error fetching to pincode details: $e');
    }
  }

  Future<void> fetchContractFreight() async {
    try {
      isLoadingFreight.value = true;
      freightErrorMessage.value = '';
      freightData.clear();

      final origin = selectedOriginDetails.value;
      final dest = selectedDestDetails.value;

      if (origin == null || dest == null) {
        CustomSnackbar.error(
          title: 'Missing Data',
          message: 'Please select Origin and Destination pincodes first',
        );
        return;
      }

      final requestModel = ContractFreightRequestModel(
        frompincode: originPinController.text,
        topincode: destPinController.text,
        contractId: selectedCustomer.value?.contractId ?? "",
        flagProceed: "P",
        depth: "CLRMSP",
        payBase: "P02",
        fromCity: origin?.fromCity ?? "",
        fromstate: origin?.orgNstnm ?? "",
        tostate: dest?.desTstnm ?? "",
        toCity: dest?.toCity ?? "",
        orgnLoc: origin?.orgncd ?? "",
        delLoc: dest?.destcd ?? "",
        serviceType: "1",
        ftlType: "",
        transMode: selectedTransportMode.value?['codeId']?.toString() ?? dest?.transType ?? "",
        chargedWeight: aWeightController.text,
        noOfPkgs: pkgsController.text,
        orderId: selectedCustomer.value?.contractId ?? "",
        invAmt: invValueController.text,
      );

      final response = await _apiService.post(
        AppConstants.getContractFreightUrl,
        data: requestModel.toJson(),
      );

      final responseData = response.data;
      if (response.statusCode == 200 && responseData['statusCode'] != 400) {
        freightErrorMessage.value = '';
        if (responseData['data'] != null) {
          if (responseData['data'] is List && (responseData['data'] as List).isNotEmpty) {
            freightData.value = responseData['data'][0];
          } else if (responseData['data'] is Map) {
            freightData.value = responseData['data'];
          }
        }
        print('Freight details fetched successfully');
      } else {
        final errorData = responseData['errors'];
        final message = errorData?['message'] ?? '';
        freightErrorMessage.value = message;
      }
    } catch (e) {
      print('Error fetching contract freight: $e');
      if (e is dio.DioException) {
        final errorMsg = e.response?.data['errors']?['message'] ?? '';
        freightErrorMessage.value = errorMsg;
      }
    } finally {
      isLoadingFreight.value = false;
    }
  }

  Future<void> docketSubmit() async {
    try {
      isLoadingBooking.value = true;
      final storageService = Get.find<StorageService>();
      final user = storageService.getUser();
      final location = storageService.getLocation();
      final locCode = location?.locCode ?? '';

      final origin = selectedOriginDetails.value;
      final dest = selectedDestDetails.value;

      double totalInvAmt = 0;
      if (invValueController.text.contains(',')) {
        totalInvAmt = invValueController.text.split(',').map((e) => double.tryParse(e.trim()) ?? 0.0).fold(0, (a, b) => a + b);
      } else {
        totalInvAmt = double.tryParse(invValueController.text) ?? 0.0;
      }

      final docket = Docket(
        dockno: cnoteController.text,
        dockdt: DateTime.now().toIso8601String(),
        manualDockno: cnoteController.text,
        ewayBillNo: isEwayBillWise.value ? addedEwayBills.join(',') : ewayBillController.text,
        partYCODE: selectedCustomer.value?.custCode ?? "",
        frompincode: originPinController.text,
        topincode: destPinController.text,
        pkgsno: int.tryParse(pkgsController.text) ?? 0,
        actuwt: double.tryParse(aWeightController.text) ?? 0,
        reassigNDESTCD: dest?.destcd ?? "",
        csgncd: selectedCustomer.value?.custCode ?? "",
        csgnnm: selectedCustomer.value?.custName ?? "",
        csgecd: consigneeType.value == 'Master' ? (selectedConsignee.value?.custCode ?? "") : "8888",
        csgenm: consigneeType.value == 'Master' ? (selectedConsignee.value?.custName ?? "") : walkInNameController.text,
        csgeaddr: consigneeType.value == 'Walk-In' ? walkInAddressController.text : "",
        csgeCity: consigneeType.value == 'Walk-In' ? walkInCityController.text : "",
        csgePinCode: consigneeType.value == 'Walk-In' ? walkInPincodeController.text : "",
        fromCity: origin?.fromCity ?? "",
        orgncd: locCode,
        orgNstnm: origin?.orgNstnm ?? "",
        orgnArea: origin?.orgnArea ?? "",
        toCity: dest?.toCity ?? "",
        destcd: dest?.destcd ?? "",
        desTstnm: dest?.desTstnm ?? "",
        destArea: dest?.destArea ?? "",
        pkpDly: dest?.pkpDly ?? "",
        transTypeUnderscore: selectedTransportMode.value?['codeId']?.toString() ?? dest?.transType ?? "",
        serviceTypeUnderscore: dest?.serviceType ?? "",
        pkgsty: dest?.pkgsty ?? "",
        businesstype: dest?.businesstype ?? "",
        contractID: selectedCustomer.value?.contractId ?? "",
        freightCharge: freightData['freightCharge'] ?? 0,
        freightRate: freightData['freightRate'] ?? 0,
        rateType: freightData['rateType'] ?? "",
        trDays: freightData['trDays'] ?? 0,
        invoiceRateApplay: "0",
        invoiceRate: 0,
        billingState: origin?.orgNstnm ?? "",
        serviceType: dest?.serviceType ?? "1",
        ftlType: dest?.businesstype ?? "1",
        transMode: selectedTransportMode.value?['codeId']?.toString() ?? dest?.transType ?? "5",
        chargedWeight: double.tryParse(aWeightController.text) ?? 0,
        noOfPkgs: int.tryParse(pkgsController.text) ?? 0,
        acTWT: double.tryParse(aWeightController.text) ?? 0,
        orderID: selectedCustomer.value?.contractId ?? "",
        invAmt: totalInvAmt.toString(),

        invNo: invNoController.text,
        companyCode: user?.baseCompanyCode ?? "",
      );

      final int totalPkgs = int.tryParse(pkgsController.text) ?? 0;
      final double totalWeight = double.tryParse(aWeightController.text) ?? 0;
      final String fullInvNoString = invNoController.text;
      final String fullInvAmtString = invValueController.text;

      final List<Map<String, dynamic>> sourceList = dimensionsList.isEmpty
          ? [
              {
                "voL_L": double.tryParse(lengthController.text) ?? 0,
                "voL_B": double.tryParse(breadthController.text) ?? 0,
                "voL_H": double.tryParse(heightController.text) ?? 0
              }
            ]
          : dimensionsList;

      final int count = sourceList.length;
      
      List<String> invNos = fullInvNoString.split(',').map((e) => e.trim()).toList();
      List<double> invAmts = fullInvAmtString.split(',').map((e) => double.tryParse(e.trim()) ?? 0.0).toList();

      final List<Invoices> invoices = [];
      
      // Determine the number of invoice entries to send.
      // Driven by the maximum of Dimensions, E-way bills, or Invoice Numbers.
      int loopCount = sourceList.length;
      if (isEwayBillWise.value && addedEwayBills.length > loopCount) {
        loopCount = addedEwayBills.length;
      }
      if (invNos.length > loopCount) {
        loopCount = invNos.length;
      }

      for (int i = 0; i < loopCount; i++) {
        // Get dimension data for this entry
        final Map<String, dynamic> d = i < sourceList.length 
            ? sourceList[i] 
            : (sourceList.isNotEmpty ? sourceList[0] : {"voL_L": 0, "voL_B": 0, "voL_H": 0});

        // Distribution of invoice numbers and amounts
        String invNo = i < invNos.length ? invNos[i] : "";
        double invAmt = i < invAmts.length ? invAmts[i] : 0.0;

        int pkgs;
        double weight;

        if (isEwayBillWise.value && i < addedEwayBillDetails.length) {
          final billDetail = addedEwayBillDetails[i];
          pkgs = int.tryParse(billDetail['totalQty']?.toString() ?? '0') ?? 0;
          weight = double.tryParse(billDetail['totalWeight']?.toString() ?? '0') ?? 0;
        } else {
          pkgs = d["pieces"] ?? (totalPkgs / loopCount).floor();
          weight = totalWeight / loopCount;
        }

        invoices.add(Invoices(
          invno: invNo,
          pkgsno: pkgs,
          actuwt: weight,
          invamt: invAmt,
          voLL: d["voL_L"]?.toDouble() ?? 0.0,
          voLB: d["voL_B"]?.toDouble() ?? 0.0,
          voLH: d["voL_H"]?.toDouble() ?? 0.0,
        ));
      }

      if (invoices.isNotEmpty && totalPkgs > 0 && !isEwayBillWise.value && dimensionsList.isEmpty) {
        int distributedPkgs = (totalPkgs / loopCount).floor() * loopCount;
        int remainder = totalPkgs - distributedPkgs;
        if (remainder > 0) {
          invoices[0].pkgsno = (invoices[0].pkgsno ?? 0) + remainder;
        }
      }

      final body = DocketSubmitRequestModel(
        docket: docket,
        invoices: invoices,
        baseusername: user?.userId,
      );

      final response = await _apiService.post(
        AppConstants.docketSubmitUrl,
        data: body.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['statusCode'] == 200) {
          final dockno = data['data']['dockno'];
          _showSuccessDialog(dockno);
        } else {
          CustomSnackbar.error(
              title: "Submission Failed",
              message: data['message'] ?? "Failed to submit booking"
          );
        }
      }
    } catch (e) {
      print('Error submitting docket: $e');
      CustomSnackbar.error(
          title: "Error",
          message: "An error occurred during submission"
      );
    } finally {
      isLoadingBooking.value = false;
    }
  }

  void _showSuccessDialog(String dockNo) {
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
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Success!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Docket generated successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'No: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      dockNo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    Get.back(); // Go back to previous screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'DONE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
