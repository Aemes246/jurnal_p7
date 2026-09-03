import 'package:get/get.dart';
import '../controllers/habit_controller.dart';

class HabitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HabitController>(() => HabitController());
  }
}
