import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/habit_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/habit_model.dart';
import '../widgets/habit_verification_sheet.dart';

class HabitController extends GetxController {
  final HabitService _habitService = Get.find<HabitService>();
  final AuthService _authService = Get.find<AuthService>();

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final selectedCategory = 'ibadah'.obs;
  final selectedIcon = 'sun'.obs;
  final points = 10.obs;

  RxList<HabitModel> get habits => _habitService.habits;

  void toggleHabit(String habitId) {
    final user = _authService.currentUser.value;
    final role = user?.role ?? 'siswa';
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

  void saveNewHabit() {
    final title = titleController.text.trim();
    final desc = descController.text.trim();

    if (title.isEmpty) {
      Get.snackbar('Peringatan', 'Judul kebiasaan harus diisi');
      return;
    }

    final newHabit = HabitModel(
      id: 'h-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: desc,
      category: selectedCategory.value,
      iconName: selectedIcon.value,
      points: points.value,
    );

    _habitService.addHabit(newHabit);

    titleController.clear();
    descController.clear();

    Get.back();
    Get.snackbar('Berhasil', 'Kebiasaan baru ditambahkan');
  }

  @override
  void onClose() {
    titleController.dispose();
    descController.dispose();
    super.onClose();
  }
}
