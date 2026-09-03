import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/habit_service.dart';
import '../../../data/services/master_data_service.dart';
import '../../../data/models/habit_model.dart';
import '../../../data/models/user_model.dart';
import '../../habit_tracker/widgets/habit_verification_sheet.dart';

class DashboardController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final HabitService _habitService = Get.find<HabitService>();

  final selectedNavIndex = 0.obs;
  final teacherSearchQuery = ''.obs;
  final searchController = TextEditingController();
  Timer? _liveTimer;

  UserModel? get currentUser => _authService.currentUser.value;
  RxList<HabitModel> get habits => _habitService.habits;
  
  double get progressPercentage => _habitService.todayCompletionPercentage;
  int get completedCount => _habitService.totalCompletedToday;
  int get totalCount => habits.length;

  @override
  void onInit() {
    super.onInit();
    _startLiveTimer();
  }

  void _startLiveTimer() {
    _liveTimer?.cancel();
    _liveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (Get.isRegistered<MasterDataService>()) {
        Get.find<MasterDataService>().fetchStudentsFromSupabase();
      }
      _habitService.fetchLogsFromSupabase();
      update();
    });
  }

  void toggleHabit(String habitId) {
    final role = currentUser?.role ?? 'siswa';
    if (role == 'guru' || role == 'guru_wali' || role == 'superadmin') {
      Get.snackbar(
        'Mode Pemantauan 👁️',
        'Guru Wali & Superadmin hanya dapat memantau jurnal kebiasaan siswa (Read-Only).',
        backgroundColor: Colors.indigo.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (_habitService.isSelectedDateFuture()) {
      Get.snackbar(
        'Tanggal Terkunci 🔒',
        'Anda belum dapat mengisi atau mengubah kebiasaan untuk tanggal di masa mendatang.',
        backgroundColor: Colors.amber.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    final habit = habits.firstWhere((h) => h.id == habitId);
    
    // Always open HabitVerificationSheet for all habits (1 to 7) for Students
    Get.bottomSheet(
      HabitVerificationSheet(habit: habit),
      isScrollControlled: true,
    );
  }

  void changeNavIndex(int index) {
    selectedNavIndex.value = index;
  }

  @override
  void onClose() {
    _liveTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
