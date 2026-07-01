import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skylark/app/core/values/app_colors.dart';
import 'package:skylark/app/core/widgets/custom_button.dart';
import 'package:skylark/app/core/widgets/custom_text_field.dart';
import 'package:skylark/app/core/widgets/custom_search_dropdown.dart';
import 'drs_update_detail_controller.dart';

class DrsUpdateDetailScreen extends GetView<DrsUpdateDetailController> {
  const DrsUpdateDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('DRS Update Detail', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.drsHeaderData.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final header = controller.drsHeaderData.value;
        if (header == null) {
          return const Center(child: Text("No details found"));
        }

        return Form(
          key: controller.formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _headerItem("DRS No", header['pdcno'] ?? "-"),
                                _headerItem("DRS Date", header['pdC_Dt'] ?? "-"),
                              ],
                            ),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _headerItem("Vehicle No", header['vehno'] ?? "-"),
                                _headerItem("Total Dockets", (header['total_Dockets_In_DRS'] ?? "0").toString()),
                              ],
                            ),
                            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1)),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Start KM: ${header['start_KM'] ?? 0}", style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      CustomTextField(
                                        controller: controller.closeKmController,
                                        keyboardType: TextInputType.number,
                                        hintText: "Enter Close KM",
                                        validator: (val) => val == null || val.isEmpty ? "Required" : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: controller.drsDetailList.length,
                        itemBuilder: (context, index) {
                          final detail = controller.drsDetailList[index];
                          return _docketCard(detail, index);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (MediaQuery.of(context).viewInsets.bottom == 0)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomButton(
                    text: "UPDATE DRS",
                    isLoading: controller.isLoading.value,
                    onPressed: () => controller.submitUpdate(),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _headerItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkBlue)),
      ],
    );
  }

  Widget _docketCard(Map<String, dynamic> detail, int index) {
    bool isChecked = detail['isChecked'] ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        border: isChecked ? Border.all(color: AppColors.primaryBlue.withOpacity(0.5), width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: isChecked,
                  onChanged: (val) => controller.updateDocketData(index, isChecked: val),
                  activeColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              Expanded(
                child: Text("Docket: ${detail['dockno']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryBlue)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.secondaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text("Pkgs: ${detail['pkgs_Arrived']}", style: const TextStyle(color: AppColors.secondaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _infoRow("Route", "${detail['orgncd']} ➔ ${detail['destcd']}"),
          _infoRow("Consignor", detail['csgnnm'] ?? "-"),
          _infoRow("Consignee", detail['csgenm'] ?? "-"),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _inputField(
                  "Delivered Pkgs", 
                  TextInputType.number, 
                  controller.getDeliveredPkgsController(index, (detail['pkgsdelivered'] ?? detail['pkgs_Arrived']).toString()),
                  (val) {
                    int? pkgs = int.tryParse(val);
                    controller.updateDocketData(index, pkgs: pkgs ?? 0);
                  },
                  enabled: isChecked,
                  validator: (val) => isChecked && (val == null || val.isEmpty) ? "Required" : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _inputField(
                  "Remark", 
                  TextInputType.text, 
                  controller.getRemarkController(index, detail['remark'] ?? ""),
                  (val) {
                    controller.updateDocketData(index, remark: val);
                  },
                  enabled: isChecked,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text("Late Reason", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          _dropdownField(
            items: controller.lateReasons,
            value: detail['hDcboReason'],
            hint: "Select Late Reason",
            onChanged: (val) => controller.updateDocketData(index, lateReason: val),
            enabled: isChecked,
            validator: (val) => isChecked && (val == null || val.isEmpty) ? "Required" : null,
          ),
          if ((detail['pkgsdelivered'] ?? 0) < detail['pkgs_Arrived']) ...[
            const SizedBox(height: 12),
            const Text("Undelivered Reason", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            _dropdownField(
              items: controller.undeliveredReasons,
              value: detail['cboLateReason'],
              hint: "Select Undelivered Reason",
              onChanged: (val) => controller.updateDocketData(index, undelReason: val),
              enabled: isChecked,
              validator: (val) => isChecked && (val == null || val.isEmpty) ? "Required" : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _inputField(String label, TextInputType type, TextEditingController textController, Function(String) onChanged, {String? Function(String?)? validator, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: enabled ? Colors.grey : Colors.grey.shade300, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        CustomTextField(
          keyboardType: type,
          controller: textController,
          hintText: label,
          onChanged: onChanged,
          validator: validator,
          enabled: enabled,
        ),
      ],
    );
  }

  Widget _dropdownField({required List<dynamic> items, required String value, required String hint, required Function(String?) onChanged, String? Function(String?)? validator, bool enabled = true}) {
    final selected = items.firstWhereOrNull((e) => e['codeDesc'].toString() == value);
    return CustomSearchDropdown<dynamic>(
      items: items,
      hintText: hint,
      selectedItem: selected,
      onSelected: (val) {
        if (val != null) {
          onChanged(val['codeDesc'].toString());
        }
      },
      itemAsString: (item) => item['codeDesc'].toString(),
      compareFn: (a, b) => a['codeDesc'] == b['codeDesc'],
      validator: validator,
      enabled: enabled,
      isLoading: items.isEmpty && enabled,
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        SizedBox(width: 70, child: Text("$label:", style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkBlue), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }
}
