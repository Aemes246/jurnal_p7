import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../data/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isObscure = true.obs;
  final isLoading = false.obs;

  final selectedStudentNisn = '113458398'.obs;
  final selectedTeacherEmail = 'saifulanwar@smkn7.sch.id'.obs;

  void togglePasswordVisibility() {
    isObscure.value = !isObscure.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Username / NISN dan Password harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    final success = await _authService.login(email, password);
    isLoading.value = false;

    if (success) {
      Get.offAllNamed(Routes.DASHBOARD);
    }
  }

  Future<void> loginWithBiometrics() async {
    final authenticated = await _authService.authenticateWithBiometrics();
    if (authenticated) {
      await _authService.login('saiful', '123456');
      Get.offAllNamed(Routes.DASHBOARD);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
