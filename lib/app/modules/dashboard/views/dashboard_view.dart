import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../../widgets/habit_card.dart';
import '../../../widgets/progress_ring.dart';
import '../../../data/services/habit_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/master_data_service.dart';
import '../../../data/models/school_data.dart';
import '../../../data/models/teacher_note_model.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/app_date_formatter.dart';
import '../../../routes/app_routes.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final habitService = Get.find<HabitService>();
    final authService = Get.find<AuthService>();
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: _buildSideDrawer(context, controller, authService),
      body: SafeArea(
        child: Obx(() {
          final user = controller.currentUser;
          final role = user?.role ?? 'siswa';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: role == 'superadmin'
                ? _buildSuperadminDashboard(context, controller, habitService, authService, scaffoldKey)
                : (role == 'guru' || role == 'guru_wali')
                    ? _buildTeacherDashboard(context, controller, habitService, authService, scaffoldKey)
                    : _buildStudentDashboard(context, controller, habitService, authService, scaffoldKey),
          );
        }),
      ),
      bottomNavigationBar: _buildBottomNavBar(controller),
    );
  }

  // ==========================================
  // BOTTOM NAVIGATION BAR
  // ==========================================
  Widget _buildBottomNavBar(DashboardController controller) {
    return Obx(
      () {
        final role = controller.currentUser?.role ?? 'siswa';
        final isSuperadmin = role == 'superadmin';

        if (isSuperadmin) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: controller.selectedNavIndex.value > 4 ? 0 : controller.selectedNavIndex.value,
              onTap: (index) {
                controller.selectedNavIndex.value = index;
                if (index == 1) {
                  Get.toNamed(Routes.MASTER_GURU);
                } else if (index == 2) {
                  Get.toNamed(Routes.MASTER_SISWA);
                } else if (index == 3) {
                  Get.toNamed(Routes.MASTER_KELAS);
                } else if (index == 4) {
                  Get.toNamed(Routes.PROFILE);
                }
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.purple.shade800,
              unselectedItemColor: AppColors.textMuted,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              items: const [
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.house, size: 18),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.userTie, size: 18),
                  label: 'Master Guru',
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.userGraduate, size: 18),
                  label: 'Master Siswa',
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.school, size: 18),
                  label: 'Master Kelas',
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.user, size: 18),
                  label: 'Profil',
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: controller.selectedNavIndex.value > 3 ? 0 : controller.selectedNavIndex.value,
            onTap: (index) {
              controller.selectedNavIndex.value = index;
              if (index == 1) {
                Get.toNamed(Routes.HABIT_LIST);
              } else if (index == 2) {
                Get.toNamed(Routes.JOURNAL_ENTRY);
              } else if (index == 3) {
                Get.toNamed(Routes.PROFILE);
              }
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textMuted,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            items: const [
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.house, size: 18),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.listCheck, size: 18),
                label: '7 Kebiasaan',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.bookOpen, size: 18),
                label: 'Refleksi',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.user, size: 18),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // LEFT SIDE DRAWER MENU
  // ==========================================
  Widget _buildSideDrawer(BuildContext context, DashboardController controller, AuthService authService) {
    final user = controller.currentUser;
    final role = user?.role ?? 'siswa';

    String roleTitle = '👦 Siswa SMKN 7';
    if (role == 'superadmin') {
      roleTitle = '👑 Superadmin (Kontrol System)';
    } else if (role == 'guru' || role == 'guru_wali') {
      roleTitle = '👨‍🏫 Guru Wali • ${user?.name ?? 'Guru'}';
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: role == 'superadmin'
                    ? [const Color(0xFF5B21B6), const Color(0xFF7C3AED)]
                    : (role == 'guru' || role == 'guru_wali')
                        ? [const Color(0xFF3730A3), const Color(0xFF4F46E5)]
                        : [const Color(0xFF0D9488), const Color(0xFF0F766E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: role == 'superadmin'
                      ? Colors.purple.shade900
                      : (role == 'guru' || role == 'guru_wali')
                          ? Colors.indigo.shade800
                          : AppColors.primary,
                ),
              ),
            ),
            accountName: Text(
              user?.name ?? 'Pengguna',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(
              roleTitle,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.house, size: 18, color: AppColors.primary),
            title: const Text('Beranda Utama', style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              controller.selectedNavIndex.value = 0;
            },
          ),
          if (role != 'superadmin') ...[
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.listCheck, size: 18, color: AppColors.primary),
              title: const Text('Daftar 7 Kebiasaan Baik'),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed(Routes.HABIT_LIST);
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.bookOpen, size: 18, color: AppColors.primary),
              title: const Text('Jurnal & Refleksi Harian'),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed(Routes.JOURNAL_ENTRY);
              },
            ),
          ],
          if (role == 'superadmin') ...[
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                'KONTROL MASTER DATA',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple, letterSpacing: 0.8),
              ),
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.userTie, size: 18, color: Colors.purple),
              title: const Text('👑 Master Guru Wali', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed(Routes.MASTER_GURU);
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.userGraduate, size: 18, color: Colors.purple),
              title: const Text('🎓 Master Data Siswa', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed(Routes.MASTER_SISWA);
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.school, size: 18, color: Colors.purple),
              title: const Text('🏫 Master Data Kelas', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed(Routes.MASTER_KELAS);
              },
            ),
          ],
          const Divider(),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.userPen, size: 18, color: AppColors.primary),
            title: const Text('Profil Saya & Ayo Berkenalan!'),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed(Routes.PROFILE);
            },
          ),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.rightFromBracket, size: 18, color: Colors.red),
            title: const Text('Keluar / Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
              authService.logout();
              Get.offAllNamed(Routes.LOGIN);
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // DASHBOARD SISWA (STUDENT VIEW)
  // ==========================================
  Widget _buildStudentDashboard(
    BuildContext context,
    DashboardController controller,
    HabitService habitService,
    AuthService authService,
    GlobalKey<ScaffoldState> scaffoldKey,
  ) {
    final user = controller.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Header Greeting with Avatar Button on the LEFT
        Row(
          children: [
            GestureDetector(
              onTap: () => scaffoldKey.currentState?.openDrawer(),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user?.name.substring(0, 1).toUpperCase() ?? 'A',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${user?.name ?? 'Siswa'}! 👋',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Wali Kelas: ${user?.homeroomTeacher ?? 'Aminah Tajudin., S.Pd.I'}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // DATE SELECTOR STRIP
        _buildDateSelectorStrip(context, habitService),
        const SizedBox(height: 16),

        // Progress Summary Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'PROGRESS HARI INI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => Text(
                        '${controller.completedCount}/${controller.totalCount} Kebiasaan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tetap semangat tuntaskan sisanya!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Obx(
                () => ProgressRing(
                  percentage: controller.progressPercentage,
                  completed: controller.completedCount,
                  total: controller.totalCount,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Action Banner to Add Journal Reflection
        InkWell(
          onTap: () => Get.toNamed(Routes.JOURNAL_ENTRY),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const FaIcon(FontAwesomeIcons.bookJournalWhills, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tulis Jurnal Refleksi Harian',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Catat hal positif yang Anda rasakan hari ini',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const FaIcon(FontAwesomeIcons.chevronRight, size: 14, color: AppColors.textMuted),
              ],
            ),
          ),
        ),

        // Teacher Appreciation Note Banner for Student
        Obx(() {
          final user = controller.currentUser;
          final studentId = user?.id ?? habitService.activeStudentId;
          final targetDate = habitService.selectedDate.value;
          final teacherNote = habitService.getTeacherNoteForStudent(studentId, targetDate: targetDate);

          if (teacherNote == null || teacherNote.note.trim().isEmpty) {
            return const SizedBox.shrink();
          }

          final teacherDisplayName = teacherNote.teacherName.isNotEmpty
              ? teacherNote.teacherName
              : (user?.homeroomTeacher != null && user!.homeroomTeacher!.isNotEmpty)
                  ? user.homeroomTeacher!
                  : 'Guru Wali Kelas';

          return Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade900, const Color(0xFF1E1B4B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.shade900.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const FaIcon(FontAwesomeIcons.envelopeOpenText, color: Colors.amberAccent, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Catatan Apresiasi Wali Kelas 💌',
                            style: TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            teacherDisplayName,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '"${teacherNote.note}"',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 24),

        // Section Header: Habits List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Obx(
                () {
                  final currentDate = habitService.selectedDate.value;
                  final isToday = habitService.isSameDay(currentDate, DateTime.now());
                  final formattedDate = AppDateFormatter.formatIndonesian(currentDate, 'EEEE, d MMMM yyyy');
                  return Text(
                    isToday ? 'Kebiasaan Hari Ini ($formattedDate)' : 'Kebiasaan $formattedDate',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => Get.toNamed(Routes.HABIT_LIST),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Habit List Cards
        Obx(
          () => controller.habits.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada kebiasaan',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.habits.length,
                  itemBuilder: (context, index) {
                    final habit = controller.habits[index];
                    return HabitCard(
                      habit: habit,
                      onToggle: () => controller.toggleHabit(habit.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==========================================
  // DASHBOARD GURU WALI (HOMEROOM TEACHER VIEW)
  // ==========================================
  Widget _buildTeacherDashboard(
    BuildContext context,
    DashboardController controller,
    HabitService habitService,
    AuthService authService,
    GlobalKey<ScaffoldState> scaffoldKey,
  ) {
    return Obx(() {
      final targetDate = habitService.selectedDate.value;
      final masterData = Get.isRegistered<MasterDataService>() ? Get.find<MasterDataService>() : null;
      final studentCount = masterData?.supabaseStudents.length ?? 0;
      final assignmentCount = masterData?.teacherStudentAssignments.length ?? 0;
      debugPrint('Active student count: $studentCount, assignments: $assignmentCount');

      final teacher = controller.currentUser;
      final teacherName = teacher?.name ?? 'Saiful Anwar., S.Kom.,Gr';
      final teacherClass = teacher?.className ?? 'X DKV 1';

      final allStudentsOnline = masterData?.getAllStudentsCombined() ?? [];

      final assignedStudents = allStudentsOnline.where((s) {
        final sTeacher = (s['homeroomTeacher'] as String? ?? s['guruWali'] as String? ?? s['waliKelas'] as String? ?? '').trim();
        final sClass = (s['className'] as String? ?? '').trim();

        if (sTeacher.isEmpty || sTeacher == 'Guru Wali Pembina') {
          if (teacherName.toLowerCase().contains('saiful')) return true;
        }

        final sClean = sTeacher.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        final tClean = teacherName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

        if (sClean.isNotEmpty && (sClean.contains(tClean) || tClean.contains(sClean))) return true;

        final tWords = tClean.split(RegExp(r'[^a-z]')).where((w) => w.length >= 4 && w != 'pembina' && w != 'guru');
        for (var w in tWords) {
          if (sClean.contains(w)) return true;
        }

        if (teacherClass.isNotEmpty && teacherClass != 'Semua Kelas' && sClass.isNotEmpty) {
          if (teacherClass.contains(sClass) || sClass.contains(teacherClass)) return true;
        }

        return false;
      }).map((s) => StudentRecord(
        nis: s['nis'] as String? ?? '-',
        nisn: s['nisn'] as String? ?? '-',
        name: s['name'] as String? ?? 'Siswa',
        className: s['className'] as String? ?? 'Siswa',
        homeroomTeacher: s['homeroomTeacher'] as String? ?? s['guruWali'] as String? ?? teacherName,
        phone: s['phone'] as String? ?? '0812-3456-7890',
      )).toList();

      final rosterList = assignedStudents;

      final List<Map<String, dynamic>> studentRoster = [];

      for (int i = 0; i < rosterList.length; i++) {
        final s = rosterList[i];
        final studentUserId = s.nisn.isNotEmpty ? s.nisn : s.nis;

        final logsForStudent = habitService.habitLogs.where((log) =>
          habitService.isSameDay(log.date, targetDate) &&
          log.isCompleted &&
          habitService.isUserMatch(log.userId, studentUserId)
        ).toList();

        int compCount = 0;
        for (final habit in habitService.habits) {
          if (habitService.isHabitCompletedForDate(habit.id, targetDate, userId: studentUserId)) {
            compCount++;
          }
        }

        final int compPercentage = (compCount / 7.0 * 100).round();
        final String compStatus = compCount == 7
            ? '✔ Tuntas 100%'
            : compCount > 0
                ? '⚡ $compCount/7 Selesai'
                : '❌ Belum Mengisi';
        final Color compStatusColor = compCount == 7
            ? Colors.green.shade700
            : compCount > 0
                ? Colors.teal.shade700
                : Colors.red.shade700;
        final Color compStatusBg = compCount == 7
            ? Colors.green.shade50
            : compCount > 0
                ? Colors.teal.shade50
                : Colors.red.shade50;

        studentRoster.add({
          'id': s.nisn,
          'name': s.name,
          'nis': s.nis,
          'class': s.className,
          'completedCount': compCount,
          'totalHabits': 7,
          'percentage': compPercentage,
          'status': compStatus,
          'statusColor': compStatusColor,
          'statusBg': compStatusBg,
          'logs': logsForStudent,
        });
      }

      double classAvg = 0;
      int tuntasCount = 0;
      for (var s in studentRoster) {
        classAvg += (s['percentage'] as int);
        if ((s['completedCount'] as int) == 7) tuntasCount++;
      }
      final String classAvgFormatted = studentRoster.isNotEmpty
          ? (classAvg / studentRoster.length).toStringAsFixed(1)
          : '0.0';

      return RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: Colors.white,
        onRefresh: () async {
          if (masterData != null) {
            await masterData.fetchStudentsFromSupabase();
            await masterData.fetchTeachersFromSupabase();
          }
          await habitService.loadLogsFromStorage();
          await habitService.fetchFromSyncServer();
          Get.snackbar(
            'Data Berhasil Diperbarui! 🔄',
            'Progress kebiasaan murid binaan ter-update.',
            backgroundColor: Colors.teal.shade800,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 2),
          );
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Guru Wali Greeting with Avatar Button on the LEFT & Refresh Button on RIGHT
              Row(
                children: [
                  GestureDetector(
                    onTap: () => scaffoldKey.currentState?.openDrawer(),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.indigo.shade700,
                        child: Text(
                          teacher?.name.substring(0, 1).toUpperCase() ?? 'G',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${teacher?.name ?? 'Guru Wali'}! 👨‍🏫',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Guru Wali Pembina • SMKN 7',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.indigo.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.refresh_rounded, color: Colors.indigo, size: 22),
                    tooltip: 'Refresh Data Real-Time',
                    onPressed: () async {
                      if (masterData != null) {
                        await masterData.fetchStudentsFromSupabase();
                        await masterData.fetchTeachersFromSupabase();
                        await masterData.fetchAssignmentsFromSupabase();
                        await masterData.fetchClassesFromSupabase();
                      }
                      await habitService.loadLogsFromStorage();
                      await habitService.fetchFromSyncServer();
                      Get.snackbar(
                        'Data Diperbarui! 🔄',
                        'Progress kebiasaan murid binaan ter-update.',
                        backgroundColor: Colors.teal.shade800,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                        duration: const Duration(seconds: 2),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

          // DATE SELECTOR STRIP
          _buildDateSelectorStrip(context, habitService),
          const SizedBox(height: 16),

          // Class Overview Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3730A3), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withValues(alpha: 0.3),
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
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'MONITORING MURID WALI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${studentRoster.length} Murid Wali',
                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rata-rata Progress Kebiasaan',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$classAvgFormatted%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Text('$tuntasCount Siswa', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          const Text('Tuntas 7/7', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section Title: List Progress Siswa
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Daftar Murid Binaan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${studentRoster.length} Anak Wali',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigo.shade800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Student Roster List
          if (studentRoster.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person_search_rounded, size: 36, color: Colors.indigo.shade700),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Belum Ada Murid Wali Terdaftar',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Siswa baru dapat mendaftar akun dan memilih $teacherName sebagai Guru Wali binaan mereka saat registrasi.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: studentRoster.length,
            itemBuilder: (context, index) {
              final student = studentRoster[index];
              final int completed = student['completedCount'];
              final int percentage = student['percentage'];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
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
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                          child: Text(
                            student['name'].substring(0, 1),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student['name'],
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'NIS: ${student['nis']} • NISN: ${student['id']}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: student['statusBg'],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            student['status'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: student['statusColor'],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Linear Progress Indicator
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: percentage / 100.0,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                percentage == 100
                                    ? Colors.green
                                    : percentage >= 50
                                        ? AppColors.primary
                                        : Colors.red,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$completed/7 ($percentage%)',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Button Detail Jurnal
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _showStudentDetailModal(context, student, habitService),
                        icon: const FaIcon(FontAwesomeIcons.fileLines, size: 12, color: AppColors.primary),
                        label: const Text(
                          'Lihat Detail Jurnal Murid Wali',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
});
}

  // ==========================================
  // DASHBOARD SUPERADMIN (DEDUPLICATED & SEARCHABLE TEACHERS)
  // ==========================================
  Widget _buildSuperadminDashboard(
    BuildContext context,
    DashboardController controller,
    HabitService habitService,
    AuthService authService,
    GlobalKey<ScaffoldState> scaffoldKey,
  ) {
    final admin = controller.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Admin Greeting with Avatar Button on the LEFT
        Row(
          children: [
            GestureDetector(
              onTap: () => scaffoldKey.currentState?.openDrawer(),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.purple.shade800,
                  child: Text(
                    admin?.name.substring(0, 1).toUpperCase() ?? 'A',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${admin?.name ?? 'Superadmin'}! 👑',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Kontrol Akun Guru & Siswa • SMKN 7 Samarinda',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Admin Overview Card
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PANEL KONTROL SUPERADMIN SMKN 7',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${Get.isRegistered<MasterDataService>() ? Get.find<MasterDataService>().getAllTeachersCombined().length : 0} Guru Wali', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const Text('Terdaftar Aktif', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${Get.isRegistered<MasterDataService>() ? Get.find<MasterDataService>().getAllStudentsCombined().length : 0} Siswa', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const Text('Total Siswa Binaan', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('91.4%', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Rata-rata Sekolah', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // MASTER MENU ACTION CARDS (SUPERADMIN)
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => Get.toNamed(Routes.MASTER_GURU),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.purple.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const FaIcon(FontAwesomeIcons.userTie, color: Colors.purple, size: 16),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Master Guru',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Supabase Wali',
                        style: TextStyle(fontSize: 10, color: Colors.purple.shade900, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () => Get.toNamed(Routes.MASTER_SISWA),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.indigo.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const FaIcon(FontAwesomeIcons.userGraduate, color: Colors.indigo, size: 16),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Master Siswa',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Biodata Siswa',
                        style: TextStyle(fontSize: 10, color: Colors.indigo.shade900, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () => Get.toNamed(Routes.MASTER_KELAS),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.teal.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const FaIcon(FontAwesomeIcons.school, color: Colors.teal, size: 16),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Master Kelas',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Sinkron Rombel',
                        style: TextStyle(fontSize: 10, color: Colors.teal.shade900, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // SEARCH BAR FOR SUPERADMIN (Pencarian Guru Wali)
        Obx(
          () => TextField(
            controller: controller.searchController,
            onChanged: (val) => controller.teacherSearchQuery.value = val,
            decoration: InputDecoration(
              hintText: '🔍 Cari Nama Guru Wali, Email, atau Kelas...',
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
              suffixIcon: controller.teacherSearchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        controller.searchController.clear();
                        controller.teacherSearchQuery.value = '';
                      },
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daftar Guru Wali (Deduplikasi Akun)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Get.snackbar('Fitur Admin', 'Form tambah akun Guru Wali baru');
              },
              icon: const Icon(Icons.person_add_rounded, size: 14),
              label: const Text('+ Guru Baru', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Deduplicated & Filtered Teachers List
        Obx(() {
          final query = controller.teacherSearchQuery.value.trim().toLowerCase();
          final allTeachersOnline = Get.isRegistered<MasterDataService>()
              ? Get.find<MasterDataService>().getAllTeachersCombined()
              : [];
          final allStudentsOnline = Get.isRegistered<MasterDataService>()
              ? Get.find<MasterDataService>().getAllStudentsCombined()
              : [];

          final filteredTeachers = allTeachersOnline.where((t) {
            final name = (t['name'] as String? ?? '').toLowerCase();
            final email = (t['email'] as String? ?? '').toLowerCase();
            final assignedClass = (t['assignedClass'] as String? ?? '').toLowerCase();
            return name.contains(query) || email.contains(query) || assignedClass.contains(query);
          }).map((t) => TeacherRecord(
            name: t['name'] as String? ?? '',
            email: t['email'] as String? ?? '',
            assignedClass: t['assignedClass'] as String? ?? 'Wali Kelas',
            phone: t['phone'] as String? ?? '08115595606',
            nip: t['nip'] as String? ?? '-',
          )).toList();

          if (filteredTeachers.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: Text(
                'Tidak ada Guru Wali yang cocok dengan "$query"',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredTeachers.length,
            itemBuilder: (context, index) {
              final t = filteredTeachers[index];
              final teacherQuery = t.name.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
              final assignedStudents = allStudentsOnline.where((s) {
                final sWali = (s['homeroomTeacher'] as String? ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
                return sWali.contains(teacherQuery) || teacherQuery.contains(sWali);
              }).map((s) => StudentRecord(
                nis: s['nis'] as String? ?? '-',
                nisn: s['nisn'] as String? ?? '-',
                name: s['name'] as String? ?? 'Siswa',
                className: s['className'] as String? ?? 'X DKV 1',
                homeroomTeacher: s['homeroomTeacher'] as String? ?? t.name,
                phone: s['phone'] as String? ?? '0812-3456-7890',
              )).toList();
              final classSet = assignedStudents.map((s) => s.className).toSet().join(', ');
              final displayClasses = classSet.isNotEmpty ? classSet : t.assignedClass;

              return InkWell(
                onTap: () => _showTeacherDetailModalForAdmin(context, t, assignedStudents),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
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
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.purple.shade100,
                        child: Text(t.name.substring(0, 1), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple.shade900)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(
                              'Wali Kelas: $displayClasses • Email: ${t.email}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${assignedStudents.length} Murid',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                            ),
                            const SizedBox(width: 4),
                            const FaIcon(FontAwesomeIcons.chevronRight, size: 10, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  // ==========================================
  // SUPERADMIN TEACHER DETAIL MODAL (LIHAT SEMUA SISWA BINAAN KELAS X, XI, XII)
  // ==========================================
  void _showTeacherDetailModalForAdmin(
    BuildContext context,
    TeacherRecord teacher,
    List<StudentRecord> assignedStudents,
  ) {
    // Group students by Class
    final Map<String, List<StudentRecord>> groupedByClass = {};
    for (var s in assignedStudents) {
      groupedByClass.putIfAbsent(s.className, () => []).add(s);
    }

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
                    backgroundColor: Colors.purple.shade100,
                    child: Text(
                      teacher.name.substring(0, 1),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacher.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Email: ${teacher.email}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const FaIcon(FontAwesomeIcons.xmark, size: 18, color: AppColors.textMuted),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Total Students Summary Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Row(
                  children: [
                    FaIcon(FontAwesomeIcons.userGroup, color: Colors.purple.shade900, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Murid Wali Pembina:',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                          ),
                          Text(
                            '${assignedStudents.length} Murid (${groupedByClass.keys.join(', ')})',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.purple.shade900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Daftar Murid Binaannya (Kelas X, XI, XII):',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),

              if (assignedStudents.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Belum ada murid binaan yang terdaftar untuk guru ini.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                )
              else
                Column(
                  children: groupedByClass.entries.map((entry) {
                    final className = entry.key;
                    final studentList = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Class Subheader
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Kelas $className',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                                Text(
                                  '${studentList.length} Murid',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),

                          // Student Roster inside Class
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: studentList.length,
                            itemBuilder: (context, idx) {
                              final s = studentList[idx];
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                                      child: Text(
                                        s.name.substring(0, 1),
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            s.name,
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                          ),
                                          Text(
                                            'NIS: ${s.nis} • NISN: ${s.nisn}',
                                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '✔ Aktif',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Get.back();
                    Get.snackbar(
                      'Kontak Guru Wali',
                      'Membuka form pesan internal ke ${teacher.name}',
                      backgroundColor: Colors.purple.shade900,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  icon: const FaIcon(FontAwesomeIcons.paperPlane, size: 14),
                  label: const Text(
                    'Kirim Pesan / Pengingat ke Guru Wali',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ==========================================
  // SHARED DATE SELECTOR STRIP WIDGET
  // ==========================================
  Widget _buildDateSelectorStrip(BuildContext context, HabitService habitService) {
    return Obx(() {
      final currentDate = habitService.selectedDate.value;
      final isToday = habitService.isSameDay(currentDate, DateTime.now());
      final dateFormatted = isToday
          ? '${AppDateFormatter.formatIndonesian(currentDate, 'EEEE, d MMMM yyyy')} (Hari Ini)'
          : AppDateFormatter.formatIndonesian(currentDate, 'EEEE, d MMMM yyyy');

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.chevronLeft, size: 14, color: AppColors.primary),
              onPressed: () {
                habitService.setSelectedDate(currentDate.subtract(const Duration(days: 1)));
              },
            ),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final now = DateTime.now();
                  final initial = currentDate.isAfter(now) ? now : currentDate;
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: initial,
                    firstDate: DateTime(2025),
                    lastDate: now,
                    locale: const Locale('id', 'ID'),
                  );
                  if (picked != null) {
                    if (habitService.isFutureDate(picked)) {
                      Get.snackbar(
                        'Tanggal Terkunci 🔒',
                        'Anda belum dapat memilih tanggal di masa mendatang.',
                        backgroundColor: Colors.amber.shade900,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    habitService.setSelectedDate(picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(FontAwesomeIcons.calendarDay, size: 14, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          dateFormatted,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 14,
                color: (isToday || habitService.isFutureDate(currentDate))
                    ? AppColors.textMuted
                    : AppColors.primary,
              ),
              onPressed: () {
                if (isToday || habitService.isFutureDate(currentDate)) {
                  Get.snackbar(
                    'Tanggal Terkunci 🔒',
                    'H+1 dan tanggal masa mendatang belum dapat dipilih.',
                    backgroundColor: Colors.amber.shade900,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 3),
                  );
                  return;
                }
                habitService.setSelectedDate(currentDate.add(const Duration(days: 1)));
              },
            ),
          ],
        ),
      );
    });
  }

  // ==========================================
  // STUDENT DETAIL MODAL FOR GURU WALI
  // ==========================================
  void _showStudentDetailModal(BuildContext context, Map<String, dynamic> student, HabitService habitService) {
    final noteController = TextEditingController();

    Get.bottomSheet(
      Obx(() {
        final targetDate = habitService.selectedDate.value;
        final studentNisn = (student['nisn'] != null && student['nisn'].toString().isNotEmpty)
            ? student['nisn'].toString()
            : student['id'].toString();
        final studentUserId = studentNisn;

        final initialTeacherNote = habitService.getTeacherNoteForStudent(studentUserId, targetDate: targetDate);
        if (initialTeacherNote != null && noteController.text.isEmpty) {
          noteController.text = initialTeacherNote.note;
        }

        final List<Map<String, dynamic>> currentLogs = [];
        for (final habit in habitService.habits) {
          final isDone = habitService.isHabitCompletedForDate(habit.id, targetDate, userId: studentUserId);
          if (isDone) {
            final existingLog = habitService.getExistingLogForHabit(habit.id, targetDate: targetDate, userId: studentUserId);
            final prayerProgress = habitService.getPrayerProgress('Islam', targetDate: targetDate, userId: studentUserId);
            currentLogs.add({
              'title': habit.title,
              'time': habit.id == 'h2'
                  ? '⚡ Progress Sholat: ${prayerProgress.displayProgress}'
                  : (existingLog?.detailType != null && existingLog!.detailType!.isNotEmpty
                      ? existingLog.detailType!
                      : 'Terisi & Diverifikasi Bukti Foto'),
              'note': existingLog?.note ?? 'Kebiasaan telah terisi dan terverifikasi.',
              'photo': existingLog?.photoUrl != null && existingLog!.photoUrl!.isNotEmpty,
              'photoUrl': existingLog?.photoUrl,
            });
          }
        }

        final int compCount = currentLogs.length;
        final int compPercentage = ((compCount / 7.0) * 100).round();
        final String compStatusText = compCount == 7
            ? '✔ Tuntas 100%'
            : compCount > 0
                ? '⚡ $compCount dari 7 Kebiasaan Terisi ($compPercentage%)'
                : '❌ Belum Mengisi (0%)';
        final Color compStatusColor = compCount == 7
            ? Colors.green.shade700
            : compCount > 0
                ? Colors.teal.shade700
                : Colors.red.shade700;
        final Color compStatusBg = compCount == 7
            ? Colors.green.shade50
            : compCount > 0
                ? Colors.teal.shade50
                : Colors.red.shade50;

        return Container(
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
                      radius: 24,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        student['name'].substring(0, 1),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
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
                            'NIS: ${student['nis']} • NISN: ${student['id']} • Kelas ${student['class']}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const FaIcon(FontAwesomeIcons.xmark, size: 18, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Progress Overview Badge
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: compStatusBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: compStatusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      FaIcon(FontAwesomeIcons.chartPie, color: compStatusColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status Pengisian Jurnal:',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: compStatusColor),
                            ),
                            Text(
                              compStatusText,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: compStatusColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Rincian 7 Kebiasaan Anak Indonesia Hebat:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),

                // Logs List for this Student
                if (currentLogs.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        FaIcon(FontAwesomeIcons.circleExclamation, color: Colors.red, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Siswa belum mengisi jurnal kebiasaan pada tanggal ini.', style: TextStyle(fontSize: 12, color: Colors.red)),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentLogs.length,
                    itemBuilder: (context, idx) {
                      final log = currentLogs[idx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    log['title'],
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '✓ ${log['time']}',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                                  ),
                                ),
                              ],
                            ),
                            if (log['note'] != null && log['note'].toString().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                log['note'],
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 20),

                // Teacher Notes Input & Action Button
                Text(
                  'Catatan Apresiasi / Catatan Wali Kelas',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Tuliskan apresiasi atau pesan motivasi untuk ${student['name']}...',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final text = noteController.text.trim();
                      if (text.isEmpty) {
                        Get.snackbar('Peringatan', 'Isi catatan apresiasi terlebih dahulu.');
                        return;
                      }
                      final newTeacherNote = TeacherNoteModel(
                        id: 'tnote-${DateTime.now().millisecondsSinceEpoch}',
                        studentId: studentUserId,
                        teacherId: controller.currentUser?.id ?? 'guru-1',
                        teacherName: controller.currentUser?.name ?? 'Saiful Anwar., S.Kom.,Gr',
                        date: targetDate,
                        note: text,
                      );
                      await habitService.sendTeacherNote(newTeacherNote);

                      Get.back();
                      Get.snackbar(
                        'Apresiasi Terkirim! 💌',
                        'Catatan motivasi berhasil dikirimkan ke jurnal ${student['name']}!',
                        backgroundColor: Colors.indigo.shade900,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    icon: const FaIcon(FontAwesomeIcons.paperPlane, size: 14),
                    label: const Text(
                      'Kirim Catatan Apresiasi ke Siswa',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (compCount > 0) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Get.defaultDialog(
                          title: 'Reset Progress Murid? 🔄',
                          middleText: 'Apakah Anda yakin ingin mereset seluruh jurnal ${student['name']} untuk tanggal ini? Data akan kembali ke 0.',
                          textConfirm: 'Ya, Reset 0',
                          textCancel: 'Batal',
                          confirmTextColor: Colors.white,
                          buttonColor: Colors.red,
                          onConfirm: () async {
                            Get.back();
                            await habitService.resetAllLogsForStudentDate(targetDate, userId: studentUserId);
                            Get.back();
                            Get.snackbar(
                              'Progress Di-reset 0 🔄',
                              'Seluruh progress jurnal ${student['name']} tanggal ini telah di-reset ke 0.',
                              backgroundColor: Colors.red.shade900,
                              colorText: Colors.white,
                            );
                          },
                        );
                      },
                      icon: const FaIcon(FontAwesomeIcons.rotateLeft, size: 14, color: Colors.red),
                      label: const Text(
                        'Reset Progress Murid Tanggal Ini (Ke 0)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      }),
      isScrollControlled: true,
    );
  }
}
