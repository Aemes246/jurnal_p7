import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../../../widgets/habit_icon_badge.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  static const List<Map<String, dynamic>> _sevenHabits = [
    {
      'id': 'h1',
      'no': '1',
      'title': 'Bangun Pagi',
      'color': Color(0xFFF59E0B),
    },
    {
      'id': 'h2',
      'no': '2',
      'title': 'Beribadah',
      'color': Color(0xFF0D9488),
    },
    {
      'id': 'h3',
      'no': '3',
      'title': 'Berolahraga',
      'color': Color(0xFF10B981),
    },
    {
      'id': 'h4',
      'no': '4',
      'title': 'Makan Sehat',
      'color': Color(0xFF84CC16),
    },
    {
      'id': 'h5',
      'no': '5',
      'title': 'Gemar Belajar',
      'color': Color(0xFF8B5CF6),
    },
    {
      'id': 'h6',
      'no': '6',
      'title': 'Bermasyarakat',
      'color': Color(0xFFF97316),
    },
    {
      'id': 'h7',
      'no': '7',
      'title': 'Tidur Cepat',
      'color': Color(0xFF4F46E5),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;
    final isMobile = mediaSize.width < 600;
    final double circleRadius = isMobile ? 130.0 : 155.0;
    final double containerHeight = isMobile ? 380.0 : 430.0;

    return Scaffold(
      body: GestureDetector(
        onTap: controller.skipSplash,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF043927), Color(0xFF064E3B), Color(0xFF0F766E)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // Top Header Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade400,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(FontAwesomeIcons.solidStar, color: Color(0xFF043927), size: 12),
                        SizedBox(width: 6),
                        Text(
                          'GERAKAN 7 KEBIASAAN BAIK',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF043927),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CIRCULAR ORBITAL LAYOUT
                  SizedBox(
                    height: containerHeight,
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background Glowing Orbit Ring
                        Container(
                          width: circleRadius * 2,
                          height: circleRadius * 2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.amber.shade400.withValues(alpha: 0.35),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.shade400.withValues(alpha: 0.15),
                                blurRadius: 25,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),

                        // Inner Decorative Dashed Circle Ring
                        Container(
                          width: circleRadius * 1.4,
                          height: circleRadius * 1.4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1.5,
                            ),
                          ),
                        ),

                        // CENTER TITLE BADGE ("7 KEBIASAAN HEBAT DI TENGAH")
                        Container(
                          width: circleRadius * 1.25,
                          height: circleRadius * 1.25,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF043927).withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.amber.shade400, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'JURNAL',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '7 KEBIASAAN',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.amber.shade400,
                                    letterSpacing: 0.5,
                                    shadows: const [
                                      Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(1, 2)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'ANAK INDONESIA\nHEBAT',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade400,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'SMK NEGERI 7 SAMARINDA',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF043927),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // MELINGKAR 7 BENTUK KEBIASAAN BAIK (7 ORBITAL ICONS)
                        ...List.generate(_sevenHabits.length, (index) {
                          final item = _sevenHabits[index];
                          final double startAngle = -math.pi / 2; // Start from top
                          final double angleStep = (2 * math.pi) / 7;
                          final double angle = startAngle + (index * angleStep);

                          final double x = circleRadius * math.cos(angle);
                          final double y = circleRadius * math.sin(angle);

                          final Color itemColor = item['color'];

                          return Transform.translate(
                            offset: Offset(x, y),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: itemColor.withValues(alpha: 0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      HabitIconBadge(
                                        habitId: item['id'],
                                        size: 40,
                                        showBadge: false,
                                      ),
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: itemColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 1.5),
                                        ),
                                        child: Center(
                                          child: Text(
                                            item['no'],
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item['title'],
                                    style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom Call To Action Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade400,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ketuk Layar Untuk Masuk Aplikasi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF043927),
                          ),
                        ),
                        SizedBox(width: 8),
                        FaIcon(FontAwesomeIcons.arrowRight, color: Color(0xFF043927), size: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
