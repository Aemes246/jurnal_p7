import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/master_data_service.dart';
import '../../../data/models/user_model.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/custom_button.dart';
import '../../../theme/app_colors.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  static const List<String> _religions = [
    'Islam',
    'Kristen',
    'Katolik',
    'Hindu',
    'Buddha',
    'Khonghucu',
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil & Biodata Lengkap'),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.rightFromBracket, size: 18, color: Colors.red),
            onPressed: controller.logout,
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Obx(() {
          final user = authService.currentUser.value;
          final isTeacher = user?.role == 'guru' || user?.role == 'guru_wali';
          final isSuperadmin = user?.role == 'superadmin';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar & Header Badge
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 100,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isTeacher
                                  ? [Colors.indigo.shade800, Colors.indigo.shade600]
                                  : isSuperadmin
                                      ? [Colors.purple.shade900, Colors.purple.shade700]
                                      : [AppColors.primary, AppColors.primaryLight],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(13),
                                  child: Image.file(File(user.avatarUrl!), fit: BoxFit.cover),
                                )
                              : Center(
                                  child: Text(
                                    user?.name.substring(0, 1).toUpperCase() ?? 'U',
                                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? 'Siswa SMKN 7',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isSuperadmin
                          ? '👑 Super Administrator SMKN 7'
                          : isTeacher
                              ? '👨‍🏫 Guru Wali • SMKN 7 Samarinda'
                              : '👦 Siswa Kelas ${user?.className ?? 'X DKV 1'}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isTeacher ? Colors.indigo.shade800 : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Notice Banner Scenario Explanation
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.blue.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: Colors.blue.shade900, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isTeacher
                            ? 'Skenario Data Guru: Data Guru Wali telah diikat oleh Superadmin. Silakan lengkapi NIP & Kontak untuk integrasi Web Sekolah.'
                            : 'Skenario Data Terikat: Data Master (Nama, NIS, NISN, Kelas, & Guru Wali) sudah ditentukan Superadmin & terkunci 🔒. Anda tinggal melengkapi biodata sisanya.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // SECTION 1: DATA MASTER TERIKAT SEKOLAH (LOCKED 🔒)
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
                        Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Data Master Resmi Sekolah (LOCKED 🔒)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ditetapkan Superadmin dari data sekolah. Tidak perlu diisi ulang.',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const Divider(height: 20),

                    _buildLockedItem('Nama Lengkap', user?.name ?? '-'),
                    if (!isTeacher && !isSuperadmin) ...[
                      _buildLockedItem('NISN (Username & Password)', user?.nisn ?? '-'),
                      _buildLockedItem('NIS Siswa', user?.nis ?? '-'),
                      _buildLockedItem('Kelas / Rombel', user?.className ?? '-'),
                      _buildLockedItem('Wali Kelas Rombel', _getWaliKelasRombelName(user)),
                      _buildLockedItem('Guru Wali Pembina (Terikat)', user?.homeroomTeacher ?? 'Saiful Anwar., S.Kom.,Gr'),
                    ],
                    if (isTeacher) ...[
                      _buildLockedItem('Email Akun Login Guru', user?.email ?? '-'),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SECTION 2: FORM MELENGKAPI SISANYA (EDITABLE FORM)
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
                        Icon(Icons.edit_note_rounded, color: isTeacher ? Colors.indigo.shade800 : AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isTeacher ? 'Melengkapi Data Guru & Integrasi API' : 'Melengkapi Biodata Diri ("Ayo Berkenalan!")',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isTeacher ? Colors.indigo.shade800 : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isTeacher ? 'Lengkapi NIP, Kontak & Pilih Rombel Wali Kelas.' : 'Silakan lengkapi sisa biodata Anda di bawah ini.',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const Divider(height: 20),

                    // Dropdown Agama
                    const Text('Agama / Kepercayaan (Untuk Format Ibadah):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        initialValue: controller.selectedReligion.value,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        items: _religions
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

                    if (!isTeacher && !isSuperadmin) ...[
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
                        hintText: 'contoh: Software Engineer / Game Developer',
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
                        controller: controller.favoriteSportController,
                        labelText: 'Olahraga Kesukaan',
                        hintText: 'contoh: Sepak Bola & Jogging Pagi',
                        prefixIcon: Icons.directions_run_outlined,
                      ),
                      const SizedBox(height: 12),

                      CustomTextField(
                        controller: controller.favoriteFoodController,
                        labelText: 'Makanan Kesukaan',
                        hintText: 'contoh: Nasi Goreng & Soto Banjar',
                        prefixIcon: Icons.restaurant_outlined,
                      ),
                      const SizedBox(height: 12),

                      CustomTextField(
                        controller: controller.favoriteSubjectController,
                        labelText: 'Mata Pelajaran Favorit',
                        hintText: 'contoh: DKV & PPLG',
                        prefixIcon: Icons.menu_book_outlined,
                      ),
                      const SizedBox(height: 12),

                      CustomTextField(
                        controller: controller.uniquenessController,
                        labelText: 'Keunikan Saya Yaitu',
                        hintText: 'contoh: Disiplin bangun jam 04.30 pagi dan tepat waktu.',
                        prefixIcon: Icons.auto_awesome_outlined,
                        maxLines: 2,
                      ),
                    ],

                    if (isTeacher) ...[
                      CustomTextField(
                        controller: controller.nipController,
                        labelText: 'NIP Guru Wali',
                        hintText: 'masukkan NIP resmi Guru',
                        prefixIcon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 12),

                      CustomTextField(
                        controller: controller.phoneController,
                        labelText: 'Nomor WhatsApp / Telp',
                        hintText: 'contoh: 081234567890',
                        prefixIcon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: 12),

                      const Text('Wali Kelas (Pilih Rombel Kelas):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Obx(() {
                        final classNames = controller.availableClasses;
                        final currentVal = classNames.contains(controller.selectedAssignedClass.value)
                            ? controller.selectedAssignedClass.value
                            : (classNames.isNotEmpty ? classNames.first : 'X DKV 1');
                        return DropdownButtonFormField<String>(
                          value: currentVal,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            prefixIcon: const Icon(Icons.school_rounded, color: Colors.indigo, size: 20),
                          ),
                          items: classNames.map((c) => DropdownMenuItem(value: c, child: Text('🏫 $c', style: const TextStyle(fontSize: 13)))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              controller.selectedAssignedClass.value = val;
                            }
                          },
                        );
                      }),
                      const SizedBox(height: 14),

                      // Web School Endpoint Integration Banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.purple.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.api_rounded, color: Colors.purple, size: 18),
                                const SizedBox(width: 8),
                                Text('Endpoint API Web Sekolah (Dapodik / SIMAK):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple.shade900)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.apiEndpointController.text,
                              style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.purple),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Save Profile Button
                    Obx(
                      () => CustomButton(
                        text: 'Simpan & Lengkapi Data Profil',
                        isLoading: controller.isLoading.value,
                        onPressed: controller.saveProfile,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: controller.logout,
                  icon: const Icon(Icons.logout, color: Colors.red, size: 18),
                  label: const Text(
                    'Keluar dari Akun',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        }),
      ),
    );
  }

  String _getWaliKelasRombelName(UserModel? user) {
    if (user == null) return 'Dra. Hajah Nurhayati';
    if (user.waliKelas != null && user.waliKelas!.isNotEmpty && user.waliKelas != user.homeroomTeacher && user.waliKelas != 'Guru Wali Pembina') {
      return user.waliKelas!;
    }
    if (Get.isRegistered<MasterDataService>()) {
      return Get.find<MasterDataService>().findWaliKelasForClass(user.className ?? 'XI PPLG 1');
    }
    return 'Dra. Hajah Nurhayati';
  }

  Widget _buildLockedItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                const Icon(Icons.lock_rounded, size: 14, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
