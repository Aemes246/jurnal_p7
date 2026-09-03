import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/master_data_service.dart';
import '../../../routes/app_routes.dart';

class RegisterController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final ImagePicker _picker = ImagePicker();

  final nisnController = TextEditingController();
  final nisController = TextEditingController();
  final nameController = TextEditingController();
  final classController = TextEditingController();
  final teacherController = TextEditingController();

  final addressController = TextEditingController();
  final hobbyController = TextEditingController();
  final ambitionController = TextEditingController();
  final sportController = TextEditingController();
  final foodController = TextEditingController();
  final subjectController = TextEditingController();
  final uniquenessController = TextEditingController();

  final selectedReligion = 'Islam'.obs;
  final photoPath = ''.obs;
  final signaturePath = ''.obs;
  final isObscure = true.obs;
  final isLoading = false.obs;

  final List<String> religions = [
    'Islam',
    'Kristen',
    'Katolik',
    'Hindu',
    'Buddha',
    'Khonghucu',
  ];

  final passwordController = TextEditingController();
  final selectedClass = 'X DKV 1'.obs;
  final selectedTeacher = 'Saiful Anwar., S.Kom.,Gr'.obs;

  final RxList<String> availableClasses = <String>['X DKV 1', 'X DKV 2', 'X TJKT 1', 'XI PPLG 1', 'XII ANIMASI 1'].obs;
  final RxList<String> availableTeachers = <String>['Saiful Anwar., S.Kom.,Gr', 'Aminah Tajudin., S.Pd.I', 'Dra. Hajah Nurhayati', 'Budi Santoso., S.T'].obs;

  @override
  void onInit() {
    super.onInit();
    loadMasterOptions();
  }

  void loadMasterOptions() {
    if (Get.isRegistered<MasterDataService>()) {
      final master = Get.find<MasterDataService>();
      final classes = master.getAllClassesCombined();
      if (classes.isNotEmpty) {
        final classNames = classes.map((c) => c['className'] as String).where((name) => name.isNotEmpty).toSet().toList();
        if (classNames.isNotEmpty) {
          availableClasses.assignAll(classNames);
          selectedClass.value = classNames.first;
        }
      }

      final teachers = master.getAllTeachersCombined();
      if (teachers.isNotEmpty) {
        final teacherNames = teachers.map((t) => t['name'] as String).where((name) => name.isNotEmpty).toSet().toList();
        if (teacherNames.isNotEmpty) {
          availableTeachers.assignAll(teacherNames);
          if (teacherNames.contains('Saiful Anwar., S.Kom.,Gr')) {
            selectedTeacher.value = 'Saiful Anwar., S.Kom.,Gr';
          } else {
            selectedTeacher.value = teacherNames.first;
          }
        }
      }
    }
  }

  void togglePasswordVisibility() {
    isObscure.value = !isObscure.value;
  }

  Future<void> pickPhoto() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );
      if (file != null) {
        photoPath.value = file.path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuka kamera: $e');
    }
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final nisn = nisnController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || nisn.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Nama Lengkap dan NISN Siswa wajib diisi!',
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    final String nisVal = nisController.text.trim().isNotEmpty ? nisController.text.trim() : '26.$nisn';
    final String chosenTeacher = selectedTeacher.value;
    final String chosenClass = selectedClass.value;

    final newUser = UserModel(
      id: 'usr-$nisn',
      email: '$nisn@smkn7.sch.id',
      name: name,
      nis: nisVal,
      nisn: nisn,
      className: chosenClass,
      role: 'siswa',
      religion: selectedReligion.value,
      address: addressController.text.trim(),
      hobby: hobbyController.text.trim(),
      ambition: ambitionController.text.trim(),
      favoriteSport: sportController.text.trim(),
      favoriteFood: foodController.text.trim(),
      favoriteSubject: subjectController.text.trim(),
      uniqueness: uniquenessController.text.trim(),
      homeroomTeacher: chosenTeacher,
      waliKelas: chosenTeacher,
      homeroomTeacherSignature: 'Telah Disetujui Wali Kelas SMKN 7',
      isProfileCompleted: true,
      totalStreak: 0,
      totalPoints: 0,
      createdAt: DateTime.now(),
    );

    // Register student to MasterDataService online/local
    if (Get.isRegistered<MasterDataService>()) {
      final master = Get.find<MasterDataService>();
      master.addLocalStudent(newUser);
      await master.addStudentToSupabase(
        customId: 'usr-$nisn',
        name: name,
        email: '$nisn@smkn7.sch.id',
        nis: nisVal,
        nisn: nisn,
        className: chosenClass,
        homeroomTeacher: chosenTeacher,
        waliKelas: chosenTeacher,
        religion: selectedReligion.value,
      );
    }

    final success = await _authService.registerUser(newUser, password.isNotEmpty ? password : nisn);
    isLoading.value = false;

    if (success) {
      Get.offAllNamed(Routes.DASHBOARD);
      Get.snackbar(
        'Pendaftaran Berhasil! 🎉',
        'Selamat datang $name! Anda telah terdaftar di kelas $chosenClass pembina $chosenTeacher.',
        backgroundColor: Colors.teal.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  void onClose() {
    nisnController.dispose();
    nisController.dispose();
    nameController.dispose();
    classController.dispose();
    teacherController.dispose();
    addressController.dispose();
    hobbyController.dispose();
    ambitionController.dispose();
    sportController.dispose();
    foodController.dispose();
    subjectController.dispose();
    uniquenessController.dispose();
    super.onClose();
  }
}
