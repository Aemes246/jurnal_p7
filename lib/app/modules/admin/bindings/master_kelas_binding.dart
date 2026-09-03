import 'package:get/get.dart';
import '../controllers/master_kelas_controller.dart';
import '../../../data/services/master_data_service.dart';

class MasterKelasBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MasterDataService>()) {
      Get.put(MasterDataService(), permanent: true);
    }
    Get.lazyPut<MasterKelasController>(
      () => MasterKelasController(),
    );
  }
}
