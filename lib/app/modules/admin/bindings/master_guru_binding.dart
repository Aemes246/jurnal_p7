import 'package:get/get.dart';
import '../controllers/master_guru_controller.dart';
import '../../../data/services/master_data_service.dart';

class MasterGuruBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MasterDataService>()) {
      Get.put(MasterDataService(), permanent: true);
    }
    Get.lazyPut<MasterGuruController>(
      () => MasterGuruController(),
    );
  }
}
