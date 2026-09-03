import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/school_data.dart';
import '../providers/supabase_provider.dart';
import 'auth_service.dart';

class MasterDataService extends GetxService {
  final _storage = const FlutterSecureStorage();
  final RxList<UserModel> supabaseTeachers = <UserModel>[].obs;
  final RxList<UserModel> supabaseStudents = <UserModel>[].obs;
  final RxList<UserModel> localStudents = <UserModel>[].obs;
  final RxList<Map<String, dynamic>> supabaseClasses = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> teacherStudentAssignments = <Map<String, dynamic>>[].obs;

  final RxMap<String, Map<String, dynamic>> savedProfileOverrides = <String, Map<String, dynamic>>{}.obs;
  final RxBool isLoadingTeachers = false.obs;
  final RxBool isLoadingStudents = false.obs;

  RealtimeChannel? _teachersChannel;
  RealtimeChannel? _studentsChannel;
  RealtimeChannel? _classesChannel;
  RealtimeChannel? _assignmentsChannel;

  Timer? _syncTimer;

  @override
  void onInit() {
    super.onInit();
    loadSavedProfilesFromStorage();
    fetchTeachersFromSupabase();
    fetchStudentsFromSupabase();
    fetchClassesFromSupabase();
    fetchAssignmentsFromSupabase();
    _subscribeRealtimeChannels();
    startRealtimeSyncTimer();
  }

