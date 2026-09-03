import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/master_data_service.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  UserModel? get user => _authService.currentUser.value;

  // Controllers untuk data siswa (melengkapi sisanya)
  final addressController = TextEditingController();
  final hobbyController = TextEditingController();
  final ambitionController = TextEditingController();
  final favoriteSportController = TextEditingController();
  final favoriteFoodController = TextEditingController();
  final favoriteSubjectController = TextEditingController();
  final uniquenessController = TextEditingController();
  final selectedReligion = 'Islam'.obs;

  // Controllers untuk data guru
  final nipController = TextEditingController();
  final phoneController = TextEditingController();
  final apiEndpointController = TextEditingController();
  final selectedAssignedClass = 'X DKV 1'.obs;

  final isLoading = false.obs;

  List<String> get availableClasses {
    if (Get.isRegistered<MasterDataService>()) {
      final list = Get.find<MasterDataService>().getAllClassesCombined();
      final names = list.map((c) => c['className'] as String).where((n) => n.isNotEmpty).toSet().toList();
      if (names.isNotEmpty) return names;
    }
    return ['X DKV 1', 'X DKV 2', 'XI PPLG 1', 'XI PPLG 2', 'X TJKT 1', 'X TJKT 2', 'X TJKT 3'];
  }

  @override
  void onInit() {
    super.onInit();
    populateUserData();
  }

  void populateUserData() {
    final u = user;
    if (u != null) {
      selectedReligion.value = u.religion;
      addressController.text = u.address ?? '';
      hobbyController.text = u.hobby ?? '';
      ambitionController.text = u.ambition ?? '';
      favoriteSportController.text = u.favoriteSport ?? '';
      favoriteFoodController.text = u.favoriteFood ?? '';
      favoriteSubjectController.text = u.favoriteSubject ?? '';
      uniquenessController.text = u.uniqueness ?? '';

      nipController.text = u.nip ?? '19890107 202421 1 009';
      phoneController.text = u.phone ?? '08115595606';
      apiEndpointController.text = 'https://api.smkn7samarinda.sch.id/v1/dapodik/sync';

      final classes = availableClasses;
      if (u.className != null && u.className!.isNotEmpty && u.className != 'Wali Kelas') {
        selectedAssignedClass.value = u.className!;
      } else if (classes.isNotEmpty) {
        selectedAssignedClass.value = classes.first;
      }
    }
  }

  Future<void> saveProfile() async {
    final u = user;
    if (u == null) return;

    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

    final updated = u.copyWith(
      religion: selectedReligion.value,
      className: (u.role == 'guru' || u.role == 'guru_wali') ? selectedAssignedClass.value : u.className,
      address: addressController.text.trim(),
      hobby: hobbyController.text.trim(),
      ambition: ambitionController.text.trim(),
      favoriteSport: favoriteSportController.text.trim(),
      favoriteFood: favoriteFoodController.text.trim(),
      favoriteSubject: favoriteSubjectController.text.trim(),
      uniqueness: uniquenessController.text.trim(),
      nip: nipController.text.trim(),
      phone: phoneController.text.trim(),
      isProfileCompleted: true,
    );

    _authService.updateProfile(updated);
    if (Get.isRegistered<MasterDataService>()) {
      Get.find<MasterDataService>().fetchTeachersFromSupabase();
      Get.find<MasterDataService>().fetchStudentsFromSupabase();
    }
    isLoading.value = false;

    Get.snackbar(
      'Profil Berhasil Disimpan 🎉',
      'Data biodata Anda telah diperbarui dan terhubung dengan sistem sekolah!',
      backgroundColor: Colors.teal.shade900,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void logout() async {
    await _authService.logout();
    Get.offAllNamed(Routes.LOGIN);
  }

  @override
  void onClose() {
    addressController.dispose();
    hobbyController.dispose();
    ambitionController.dispose();
    favoriteSportController.dispose();
    favoriteFoodController.dispose();
    favoriteSubjectController.dispose();
    uniquenessController.dispose();
    nipController.dispose();
    phoneController.dispose();
    apiEndpointController.dispose();
    super.onClose();
  }
}
