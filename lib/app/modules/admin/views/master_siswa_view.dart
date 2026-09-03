import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/master_siswa_controller.dart';
import '../../../theme/app_colors.dart';

class MasterSiswaView extends GetView<MasterSiswaController> {
  const MasterSiswaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '👑 Master Data Siswa (Superadmin)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        backgroundColor: Colors.purple.shade900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
            onPressed: () => controller.refreshData(),
            tooltip: 'Refresh Data Supabase',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStudentSheet(context, controller),
        backgroundColor: Colors.purple.shade800,
        icon: const FaIcon(FontAwesomeIcons.userGraduate, size: 16, color: Colors.white),
        label: const Text('Tambah Siswa', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // STATS HEADER CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade900, Colors.purple.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'DATA MASTER SISWA SMKN 7',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Obx(
                          () => Text(
                            '${controller.allStudents.length} Siswa Terdaftar',
                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${controller.allStudents.length}',
                                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                              const Text('Total Siswa', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${controller.masterDataService.supabaseStudents.length}',
                                style: const TextStyle(color: Colors.cyanAccent, fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                              const Text('Supabase Cloud ☁️', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${controller.allStudents.length}',
                                style: const TextStyle(color: Colors.amberAccent, fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                              const Text('Siswa Terdaftar', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SEARCH & FILTER ROW
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => TextField(
                        controller: controller.searchController,
                        onChanged: (val) => controller.searchQuery.value = val,
                        decoration: InputDecoration(
                          hintText: '🔍 Cari Nama Siswa, NIS, NISN...',
                          hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          prefixIcon: const Icon(Icons.search_rounded, color: Colors.purple, size: 20),
                          suffixIcon: controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    controller.searchController.clear();
                                    controller.searchQuery.value = '';
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // FILTER CLASS DROPDOWN
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedClassFilter.value,
                          icon: const Icon(Icons.filter_list_rounded, color: Colors.purple, size: 20),
                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                          items: controller.availableClasses.map((String className) {
                            return DropdownMenuItem<String>(
                              value: className,
                              child: Text(className),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) controller.selectedClassFilter.value = val;
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // SECTION HEADER & LIST
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Murid SMKN 7',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Obx(
                    () => Text(
                      'Menampilkan ${controller.filteredStudents.length} siswa',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Obx(() {
                final list = controller.filteredStudents;

                if (list.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(30),
                    alignment: Alignment.center,
                    child: const Column(
                      children: [
                        FaIcon(FontAwesomeIcons.graduationCap, size: 40, color: AppColors.textMuted),
                        SizedBox(height: 10),
                        Text(
                          'Tidak ada data siswa yang cocok dengan filter.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final s = list[index];
                    final String waliKelas = s['waliKelas'] ?? 'Belum Ditentukan';
                    final String guruWali = s['guruWali'] ?? s['homeroomTeacher'] ?? 'Belum Ditentukan';

                    return InkWell(
                      onTap: () => _showStudentDetailModal(context, s),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                                  child: Text(
                                    (s['name'] as String).substring(0, 1).toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              s['name'],
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                          ),
                                          if (s['isSupabase'])
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.cyan.shade50,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Supabase ☁️',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.cyan.shade900,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Kelas: ${s['className']} • NIS: ${s['nis']} • NISN: ${s['nisn']}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_rounded, color: Colors.indigo, size: 20),
                                    tooltip: 'Edit / Update Data Siswa',
                                    onPressed: () => _showEditStudentSheet(context, controller, s),
                                  ),
                                  if (s['isSupabase'])
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                      onPressed: () {
                                        Get.defaultDialog(
                                          title: 'Hapus Siswa?',
                                          middleText: 'Apakah Anda yakin ingin menghapus data ${s['name']} dari Supabase?',
                                          textConfirm: 'Hapus',
                                          textCancel: 'Batal',
                                          confirmTextColor: Colors.white,
                                          buttonColor: Colors.red,
                                          onConfirm: () {
                                            Get.back();
                                            controller.deleteStudent(s['id'], s['name']);
                                          },
                                        );
                                      },
                                    ),
                                ],
                              ),

                              const Divider(height: 16, color: Color(0xFFF1F5F9)),

                            // DETAILED TEACHER ASSIGNMENTS (Wali Kelas Rombel vs Guru Wali Pembina)
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const FaIcon(FontAwesomeIcons.school, size: 12, color: Colors.indigo),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Wali Kelas Rombel',
                                              style: TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              waliKelas,
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Row(
                                    children: [
                                      const FaIcon(FontAwesomeIcons.userCheck, size: 12, color: Colors.purple),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Guru Wali Pembina',
                                              style: TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              guruWali,
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // DETAIL MODAL FOR STUDENT BIODATA & MASTER
  // ==========================================
  void _showStudentDetailModal(BuildContext context, Map<String, dynamic> student) {
    final String waliKelas = student['waliKelas'] ?? 'Belum Ditentukan';
    final String guruWali = student['guruWali'] ?? student['homeroomTeacher'] ?? 'Belum Ditentukan';

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      (student['name'] as String).substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student['name'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Kelas: ${student['className']}',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.indigo),
                    tooltip: 'Edit / Update Data Siswa',
                    onPressed: () {
                      Get.back();
                      _showEditStudentSheet(context, controller, student);
                    },
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const FaIcon(FontAwesomeIcons.xmark, size: 18, color: AppColors.textMuted),
                  ),
                ],
              ),
              const Divider(height: 24),

              // TEACHERS DETAIL BANNER
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.school, color: Colors.indigo, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Wali Kelas Rombel:', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                              Text(waliKelas, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.indigo.shade900)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      children: [
                        const FaIcon(FontAwesomeIcons.userCheck, color: Colors.purple, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Guru Wali Pembina Jurnal:', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                              Text(guruWali, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.purple.shade900)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text('Informasi Biodata Siswa:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 10),

              _buildDetailTile(Icons.numbers_rounded, 'NISN', student['nisn']),
              _buildDetailTile(Icons.badge_rounded, 'NIS', student['nis']),
              _buildDetailTile(Icons.phone_android_rounded, 'No. HP / WhatsApp', student['phone'] ?? '0812-3456-7890'),
              _buildDetailTile(Icons.mosque_rounded, 'Agama', student['religion'] ?? 'Islam'),
              _buildDetailTile(Icons.home_rounded, 'Alamat', student['address']),
              _buildDetailTile(Icons.star_rounded, 'Cita-cita', student['ambition']),
              _buildDetailTile(Icons.sports_soccer_rounded, 'Hobi & Olahraga', '${student['hobby']} • ${student['favoriteSport']}'),
              _buildDetailTile(Icons.fastfood_rounded, 'Makanan Kesukaan', student['favoriteFood']),
              _buildDetailTile(Icons.menu_book_rounded, 'Mapel Favorit', student['favoriteSubject']),
              _buildDetailTile(Icons.auto_awesome_rounded, 'Keunikan Diri', student['uniqueness']),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => controller.openWhatsApp(student['phone'] ?? '081234567890', student['name']),
                  icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 18),
                  label: const Text('Chat WhatsApp 💬', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text('Tutup Detail Siswa', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailTile(IconData icon, String title, dynamic value) {
    final String valStr = (value != null && value.toString().trim().isNotEmpty) ? value.toString() : '-';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.purple.shade700),
          const SizedBox(width: 10),
          Text('$title: ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          Expanded(
            child: Text(
              valStr,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStudentSheet(BuildContext context, MasterSiswaController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '➕ Tambah Siswa Baru (Supabase)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap Siswa',
                  hintText: 'Contoh: KHALIL AKHDAN IBRAHIM',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.nisnController,
                      decoration: InputDecoration(
                        labelText: 'NISN',
                        hintText: '113458398',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.numbers_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller.nisController,
                      decoration: InputDecoration(
                        labelText: 'NIS (Opsional)',
                        hintText: '26.06775',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.badge_rounded),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                controller: controller.classController,
                decoration: InputDecoration(
                  labelText: 'Kelas',
                  hintText: 'Contoh: X DKV 1, XI TJKT 2',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.class_rounded),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: controller.phoneController,
                decoration: InputDecoration(
                  labelText: 'No. HP / WhatsApp',
                  hintText: '081234567890',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone_android_rounded),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: controller.waliKelasController,
                decoration: InputDecoration(
                  labelText: 'Wali Kelas Rombel',
                  hintText: 'Aminah Tajudin., S.Pd.I',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.school_rounded),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: controller.teacherController,
                decoration: InputDecoration(
                  labelText: 'Guru Wali Pembina',
                  hintText: 'Saiful Anwar., S.Kom.,Gr',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.supervisor_account_rounded),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => controller.addNewStudent(),
                  icon: const Icon(Icons.cloud_upload_rounded),
                  label: const Text('Simpan Data Siswa ke Supabase', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showEditStudentSheet(BuildContext context, MasterSiswaController controller, Map<String, dynamic> student) {
    controller.nameController.text = student['name'] ?? '';
    controller.nisnController.text = student['nisn'] ?? '';
    controller.nisController.text = student['nis'] ?? '';
    controller.phoneController.text = student['phone'] ?? '';
    controller.emailController.text = student['email'] ?? '';
    controller.religionValue.value = student['religion'] ?? 'Islam';

    final classes = controller.masterDataService.getAllClassesCombined();
    final classNames = classes.map((c) => c['className'] as String).where((n) => n.isNotEmpty).toSet().toList();
    if (classNames.isEmpty) classNames.add('X DKV 1');

    final teachers = controller.masterDataService.getAllTeachersCombined();
    final teacherNames = teachers.map((t) => t['name'] as String).where((n) => n.isNotEmpty).toSet().toList();
    if (teacherNames.isEmpty) teacherNames.add('Saiful Anwar., S.Kom.,Gr');

    final currClass = (student['className'] as String? ?? '').trim();
    controller.selectedClass.value = classNames.contains(currClass) ? currClass : classNames.first;

    final currWali = (student['waliKelas'] as String? ?? '').trim();
    controller.selectedWaliKelas.value = teacherNames.contains(currWali) ? currWali : teacherNames.first;

    final currPembina = (student['guruWali'] as String? ?? student['homeroomTeacher'] as String? ?? '').trim();
    controller.selectedHomeroomTeacher.value = teacherNames.contains(currPembina) ? currPembina : teacherNames.first;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '✏️ Edit / Update Data Siswa',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap Siswa',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.nisnController,
                      decoration: InputDecoration(
                        labelText: 'NISN',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.numbers_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller.nisController,
                      decoration: InputDecoration(
                        labelText: 'NIS Siswa',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.badge_rounded),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Obx(() => DropdownButtonFormField<String>(
                value: classNames.contains(controller.selectedClass.value)
                    ? controller.selectedClass.value
                    : classNames.first,
                decoration: InputDecoration(
                  labelText: 'Kelas / Rombel',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.class_rounded),
                ),
                items: classNames.map((c) => DropdownMenuItem(value: c, child: Text('🏫 $c'))).toList(),
                onChanged: (val) {
                  if (val != null) controller.selectedClass.value = val;
                },
              )),
              const SizedBox(height: 12),

              Obx(() => DropdownButtonFormField<String>(
                value: teacherNames.contains(controller.selectedWaliKelas.value)
                    ? controller.selectedWaliKelas.value
                    : teacherNames.first,
                decoration: InputDecoration(
                  labelText: 'Wali Kelas Rombel',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.school_rounded),
                ),
                items: teacherNames.map((t) => DropdownMenuItem(value: t, child: Text('👩‍🏫 $t'))).toList(),
                onChanged: (val) {
                  if (val != null) controller.selectedWaliKelas.value = val;
                },
              )),
              const SizedBox(height: 12),

              Obx(() => DropdownButtonFormField<String>(
                value: teacherNames.contains(controller.selectedHomeroomTeacher.value)
                    ? controller.selectedHomeroomTeacher.value
                    : teacherNames.first,
                decoration: InputDecoration(
                  labelText: 'Guru Wali Pembina (Lintas Kelas)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.supervisor_account_rounded),
                ),
                items: teacherNames.map((t) => DropdownMenuItem(value: t, child: Text('👨‍🏫 $t'))).toList(),
                onChanged: (val) {
                  if (val != null) controller.selectedHomeroomTeacher.value = val;
                },
              )),
              const SizedBox(height: 12),

              TextField(
                controller: controller.phoneController,
                decoration: InputDecoration(
                  labelText: 'No. HP / WhatsApp',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone_android_rounded),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => controller.updateStudent(student['id']),
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Simpan Pembaruan Data Siswa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
