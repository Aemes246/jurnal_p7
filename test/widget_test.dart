import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jurnal_kebiasaan_baik_p7/app/routes/app_routes.dart';
import 'package:jurnal_kebiasaan_baik_p7/app/routes/app_pages.dart';
import 'package:jurnal_kebiasaan_baik_p7/app/modules/splash/views/splash_view.dart';
import 'package:jurnal_kebiasaan_baik_p7/app/modules/splash/controllers/splash_controller.dart';
import 'package:jurnal_kebiasaan_baik_p7/app/data/services/auth_service.dart';

void main() {
  testWidgets('SplashView renders correctly with SMKN 7 Samarinda titles', (WidgetTester tester) async {
    Get.put(AuthService());
    Get.put(SplashController());

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: Routes.SPLASH,
        getPages: AppPages.routes,
      ),
    );

    expect(find.byType(SplashView), findsOneWidget);
    expect(find.text('JURNAL'), findsOneWidget);
    expect(find.text('SMK NEGERI 7 SAMARINDA'), findsWidgets);

    // Fast forward timer by 6 seconds to complete splash timer
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  });
}
