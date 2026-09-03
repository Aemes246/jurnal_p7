import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/journal_controller.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/custom_button.dart';
import '../../../theme/app_colors.dart';

class JournalEntryView extends GetView<JournalController> {
  const JournalEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Jurnal & Refleksi Harian'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  FaIcon(FontAwesomeIcons.lightbulb, color: AppColors.primary, size: 20),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Refleksikan hal-hal baik yang Anda lakukan hari ini beserta tantangan yang berhasil dilalui.',
                      style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: controller.noteController,
              labelText: 'Catatan Refleksi',
              hintText: 'Tuliskan pengalaman atau kebaikan yang Anda rasakan hari ini...',
              prefixIcon: Icons.edit_note_rounded,
              maxLines: 4,
            ),
            const SizedBox(height: 20),

            const Text(
              'Unggah Bukti / Foto (Opsional)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Obx(() {
              if (controller.imagePath.value.isNotEmpty) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(controller.imagePath.value),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const FaIcon(FontAwesomeIcons.xmark, color: Colors.white, size: 16),
                          onPressed: () => controller.imagePath.value = '',
                        ),
                      ),
                    ),
                  ],
                );
              }
              return InkWell(
                onTap: controller.pickImage,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.image, color: AppColors.primary, size: 24),
                      SizedBox(height: 8),
                      Text('Pilih Foto dari Galeri', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 28),

            Obx(
              () => CustomButton(
                text: 'Simpan Refleksi Jurnal',
                isLoading: controller.isSaving.value,
                onPressed: controller.saveJournalEntry,
                icon: Icons.bookmark_add_outlined,
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              'Riwayat Refleksi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Obx(
              () => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.logs.length,
                itemBuilder: (context, index) {
                  final log = controller.logs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const FaIcon(FontAwesomeIcons.bookOpen, color: AppColors.primary, size: 16),
                      ),
                      title: Text(log.note ?? 'Kebiasaan Terselesaikan'),
                      subtitle: Text(
                        'Tanggal: ${log.date.day}/${log.date.month}/${log.date.year}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+${log.earnedPoints} Pts',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
