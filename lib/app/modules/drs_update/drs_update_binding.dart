import 'package:get/get.dart';
import 'drs_update_controller.dart';
import 'sub_screen/drs_update_detail_controller.dart';

class DrsUpdateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DrsUpdateController>(() => DrsUpdateController());
    Get.lazyPut<DrsUpdateDetailController>(() => DrsUpdateDetailController());
  }
}
