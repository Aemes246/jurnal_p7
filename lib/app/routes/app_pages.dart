// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'app_routes.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/bindings/register_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/habit_tracker/views/habit_list_view.dart';
import '../modules/habit_tracker/views/add_habit_view.dart';
import '../modules/habit_tracker/bindings/habit_binding.dart';
import '../modules/journal/views/journal_entry_view.dart';
import '../modules/journal/bindings/journal_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/admin/views/master_guru_view.dart';
import '../modules/admin/bindings/master_guru_binding.dart';
import '../modules/admin/views/master_siswa_view.dart';
import '../modules/admin/bindings/master_siswa_binding.dart';
import '../modules/admin/views/master_kelas_view.dart';
import '../modules/admin/bindings/master_kelas_binding.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.HABIT_LIST,
      page: () => const HabitListView(),
      binding: HabitBinding(),
    ),
    GetPage(
      name: Routes.ADD_HABIT,
      page: () => const AddHabitView(),
      binding: HabitBinding(),
    ),
    GetPage(
      name: Routes.JOURNAL_ENTRY,
      page: () => const JournalEntryView(),
      binding: JournalBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.MASTER_GURU,
      page: () => const MasterGuruView(),
      binding: MasterGuruBinding(),
    ),
    GetPage(
      name: Routes.MASTER_SISWA,
      page: () => const MasterSiswaView(),
      binding: MasterSiswaBinding(),
    ),
    GetPage(
      name: Routes.MASTER_KELAS,
      page: () => const MasterKelasView(),
      binding: MasterKelasBinding(),
    ),
  ];
}
