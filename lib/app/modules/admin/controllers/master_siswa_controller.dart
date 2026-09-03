import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/services/master_data_service.dart';

class MasterSiswaController extends GetxController {
  final MasterDataService masterDataService = Get.find<MasterDataService>();

  final searchQuery = ''.obs;
  final selectedClassFilter = 'Semua Kelas'.obs;
  final searchController = TextEditingController();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final nisController = TextEditingController();
  final nisnController = TextEditingController();
  final phoneController = TextEditingController();
  final classController = TextEditingController();
  final waliKelasController = TextEditingController(); // Wali Kelas Rombel
  final teacherController = TextEditingController(); // Guru Wali Pembina
  final religionValue = 'Islam'.obs;

  List<Map<String, dynamic>> get allStudents => masterDataService.getAllStudentsCombined();

  List<String> get availableClasses {
    final classesSet = <String>{'Semua Kelas'};
    for (var c in masterDataService.getAllClassesCombined()) {
      final cName = c['className'] as String?;
      if (cName != null && cName.isNotEmpty) {
        classesSet.add(cName);
      }
    }
    return classesSet.toList();
  }

  List<Map<String, dynamic>> get filteredStudents {
    final query = searchQuery.value.trim().toLowerCase();
    final filterClass = selectedClassFilter.value;

    return allStudents.where((s) {
      final nameMatches = (s['name'] as String).toLowerCase().contains(query);
      final nisMatches = (s['nis'] as String).toLowerCase().contains(query);
      final nisnMatches = (s['nisn'] as String).toLowerCase().contains(query);
      final phoneMatches = (s['phone'] as String? ?? '').toLowerCase().contains(query);
      final classMatches = (s['className'] as String).toLowerCase().contains(query);

      final matchesQuery = query.isEmpty || nameMatches || nisMatches || nisnMatches || phoneMatches || classMatches;

      if (filterClass == 'Semua Kelas') {
        return matchesQuery;
      } else {
        return matchesQuery && (s['className'] as String) == filterClass;
      }
    }).toList();
  }

  void refreshData() {
    masterDataService.fetchStudentsFromSupabase();
  }

  Future<void> openWhatsApp(String rawPhone, String name) async {
    final cleanPhone = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.isEmpty) {
      Get.snackbar(
        'Nomor Tidak Valid ⚠️',
        'Nomor WhatsApp $name belum diisi.',
        backgroundColor: Colors.amber.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    String waNumber = cleanPhone;
    if (cleanPhone.startsWith('0')) {
      waNumber = '62${cleanPhone.substring(1)}';
    } else if (!cleanPhone.startsWith('62')) {
      waNumber = '62$cleanPhone';
    }

    final message = Uri.encodeComponent('Halo $name, salam dari Admin Jurnal Kebiasaan Baik SMKN 7 Samarinda.');
    final url = Uri.parse('https://wa.me/$waNumber?text=$message');

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      Get.snackbar(
        'Buka WhatsApp Gagal ⚠️',
        'Tidak dapat membuka tautan WhatsApp.',
        backgroundColor: Colors.amber.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> addNewStudent() async {
    final name = nameController.text.trim();
    final nisn = nisnController.text.trim();
    final nis = nisController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim().isNotEmpty
        ? emailController.text.trim()
        : '$nisn@smkn7.sch.id';
    final className = classController.text.trim();
    final waliKelas = waliKelasController.text.trim();
    final homeroomTeacher = teacherController.text.trim();

    if (name.isEmpty || nisn.isEmpty) {
      Get.snackbar(
        'Form Belum Lengkap ⚠️',
        'Nama dan NISN siswa wajib diisi.',
        backgroundColor: Colors.amber.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final success = await masterDataService.addStudentToSupabase(
      name: name,
      email: email,
      nis: nis.isNotEmpty ? nis : '26.$nisn',
      nisn: nisn,
      phone: phone.isNotEmpty ? phone : '0812-3456-7890',
      className: className.isNotEmpty ? className : 'X DKV 1',
      waliKelas: waliKelas.isNotEmpty ? waliKelas : null,
      homeroomTeacher: homeroomTeacher.isNotEmpty ? homeroomTeacher : 'Saiful Anwar., S.Kom.,Gr',
      religion: religionValue.value,
    );

    if (success) {
      nameController.clear();
      emailController.clear();
      nisController.clear();
      nisnController.clear();
      phoneController.clear();
      classController.clear();
      waliKelasController.clear();
      teacherController.clear();
      Get.back(); // close modal
      Get.snackbar(
        'Siswa Berhasil Ditambahkan! 🎉',
        'Data $name tersimpan di Supabase Cloud & Master Data.',
        backgroundColor: Colors.purple.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Gagal Menyimpan ❌',
        'Terjadi kendala saat menyimpan ke Supabase.',
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  final selectedClass = 'X DKV 1'.obs;
  final selectedWaliKelas = 'Saiful Anwar., S.Kom.,Gr'.obs;
  final selectedHomeroomTeacher = 'Saiful Anwar., S.Kom.,Gr'.obs;

  Future<void> updateStudent(String id) async {
    final name = nameController.text.trim();
    final nisn = nisnController.text.trim();
    final nis = nisController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim().isNotEmpty
        ? emailController.text.trim()
        : '$nisn@smkn7.sch.id';
    final className = selectedClass.value.isNotEmpty ? selectedClass.value : classController.text.trim();
    final waliKelas = selectedWaliKelas.value.isNotEmpty ? selectedWaliKelas.value : waliKelasController.text.trim();
    final homeroomTeacher = selectedHomeroomTeacher.value.isNotEmpty ? selectedHomeroomTeacher.value : teacherController.text.trim();

    if (name.isEmpty || nisn.isEmpty) {
      Get.snackbar(
        'Form Belum Lengkap ⚠️',
        'Nama dan NISN siswa wajib diisi.',
        backgroundColor: Colors.amber.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final success = await masterDataService.updateStudentInSupabase(
      id: id,
      name: name,
      email: email,
      nis: nis.isNotEmpty ? nis : '26.$nisn',
      nisn: nisn,
      phone: phone.isNotEmpty ? phone : '0812-3456-7890',
      className: className.isNotEmpty ? className : 'X DKV 1',
      waliKelas: waliKelas.isNotEmpty ? waliKelas : 'Saiful Anwar., S.Kom.,Gr',
      homeroomTeacher: homeroomTeacher.isNotEmpty ? homeroomTeacher : 'Saiful Anwar., S.Kom.,Gr',
      religion: religionValue.value,
    );

    if (success) {
      nameController.clear();
      emailController.clear();
      nisController.clear();
      nisnController.clear();
      phoneController.clear();
      classController.clear();
      waliKelasController.clear();
      teacherController.clear();
      Get.back(); // close modal
      Get.snackbar(
        'Data Siswa Diperbarui! 🎉',
        'Data $name berhasil diperbarui di Supabase Cloud.',
        backgroundColor: Colors.purple.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Gagal Memperbarui ❌',
        'Terjadi kendala saat menyimpan ke Supabase.',
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteStudent(String id, String name) async {
    final success = await masterDataService.deleteStudentFromSupabase(id);
    if (success) {
      Get.snackbar(
        'Data Dihapus 🗑️',
        'Siswa $name telah dihapus dari Supabase.',
        backgroundColor: Colors.purple.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    nameController.dispose();
    emailController.dispose();
    nisController.dispose();
    nisnController.dispose();
    phoneController.dispose();
    classController.dispose();
    waliKelasController.dispose();
    teacherController.dispose();
    super.onClose();
  }
}
