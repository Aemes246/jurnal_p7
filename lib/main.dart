import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'app/data/providers/supabase_provider.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/services/habit_service.dart';
import 'app/data/services/master_data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Indonesian Locale Date Formatting
  await initializeDateFormatting('id_ID', null);

  // Initialize Supabase Client
  await SupabaseProvider.init();

  // Initialize Core Services
  Get.put(MasterDataService(), permanent: true);
  Get.put(AuthService(), permanent: true);
  Get.put(HabitService(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Jurnal Kebiasaan Baik (P7)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Jika diakses di layar desktop/laptop (lebar > 480px)
            if (constraints.maxWidth > 480) {
              return Container(
                color: const Color(0xFF0F172A), // Dark Slate background untuk area desktop
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 25,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ),
              );
            }
            // Jika diakses dari HP atau Chrome Mobile Emulator (lebar <= 480px)
            return child!;
          },
        );
      },
    );
  }
}
