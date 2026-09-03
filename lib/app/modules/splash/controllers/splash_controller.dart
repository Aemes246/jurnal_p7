import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../data/services/auth_service.dart';

class SplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  bool _hasNavigated = false;

  @override
  void onInit() {
    super.onInit();
    _startNavigationTimer();
  }

  void _startNavigationTimer() async {
    if (_hasNavigated) return;
    // Splash screen duration increased to 5 seconds
    await Future.delayed(const Duration(seconds: 5));
    if (_hasNavigated) return;
    _hasNavigated = true;

    if (_authService.isLoggedIn.value) {
      Get.offAllNamed(Routes.DASHBOARD);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  void skipSplash() {
    if (_hasNavigated) return;
    _hasNavigated = true;
    if (_authService.isLoggedIn.value) {
      Get.offAllNamed(Routes.DASHBOARD);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
