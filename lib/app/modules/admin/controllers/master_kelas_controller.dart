import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/master_data_service.dart';
import '../../../routes/app_routes.dart';

class MasterKelasController extends GetxController {
  final MasterDataService masterDataService = Get.find<MasterDataService>();

  final searchQuery = ''.obs;
  final selectedMajorFilter = 'Semua Jurusan'.obs;
  final selectedGradeFilter = 'Semua Tingkat'.obs;
  final searchController = TextEditingController();

  final newClassNameController = TextEditingController();
  final newHomeroomTeacherController = TextEditingController();

  final isLoading = false.obs;

  List<String> get availableMajors => const ['Semua Jurusan', 'TJKT', 'DKV', 'PPLG', 'Animasi'];
  List<String> get availableGrades => const ['Semua Tingkat', 'X', 'XI', 'XII'];

  List<Map<String, dynamic>> get allClasses => masterDataService.getAllClassesCombined();
  List<Map<String, dynamic>> get availableTeachers => masterDataService.getAllTeachersCombined();

  List<Map<String, dynamic>> get filteredClasses {
    final query = searchQuery.value.trim().toLowerCase();
    final major = selectedMajorFilter.value;
    final grade = selectedGradeFilter.value;

    return allClasses.where((c) {
      final nameMatches = (c['className'] as String).toLowerCase().contains(query);
      final teacherMatches = (c['homeroomTeacher'] as String).toLowerCase().contains(query);
      final matchesQuery = query.isEmpty || nameMatches || teacherMatches;

      final matchesMajor = major == 'Semua Jurusan' || (c['major'] as String) == major;
      final matchesGrade = grade == 'Semua Tingkat' || (c['grade'] as String) == grade;

      return matchesQuery && matchesMajor && matchesGrade;
    }).toList();
  }

  void refreshData() {
    masterDataService.fetchClassesFromSupabase();
    masterDataService.fetchStudentsFromSupabase();
    masterDataService.fetchTeachersFromSupabase();
  }

  Future<void> assignTeacherToClass({
    required String className,
    required String teacherId,
    required String teacherName,
  }) async {
    isLoading.value = true;
    final success = await masterDataService.assignHomeroomTeacherToClass(
      className: className,
      teacherId: teacherId,
      teacherName: teacherName,
    );
    isLoading.value = false;

    if (success) {
      Get.back();
      Get.snackbar(
        'Penugasan Berhasil! 🎉',
        '$teacherName kini resmi menjadi Wali Kelas $className.',
        backgroundColor: Colors.purple.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } else {
      Get.snackbar(
        'Gagal Menugaskan',
        'Terjadi kendala saat menyimpan penugasan wali kelas.',
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void navigateToStudentsInClass(String className) {
    Get.toNamed(Routes.MASTER_SISWA);
  }

  @override
  void onClose() {
    searchController.dispose();
    newClassNameController.dispose();
    newHomeroomTeacherController.dispose();
    super.onClose();
  }
}
