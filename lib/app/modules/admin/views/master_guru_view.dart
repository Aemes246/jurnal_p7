import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/master_guru_controller.dart';
import '../../../theme/app_colors.dart';
import '../../../data/models/school_data.dart';

class MasterGuruView extends GetView<MasterGuruController> {
  const MasterGuruView({super.key});

  List<StudentRecord> _getAssignedStudents(dynamic rawList) {
    if (rawList == null || rawList is! List) return [];
    return rawList.map((item) {
      if (item is StudentRecord) return item;
      if (item is Map) {
        return StudentRecord(
          nis: item['nis']?.toString() ?? '-',
          nisn: item['nisn']?.toString() ?? '-',
          name: item['name']?.toString() ?? 'Siswa',
          className: item['className']?.toString() ?? 'Siswa',
          homeroomTeacher: item['homeroomTeacher']?.toString() ?? 'Guru Wali',
          phone: item['phone']?.toString() ?? '0812-3456-7890',
        );
      }
      return const StudentRecord(nis: '-', nisn: '-', name: 'Siswa', className: '-', homeroomTeacher: '-');
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '👑 Master Guru Wali (Superadmin)',
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
        onPressed: () => _showAddTeacherSheet(context, controller),
        backgroundColor: Colors.purple.shade800,
        icon: const FaIcon(FontAwesomeIcons.userPlus, size: 16, color: Colors.white),
        label: const Text('Tambah Guru', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                            'DATA MASTER GURU WALI',
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
                            '${controller.allTeachers.length} Guru Terdaftar',
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
                                '${controller.allTeachers.length}',
                                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                              const Text('Total Guru Wali', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${controller.masterDataService.supabaseTeachers.length}',
                                style: const TextStyle(color: Colors.cyanAccent, fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                              const Text('Supabase Cloud ☁️', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${controller.allTeachers.length}',
                                style: const TextStyle(color: Colors.amberAccent, fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                              const Text('Guru Terdaftar', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SEARCH BAR
              Obx(
                () => TextField(
                  controller: controller.searchController,
                  onChanged: (val) => controller.searchQuery.value = val,
                  decoration: InputDecoration(
                    hintText: '🔍 Cari Nama Guru Wali, NIP, Email, atau Kelas...',
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

              const SizedBox(height: 16),

              // SECTION HEADER & LIST
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Guru Wali',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Obx(
                    () => Text(
                      'Menampilkan ${controller.filteredTeachers.length} data',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Obx(() {
                final list = controller.filteredTeachers;

                if (list.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(30),
                    alignment: Alignment.center,
                    child: const Column(
                      children: [
                        FaIcon(FontAwesomeIcons.folderOpen, size: 40, color: AppColors.textMuted),
                        SizedBox(height: 10),
                        Text(
                          'Tidak ada data guru yang cocok dengan pencarian.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          textAlign: TextAlign.center,
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
                    final t = list[index];
                    final List<StudentRecord> assignedStudents = _getAssignedStudents(t['assignedStudents']);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ExpansionTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        leading: InkWell(
                          onTap: () => _showTeacherDetailModal(context, t),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: t['isSupabase'] ? Colors.cyan.shade100 : Colors.purple.shade100,
                            child: Text(
                              (t['name'] as String).substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: t['isSupabase'] ? Colors.cyan.shade900 : Colors.purple.shade900,
                              ),
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _showTeacherDetailModal(context, t),
                                child: Text(
                                  t['name'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.info_outline_rounded, color: Colors.purple.shade700, size: 20),
                              onPressed: () => _showTeacherDetailModal(context, t),
                              tooltip: 'Lihat Detail Guru',
                              visualDensity: VisualDensity.compact,
                            ),
                            if (t['isSupabase'])
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.cyan.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.cyan.shade200,
                                  ),
                                ),
                                child: Text(
                                  'Supabase ☁️',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.cyan.shade900,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Wali Kelas: ${t['assignedClass']} • NIP: ${t['nip']}\nEmail: ${t['email']}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            color: Colors.grey.shade50,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Murid Binaannya (${(t['binaanStudents'] as List? ?? assignedStudents).length} Siswa):',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                                    ),
                                    Row(
                                      children: [
                                        TextButton.icon(
                                          onPressed: () => _showEditTeacherSheet(context, controller, t),
                                          icon: const Icon(Icons.edit_rounded, size: 14, color: Colors.indigo),
                                          label: const Text('Edit Guru', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigo)),
                                        ),
                                        TextButton.icon(
                                          onPressed: () => _showTeacherDetailModal(context, t),
                                          icon: const Icon(Icons.open_in_new_rounded, size: 14),
                                          label: const Text('Detail', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        ),
                                        if (t['isSupabase'])
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                                            onPressed: () {
                                              Get.defaultDialog(
                                                title: 'Hapus Guru?',
                                                middleText: 'Apakah Anda yakin ingin menghapus data ${t['name']} dari Supabase?',
                                                textConfirm: 'Hapus',
                                                textCancel: 'Batal',
                                                confirmTextColor: Colors.white,
                                                buttonColor: Colors.red,
                                                onConfirm: () {
                                                  Get.back();
                                                  controller.deleteTeacher(t['id'], t['name']);
                                                },
                                              );
                                            },
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
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
  // DETAIL GURU MODAL (WITH ROSTER & BINAAN STUDENTS)
  // ==========================================
  void _showTeacherDetailModal(BuildContext context, Map<String, dynamic> teacher) {
    final controller = Get.find<MasterGuruController>();
    final teacherEmail = (teacher['email'] as String? ?? '').trim().toLowerCase();
    final teacherName = (teacher['name'] as String? ?? '').trim().toLowerCase();

    final savedOverride = controller.masterDataService.savedProfileOverrides[teacherEmail] ??
        controller.masterDataService.savedProfileOverrides[teacherName];

    final liveNip = (savedOverride != null && savedOverride['nip'] != null && savedOverride['nip'].toString().isNotEmpty)
        ? savedOverride['nip']
        : teacher['nip'];
    final livePhone = (savedOverride != null && savedOverride['phone'] != null && savedOverride['phone'].toString().isNotEmpty)
        ? savedOverride['phone']
        : teacher['phone'];

    final List<StudentRecord> binaanStudents = teacher['binaanStudents'] as List<StudentRecord>? ??
        teacher['assignedStudents'] as List<StudentRecord>? ?? [];
    final List<StudentRecord> rosterStudents = teacher['rosterStudents'] as List<StudentRecord>? ?? [];

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
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.purple.shade100,
                    child: Text(
                      teacher['name'].substring(0, 1).toUpperCase(),
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacher['name'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Wali Kelas: ${teacher['assignedClass']}',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.indigo),
                    tooltip: 'Edit / Update Data Guru',
                    onPressed: () {
                      Get.back();
                      _showEditTeacherSheet(context, controller, teacher);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),

              const Divider(height: 24),

              _buildDetailTile(Icons.person_rounded, 'Nama Lengkap & Gelar', teacher['name']),
              _buildDetailTile(Icons.email_rounded, 'Email Resmi', teacher['email']),
              _buildDetailTile(Icons.badge_rounded, 'NIP (Nomor Induk Pegawai)', liveNip),
              _buildDetailTile(Icons.phone_android_rounded, 'No. HP / WhatsApp', livePhone),
              _buildDetailTile(Icons.school_rounded, 'Tugas Wali Kelas Rombel', teacher['assignedClass']),
              _buildDetailTile(Icons.mosque_rounded, 'Agama', teacher['religion'] ?? 'Islam'),
              _buildDetailTile(Icons.groups_rounded, 'Total Murid Binaan Lintas Kelas', '${binaanStudents.length} Siswa'),
              _buildDetailTile(Icons.meeting_room_rounded, 'Total Murid Rombel Kelas', '${rosterStudents.length} Siswa'),

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
                  onPressed: () => controller.openWhatsApp(livePhone.toString(), teacher['name']),
                  icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 18),
                  label: const Text('Chat WhatsApp 💬', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Daftar Murid Binaan Lintas Kelas (${binaanStudents.length} Siswa):',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),

              if (binaanStudents.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Belum ada siswa binaan lintas kelas.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: binaanStudents.length,
                  itemBuilder: (ctx, sIdx) {
                    final s = binaanStudents[sIdx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.purple.shade100,
                            child: Text(
                              s.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                Text('NIS: ${s.nis} • NISN: ${s.nisn} • Kelas: ${s.className}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 16),
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
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          Flexible(
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

  void _showAddTeacherSheet(BuildContext context, MasterGuruController controller) {
    final classes = controller.masterDataService.getAllClassesCombined();
    final classNames = classes.map((c) => c['className'] as String).where((n) => n.isNotEmpty).toSet().toList();
    if (classNames.isEmpty) classNames.add('X DKV 1');
    controller.selectedAssignedClass.value = classNames.first;

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
                '➕ Tambah Guru Wali Baru (Supabase)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap Guru (dengan Gelar)',
                  hintText: 'Saiful Anwar., S.Kom.,Gr',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: controller.emailController,
                decoration: InputDecoration(
                  labelText: 'Email Resmi',
                  hintText: 'saifulanwar@smkn7.sch.id',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.email_rounded),
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
                controller: controller.nipController,
                decoration: InputDecoration(
                  labelText: 'NIP (Nomor Induk Pegawai)',
                  hintText: '19850115...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.badge_rounded),
                ),
              ),
              const SizedBox(height: 12),

              Obx(() => DropdownButtonFormField<String>(
                value: classNames.contains(controller.selectedAssignedClass.value)
                    ? controller.selectedAssignedClass.value
                    : classNames.first,
                decoration: InputDecoration(
                  labelText: 'Tugas Wali Kelas Rombel (Pilih 1 Kelas)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.school_rounded),
                ),
                items: classNames.map((c) => DropdownMenuItem(value: c, child: Text('🏫 $c'))).toList(),
                onChanged: (val) {
                  if (val != null) controller.selectedAssignedClass.value = val;
                },
              )),
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
                  onPressed: () => controller.addNewTeacher(),
                  icon: const Icon(Icons.cloud_upload_rounded),
                  label: const Text('Simpan Data Guru ke Supabase', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showEditTeacherSheet(BuildContext context, MasterGuruController controller, Map<String, dynamic> teacher) {
    controller.nameController.text = teacher['name'] ?? '';
    controller.emailController.text = teacher['email'] ?? '';
    controller.nipController.text = teacher['nip'] ?? '';
    controller.phoneController.text = teacher['phone'] ?? '';

    final classes = controller.masterDataService.getAllClassesCombined();
    final classNames = classes.map((c) => c['className'] as String).where((n) => n.isNotEmpty).toSet().toList();
    if (classNames.isEmpty) classNames.add('X DKV 1');

    final currentAssigned = (teacher['assignedClass'] as String? ?? '').trim();
    if (classNames.contains(currentAssigned)) {
      controller.selectedAssignedClass.value = currentAssigned;
    } else {
      controller.selectedAssignedClass.value = classNames.first;
    }

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
                    '✏️ Edit / Update Data Guru Wali',
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
                  labelText: 'Nama Lengkap Guru (dengan Gelar)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: controller.emailController,
                decoration: InputDecoration(
                  labelText: 'Email Resmi',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.email_rounded),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: controller.phoneController,
                decoration: InputDecoration(
                  labelText: 'No. HP / WhatsApp',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone_android_rounded),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: controller.nipController,
                decoration: InputDecoration(
                  labelText: 'NIP (Nomor Induk Pegawai)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.badge_rounded),
                ),
              ),
              const SizedBox(height: 12),

              Obx(() => DropdownButtonFormField<String>(
                value: classNames.contains(controller.selectedAssignedClass.value)
                    ? controller.selectedAssignedClass.value
                    : classNames.first,
                decoration: InputDecoration(
                  labelText: 'Tugas Wali Kelas Rombel (Pilih 1 Kelas)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.school_rounded),
                ),
                items: classNames.map((c) => DropdownMenuItem(value: c, child: Text('🏫 $c'))).toList(),
                onChanged: (val) {
                  if (val != null) controller.selectedAssignedClass.value = val;
                },
              )),
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
                  onPressed: () => controller.updateTeacher(teacher['id']),
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Simpan Pembaruan Data Guru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
