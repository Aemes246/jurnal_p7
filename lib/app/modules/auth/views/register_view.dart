import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/custom_button.dart';
import '../../../theme/app_colors.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pendaftaran Akun Siswa Baru'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.badge_rounded, color: AppColors.primary, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Silakan daftarkan akun siswa Anda. Pilih Kelas dan Guru Wali Anda. Setelah mendaftar, akun Anda akan otomatis terhubung ke daftar murid binaan Guru Wali yang dipilih.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // SECTION 1: DATA UTAMA SISWA (AKUN & KELAS)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.person_pin_rounded, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Data Utama Akun Siswa',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    CustomTextField(
                      controller: controller.nameController,
                      labelText: 'Nama Lengkap Siswa *',
                      hintText: 'contoh: KHALIL AKHDAN IBRAHIM',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: controller.nisnController,
                      labelText: 'Nomor NISN Siswa (Username) *',
                      hintText: 'masukkan 10 digit NISN',
                      prefixIcon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: controller.nisController,
                      labelText: 'Nomor NIS Siswa (Opsional)',
                      hintText: 'contoh: 26.06775',
                      prefixIcon: Icons.confirmation_number_outlined,
                    ),
                    const SizedBox(height: 12),

                    Obx(
                      () => CustomTextField(
                        controller: controller.passwordController,
                        labelText: 'Kata Sandi / Password *',
                        hintText: 'masukkan kata sandi akun Anda',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: controller.isObscure.value,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isObscure.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Dropdown Pilih Kelas
                    const Text('Pilih Kelas / Rombel Belajar *:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.selectedClass.value,
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: controller.availableClasses
                            .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.selectedClass.value = val;
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Dropdown Pilih Guru Wali (Combo box)
                    const Text('Pilih Guru Wali Binaannya *:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.selectedTeacher.value,
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: controller.availableTeachers
                            .map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(
                                    t,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: t.contains('Saiful Anwar') ? Colors.indigo.shade900 : AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.selectedTeacher.value = val;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // SECTION 2: FORM MELENGKAPI SISANYA ("Ayo Berkenalan!")
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.edit_note_rounded, color: AppColors.textPrimary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Melengkapi Biodata Diri ("Ayo Berkenalan!")',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Siswa dapat melengkapi biodata diri di bawah ini:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const Divider(height: 20),

                    const Text('Agama / Kepercayaan (Untuk Format Ibadah):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.selectedReligion.value,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: controller.religions
                            .map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.selectedReligion.value = val;
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 14),

                    CustomTextField(
                      controller: controller.addressController,
                      labelText: 'Saya Tinggal Di (Alamat Rumah)',
                      hintText: 'contoh: Jl. Aminah Syukur No. 82, Samarinda',
                      prefixIcon: Icons.home_outlined,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: controller.ambitionController,
                      labelText: 'Cita-Cita Saya',
                      hintText: 'contoh: Software Engineer / Animator',
                      prefixIcon: Icons.star_outline_rounded,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: controller.hobbyController,
                      labelText: 'Hobi Saya',
                      hintText: 'contoh: Membaca & Pemrograman Web',
                      prefixIcon: Icons.sports_esports_outlined,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: controller.sportController,
                      labelText: 'Olahraga Kesukaan',
                      hintText: 'contoh: Sepak Bola & Jogging Pagi',
                      prefixIcon: Icons.directions_run_outlined,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: controller.foodController,
                      labelText: 'Makanan Kesukaan',
                      hintText: 'contoh: Nasi Goreng & Soto Banjar',
                      prefixIcon: Icons.restaurant_outlined,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: controller.subjectController,
                      labelText: 'Mata Pelajaran Favorit',
                      hintText: 'contoh: DKV & PPLG',
                      prefixIcon: Icons.menu_book_outlined,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      controller: controller.uniquenessController,
                      labelText: 'Keunikan Saya Yaitu',
                      hintText: 'contoh: Disiplin bangun jam 04.30 pagi dan selalu tepat waktu.',
                      prefixIcon: Icons.auto_awesome_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),

                    Obx(
                      () => CustomButton(
                        text: 'Daftar Akun Siswa Baru',
                        isLoading: controller.isLoading.value,
                        onPressed: controller.register,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
