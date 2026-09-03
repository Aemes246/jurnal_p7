import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/habit_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/models/habit_log_model.dart';
import '../../../theme/app_colors.dart';

class JournalController extends GetxController {
  final HabitService _habitService = Get.find<HabitService>();
  final AuthService _authService = Get.find<AuthService>();
  final ImagePicker _picker = ImagePicker();

  final noteController = TextEditingController();
  final selectedHabitId = ''.obs;
  final imagePath = ''.obs;
  final isSaving = false.obs;

  RxList<HabitLogModel> get logs => _habitService.habitLogs;

  void pickImage() {
    final user = _authService.currentUser.value;
    final role = user?.role ?? 'siswa';
    if (role == 'guru' || role == 'guru_wali' || role == 'superadmin') {
      Get.snackbar('Mode Pemantauan 👁️', 'Guru Wali & Superadmin tidak dapat mengambil foto bukti.');
      return;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const FaIcon(FontAwesomeIcons.camera, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lampirkan Foto Bukti 📷',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Pilih sumber foto bukti kegiatan refleksi Anda',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FaIcon(FontAwesomeIcons.camera, color: Colors.teal.shade700, size: 20),
              ),
              title: const Text('Ambil Foto Kamera 📸', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Buka kamera hp / emulator secara langsung'),
              onTap: () {
                Get.back();
                _pickImageWithSource(ImageSource.camera);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const FaIcon(FontAwesomeIcons.image, color: Colors.indigo, size: 20),
              ),
              title: const Text('Pilih dari Galeri / File 🖼️', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Pilih foto bukti dari memori galeri'),
              onTap: () {
                Get.back();
                _pickImageWithSource(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageWithSource(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 70,
        maxWidth: 1024,
      );
      if (file != null) {
        imagePath.value = file.path;
      }
    } catch (e) {
      if (source == ImageSource.camera) {
        try {
          final XFile? file = await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 70,
            maxWidth: 1024,
          );
          if (file != null) {
            imagePath.value = file.path;
          }
          return;
        } catch (_) {}
      }
      Get.snackbar('Gagal Mengambil Foto', 'Pastikan izin kamera dan galeri telah diberikan.');
    }
  }

  void saveJournalEntry() async {
    final user = _authService.currentUser.value;
    final role = user?.role ?? 'siswa';
    if (role == 'guru' || role == 'guru_wali' || role == 'superadmin') {
      Get.snackbar(
        'Mode Pemantauan 👁️',
        'Guru Wali & Superadmin hanya dapat memantau refleksi siswa (Read-Only).',
        backgroundColor: Colors.indigo.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final note = noteController.text.trim();
    if (note.isEmpty) {
      Get.snackbar('Peringatan', 'Tuliskan catatan refleksi Anda hari ini');
      return;
    }

    isSaving.value = true;
    await Future.delayed(const Duration(milliseconds: 500));

    final targetHabitId = selectedHabitId.value.isEmpty ? 'h1' : selectedHabitId.value;
    final targetDate = _habitService.selectedDate.value;

    final newLog = HabitLogModel(
      id: 'log-${DateTime.now().millisecondsSinceEpoch}',
      habitId: targetHabitId,
      userId: _habitService.activeStudentId,
      date: targetDate,
      isCompleted: true,
      note: note,
      photoUrl: imagePath.value.isEmpty ? null : imagePath.value,
      earnedPoints: 10,
    );

    await _habitService.addOrUpdateHabitLog(newLog, religion: user?.religion);
    isSaving.value = false;

    noteController.clear();
    imagePath.value = '';
    
    Get.snackbar(
      'Jurnal Tersimpan',
      'Refleksi kebiasaan baik Anda berhasil dicatat!',
      backgroundColor: Colors.teal.shade700,
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }
}
