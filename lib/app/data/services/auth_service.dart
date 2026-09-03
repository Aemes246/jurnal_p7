import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import '../models/user_model.dart';
import '../providers/supabase_provider.dart';
import '../services/habit_service.dart';
import '../services/master_data_service.dart';

class AuthService extends GetxService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    webOptions: WebOptions(dbName: 'jurnal_auth_v9', publicKey: 'jurnal_auth_key_v9'),
  );
  final _localAuth = LocalAuthentication();

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoggedIn = false.obs;
  final RxBool isBiometricsAvailable = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkBiometrics();
    loadDefaultUser();
  }

  void _notifyHabitServiceRefresh() {
    try {
      if (Get.isRegistered<HabitService>()) {
        Get.find<HabitService>().refreshHabitsForSelectedDate();
      }
    } catch (_) {}
  }

  Future<UserModel?> _getSavedProfile(String email) async {
    try {
      final key = 'profile_${email.trim().toLowerCase()}';
      final savedJson = await _storage.read(key: key);
      if (savedJson != null && savedJson.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(savedJson);
        return UserModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error reading saved profile: $e');
    }
    return null;
  }

  Future<void> checkBiometrics() async {
    try {
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      isBiometricsAvailable.value = canAuthenticate;
    } catch (_) {
      isBiometricsAvailable.value = false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    if (!isBiometricsAvailable.value) return false;
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Gunakan biometrik untuk masuk ke Jurnal Kebiasaan Baik',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  void setReligion(String newReligion) {
    if (currentUser.value != null) {
      currentUser.value = currentUser.value!.copyWith(religion: newReligion);
    }
  }

  void loadDefaultUser() {
    if (Get.isRegistered<MasterDataService>()) {
      final master = Get.find<MasterDataService>();
      final students = master.getAllStudentsCombined();
      if (students.isNotEmpty) {
        final s = students.first;
        final name = s['name'] as String? ?? 'Siswa';
        final nisn = s['nisn'] as String? ?? s['id'] as String? ?? '';
        final nis = s['nis'] as String? ?? '-';
        final className = s['className'] as String? ?? 'X DKV 1';
        final teacher = s['homeroomTeacher'] as String? ?? 'Saiful Anwar., S.Kom.,Gr';
        final email = s['email'] as String? ?? '$nisn@smkn7.sch.id';

        currentUser.value = UserModel(
          id: s['id'] as String? ?? 'usr-$nisn',
          email: email,
          name: name,
          nis: nis,
          nisn: nisn,
          className: className,
          phone: s['phone'] as String? ?? '0812-3456-7890',
          role: 'siswa',
          religion: s['religion'] as String? ?? 'Islam',
          address: s['address'] as String? ?? '',
          hobby: s['hobby'] as String? ?? '',
          ambition: s['ambition'] as String? ?? '',
          favoriteSport: s['favoriteSport'] as String? ?? '',
          favoriteFood: s['favoriteFood'] as String? ?? '',
          favoriteSubject: s['favoriteSubject'] as String? ?? '',
          uniqueness: s['uniqueness'] as String? ?? '',
          homeroomTeacher: teacher,
          homeroomTeacherSignature: 'Telah Disetujui Wali Kelas SMKN 7',
          isProfileCompleted: false,
          totalStreak: 0,
          totalPoints: 0,
          createdAt: DateTime.now(),
        );
        isLoggedIn.value = false;
        _notifyHabitServiceRefresh();
        return;
      }
    }

    currentUser.value = null;
    isLoggedIn.value = false;
    _notifyHabitServiceRefresh();
  }

  Future<void> loadTeacherUser(String teacherName) async {
    if (Get.isRegistered<MasterDataService>()) {
      final master = Get.find<MasterDataService>();
      final teachers = master.supabaseTeachers;
      final query = teacherName.toLowerCase();
      final match = teachers.firstWhereOrNull(
        (t) => t.name.toLowerCase().contains(query) || t.email.toLowerCase().contains(query),
      );

      if (match != null) {
        final saved = await _getSavedProfile(match.email);
        currentUser.value = saved ?? match;
        isLoggedIn.value = true;
        _notifyHabitServiceRefresh();
        return;
      }
    }

    currentUser.value = UserModel(
      id: 'guru-1',
      email: 'saifulanwar@smkn7.sch.id',
      name: teacherName.isNotEmpty ? teacherName : 'Saiful Anwar., S.Kom.,Gr',
      role: 'guru_wali',
      nip: '19890107 202421 1 009',
      phone: '08115595606',
      className: 'X, XI, XII DKV 1',
      homeroomTeacher: teacherName.isNotEmpty ? teacherName : 'Saiful Anwar., S.Kom.,Gr',
      isProfileCompleted: true,
      createdAt: DateTime.now(),
    );
    isLoggedIn.value = true;
    _notifyHabitServiceRefresh();
  }

  Future<void> loadSuperadminUser() async {
    const email = 'superadmin@smkn7samarinda.sch.id';
    final saved = await _getSavedProfile(email);
    if (saved != null) {
      currentUser.value = saved;
    } else {
      currentUser.value = UserModel(
        id: 'usr-superadmin-1',
        email: email,
        name: 'Super Administrator SMKN 7',
        role: 'superadmin',
        className: 'Semua Kelas',
        phone: '0812-7777-8888',
        isProfileCompleted: true,
        createdAt: DateTime.now(),
      );
    }
    isLoggedIn.value = true;
    _notifyHabitServiceRefresh();
  }

  Future<bool> login(String nisnOrEmail, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final query = nisnOrEmail.trim().toLowerCase();

    if (query.isEmpty) return false;

    // 1. Superadmin login (query contains 'admin' or 'super')
    if (query.contains('admin') || query.contains('super')) {
      await loadSuperadminUser();
      await _storage.write(key: 'session_token', value: 'admin_token');
      return true;
    }

    // 2. Guru Wali (Saiful Anwar) login (query contains 'saiful' or 'guru')
    if (query.contains('saiful') || query.contains('guru') || query == '19890107 202421 1 009') {
      await loadTeacherUser('Saiful Anwar., S.Kom.,Gr');
      await _storage.write(key: 'session_token', value: 'teacher_token');
      return true;
    }

    // 3. Query Supabase Database directly for profiles / students matching NISN, email, NIS, or name
    try {
      final client = SupabaseProvider.client;
      if (client != null) {
        // Query profiles table
        final response = await client
            .from('profiles')
            .select()
            .or('email.ilike.%$query%,nisn.eq.$query,nis.eq.$query,name.ilike.%$query%')
            .limit(1);

        if (response.isNotEmpty) {
          final matchedUser = UserModel.fromJson(response.first);
          currentUser.value = matchedUser;
          isLoggedIn.value = true;
          await _storage.write(key: 'session_token', value: 'token_${matchedUser.id}');
          _notifyHabitServiceRefresh();
          return true;
        }

        // Query students table directly
        final studentRes = await client
            .from('students')
            .select()
            .or('email.ilike.%$query%,nisn.eq.$query,nis.eq.$query,name.ilike.%$query%')
            .limit(1);

        if (studentRes.isNotEmpty) {
          final item = studentRes.first;
          final matchedUser = UserModel(
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
            homeroomTeacher: item['homeroom_teacher'] ?? 'Saiful Anwar., S.Kom.,Gr',
            waliKelas: item['wali_kelas'] ?? 'Saiful Anwar., S.Kom.,Gr',
            totalStreak: item['total_streak'] ?? 0,
            totalPoints: item['total_points'] ?? 0,
            createdAt: DateTime.now(),
          );
          currentUser.value = matchedUser;
          isLoggedIn.value = true;
          await _storage.write(key: 'session_token', value: 'token_${matchedUser.id}');
          _notifyHabitServiceRefresh();
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error logging in via Supabase online: $e');
    }

    // 4. Query loaded MasterDataService students list (fetched live from Supabase DB)
    if (Get.isRegistered<MasterDataService>()) {
      final master = Get.find<MasterDataService>();
      final studentMatch = master.supabaseStudents.firstWhereOrNull(
        (s) => (s.nisn ?? '').toLowerCase() == query ||
            (s.nis ?? '').toLowerCase() == query ||
            s.email.toLowerCase() == query ||
            s.name.toLowerCase().contains(query),
      );

      if (studentMatch != null) {
        currentUser.value = studentMatch;
        isLoggedIn.value = true;
        await _storage.write(key: 'session_token', value: 'token_${studentMatch.id}');
        _notifyHabitServiceRefresh();
        return true;
      }
    }

    // 5. Search saved profile
    final email = query.contains('@') ? query : '$query@smkn7.sch.id';
    final saved = await _getSavedProfile(email) ?? await _getSavedProfile(query);
    if (saved != null) {
      currentUser.value = saved;
      isLoggedIn.value = true;
      await _storage.write(key: 'session_token', value: 'token_${saved.id}');
      _notifyHabitServiceRefresh();
      return true;
    }

    return false;
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    currentUser.value = updatedUser;

    try {
      // 1. Save to FlutterSecureStorage locally
      final key = 'profile_${updatedUser.email.trim().toLowerCase()}';
      await _storage.write(key: key, value: jsonEncode(updatedUser.toJson()));

      // 2. Upsert to Supabase profiles & relational tables (students/teachers)
      final client = SupabaseProvider.client;
      if (client != null) {
        final profileData = {
          'id': updatedUser.id,
          'email': updatedUser.email,
          'name': updatedUser.name,
          'role': updatedUser.role,
          'religion': updatedUser.religion,
          'nis': updatedUser.nis,
          'nisn': updatedUser.nisn,
          'nip': updatedUser.nip,
          'phone': updatedUser.phone,
          'class_name': updatedUser.className,
          'address': updatedUser.address,
          'hobby': updatedUser.hobby,
          'ambition': updatedUser.ambition,
          'favorite_sport': updatedUser.favoriteSport,
          'favorite_food': updatedUser.favoriteFood,
          'favorite_subject': updatedUser.favoriteSubject,
          'uniqueness': updatedUser.uniqueness,
          'homeroom_teacher': updatedUser.homeroomTeacher ?? updatedUser.waliKelas,
          'wali_kelas': updatedUser.waliKelas ?? updatedUser.homeroomTeacher,
          'is_profile_completed': updatedUser.isProfileCompleted,
          'updated_at': DateTime.now().toIso8601String(),
        };

        await client.from('profiles').upsert(profileData);

        if (updatedUser.role == 'siswa') {
          await client.from('students').upsert({
            'id': updatedUser.id,
            'email': updatedUser.email,
            'name': updatedUser.name,
            'nis': updatedUser.nis ?? '-',
            'nisn': updatedUser.nisn ?? updatedUser.id,
            'class_id': updatedUser.className,
            'class_name': updatedUser.className,
            'phone': updatedUser.phone,
            'religion': updatedUser.religion,
            'address': updatedUser.address,
            'hobby': updatedUser.hobby,
            'ambition': updatedUser.ambition,
            'favorite_sport': updatedUser.favoriteSport,
            'favorite_food': updatedUser.favoriteFood,
            'favorite_subject': updatedUser.favoriteSubject,
            'uniqueness': updatedUser.uniqueness,
            'homeroom_teacher': updatedUser.homeroomTeacher ?? updatedUser.waliKelas,
            'wali_kelas': updatedUser.waliKelas ?? updatedUser.homeroomTeacher,
            'updated_at': DateTime.now().toIso8601String(),
          });
        } else if (updatedUser.role == 'guru' || updatedUser.role == 'guru_wali') {
          await client.from('teachers').upsert({
            'id': updatedUser.id,
            'email': updatedUser.email,
            'name': updatedUser.name,
            'nip': updatedUser.nip,
            'phone': updatedUser.phone,
            'assigned_class': updatedUser.className,
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      debugPrint('Error updating user profile in storage/supabase: $e');
    }

    if (Get.isRegistered<MasterDataService>()) {
      await Get.find<MasterDataService>().loadSavedProfilesFromStorage();
      await Get.find<MasterDataService>().fetchTeachersFromSupabase();
      await Get.find<MasterDataService>().fetchStudentsFromSupabase();
    }

    _notifyHabitServiceRefresh();
    return true;
  }

  Future<bool> registerUser(UserModel newUser, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    currentUser.value = newUser;
    isLoggedIn.value = true;
    await _storage.write(key: 'session_token', value: 'user_token_${newUser.id}');
    await updateProfile(newUser);
    _notifyHabitServiceRefresh();
    return true;
  }

  Future<void> logout() async {
    currentUser.value = null;
    isLoggedIn.value = false;
    await _storage.delete(key: 'session_token');
    loadDefaultUser();
  }
}
