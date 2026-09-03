import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/master_kelas_controller.dart';
import '../../../theme/app_colors.dart';

class MasterKelasView extends GetView<MasterKelasController> {
  const MasterKelasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '👑 Master Data Rombel Kelas (Superadmin)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
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
            tooltip: 'Refresh Data Kelas',
          ),
        ],
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
                            'MASTER ROMBEL KELAS SMKN 7',
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
                            '${controller.allClasses.length} Rombel Kelas',
                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Obx(() {
                      int totalStudentsCount = 0;
                      for (var c in controller.allClasses) {
                        totalStudentsCount += (c['studentCount'] as int);
                      }

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${controller.allClasses.length}',
                                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                              const Text('Total Rombel Kelas', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$totalStudentsCount',
                                style: const TextStyle(color: Colors.cyanAccent, fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                              const Text('Siswa Terkoneksi', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '24 Rombel',
                                style: TextStyle(color: Colors.amberAccent, fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              Text('TJKT, DKV, PPLG, Animasi', style: TextStyle(color: Colors.white70, fontSize: 10)),
                            ],
                          ),
                        ],
                      );
                    }),
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
                          hintText: '🔍 Cari Kelas / Wali Kelas...',
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
                  const SizedBox(width: 8),

                  // FILTER MAJOR DROPDOWN
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedMajorFilter.value,
                          icon: const Icon(Icons.filter_list_rounded, color: Colors.purple, size: 18),
                          style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                          items: controller.availableMajors.map((String m) {
                            return DropdownMenuItem<String>(
                              value: m,
                              child: Text(m),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) controller.selectedMajorFilter.value = val;
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
                    'Daftar Rombel & Wali Kelas Pengampu',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Obx(
                    () => Text(
                      'Menampilkan ${controller.filteredClasses.length} rombel',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Obx(() {
                final list = controller.filteredClasses;

                if (list.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(30),
                    alignment: Alignment.center,
                    child: const Column(
                      children: [
                        FaIcon(FontAwesomeIcons.school, size: 40, color: AppColors.textMuted),
                        SizedBox(height: 10),
                        Text(
                          'Tidak ada data kelas yang cocok dengan filter.',
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
                    final c = list[index];
                    final String className = c['className'];
                    final String grade = c['grade'];
                    final String major = c['major'];
                    final String homeroomTeacher = c['homeroomTeacher'];
                    final int studentCount = c['studentCount'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.purple.shade100,
                                child: const FaIcon(FontAwesomeIcons.school, size: 16, color: Colors.purple),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kelas $className',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.indigo.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Jurusan $major',
                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.purple.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Tingkat $grade',
                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.cyan.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.cyan.shade200),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '$studentCount',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.cyan.shade900),
                                    ),
                                    Text(
                                      'Siswa Aktif',
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.cyan.shade900),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 20, color: Color(0xFFF1F5F9)),

                          Row(
                            children: [
                              const FaIcon(FontAwesomeIcons.school, size: 13, color: Colors.indigo),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Wali Kelas Rombel Pengampu:',
                                      style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      homeroomTeacher,
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.indigo.shade300),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    ),
                                    onPressed: () => _showAssignTeacherDialog(context, className, homeroomTeacher),
                                    icon: const Icon(Icons.edit_rounded, size: 12, color: Colors.indigo),
                                    label: const Text(
                                      'Atur Wali ✏️',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.purple.shade300),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    ),
                                    onPressed: () => controller.navigateToStudentsInClass(className),
                                    icon: const FaIcon(FontAwesomeIcons.userGraduate, size: 12, color: Colors.purple),
                                    label: const Text(
                                      'Lihat Siswa 🎓',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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

  void _showAssignTeacherDialog(BuildContext context, String className, String currentTeacher) {
    final teachers = controller.availableTeachers;
    String selectedId = teachers.isNotEmpty ? (teachers.first['id'] as String? ?? '') : '';
    String selectedName = teachers.isNotEmpty ? (teachers.first['name'] as String? ?? '') : '';

    final matched = teachers.firstWhereOrNull((t) {
      final tName = (t['name'] as String? ?? '').toLowerCase();
      return tName.contains(currentTeacher.toLowerCase()) || currentTeacher.toLowerCase().contains(tName);
    });

    if (matched != null) {
      selectedId = matched['id'] as String? ?? '';
      selectedName = matched['name'] as String? ?? '';
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '✏️ Atur Wali Kelas - $className',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Pilih Guru yang akan ditugaskan sebagai Wali Kelas Pengampu utama rombel $className.',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setStateModal) {
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.purple.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedId.isNotEmpty ? selectedId : null,
                            hint: const Text('Pilih Guru Wali Kelas', style: TextStyle(fontSize: 13)),
                            items: teachers.map((t) {
                              final String tid = t['id'] as String? ?? '';
                              final String tName = t['name'] as String? ?? 'Guru';
                              final String tNip = t['nip'] as String? ?? '-';
                              return DropdownMenuItem<String>(
                                value: tid,
                                child: Text(
                                  '$tName (NIP: $tNip)',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                final found = teachers.firstWhere((t) => t['id'] == val);
                                setStateModal(() {
                                  selectedId = val;
                                  selectedName = found['name'] as String? ?? '';
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Obx(() => SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade900,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.assignTeacherToClass(
                                    className: className,
                                    teacherId: selectedId,
                                    teacherName: selectedName,
                                  ),
                          icon: controller.isLoading.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.check_circle_rounded, color: Colors.white),
                          label: Text(
                            controller.isLoading.value ? 'Menyimpan...' : 'Simpan Penugasan Wali Kelas',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      )),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
