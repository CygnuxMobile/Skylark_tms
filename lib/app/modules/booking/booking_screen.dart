import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/widgets/custom_button.dart';
import 'package:skylark/app/core/widgets/custom_text_field.dart';
import 'package:skylark/app/core/widgets/custom_search_dropdown.dart';
import 'package:skylark/app/data/models/customer_model.dart';
import 'package:skylark/app/data/models/pincode_model.dart';
import 'booking_controller.dart';

class BookingScreen extends GetView<BookingController> {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Booking Screen',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.5),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
                  child: Row(
                    children: [
                      const Text(
                        "Cnote NO",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
                      _buildCnoteToggle(),
                    ],
                  ),
                ),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: controller.cnoteController,
                        focusNode: controller.cnoteFocus,
                        hintText: 'Enter Cnote Number',
                        isLoading: controller.isValidatingCnote.value,
                        prefixIcon: const Icon(Icons.numbers_rounded, color: AppColors.primaryBlue, size: 20),
                        suffixIcon: controller.cnoteController.text.length >= 4
                            ? Icon(
                                controller.isCnoteValid.value ? Icons.check_circle : Icons.error,
                                color: controller.isCnoteValid.value ? Colors.green : Colors.red,
                                size: 20,
                              )
                            : null,
                      ),
                      if (controller.cnoteValidationMessage.value.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 4),
                          child: Text(
                            controller.cnoteValidationMessage.value,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: controller.isCnoteValid.value ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Obx(
                  () => Visibility(
                    visible: controller.isEwayBillWise.value,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Eway Bill No'),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: controller.ewayBillController,
                                focusNode: controller.ewayBillFocus,
                                hintText: 'Enter Eway Bill Number',
                                keyboardType: TextInputType.number,
                                maxLength: 12,
                                prefixIcon: const Icon(Icons.receipt_long_rounded, color: AppColors.primaryBlue, size: 20),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Obx(() => controller.isLoadingEwayBill.value
                                ? const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : IconButton(
                                    onPressed: () {
                                      final bill = controller.ewayBillController.text.trim();
                                      if (bill.length == 12) {
                                        controller.getEwayBillDetails(bill);
                                      } else {
                                        Get.snackbar("Invalid Input", "Eway Bill must be 12 digits",
                                          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
                                      }
                                    },
                                    icon: const Icon(Icons.add_circle, color: AppColors.primaryBlue, size: 35),
                                  )),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Obx(() => Column(
                              children: controller.addedEwayBills.map((bill) {
                                int index = controller.addedEwayBills.indexOf(bill);
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.receipt, color: AppColors.primaryBlue, size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(child: Text(bill, style: const TextStyle(fontWeight: FontWeight.w500))),
                                      IconButton(
                                        onPressed: () => controller.removeEwayBill(index),
                                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            )),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                Obx(
                  () => Visibility(
                    visible: !controller.isEwayBillWise.value,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Eway Bill'),
                        CustomTextField(
                          controller: controller.ewayBillController,
                          focusNode: controller.ewayBillFocus,
                          hintText: 'Enter Eway Bill Number',
                          keyboardType: TextInputType.number,
                          maxLength: 12,
                          readOnly: controller.isFieldsReadOnly.value,
                          prefixIcon: controller.isLoadingEwayBill.value
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2)),
                                )
                              : const Icon(Icons.receipt_long_rounded,
                                  color: AppColors.primaryBlue, size: 20),
                          suffixIcon: controller.isFieldsReadOnly.value
                              ? IconButton(
                                  icon: const Icon(Icons.edit, color: AppColors.primaryBlue, size: 20),
                                  onPressed: () => controller.editEwayBill(),
                                )
                              : null,
                          validator: (value) {
                            if (controller.isEwayBillWise.value) return null;
                            if (value != null &&
                                value.isNotEmpty &&
                                value.length != 12) {
                              return 'Eway Bill must be 12 digits';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                _buildFieldLabel('Customer Name'),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomSearchDropdown<CustomerModel>(
                        items: controller.customers,
                        focusNode: controller.customerFocus,
                        hintText: 'Select Customer',
                        title: 'Select Customer',
                        onRefresh: () => controller.fetchCustomers(),
                        isLoading: controller.isLoadingCustomers.value,
                        selectedItem: controller.selectedCustomer.value,
                        itemAsString: (customer) => "${customer.custCode ?? ''} - ${customer.custName ?? ''}",
                        compareFn: (item, selectedItem) => item.custCode == selectedItem.custCode && item.custName == selectedItem.custName,
                        validator: (value) => value == null || value.isEmpty ? 'Customer is required' : null,
                        onSelected: (value) {
                          if (value != null) {
                            controller.selectedCustomer.value = value;
                          }
                        },
                      ),
                      if (controller.customerErrorMessage.value.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                          child: Text(controller.customerErrorMessage.value, style: const TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _buildFieldLabel('Transport Mode'),
                Obx(
                  () => CustomSearchDropdown<Map<String, dynamic>>(
                    items: controller.transportModes,
                    hintText: 'Select Transport Mode',
                    isLoading: controller.isLoadingTransportModes.value,
                    selectedItem: controller.selectedTransportMode.value,
                    itemAsString: (item) => item['codeDesc']?.toString() ?? '',
                    compareFn: (item, selectedItem) => item['codeId'] == selectedItem['codeId'],
                    validator: (value) => value == null || value.isEmpty ? 'Transport Mode is required' : null,
                    onSelected: (value) {
                      controller.selectedTransportMode.value = value;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Origin Pin'),
                          Obx(
                            () => CustomSearchDropdown<PincodeModel>(
                              items: controller.fromLocations,
                              focusNode: controller.originFocus,
                              hintText: 'Origin',
                              isLoading: controller.isLoadingFromPincodes.value,
                              isSearching: controller.isLoadingFromPincodes,
                              selectedItem: controller.selectedOrigin.value,
                              itemAsString: (item) => item.pincode ?? '',
                              onSearch: (val) => controller.fetchPincodesForOrigin(val),
                              onTap: () {
                                if (controller.fromLocations.isEmpty) {
                                  controller.fetchFromPincodes();
                                }
                              },
                              onRefresh: () => controller.fetchFromPincodes(),
                              compareFn: (item, selectedItem) => item.pincode == selectedItem.pincode,
                              validator: (value) => value == null || value.isEmpty ? 'Origin required' : null,
                              onSelected: (value) => controller.onOriginSelected(value),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Dest Pin'),
                          Obx(
                            () => CustomSearchDropdown<PincodeModel>(
                              items: controller.locations,
                              focusNode: controller.destFocus,
                              hintText: 'Destination',
                              isLoading: controller.isLoadingLocations.value,
                              isSearching: controller.isLoadingLocations,
                              selectedItem: controller.selectedDest.value,
                              itemAsString: (item) => item.pincode ?? '',
                              onSearch: (val) => controller.fetchPincodes(val),
                              onTap: () => controller.locations.clear(),
                              compareFn: (item, selectedItem) => item.pincode == selectedItem.pincode,
                              validator: (value) => value == null || value.isEmpty ? 'Dest required' : null,
                              onSelected: (value) => controller.onDestSelected(value),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildFieldLabel('Consignor'),
                CustomTextField(
                  controller: controller.consignorController,
                  hintText: 'Consignor Name',
                  enabled: false,
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryBlue, size: 20),
                  validator: (value) => value == null || value.isEmpty ? 'Consignor is required' : null,
                ),
                const SizedBox(height: 16),

                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Select Consignee',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkBlue, letterSpacing: 0.3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              _buildSelectionTab('From Master', 'Master'),
                              const SizedBox(width: 8),
                              _buildSelectionTab('Walk-In', 'Walk-In'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (controller.consigneeType.value == 'Master')
                        CustomSearchDropdown<CustomerModel>(
                          items: controller.consignees,
                          focusNode: controller.consigneeFocus,
                          hintText: 'Select Consignee',
                          title: 'Select Consignee',
                          onRefresh: () => controller.fetchConsigneesByPincode(controller.selectedDest.value?.pincode ?? ''),
                          isLoading: controller.isLoadingConsignees.value,
                          selectedItem: controller.selectedConsignee.value,
                          itemAsString: (item) => "${item.custCode ?? ''} - ${item.custName ?? ''}",
                          compareFn: (item, selectedItem) => item.custCode == selectedItem.custCode,
                          validator: (value) => value == null || value.isEmpty ? 'Consignee required' : null,
                          onSelected: (value) {
                            controller.selectedConsignee.value = value;
                            if (value != null) {
                              controller.consigneeController.text = value.custName ?? '';
                            }
                          },
                        )
                      else
                        Column(
                          children: [
                            CustomTextField(
                              controller: controller.walkInNameController,
                              focusNode: controller.walkInNameFocus,
                              hintText: 'Name',
                              prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryBlue, size: 20),
                              validator: (value) => value == null || value.isEmpty ? 'Name required' : null,
                            ),
                            const SizedBox(height: 12),
                            CustomTextField(
                              controller: controller.walkInAddressController,
                              focusNode: controller.walkInAddressFocus,
                              hintText: 'Address',
                              prefixIcon: const Icon(Icons.home_outlined, color: AppColors.primaryBlue, size: 20),
                              validator: (value) => value == null || value.isEmpty ? 'Address required' : null,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: controller.walkInCityController,
                                    focusNode: controller.walkInCityFocus,
                                    hintText: 'City',
                                    prefixIcon: const Icon(Icons.location_city_outlined, color: AppColors.primaryBlue, size: 20),
                                    validator: (value) => value == null || value.isEmpty ? 'City required' : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomTextField(
                                  controller: controller.walkInPincodeController,
                                  focusNode: controller.walkInPincodeFocus,
                                  hintText: 'Pincode',
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  prefixIcon: const Icon(Icons.pin_drop_outlined, color: AppColors.primaryBlue, size: 20),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Pincode required';
                                    if (value.length != 6) return 'Must be 6 digits';
                                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'Digits only';
                                    return null;
                                  },
                                ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('PKGS'),
                          CustomTextField(
                            controller: controller.pkgsController,
                            focusNode: controller.pkgsFocus,
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Actual Wt'),
                          CustomTextField(
                            controller: controller.aWeightController,
                            focusNode: controller.aWeightFocus,
                            hintText: '0.00',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Obx(() => _buildFieldLabel('Invoice Value${controller.isZeroFreightSubmit.value ? '' : ' *'}')),
                Obx(
                  () => CustomTextField(
                    controller: controller.invValueController,
                    focusNode: controller.invValueFocus,
                    hintText: 'Enter INV Value',
                    keyboardType: TextInputType.text,
                    readOnly: controller.isFieldsReadOnly.value,
                    prefixIcon: const Icon(Icons.currency_rupee_rounded, color: AppColors.primaryBlue, size: 20),
                    validator: (value) {
                      if (!controller.isZeroFreightSubmit.value && (value == null || value.isEmpty)) {
                        return 'Value is required';
                      }
                      if (controller.isEwayBillWise.value && controller.addedEwayBills.isNotEmpty) {
                        final valCount = value?.split(',').where((s) => s.trim().isNotEmpty).length ?? 0;
                        if (valCount != controller.addedEwayBills.length) {
                          return 'Expected ${controller.addedEwayBills.length} values (comma separated)';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Invoice Number'),
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: controller.invNoController,
                        focusNode: controller.invNoFocus,
                        hintText: 'Enter INV No',
                        readOnly: controller.isFieldsReadOnly.value,
                        prefixIcon: controller.isLoadingFreight.value
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                              )
                            : const Icon(Icons.description_outlined, color: AppColors.primaryBlue, size: 20),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'INV No is required';
                          if (controller.isEwayBillWise.value && controller.addedEwayBills.isNotEmpty) {
                            final count = value.split(',').where((s) => s.trim().isNotEmpty).length;
                            if (count != controller.addedEwayBills.length) {
                              return 'Expected ${controller.addedEwayBills.length} numbers (comma separated)';
                            }
                          }
                          return null;
                        },
                      ),
                      if (controller.freightErrorMessage.value.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                          child: Text(
                            controller.freightErrorMessage.value,
                            style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => controller.toggleDimensions(),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(controller.showDimensions.value ? Icons.remove_circle_outline : Icons.add_circle_outline, color: AppColors.primaryBlue, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                controller.showDimensions.value ? 'HIDE DIMENSIONS' : 'ADD DIMENSIONS',
                                style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (controller.showDimensions.value) ...[const SizedBox(height: 16), _buildDimensionSection()],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Obx(() => CustomButton(
                      text: 'SUBMIT BOOKING',
                      isLoading: controller.isLoadingBooking.value,
                      onPressed: () => controller.submitBooking())),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkBlue, letterSpacing: 0.3),
      ),
    );
  }

  Widget _buildCnoteToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(() => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSmallToggleItem("Eway Bill", controller.isEwayBillWise.value, () => controller.isEwayBillWise.value = true),
              _buildSmallToggleItem("Normal", !controller.isEwayBillWise.value, () => controller.isEwayBillWise.value = false),
            ],
          )),
    );
  }

  Widget _buildSmallToggleItem(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionTab(String title, String type) {
    return GestureDetector(
      onTap: () => controller.consigneeType.value = type,
      child: Obx(
        () {
          final isSelected = controller.consigneeType.value == type;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : Colors.grey.shade300,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : [],
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDimensionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final dimensionsCount = controller.dimensionsList.length;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dimensionsCount,
            itemBuilder: (context, index) {
              final dim = controller.dimensionsList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    _buildDimLabelValue('L', dim['voL_L'].toString()),
                    _buildDimLabelValue('B', dim['voL_B'].toString()),
                    _buildDimLabelValue('H', dim['voL_H'].toString()),
                    _buildDimLabelValue('Pcs', dim['pieces'].toString()),
                    IconButton(
                      onPressed: () => controller.removeDimension(index),
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            },
          );
        }),
        const SizedBox(height: 12),
        _buildFieldLabel('Enter Dimensions (L x B x H x Piece)'),
        Row(
          children: [
            _buildSmallDimField('L', controller.lengthController, controller.lengthFocus),
            const SizedBox(width: 16),
            _buildSmallDimField('B', controller.breadthController, controller.breadthFocus),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildSmallDimField('H', controller.heightController, controller.heightFocus),
            const SizedBox(width: 16),
            _buildSmallDimField('Pcs', controller.pieceController, controller.pieceFocus),
            const SizedBox(width: 16),
            InkWell(
              onTap: () {
                final l = double.tryParse(controller.lengthController.text) ?? 0;
                final b = double.tryParse(controller.breadthController.text) ?? 0;
                final h = double.tryParse(controller.heightController.text) ?? 0;
                final p = int.tryParse(controller.pieceController.text) ?? 0;

                final totalPkgs = int.tryParse(controller.pkgsController.text) ?? 0;
                int currentPcs = 0;
                for (var dim in controller.dimensionsList) {
                  currentPcs += dim['pieces'] as int? ?? 0;
                }

                if (l > 0 && b > 0 && h > 0 && p > 0) {
                  if (currentPcs + p > totalPkgs) {
                    Get.snackbar('Error', 'Total pieces cannot exceed PKGS ($totalPkgs)', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
                  } else {
                    controller.addDimension(l, b, h, p);
                  }
                } else {
                  Get.snackbar('Error', 'Please enter valid dimensions and pieces', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                height: 55, // Matching height of CustomTextField
                width: 55,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDimLabelValue(String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.darkBlue)),
        ],
      ),
    );
  }

  Widget _buildSmallDimField(String label, TextEditingController textController, FocusNode focusNode) {
    return Expanded(
      child: CustomTextField(
        controller: textController,
        focusNode: focusNode,
        hintText: label,
        keyboardType: TextInputType.number,
      ),
    );
  }
}
