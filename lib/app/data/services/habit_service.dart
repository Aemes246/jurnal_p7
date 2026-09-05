import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../models/habit_model.dart';
import '../models/habit_log_model.dart';
import '../services/auth_service.dart';
import '../services/master_data_service.dart';
import '../providers/supabase_provider.dart';

import '../models/teacher_note_model.dart';

class PrayerProgressModel {
  final String religion;
  final int completedCount;
  final int totalRequired;
  final Set<String> completedPrayers;
  final bool isAllCompleted;

  PrayerProgressModel({
    required this.religion,
    required this.completedCount,
    required this.totalRequired,
    required this.completedPrayers,
    required this.isAllCompleted,
  });

  int get targetCount => totalRequired;
  String get displayProgress => '$completedCount/$totalRequired Waktu';
}

class HabitService extends GetxService {
  static const String _logsStorageKey = 'jurnal_habit_logs_v9';
  static final List<HabitLogModel> _memoryLogsCache = [];

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    webOptions: WebOptions(dbName: 'jurnal_kebiasaan_v9', publicKey: 'jurnal_key_v9'),
  );

  final RxList<HabitModel> habits = <HabitModel>[].obs;
  final RxList<HabitLogModel> habitLogs = <HabitLogModel>[].obs;
  final RxList<TeacherNoteModel> teacherNotes = <TeacherNoteModel>[].obs;

  final Rx<DateTime> selectedDate = Rx<DateTime>(DateTime.now());
  Timer? _syncTimer;

  String get activeStudentId {
    try {
      if (Get.isRegistered<AuthService>()) {
        final user = Get.find<AuthService>().currentUser.value;
        if (user != null && user.id.isNotEmpty) {
          return user.id;
        }
      }
    } catch (_) {}
    return 'usr-guest';
  }

  @override
  void onInit() {
    super.onInit();
    loadDefaultHabits();
    loadLogsFromStorage();
    fetchLogsFromSupabase();
    _startLiveSyncTimer();
    _subscribeToSupabaseRealtime();
  }

  /// Subscribe to Supabase Realtime changes on habit_logs & teacher_notes tables
  void _subscribeToSupabaseRealtime() {
    try {
      final client = SupabaseProvider.client;
      if (client != null) {
        client.from('habit_logs').stream(primaryKey: ['id']).listen((data) {
          final loadedLogs = data.map((item) => HabitLogModel.fromJson(item)).toList();
          habitLogs.assignAll(loadedLogs);
          habitLogs.refresh();
          _syncToMemoryCache();
          saveLogsToStorage();
          refreshHabitsForSelectedDate();
        });

        client.from('teacher_notes').stream(primaryKey: ['id']).listen((data) {
          final loadedNotes = data.map((item) => TeacherNoteModel.fromJson(item)).toList();
          teacherNotes.assignAll(loadedNotes);
          teacherNotes.refresh();
        });
      }
    } catch (e) {
      debugPrint('Error subscribing to habit_logs/teacher_notes realtime stream: $e');
    }
  }

  void _startLiveSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      fetchLogsFromSupabase();
    });
  }

  /// Fetch habit_logs & teacher_notes 100% online from Supabase Cloud Database
  Future<void> fetchLogsFromSupabase() async {
    try {
      List<dynamic> response = [];
      final client = SupabaseProvider.client;
      if (client != null) {
        try {
          response = await client.from('habit_logs').select();
        } catch (e) {
          debugPrint('client.from(habit_logs) error: $e');
        }
      }
      if (response.isEmpty) {
        response = await SupabaseProvider.restGet('habit_logs');
      }

      if (response.isNotEmpty) {
        final loadedLogs = response.map((item) => HabitLogModel.fromJson(item)).toList();
        habitLogs.assignAll(loadedLogs);
        habitLogs.refresh();
        _syncToMemoryCache();
        await saveLogsToStorage();
        refreshHabitsForSelectedDate();
      }

      List<dynamic> notesRes = [];
      if (client != null) {
        try {
          notesRes = await client.from('teacher_notes').select();
        } catch (e) {
          debugPrint('client.from(teacher_notes) error: $e');
        }
      }
      if (notesRes.isEmpty) {
        notesRes = await SupabaseProvider.restGet('teacher_notes');
      }

      if (notesRes.isNotEmpty) {
        final loadedNotes = notesRes.map((item) => TeacherNoteModel.fromJson(item)).toList();
        teacherNotes.assignAll(loadedNotes);
        teacherNotes.refresh();
      }
    } catch (e) {
      debugPrint('Error fetching habit_logs/teacher_notes from Supabase: $e');
    }
  }

  /// Clear all logs and notes data to reset to 0
  Future<void> clearAllLogsAndData() async {
    habitLogs.clear();
    teacherNotes.clear();
    _memoryLogsCache.clear();
    habitLogs.refresh();
    teacherNotes.refresh();
    await _storage.delete(key: _logsStorageKey);
    refreshHabitsForSelectedDate();
  }

  Future<void> sendTeacherNote(TeacherNoteModel note) async {
    teacherNotes.removeWhere((n) => isSameDay(n.date, note.date) && isUserMatch(n.studentId, note.studentId));
    teacherNotes.add(note);
    teacherNotes.refresh();

    try {
      final client = SupabaseProvider.client;
      if (client != null) {
        await client.from('teacher_notes').upsert(note.toJson());
      }
    } catch (e) {
      debugPrint('Error sending teacher note to Supabase: $e');
    }
  }

  TeacherNoteModel? getTeacherNoteForStudent(String studentId, {DateTime? targetDate}) {
    final dateToUse = targetDate ?? selectedDate.value;
    final target = DateTime(dateToUse.year, dateToUse.month, dateToUse.day);

    try {
      return teacherNotes.firstWhere(
        (n) => isSameDay(n.date, target) && isUserMatch(n.studentId, studentId),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchFromSyncServer() => fetchLogsFromSupabase();

  /// Push local habit_logs to Supabase Cloud Database
  Future<void> _postToSupabase() async {
    try {
      final client = SupabaseProvider.client;
      if (client != null && habitLogs.isNotEmpty) {
        final payload = habitLogs.map((log) => log.toJson()).toList();
        await client.from('habit_logs').upsert(payload);
      }
    } catch (e) {
      debugPrint('Error upserting habit_logs to Supabase: $e');
    }
  }

  void setSelectedDate(DateTime date) {
    if (isFutureDate(date)) {
      Get.snackbar(
        'Tanggal Terkunci 🔒',
        'Anda belum dapat mengisi atau melihat kebiasaan untuk tanggal di masa mendatang.',
        backgroundColor: Colors.amber.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }
    selectedDate.value = DateTime(date.year, date.month, date.day);
    refreshHabitsForSelectedDate();
  }

  bool isFutureDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.isAfter(today);
  }

  bool isSelectedDateFuture() => isFutureDate(selectedDate.value);

  bool isSameDay(DateTime a, DateTime b) {
    final la = a.toLocal();
    final lb = b.toLocal();
    return la.year == lb.year && la.month == lb.month && la.day == lb.day;
  }

  void loadDefaultHabits() {
    habits.assignAll([
      HabitModel(
        id: 'h1',
        title: '1. Bangun Pagi',
        description: 'Bangun pagi sebelum jam 05.00 WITA & merapikan tempat tidur.',
        category: 'Kedisiplinan',
        iconName: 'sun',
        points: 10,
        currentStreak: 0,
        isCompletedToday: false,
      ),
      HabitModel(
        id: 'h2',
        title: '2. Beribadah',
        description: 'Melaksanakan sholat 5 waktu / ibadah sesuai keyakinan.',
        category: 'Spiritual',
        iconName: 'praying-hands',
        points: 10,
        currentStreak: 0,
        isCompletedToday: false,
      ),
      HabitModel(
        id: 'h3',
        title: '3. Berolahraga',
        description: 'Melakukan senam / olahraga ringan minimal 15-30 menit.',
        category: 'Kesehatan',
        iconName: 'running',
        points: 10,
        currentStreak: 0,
        isCompletedToday: false,
      ),
      HabitModel(
        id: 'h4',
        title: '4. Makan Sehat & Bergizi',
        description: 'Makan sarapan / makanan sehat bergizi seimbang.',
        category: 'Kesehatan',
        iconName: 'utensils',
        points: 10,
        currentStreak: 0,
        isCompletedToday: false,
      ),
      HabitModel(
        id: 'h5',
        title: '5. Gemar Membaca',
        description: 'Membaca buku / literasi minimal 15-30 menit.',
        category: 'Literasi',
        iconName: 'book-open',
        points: 10,
        currentStreak: 0,
        isCompletedToday: false,
      ),
      HabitModel(
        id: 'h6',
        title: '6. Bermasyarakat / Kerja Bakti',
        description: 'Membantu orang tua, membersihkan rumah, atau kegiatan sosial.',
        category: 'Sosial',
        iconName: 'hands-helping',
        points: 10,
        currentStreak: 0,
        isCompletedToday: false,
      ),
      HabitModel(
        id: 'h7',
        title: '7. Istirahat Cepat',
        description: 'Tidur malam tepat waktu sebelum jam 21.30 / 22.00 WITA.',
        category: 'Kesehatan',
        iconName: 'bed',
        points: 10,
        currentStreak: 0,
        isCompletedToday: false,
      ),
    ]);

    if (_memoryLogsCache.isNotEmpty) {
      habitLogs.assignAll(_memoryLogsCache);
    }

    refreshHabitsForSelectedDate();
  }

  void addHabit(HabitModel newHabit) {
    habits.add(newHabit);
  }

  /// Filter completed habits by target date & userId matching
  bool isHabitCompletedForDate(String habitId, DateTime targetDate, {String? userId}) {
    final uid = userId ?? activeStudentId;
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);

    if (habitId == 'h2') {
      final progress = getPrayerProgress('Islam', targetDate: targetDate, userId: uid);
      return progress.completedCount > 0;
    }

    return habitLogs.any(
      (log) =>
          log.habitId == habitId &&
          isSameDay(log.date, target) &&
          log.isCompleted &&
          isUserMatch(log.userId, uid),
    );
  }

  /// Robustly match logUserId against activeUid (matches id, nisn, nis, email via MasterDataService)
  bool isUserMatch(String logUserId, String activeUid) {
    if (logUserId.trim().isEmpty || activeUid.trim().isEmpty) return false;

    final logLower = logUserId.trim().toLowerCase();
    final activeLower = activeUid.trim().toLowerCase();

    if (logLower == activeLower) return true;

    final cleanLog = logLower.replaceAll('usr-', '').replaceAll('siswa-', '').replaceAll('guru-', '').trim();
    final cleanActive = activeLower.replaceAll('usr-', '').replaceAll('siswa-', '').replaceAll('guru-', '').trim();

    if (cleanLog.isNotEmpty && cleanLog == cleanActive) return true;
    if ('usr-$cleanLog' == activeLower || 'usr-$cleanActive' == logLower) return true;
    if ('siswa-$cleanLog' == activeLower || 'siswa-$cleanActive' == logLower) return true;

    if (Get.isRegistered<MasterDataService>()) {
      final master = Get.find<MasterDataService>();

      // 1. Check Students
      for (var s in master.getAllStudentsCombined()) {
        final sid = (s['id'] as String? ?? '').toLowerCase();
        final snisn = (s['nisn'] as String? ?? '').toLowerCase();
        final snis = (s['nis'] as String? ?? '').toLowerCase();
        final semail = (s['email'] as String? ?? '').toLowerCase();

        final Set<String> studentAliases = {
          if (sid.isNotEmpty) sid,
          if (snisn.isNotEmpty) snisn,
          if (snis.isNotEmpty) snis,
          if (semail.isNotEmpty) semail,
          if (snisn.isNotEmpty) 'usr-$snisn',
          if (snisn.isNotEmpty) 'siswa-$snisn',
          if (sid.isNotEmpty) 'usr-$sid',
        };

        final logInStudent = studentAliases.contains(logLower) || (cleanLog.isNotEmpty && studentAliases.contains(cleanLog));
        final activeInStudent = studentAliases.contains(activeLower) || (cleanActive.isNotEmpty && studentAliases.contains(cleanActive));

        if (logInStudent && activeInStudent) return true;
      }

      // 2. Check Teachers
      for (var t in master.getAllTeachersCombined()) {
        final tid = (t['id'] as String? ?? '').toLowerCase();
        final temail = (t['email'] as String? ?? '').toLowerCase();
        final tname = (t['name'] as String? ?? '').toLowerCase();

        final Set<String> teacherAliases = {
          if (tid.isNotEmpty) tid,
          if (temail.isNotEmpty) temail,
          if (tname.isNotEmpty) tname,
          if (tid.isNotEmpty) 'usr-$tid',
          if (tid.isNotEmpty) 'guru-$tid',
        };

        final logInTeacher = teacherAliases.contains(logLower) || (cleanLog.isNotEmpty && teacherAliases.contains(cleanLog));
        final activeInTeacher = teacherAliases.contains(activeLower) || (cleanActive.isNotEmpty && teacherAliases.contains(cleanActive));

        if (logInTeacher && activeInTeacher) return true;
      }
    }

    return false;
  }

  int get totalCompletedForSelectedDate {
    final target = selectedDate.value;
    int count = 0;
    for (final habit in habits) {
      if (isHabitCompletedForDate(habit.id, target)) {
        count++;
      }
    }
    return count;
  }

  double get selectedDateCompletionPercentage {
    if (habits.isEmpty) return 0.0;
    return totalCompletedForSelectedDate / habits.length;
  }

  int get totalCompletedToday => totalCompletedForSelectedDate;
  double get todayCompletionPercentage => selectedDateCompletionPercentage;

  void refreshHabitsForSelectedDate() {
    final targetDate = selectedDate.value;

    habits.value = habits.map((habit) {
      final isDone = isHabitCompletedForDate(habit.id, targetDate);
      return habit.copyWith(isCompletedToday: isDone);
    }).toList();
  }

  PrayerProgressModel getPrayerProgress(String religion, {DateTime? targetDate, String? userId}) {
    final uid = userId ?? activeStudentId;
    final dateToUse = targetDate ?? selectedDate.value;
    final target = DateTime(dateToUse.year, dateToUse.month, dateToUse.day);

    if (religion == 'Islam') {
      final logsForDate = habitLogs.where(
        (log) =>
            log.habitId == 'h2' &&
            isSameDay(log.date, target) &&
            log.isCompleted &&
            isUserMatch(log.userId, uid),
      ).toList();

      final completedPrayers = logsForDate
          .map((l) => l.detailType ?? '')
          .where((type) => type.isNotEmpty)
          .toSet();

      final isSubuh = completedPrayers.contains('Sholat Subuh');
      final isDzuhur = completedPrayers.contains('Sholat Dzuhur');
      final isAshar = completedPrayers.contains('Sholat Ashar');
      final isMaghrib = completedPrayers.contains('Sholat Maghrib');
      final isIsya = completedPrayers.contains('Sholat Isya');

      final count = [isSubuh, isDzuhur, isAshar, isMaghrib, isIsya].where((b) => b).length;

      return PrayerProgressModel(
        religion: religion,
        completedCount: count,
        totalRequired: 5,
        completedPrayers: completedPrayers,
        isAllCompleted: count >= 5,
      );
    } else {
      final isDone = habitLogs.any(
        (log) =>
            log.habitId == 'h2' &&
            isSameDay(log.date, target) &&
            log.isCompleted &&
            isUserMatch(log.userId, uid),
      );
      return PrayerProgressModel(
        religion: religion,
        completedCount: isDone ? 1 : 0,
        totalRequired: 1,
        completedPrayers: isDone ? {'Ibadah Harian'} : {},
        isAllCompleted: isDone,
      );
    }
  }

  HabitLogModel? getExistingLogForPrayer(String prayerName, {DateTime? targetDate, String? userId}) {
    final uid = userId ?? activeStudentId;
    final dateToUse = targetDate ?? selectedDate.value;
    final target = DateTime(dateToUse.year, dateToUse.month, dateToUse.day);

    try {
      return habitLogs.firstWhere(
        (log) =>
            log.habitId == 'h2' &&
            isSameDay(log.date, target) &&
            log.detailType == prayerName &&
            isUserMatch(log.userId, uid),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> completePrayer({
    required String prayerName,
    required String religion,
    String? note,
    String? photoUrl,
    DateTime? targetDate,
  }) async {
    final dateToUse = targetDate ?? selectedDate.value;
    if (isFutureDate(dateToUse)) return;

    final uid = activeStudentId;
    final target = DateTime(dateToUse.year, dateToUse.month, dateToUse.day);

    habitLogs.removeWhere(
      (log) =>
          log.habitId == 'h2' &&
          isSameDay(log.date, target) &&
          log.detailType == prayerName &&
          isUserMatch(log.userId, uid),
    );

    final newLog = HabitLogModel(
      id: 'log-${DateTime.now().millisecondsSinceEpoch}',
      habitId: 'h2',
      userId: uid,
      date: target,
      isCompleted: true,
      detailType: prayerName,
      note: note ?? 'Sholat $prayerName',
      photoUrl: photoUrl,
      earnedPoints: 10,
    );

    habitLogs.add(newLog);
    habitLogs.refresh();
    _syncToMemoryCache();
    await saveLogsToStorage();
    await _postToSupabase();
    refreshHabitsForSelectedDate();
  }

  Future<void> resetPrayerLogsForDate(String religion, {DateTime? targetDate}) async {
    final dateToUse = targetDate ?? selectedDate.value;
    final uid = activeStudentId;
    final target = DateTime(dateToUse.year, dateToUse.month, dateToUse.day);

    habitLogs.removeWhere(
      (log) => log.habitId == 'h2' && isSameDay(log.date, target) && isUserMatch(log.userId, uid),
    );
    habitLogs.refresh();
    _syncToMemoryCache();
    await saveLogsToStorage();
    await _postToSupabase();
    refreshHabitsForSelectedDate();
  }

  Future<void> addHabitLog(HabitLogModel log, {String? religion}) async {
    habitLogs.removeWhere((existing) {
      if (!isSameDay(existing.date, log.date) || !isUserMatch(existing.userId, log.userId)) {
        return false;
      }
      if (log.habitId == 'h2') {
        return existing.habitId == 'h2' && existing.detailType == log.detailType;
      }
      return existing.habitId == log.habitId;
    });
    habitLogs.add(log);
    habitLogs.refresh();
    _syncToMemoryCache();
    await saveLogsToStorage();
    await _postToSupabase();
    refreshHabitsForSelectedDate();
  }

  Future<void> addOrUpdateHabitLog(HabitLogModel log, {String? religion}) async {
    await addHabitLog(log, religion: religion);
  }

  Future<void> toggleHabitCompletion(
    String habitId, {
    String? note,
    String? photoUrl,
    String? detailType,
    DateTime? targetDate,
  }) async {
    final dateToUse = targetDate ?? selectedDate.value;
    if (isFutureDate(dateToUse)) return;

    final uid = activeStudentId;
    final target = DateTime(dateToUse.year, dateToUse.month, dateToUse.day);

    final isCurrentlyCompleted = isHabitCompletedForDate(habitId, target, userId: uid);

    if (isCurrentlyCompleted) {
      habitLogs.removeWhere(
        (log) => log.habitId == habitId && isSameDay(log.date, target) && isUserMatch(log.userId, uid),
      );
    } else {
      final newLog = HabitLogModel(
        id: 'log-${DateTime.now().millisecondsSinceEpoch}',
        habitId: habitId,
        userId: uid,
        date: target,
        isCompleted: true,
        detailType: detailType,
        note: note ?? 'Telah dilaksanakan dengan baik.',
        photoUrl: photoUrl,
        earnedPoints: 10,
      );
      habitLogs.add(newLog);
    }

    habitLogs.refresh();
    _syncToMemoryCache();
    await saveLogsToStorage();
    await _postToSupabase();
    refreshHabitsForSelectedDate();
  }

  void _syncToMemoryCache() {
    _memoryLogsCache.clear();
    _memoryLogsCache.addAll(habitLogs);
  }

  HabitLogModel? getExistingLogForHabit(String habitId, {DateTime? targetDate, String? userId}) {
    final uid = userId ?? activeStudentId;
    final dateToUse = targetDate ?? selectedDate.value;
    final target = DateTime(dateToUse.year, dateToUse.month, dateToUse.day);

    try {
      return habitLogs.firstWhere(
        (log) => log.habitId == habitId && isSameDay(log.date, target) && log.isCompleted && isUserMatch(log.userId, uid),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> removeHabitLog(String habitId, DateTime targetDate, {String? userId}) async {
    final uid = userId ?? activeStudentId;
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);

    habitLogs.removeWhere(
      (log) => log.habitId == habitId && isSameDay(log.date, target) && isUserMatch(log.userId, uid),
    );

    try {
      final client = SupabaseProvider.client;
      if (client != null) {
        final targetDateStr = '${target.year}-${target.month.toString().padLeft(2, '0')}-${target.day.toString().padLeft(2, '0')}';
        await client.from('habit_logs').delete().eq('habit_id', habitId).eq('date', targetDateStr);
      }
    } catch (_) {}

    habitLogs.refresh();
    _syncToMemoryCache();
    await saveLogsToStorage();
    await _postToSupabase();
    refreshHabitsForSelectedDate();
  }

  Future<void> resetAllLogsForStudentDate(DateTime targetDate, {String? userId}) async {
    final uid = userId ?? activeStudentId;
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);

    habitLogs.removeWhere(
      (log) => isSameDay(log.date, target) && isUserMatch(log.userId, uid),
    );

    try {
      final client = SupabaseProvider.client;
      if (client != null) {
        final targetDateStr = '${target.year}-${target.month.toString().padLeft(2, '0')}-${target.day.toString().padLeft(2, '0')}';
        await client.from('habit_logs').delete().eq('date', targetDateStr);
      }
    } catch (_) {}

    habitLogs.refresh();
    _syncToMemoryCache();
    await saveLogsToStorage();
    await _postToSupabase();
    refreshHabitsForSelectedDate();
  }

  Future<void> saveLogsToStorage() async {
    try {
      final jsonList = habitLogs.map((log) => log.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _storage.write(key: _logsStorageKey, value: jsonString);
    } catch (_) {}
  }

  void _seedSampleLogsIfEmpty() {
    if (habitLogs.isEmpty) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final List<String> habitIds = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'h7'];

      // Seed 7 habits for Ahmad Fadhil (0071234567) - 100% tuntas
      for (final hId in habitIds) {
        habitLogs.add(HabitLogModel(
          id: 'sample-$hId-0071234567',
          habitId: hId,
          userId: '0071234567',
          date: today,
          isCompleted: true,
          detailType: hId == 'h2' ? 'Sholat Subuh' : null,
          note: 'Sudah dilaksanakan dengan baik.',
          earnedPoints: 10,
        ));
      }

      // Seed 7 habits for Siti Rahmawati (0071234568) - 100% tuntas
      for (final hId in habitIds) {
        habitLogs.add(HabitLogModel(
          id: 'sample-$hId-0071234568',
          habitId: hId,
          userId: '0071234568',
          date: today,
          isCompleted: true,
          detailType: hId == 'h2' ? 'Sholat Subuh' : null,
          note: 'Alhamdulillah sudah terlaksana.',
          earnedPoints: 10,
        ));
      }

      // Seed 4 habits for Budi Santoso Jr (0071234569) - 4/7 selesai
      for (final hId in habitIds.take(4)) {
        habitLogs.add(HabitLogModel(
          id: 'sample-$hId-0071234569',
          habitId: hId,
          userId: '0071234569',
          date: today,
          isCompleted: true,
          detailType: hId == 'h2' ? 'Sholat Subuh' : null,
          note: 'Selesai tepat waktu.',
          earnedPoints: 10,
        ));
      }
      habitLogs.refresh();
      _syncToMemoryCache();
    }
  }

  Future<void> loadLogsFromStorage() async {
    try {
      final storedJson = await _storage.read(key: _logsStorageKey);
      if (storedJson != null && storedJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(storedJson);
        final loadedLogs = decoded.map((item) => HabitLogModel.fromJson(item)).toList();
        
        habitLogs.assignAll(loadedLogs);
        _syncToMemoryCache();
      } else if (_memoryLogsCache.isNotEmpty) {
        habitLogs.assignAll(_memoryLogsCache);
      }
    } catch (_) {}
    _seedSampleLogsIfEmpty();
    refreshHabitsForSelectedDate();
  }

  Future<void> clearAllLogs() async {
    habitLogs.clear();
    _memoryLogsCache.clear();
    await _storage.delete(key: _logsStorageKey);
    refreshHabitsForSelectedDate();
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    super.onClose();
  }
}