  void startRealtimeSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      fetchStudentsFromSupabase();
      fetchAssignmentsFromSupabase();
      loadSavedProfilesFromStorage();
    });
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    _teachersChannel?.unsubscribe();
    _studentsChannel?.unsubscribe();
    _classesChannel?.unsubscribe();
    _assignmentsChannel?.unsubscribe();
    super.onClose();
  }

  /// Subscribe to Realtime changes on all relational master tables
  void _subscribeRealtimeChannels() {
    try {
      final client = SupabaseProvider.client;
      if (client != null) {
        // 1. Teachers channel
        _teachersChannel = client.channel('public:teachers').onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'teachers',
          callback: (_) {
            fetchTeachersFromSupabase();
          },
        );
        _teachersChannel?.subscribe();

        // 2. Students channel
        _studentsChannel = client.channel('public:students').onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'students',
          callback: (_) {
            fetchStudentsFromSupabase();
            fetchAssignmentsFromSupabase();
          },
        );
        _studentsChannel?.subscribe();

        // 3. Classes channel
        _classesChannel = client.channel('public:classes').onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'classes',
          callback: (_) {
            fetchClassesFromSupabase();
          },
        );
        _classesChannel?.subscribe();

        // 4. Relasi Assignments channel
        _assignmentsChannel = client.channel('public:teacher_student_assignments').onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'teacher_student_assignments',
          callback: (_) {
            fetchAssignmentsFromSupabase();
          },
        );
        _assignmentsChannel?.subscribe();
      }
    } catch (e) {
      debugPrint('Error subscribing to Realtime channels: $e');
    }
  }

  /// Load saved profile overrides
  Future<void> loadSavedProfilesFromStorage() async {
    try {
      final all = await _storage.readAll();
      final List<UserModel> loadedLocal = [];
      all.forEach((key, raw) {
        if (key.startsWith('profile_') && raw.isNotEmpty) {
          try {
            final emailKey = key.replaceFirst('profile_', '').trim().toLowerCase();
            final Map<String, dynamic> data = jsonDecode(raw);
            savedProfileOverrides[emailKey] = data;
            if (data['name'] != null) {
              final nameKey = data['name'].toString().trim().toLowerCase();
              savedProfileOverrides[nameKey] = data;
            }
            final role = data['role'] as String? ?? 'siswa';
            if (role == 'siswa') {
              final user = UserModel.fromJson(data);
              if (!loadedLocal.any((u) => u.id == user.id || u.nisn == user.nisn)) {
                loadedLocal.add(user);
              }
            }
          } catch (_) {}
        }
      });
      if (loadedLocal.isNotEmpty) {
        localStudents.assignAll(loadedLocal);
      }
      savedProfileOverrides.refresh();
      localStudents.refresh();
    } catch (e) {
      debugPrint('Error loading saved profile overrides: $e');
    }
  }

  void addLocalStudent(UserModel student) {
    if (!localStudents.any((s) => s.id == student.id || (s.nisn != null && s.nisn == student.nisn))) {
      localStudents.add(student);
      localStudents.refresh();
    }
    final emailKey = student.email.trim().toLowerCase();
    savedProfileOverrides[emailKey] = student.toJson();
    if (student.name.isNotEmpty) {
      savedProfileOverrides[student.name.trim().toLowerCase()] = student.toJson();
    }
    savedProfileOverrides.refresh();
  }

  /// Fetch teachers from Supabase `teachers` table
  Future<List<UserModel>> fetchTeachersFromSupabase() async {
    try {
      isLoadingTeachers.value = true;
      final client = SupabaseProvider.client;
      if (client != null) {
        final response = await client.from('teachers').select();

        final List<UserModel> loaded = (response as List).map((item) {
          return UserModel(
            id: item['id'] ?? '',
            email: item['email'] ?? '',
            name: item['name'] ?? '',
            role: 'guru_wali',
            nip: item['nip'] ?? '-',
            phone: item['phone'] ?? '08115595606',
            className: item['assigned_class'] ?? 'Wali Kelas',
            homeroomTeacher: item['name'],
            createdAt: DateTime.now(),
          );
        }).toList();

        supabaseTeachers.assignAll(loaded);
        return loaded;
      }
    } catch (e) {
      debugPrint('Error fetching teachers from Supabase: $e');
    } finally {
      isLoadingTeachers.value = false;
    }
    return [];
  }

  /// Fetch students from Supabase `students` & `profiles` tables
  Future<List<UserModel>> fetchStudentsFromSupabase() async {
    try {
      isLoadingStudents.value = true;
      final client = SupabaseProvider.client;
      if (client != null) {
        final Map<String, UserModel> studentMap = {};

        // 1. Fetch from students table
        try {
          final response = await client.from('students').select();
          for (var item in (response as List)) {
            final u = UserModel(
              id: item['id'] ?? '',
              email: item['email'] ?? '',
              name: item['name'] ?? '',
              role: 'siswa',
              nis: item['nis'] ?? '-',
              nisn: item['nisn'] ?? '-',
              className: item['class_name'] ?? 'X DKV 1',
              phone: item['phone'] ?? '0812-3456-7890',
              religion: item['religion'] ?? 'Islam',
              address: item['address'] ?? '-',
              hobby: item['hobby'] ?? '-',
              ambition: item['ambition'] ?? '-',
              favoriteSport: item['favorite_sport'] ?? '-',
              favoriteFood: item['favorite_food'] ?? '-',
              favoriteSubject: item['favorite_subject'] ?? '-',
              uniqueness: item['uniqueness'] ?? '-',
              homeroomTeacher: item['homeroom_teacher'] ?? item['wali_kelas'] ?? 'Saiful Anwar., S.Kom.,Gr',
              waliKelas: item['wali_kelas'] ?? item['homeroom_teacher'] ?? 'Saiful Anwar., S.Kom.,Gr',
              totalStreak: item['total_streak'] ?? 0,
              totalPoints: item['total_points'] ?? 0,
              createdAt: DateTime.now(),
            );
            final key = (u.nisn != null && u.nisn!.isNotEmpty) ? u.nisn! : u.id;
            studentMap[key] = u;
          }
        } catch (e) {
          debugPrint('Error fetching from students table: $e');
        }

        // 2. Fetch from profiles table (where role = 'siswa')
        try {
          final profRes = await client.from('profiles').select().eq('role', 'siswa');
          for (var item in (profRes as List)) {
            final u = UserModel.fromJson(item);
            final key = (u.nisn != null && u.nisn!.isNotEmpty) ? u.nisn! : u.id;
            if (!studentMap.containsKey(key)) {
              studentMap[key] = u;
            }
          }
        } catch (e) {
          debugPrint('Error fetching from profiles table: $e');
        }

        final List<UserModel> loaded = studentMap.values.toList();
        if (loaded.isNotEmpty) {
          supabaseStudents.assignAll(loaded);
          supabaseStudents.refresh();
        }
        return loaded;
      }
    } catch (e) {
      debugPrint('Error fetching students from Supabase: $e');
    } finally {
      isLoadingStudents.value = false;
    }
    return [];
  }

  /// Fetch master classes from Supabase `classes` table
  Future<void> fetchClassesFromSupabase() async {
    try {
      final client = SupabaseProvider.client;
      if (client != null) {
        final response = await client.from('classes').select();
        supabaseClasses.assignAll((response as List).cast<Map<String, dynamic>>());
      }
    } catch (e) {
      debugPrint('Error fetching classes from Supabase: $e');
    }
  }

  /// Fetch teacher-student assignments from `teacher_student_assignments`
  Future<void> fetchAssignmentsFromSupabase() async {
    try {
      final client = SupabaseProvider.client;
      if (client != null) {
        final response = await client.from('teacher_student_assignments').select();
        teacherStudentAssignments.assignAll((response as List).cast<Map<String, dynamic>>());
      }
    } catch (e) {
      debugPrint('Error fetching assignments from Supabase: $e');
    }
  }

  /// Get Teachers List dynamically from Supabase
  List<Map<String, dynamic>> getAllTeachersCombined() {
    final Map<String, Map<String, dynamic>> map = {};
    final sourceList = supabaseTeachers;

    for (var u in sourceList) {
      final key = u.name.trim().toLowerCase();
      final emailKey = u.email.trim().toLowerCase();
      final saved = savedProfileOverrides[emailKey] ?? savedProfileOverrides[key];

      final assignedStudentIds = teacherStudentAssignments
          .where((a) => a['teacher_id'] == u.id)
          .map((a) => a['student_id'] as String)
          .toSet();

      final allStudents = getAllStudentsCombined();

      // 1. Murid Binaan (Lintas Kelas)
      final List<StudentRecord> binaanStudents = allStudents.where((s) {
        final sid = s['id'] as String? ?? '';
        if (assignedStudentIds.contains(sid)) return true;
        final teacherQuery = u.name.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
        final studentTeacher = (s['homeroomTeacher'] as String? ?? s['guruWali'] as String? ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

        bool nameMatch = studentTeacher.isNotEmpty && (studentTeacher.contains(teacherQuery) || teacherQuery.contains(studentTeacher));
        if (!nameMatch && teacherQuery.contains('saiful')) {
          nameMatch = studentTeacher.contains('saiful') || studentTeacher.isEmpty;
        } else if (!nameMatch && teacherQuery.contains('aminah')) {
          nameMatch = studentTeacher.contains('aminah');
        } else if (!nameMatch && teacherQuery.contains('nurhayati')) {
          nameMatch = studentTeacher.contains('nurhayati');
        } else if (!nameMatch && teacherQuery.contains('budi')) {
          nameMatch = studentTeacher.contains('budi');
        }
        return nameMatch;
      }).map((s) => StudentRecord(
        nis: s['nis'] as String? ?? '-',
        nisn: s['nisn'] as String? ?? '-',
        name: s['name'] as String? ?? 'Siswa',
        className: s['className'] as String? ?? 'Siswa',
        homeroomTeacher: s['homeroomTeacher'] as String? ?? s['guruWali'] as String? ?? u.name,
        phone: s['phone'] as String? ?? '0812-3456-7890',
      )).toList();

      // 2. Murid Rombel Kelas (1 Kelas Rombel)
      final List<StudentRecord> rosterStudents = allStudents.where((s) {
        final sClass = (s['className'] as String? ?? '').trim().toLowerCase();
        final tClass = (u.className ?? '').trim().toLowerCase();
        return tClass.isNotEmpty && tClass != 'wali kelas' && sClass.isNotEmpty && (tClass == sClass || tClass.contains(sClass) || sClass.contains(tClass));
      }).map((s) => StudentRecord(
        nis: s['nis'] as String? ?? '-',
        nisn: s['nisn'] as String? ?? '-',
        name: s['name'] as String? ?? 'Siswa',
        className: s['className'] as String? ?? 'Siswa',
        homeroomTeacher: s['homeroomTeacher'] as String? ?? s['guruWali'] as String? ?? u.name,
        phone: s['phone'] as String? ?? '0812-3456-7890',
      )).toList();

      map[key] = {
        'id': u.id,
        'name': u.name,
        'email': u.email,
        'nip': (saved != null && saved['nip'] != null && saved['nip'].toString().isNotEmpty)
            ? saved['nip']
            : ((u.nip != null && u.nip!.isNotEmpty) ? u.nip! : '-'),
        'phone': (saved != null && saved['phone'] != null && saved['phone'].toString().isNotEmpty)
            ? saved['phone']
            : ((u.phone != null && u.phone!.isNotEmpty) ? u.phone! : '08115595606'),
        'assignedClass': u.className ?? 'X DKV 1',
        'source': 'Master Teachers 🏫',
        'isSupabase': true,
        'assignedStudents': binaanStudents,
        'binaanStudents': binaanStudents,
        'rosterStudents': rosterStudents,
        'userModel': u,
      };
    }

    if (Get.isRegistered<AuthService>()) {
      final currentUser = Get.find<AuthService>().currentUser.value;
      if (currentUser != null && (currentUser.role == 'guru' || currentUser.role == 'guru_wali')) {
        final key = currentUser.name.trim().toLowerCase();
        if (map.containsKey(key)) {
          final existing = map[key]!;
          map[key] = {
            ...existing,
            'nip': (currentUser.nip != null && currentUser.nip!.isNotEmpty) ? currentUser.nip! : existing['nip'],
            'phone': (currentUser.phone != null && currentUser.phone!.isNotEmpty) ? currentUser.phone! : existing['phone'],
          };
        }
      }
    }

    return map.values.toList();
  }

  /// Default Master Students fallback list (empty, online data only)
  final List<UserModel> defaultMasterStudents = [];

  String findWaliKelasForClass(String className) {
    final cleanClass = className.trim().toLowerCase();
    if (cleanClass.isEmpty) return 'Dra. Hajah Nurhayati';

    // 1. Check matching teacher in supabaseTeachers who chose this class as assignedClass
    for (var t in supabaseTeachers) {
      final assigned = (t.className ?? '').trim().toLowerCase();
      if (assigned.isNotEmpty && (assigned == cleanClass || assigned.contains(cleanClass) || cleanClass.contains(assigned))) {
        return t.name;
      }
    }

    // 2. Default mapping by class if not registered yet in supabaseTeachers
    if (cleanClass.contains('dkv 1')) return 'Saiful Anwar., S.Kom.,Gr';
    if (cleanClass.contains('dkv 2')) return 'Aminah Tajudin., S.Pd.I';
    if (cleanClass.contains('pplg 1') || cleanClass.contains('pplg')) return 'Dra. Hajah Nurhayati';
    if (cleanClass.contains('tjkt 3')) return 'Vicky Priyadi., S.Pd.,Gr';
    if (cleanClass.contains('tjkt')) return 'Budi Santoso., S.T';

    return 'Dra. Hajah Nurhayati';
  }

  /// Get Students List
  List<Map<String, dynamic>> getAllStudentsCombined() {
    final Map<String, Map<String, dynamic>> map = {};

    // 1. Add students from supabaseStudents (100% Online Supabase DB)
    for (var u in supabaseStudents) {
      final key = (u.nisn != null && u.nisn!.isNotEmpty) ? u.nisn!.trim().toLowerCase() : u.id;
      final cName = u.className ?? 'X DKV 1';
      final defaultWaliKelasRombel = findWaliKelasForClass(cName);

      // Wali Kelas Rombel: Guru yang mengampu rombel kelas siswa
      final waliKelasRombel = (u.waliKelas != null && u.waliKelas!.isNotEmpty && u.waliKelas != 'Guru Wali Pembina' && u.waliKelas != u.homeroomTeacher)
          ? u.waliKelas!
          : defaultWaliKelasRombel;

      // Guru Wali Pembina: Guru pembina jurnal kebiasaan (terikat/lintas kelas)
      final guruWaliPembina = (u.homeroomTeacher != null && u.homeroomTeacher!.isNotEmpty && u.homeroomTeacher != 'Guru Wali Pembina')
          ? u.homeroomTeacher!
          : defaultWaliKelasRombel;

      map[key] = {
        'id': u.id,
        'name': u.name,
        'nis': u.nis ?? '-',
        'nisn': u.nisn ?? '-',
        'className': cName,
        'phone': u.phone ?? '0812-3456-7890',
        'waliKelas': waliKelasRombel,
        'guruWali': guruWaliPembina,
        'homeroomTeacher': guruWaliPembina,
        'religion': u.religion,
        'address': u.address ?? '-',
        'hobby': u.hobby ?? '-',
        'ambition': u.ambition ?? '-',
        'favoriteSport': u.favoriteSport ?? '-',
        'favoriteFood': u.favoriteFood ?? '-',
        'favoriteSubject': u.favoriteSubject ?? '-',
        'uniqueness': u.uniqueness ?? '-',
        'streak': u.totalStreak,
        'points': u.totalPoints,
        'source': 'Supabase Master Students 🎓',
        'isSupabase': true,
        'userModel': u.copyWith(
          waliKelas: waliKelasRombel,
          homeroomTeacher: guruWaliPembina,
        ),
      };
    }

    // 2. Add students from localStudents RxList
    for (var u in localStudents) {
      final key = (u.nisn != null && u.nisn!.isNotEmpty) ? u.nisn!.trim().toLowerCase() : u.id;
      if (!map.containsKey(key)) {
        final cName = u.className ?? 'X DKV 1';
        final waliKelasRombel = findWaliKelasForClass(cName);
        final guruWaliPembina = (u.homeroomTeacher != null && u.homeroomTeacher!.isNotEmpty && u.homeroomTeacher != 'Guru Wali Pembina')
            ? u.homeroomTeacher!
            : waliKelasRombel;

        map[key] = {
          'id': u.id,
          'name': u.name,
          'nis': u.nis ?? '-',
          'nisn': u.nisn ?? '-',
          'className': cName,
          'phone': u.phone ?? '0812-3456-7890',
          'waliKelas': waliKelasRombel,
          'guruWali': guruWaliPembina,
          'homeroomTeacher': guruWaliPembina,
          'religion': u.religion,
          'address': u.address ?? '-',
          'hobby': u.hobby ?? '-',
          'ambition': u.ambition ?? '-',
          'favoriteSport': u.favoriteSport ?? '-',
          'favoriteFood': u.favoriteFood ?? '-',
          'favoriteSubject': u.favoriteSubject ?? '-',
          'uniqueness': u.uniqueness ?? '-',
          'streak': u.totalStreak,
          'points': u.totalPoints,
          'source': 'Local Registered Student 🎓',
          'isSupabase': false,
          'userModel': u.copyWith(
            waliKelas: waliKelasRombel,
            homeroomTeacher: guruWaliPembina,
          ),
        };
      }
    }

    // 3. Add students from savedProfileOverrides (locally registered profiles)
    savedProfileOverrides.forEach((key, data) {
      final role = data['role'] as String? ?? 'siswa';
      if (role == 'siswa') {
        final nisn = data['nisn'] as String? ?? data['id'] as String? ?? '';
        final mapKey = nisn.isNotEmpty ? nisn.trim().toLowerCase() : (data['id'] as String? ?? '');
        if (mapKey.isNotEmpty && !map.containsKey(mapKey)) {
          final cName = data['class_name'] as String? ?? data['className'] as String? ?? 'X DKV 1';
          final waliKelasRombel = findWaliKelasForClass(cName);
          final guruWaliPembina = data['homeroom_teacher'] as String? ?? data['homeroomTeacher'] as String? ?? waliKelasRombel;

          map[mapKey] = {
            'id': data['id'] ?? 'usr-$nisn',
            'name': data['name'] ?? 'Siswa Baru',
            'nis': data['nis'] ?? '-',
            'nisn': nisn.isNotEmpty ? nisn : '-',
            'className': cName,
            'phone': data['phone'] ?? '0812-3456-7890',
            'waliKelas': waliKelasRombel,
            'guruWali': guruWaliPembina,
            'homeroomTeacher': guruWaliPembina,
            'religion': data['religion'] ?? 'Islam',
            'address': data['address'] ?? '-',
            'hobby': data['hobby'] ?? '-',
            'ambition': data['ambition'] ?? '-',
            'favoriteSport': data['favorite_sport'] ?? '-',
            'favoriteFood': data['favorite_food'] ?? '-',
            'favoriteSubject': data['favorite_subject'] ?? '-',
            'uniqueness': data['uniqueness'] ?? '-',
            'streak': data['total_streak'] ?? 0,
            'points': data['total_points'] ?? 0,
            'source': 'Local Registered Student 🎓',
            'isSupabase': false,
            'userModel': UserModel.fromJson(data),
          };
        }
      }
    });

    return map.values.toList();
  }

  /// Get Classes List
  /// Get Classes List dynamically 100% from Supabase `classes`, `students`, & `teachers`
  List<Map<String, dynamic>> getAllClassesCombined() {
    final students = getAllStudentsCombined();
    final teachers = getAllTeachersCombined();

    final Map<String, int> classStudentCountMap = {};

    // 1. Add classes from Supabase `classes` table
    for (var c in supabaseClasses) {
      final className = (c['name'] as String? ?? c['class_name'] as String? ?? '').trim();
      if (className.isNotEmpty) {
        classStudentCountMap[className] = 0;
      }
    }

    // 2. Add classes from students
    for (var s in students) {
      final cName = (s['className'] as String?)?.trim();
      if (cName != null && cName.isNotEmpty) {
        classStudentCountMap[cName] = (classStudentCountMap[cName] ?? 0) + 1;
      }
    }

    // 3. Add classes assigned to teachers
    for (var t in teachers) {
      final assigned = (t['assignedClass'] as String?)?.trim();
      if (assigned != null && assigned.isNotEmpty && assigned != 'Wali Kelas') {
        classStudentCountMap.putIfAbsent(assigned, () => 0);
      }
    }

    // Default classes fallback (All 24 classes for TJKT, PPLG, DKV, Animasi across X, XI, XII)
    final defaultClassNames = [
      'X TJKT 1', 'X TJKT 2', 'X TJKT 3',
      'XI TJKT 1', 'XI TJKT 2', 'XI TJKT 3',
      'XII TJKT 1', 'XII TJKT 2', 'XII TJKT 3',
      'X PPLG 1', 'X PPLG 2',
      'XI PPLG 1', 'XI PPLG 2',
      'XII PPLG 1', 'XII PPLG 2',
      'X DKV 1', 'X DKV 2',
      'XI DKV 1', 'XI DKV 2',
      'XII DKV 1', 'XII DKV 2',
      'X Animasi', 'XI Animasi', 'XII Animasi'
    ];
    for (var c in defaultClassNames) {
      classStudentCountMap.putIfAbsent(c, () => 0);
    }

    final List<Map<String, dynamic>> result = [];

    classStudentCountMap.forEach((cName, count) {
      String teacherName = findWaliKelasForClass(cName);

      // Check explicit homeroom_teacher_id from supabaseClasses
      final classRecord = supabaseClasses.firstWhereOrNull((c) {
        final name = (c['name'] as String? ?? c['class_name'] as String? ?? '').trim();
        return name == cName;
      });

      if (classRecord != null && classRecord['homeroom_teacher_id'] != null) {
        final teacherId = classRecord['homeroom_teacher_id'] as String;
        final matchedTeacher = supabaseTeachers.firstWhereOrNull((t) => t.id == teacherId);
        if (matchedTeacher != null) {
          teacherName = matchedTeacher.name;
        }
      }

      if (teacherName.isEmpty || teacherName == 'Dra. Hajah Nurhayati') {
        for (var t in teachers) {
          final assigned = (t['assignedClass'] as String? ?? '').trim();
          if (assigned == cName || assigned.contains(cName)) {
            teacherName = t['name'] as String;
            break;
          }
        }
      }

      String grade = 'X';
      if (cName.startsWith('XII')) {
        grade = 'XII';
      } else if (cName.startsWith('XI')) {
        grade = 'XI';
      } else if (cName.startsWith('X')) {
        grade = 'X';
      }

      String major = 'Umum';
      if (cName.contains('TJKT')) {
        major = 'TJKT';
      } else if (cName.contains('DKV')) {
        major = 'DKV';
      } else if (cName.contains('PPLG')) {
        major = 'PPLG';
      } else if (cName.contains('Animasi')) {
        major = 'Animasi';
      }

      result.add({
        'className': cName,
        'grade': grade,
        'major': major,
        'homeroomTeacher': teacherName,
        'studentCount': count,
      });
    });

    result.sort((a, b) => (a['className'] as String).compareTo(b['className'] as String));
    return result;
  }

  /// Assign / Update Homeroom Teacher (Wali Kelas) for a Class in Supabase DB
  Future<bool> assignHomeroomTeacherToClass({
    required String className,
    required String teacherId,
    required String teacherName,
  }) async {
    try {
      final client = SupabaseProvider.client;
      if (client != null) {
        // 1. Update or upsert class in `classes` table with homeroom_teacher_id
        await client.from('classes').upsert({
          'id': className,
          'class_name': className,
          'homeroom_teacher_id': teacherId,
          'updated_at': DateTime.now().toIso8601String(),
        });

        // 2. Update teacher's assigned_class in `teachers` & `profiles` table
        await client.from('teachers').update({
          'assigned_class': className,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', teacherId);

        await client.from('profiles').update({
          'class_name': className,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', teacherId);

        // 3. Update all students in this class to have this teacher as homeroom_teacher / wali_kelas
        await client.from('students').update({
          'homeroom_teacher': teacherName,
          'wali_kelas': teacherName,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('class_name', className);

        await client.from('profiles').update({
          'homeroom_teacher': teacherName,
          'wali_kelas': teacherName,
          'updated_at': DateTime.now().toIso8601String(),
        }).filter('role', 'eq', 'siswa').filter('class_name', 'eq', className);

        // 4. Refresh real-time state from Supabase DB
        await fetchClassesFromSupabase();
        await fetchTeachersFromSupabase();
        await fetchStudentsFromSupabase();
        await fetchAssignmentsFromSupabase();
        return true;
      }
    } catch (e) {
      debugPrint('Error assigning homeroom teacher to class: $e');
    }
    return false;
  }

  /// Synchronize / Move a student to a new class & update homeroom teacher
  Future<bool> updateStudentClass({
    required String studentId,
    required String newClassName,
    required String newHomeroomTeacher,
  }) async {
    try {
      final client = SupabaseProvider.client;
      if (client != null) {
        await client.from('students').update({
          'class_name': newClassName,
          'homeroom_teacher': newHomeroomTeacher,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', studentId);
        
        await client.from('profiles').update({
          'class_name': newClassName,
          'homeroom_teacher': newHomeroomTeacher,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', studentId);

        await fetchStudentsFromSupabase();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating student class in Supabase: $e');
    }
    return false;
  }

  /// Add new Teacher to Supabase `teachers` table
  Future<bool> addTeacherToSupabase({
    required String name,
    required String email,
    required String assignedClass,
    String? nip,
    String? phone,
  }) async {
    try {
      final client = SupabaseProvider.client;
      if (client != null) {
        final newId = 'guru-${DateTime.now().millisecondsSinceEpoch}';
        final teacherData = {
          'id': newId,
          'email': email,
          'name': name,
          'phone': phone ?? '08115595606',
          'nip': nip ?? '-',
          'assigned_class': assignedClass,
          'updated_at': DateTime.now().toIso8601String(),
        };

        await client.from('teachers').insert(teacherData);
        await client.from('profiles').insert({
          'id': newId,
          'email': email,
          'name': name,
          'phone': phone ?? '08115595606',
          'nip': nip ?? '-',
          'role': 'guru_wali',
          'class_name': assignedClass,
          'homeroom_teacher': name,
          'updated_at': DateTime.now().toIso8601String(),
        });

        await fetchTeachersFromSupabase();
        return true;
      }
    } catch (e) {
      debugPrint('Error adding teacher to Supabase: $e');
    }
    return false;
  }

  /// Add new Student to Supabase `students` table & create assignment relation
  Future<bool> addStudentToSupabase({
    required String name,
    required String email,
    required String nis,
    required String nisn,
    required String className,
    required String homeroomTeacher,
    String? waliKelas,
    String? phone,
    String religion = 'Islam',
    String? customId,
  }) async {
    try {
      final client = SupabaseProvider.client;
      if (client != null) {
        final newId = (customId != null && customId.isNotEmpty) ? customId : 'usr-$nisn';
        final teacherVal = homeroomTeacher.isNotEmpty ? homeroomTeacher : (waliKelas ?? 'Saiful Anwar., S.Kom.,Gr');
        final waliVal = (waliKelas != null && waliKelas.isNotEmpty) ? waliKelas : teacherVal;

        final studentData = {
          'id': newId,
          'email': email,
          'name': name,
          'nis': nis,
          'nisn': nisn,
          'religion': religion,
          'class_id': className,
          'class_name': className,
          'phone': phone ?? '0812-3456-7890',
          'homeroom_teacher': teacherVal,
          'wali_kelas': waliVal,
          'updated_at': DateTime.now().toIso8601String(),
        };

        await client.from('students').upsert(studentData);
        await client.from('profiles').upsert({
          'id': newId,
          'email': email,
          'name': name,
          'nis': nis,
          'nisn': nisn,
          'religion': religion,
          'class_name': className,
          'phone': phone ?? '0812-3456-7890',
          'homeroom_teacher': teacherVal,
          'wali_kelas': waliVal,
          'role': 'siswa',
          'is_profile_completed': true,
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Find teacher ID for homeroomTeacher to create junction table relation
        String? teacherId;
        final teacherMatch = supabaseTeachers.firstWhereOrNull(
          (t) => t.name.toLowerCase().contains(teacherVal.toLowerCase()) || teacherVal.toLowerCase().contains(t.name.toLowerCase()),
        );
        if (teacherMatch != null) {
          teacherId = teacherMatch.id;
        } else if (teacherVal.toLowerCase().contains('saiful')) {
          teacherId = 'guru-1';
        } else {
          try {
            final tRes = await client.from('teachers').select('id').ilike('name', '%$teacherVal%').limit(1);
            if (tRes.isNotEmpty) {
              teacherId = tRes.first['id'] as String?;
            }
          } catch (_) {}
        }

        if (teacherId != null && teacherId.isNotEmpty) {
          await client.from('teacher_student_assignments').upsert({
            'teacher_id': teacherId,
            'student_id': newId,
          });
        }

        await fetchStudentsFromSupabase();
        await fetchAssignmentsFromSupabase();
        return true;
      }
    } catch (e) {
      debugPrint('Error adding student to Supabase: $e');
    }
    return false;
  }

  /// Delete Teacher profile from Supabase `teachers` & `profiles`
  Future<bool> deleteTeacherFromSupabase(String id) async {
    try {
      final client = SupabaseProvider.client;
      if (client != null) {
        await client.from('teachers').delete().eq('id', id);
        await client.from('profiles').delete().eq('id', id);
        await fetchTeachersFromSupabase();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting teacher: $e');
    }
    return false;
  }

  /// Update existing Teacher in Supabase `teachers` & `profiles`
  Future<bool> updateTeacherInSupabase({
    required String id,
    required String name,
    required String email,
    required String nip,
    required String phone,
    required String assignedClass,
  }) async {
    try {
      final client = SupabaseProvider.client;
      if (client != null) {
        final teacherData = {
          'id': id,
          'email': email,
          'name': name,
          'nip': nip,
          'phone': phone,
          'assigned_class': assignedClass,
          'updated_at': DateTime.now().toIso8601String(),
        };

        await client.from('teachers').upsert(teacherData);
        await client.from('profiles').upsert({
          'id': id,
          'email': email,
          'name': name,
          'nip': nip,
          'phone': phone,
          'role': 'guru_wali',
          'class_name': assignedClass,
          'updated_at': DateTime.now().toIso8601String(),
        });

        await fetchTeachersFromSupabase();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating teacher in Supabase: $e');
    }
    return false;
  }

  /// Update existing Student in Supabase `students` & `profiles`
  Future<bool> updateStudentInSupabase({
    required String id,
    required String name,
    required String email,
    required String nis,
    required String nisn,
    required String className,
    required String waliKelas,
    required String homeroomTeacher,
    String? phone,
    String religion = 'Islam',
  }) async {
    try {
      final client = SupabaseProvider.client;
      if (client != null) {
        final studentData = {
          'id': id,
          'email': email,
          'name': name,
          'nis': nis,
          'nisn': nisn,
          'class_id': className,
          'class_name': className,
          'wali_kelas': waliKelas,
          'homeroom_teacher': homeroomTeacher,
          'phone': phone ?? '0812-3456-7890',
          'religion': religion,
          'updated_at': DateTime.now().toIso8601String(),
        };

        await client.from('students').upsert(studentData);
        await client.from('profiles').upsert({
          'id': id,
          'email': email,
          'name': name,
          'nis': nis,
          'nisn': nisn,
          'class_name': className,
          'wali_kelas': waliKelas,
          'homeroom_teacher': homeroomTeacher,
          'phone': phone ?? '0812-3456-7890',
          'religion': religion,
          'role': 'siswa',
          'is_profile_completed': true,
          'updated_at': DateTime.now().toIso8601String(),
        });

        await fetchStudentsFromSupabase();
        await fetchAssignmentsFromSupabase();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating student in Supabase: $e');
    }
    return false;
  }

  /// Delete Student profile from Supabase `students` & `profiles`
  Future<bool> deleteStudentFromSupabase(String id) async {
    try {
      final client = SupabaseProvider.client;
      if (client != null) {
        await client.from('students').delete().eq('id', id);
        await client.from('profiles').delete().eq('id', id);
        await fetchStudentsFromSupabase();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting student: $e');
    }
    return false;
  }
}
