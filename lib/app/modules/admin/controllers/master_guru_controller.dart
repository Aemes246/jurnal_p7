import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/services/master_data_service.dart';

class MasterGuruController extends GetxController {
  final MasterDataService masterDataService = Get.find<MasterDataService>();

  final searchQuery = ''.obs;
  final selectedClassFilter = 'Semua Kelas'.obs;
  final searchController = TextEditingController();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final nipController = TextEditingController();
  final phoneController = TextEditingController();
  final classController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    masterDataService.loadSavedProfilesFromStorage();
    masterDataService.savedProfileOverrides.listen((_) => update());
  }

  @override
  void onReady() {
    super.onReady();
    masterDataService.loadSavedProfilesFromStorage();
  }

  List<Map<String, dynamic>> get allTeachers => masterDataService.getAllTeachersCombined();

  List<Map<String, dynamic>> get filteredTeachers {
    final query = searchQuery.value.trim().toLowerCase();
    final filterClass = selectedClassFilter.value;

    return allTeachers.where((t) {
      final nameMatches = (t['name'] as String).toLowerCase().contains(query);
      final emailMatches = (t['email'] as String).toLowerCase().contains(query);
      final nipMatches = (t['nip'] as String).toLowerCase().contains(query);
      final phoneMatches = (t['phone'] as String? ?? '').toLowerCase().contains(query);
      final classMatches = (t['assignedClass'] as String).toLowerCase().contains(query);

      final matchesQuery = query.isEmpty || nameMatches || emailMatches || nipMatches || phoneMatches || classMatches;

      if (filterClass == 'Semua Kelas') {
        return matchesQuery;
      } else {
        return matchesQuery && (t['assignedClass'] as String).contains(filterClass);
      }
    }).toList();
  }

  void refreshData() {
    masterDataService.loadSavedProfilesFromStorage();
    masterDataService.fetchTeachersFromSupabase();
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

    final message = Uri.encodeComponent('Halo Bapak/Ibu $name, salam dari Admin Jurnal Kebiasaan Baik SMKN 7 Samarinda.');
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

  Future<void> addNewTeacher() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final assignedClass = classController.text.trim();
    final nip = nipController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      Get.snackbar(
        'Form Belum Lengkap ⚠️',
        'Nama dan Email wajib diisi.',
        backgroundColor: Colors.amber.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final success = await masterDataService.addTeacherToSupabase(
      name: name,
      email: email,
      assignedClass: assignedClass.isNotEmpty ? assignedClass : 'Wali Kelas',
      nip: nip,
      phone: phone.isNotEmpty ? phone : '08115595606',
    );

    if (success) {
      nameController.clear();
      emailController.clear();
      nipController.clear();
      phoneController.clear();
      classController.clear();
      Get.back(); // close modal
      Get.snackbar(
        'Guru Berhasil Ditambahkan! 🎉',
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

  final selectedAssignedClass = 'X DKV 1'.obs;

  Future<void> updateTeacher(String id) async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final assignedClass = selectedAssignedClass.value.isNotEmpty ? selectedAssignedClass.value : classController.text.trim();
    final nip = nipController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      Get.snackbar(
        'Form Belum Lengkap ⚠️',
        'Nama dan Email wajib diisi.',
        backgroundColor: Colors.amber.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final success = await masterDataService.updateTeacherInSupabase(
      id: id,
      name: name,
      email: email,
      assignedClass: assignedClass.isNotEmpty ? assignedClass : 'X DKV 1',
      nip: nip,
      phone: phone.isNotEmpty ? phone : '08115595606',
    );

    if (success) {
      nameController.clear();
      emailController.clear();
      nipController.clear();
      phoneController.clear();
      classController.clear();
      Get.back(); // close modal
      Get.snackbar(
        'Data Guru Diperbarui! 🎉',
        'Data $name berhasil diperbarui di Supabase Cloud.',
        backgroundColor: Colors.purple.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Gagal Memperbarui ❌',
        'Terjadi kendala saat menyimpan pembaruan ke Supabase.',
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteTeacher(String id, String name) async {
    final success = await masterDataService.deleteTeacherFromSupabase(id);
    if (success) {
      Get.snackbar(
        'Data Dihapus 🗑️',
        'Guru $name telah dihapus dari Supabase.',
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
    nipController.dispose();
    phoneController.dispose();
    classController.dispose();
    super.onClose();
  }
}
