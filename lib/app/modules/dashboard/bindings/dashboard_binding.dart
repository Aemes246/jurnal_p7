import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../habit_tracker/controllers/habit_controller.dart';
import '../../journal/controllers/journal_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HabitController>(() => HabitController());
    Get.lazyPut<JournalController>(() => JournalController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
