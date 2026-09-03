import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/habit_controller.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/custom_button.dart';
import '../../../theme/app_colors.dart';

class AddHabitView extends GetView<HabitController> {
  const AddHabitView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buat Kebiasaan Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: controller.titleController,
              labelText: 'Nama Kebiasaan',
              hintText: 'misal: Membaca Al-Qur\'an 15 Menit',
              prefixIcon: Icons.edit_note_rounded,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: controller.descController,
              labelText: 'Deskripsi / Target',
              hintText: 'misal: Setiap selesai sholat Maghrib',
              prefixIcon: Icons.description_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            const Text(
              'Pilih Kategori',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                spacing: 8,
                children: [
                  _categoryChip('ibadah', 'Ibadah', AppColors.ibadah),
                  _categoryChip('belajar', 'Belajar', AppColors.belajar),
                  _categoryChip('kesehatan', 'Kesehatan', AppColors.kesehatan),
                  _categoryChip('kedisiplinan', 'Kedisiplinan', AppColors.kedisiplinan),
                ],
              ),
            ),
            const SizedBox(height: 28),

            CustomButton(
              text: 'Simpan Kebiasaan',
              onPressed: controller.saveNewHabit,
              icon: Icons.check_circle_outline_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(String val, String label, Color color) {
    final isSelected = controller.selectedCategory.value == val;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.bold,
        ),
      ),
      selected: isSelected,
      selectedColor: color,
      backgroundColor: color.withValues(alpha: 0.1),
      onSelected: (selected) {
        if (selected) controller.selectedCategory.value = val;
      },
    );
  }
}
