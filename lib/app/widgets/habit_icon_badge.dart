import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HabitIconConfig {
  final LinearGradient gradient;
  final dynamic mainIcon;
  final dynamic badgeIcon;
  final Color badgeColor;
  final Color shadowColor;

  const HabitIconConfig({
    required this.gradient,
    required this.mainIcon,
    required this.badgeIcon,
    required this.badgeColor,
    required this.shadowColor,
  });
}

class HabitIconBadge extends StatelessWidget {
  final String habitId;
  final String? iconName;
  final String religion;
  final double size;
  final bool showBadge;
  final bool isCompleted;

  const HabitIconBadge({
    super.key,
    required this.habitId,
    this.iconName,
    this.religion = 'Islam',
    this.size = 48.0,
    this.showBadge = true,
    this.isCompleted = false,
  });

  static HabitIconConfig getConfig(String habitId, String religion, String? iconName) {
    switch (habitId.toLowerCase()) {
      case 'h1': // Bangun Pagi
        return const HabitIconConfig(
          gradient: LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          mainIcon: FontAwesomeIcons.sun,
          badgeIcon: FontAwesomeIcons.cloudSun,
          badgeColor: Color(0xFFFEF08A),
          shadowColor: Color(0xFFF59E0B),
        );
      case 'h2': // Beribadah
        dynamic ibadahIcon = FontAwesomeIcons.mosque;
        if (religion.toLowerCase().contains('kristen') || religion.toLowerCase().contains('katolik')) {
          ibadahIcon = FontAwesomeIcons.bookBible;
        } else if (religion.toLowerCase().contains('hindu')) {
          ibadahIcon = FontAwesomeIcons.gopuram;
        } else if (religion.toLowerCase().contains('buddha') || religion.toLowerCase().contains('konghucu')) {
          ibadahIcon = FontAwesomeIcons.placeOfWorship;
        }
        return HabitIconConfig(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D9488), Color(0xFF10B981)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          mainIcon: ibadahIcon,
          badgeIcon: FontAwesomeIcons.handsPraying,
          badgeColor: const Color(0xFFA7F3D0),
          shadowColor: const Color(0xFF0D9488),
        );
      case 'h3': // Berolahraga
        return const HabitIconConfig(
          gradient: LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          mainIcon: FontAwesomeIcons.personRunning,
          badgeIcon: FontAwesomeIcons.bolt,
          badgeColor: Color(0xFFBAE6FD),
          shadowColor: Color(0xFF10B981),
        );
      case 'h4': // Makan Sehat
        return const HabitIconConfig(
          gradient: LinearGradient(
            colors: [Color(0xFF84CC16), Color(0xFF10B981)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          mainIcon: FontAwesomeIcons.utensils,
          badgeIcon: FontAwesomeIcons.leaf,
          badgeColor: Color(0xFFDCFCE7),
          shadowColor: Color(0xFF84CC16),
        );
      case 'h5': // Gemar Belajar
        return const HabitIconConfig(
          gradient: LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          mainIcon: FontAwesomeIcons.bookOpenReader,
          badgeIcon: FontAwesomeIcons.lightbulb,
          badgeColor: Color(0xFFDDD6FE),
          shadowColor: Color(0xFF8B5CF6),
        );
      case 'h6': // Bermasyarakat
        return const HabitIconConfig(
          gradient: LinearGradient(
            colors: [Color(0xFFF97316), Color(0xFFEC4899)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          mainIcon: FontAwesomeIcons.users,
          badgeIcon: FontAwesomeIcons.heart,
          badgeColor: Color(0xFFFBCFE8),
          shadowColor: Color(0xFFF97316),
        );
      case 'h7': // Tidur Cepat
        return const HabitIconConfig(
          gradient: LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF1E1B4B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          mainIcon: FontAwesomeIcons.moon,
          badgeIcon: FontAwesomeIcons.solidStar,
          badgeColor: Color(0xFFC7D2FE),
          shadowColor: Color(0xFF4F46E5),
        );
      default:
        return const HabitIconConfig(
          gradient: LinearGradient(
            colors: [Color(0xFF0D9488), Color(0xFF10B981)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          mainIcon: FontAwesomeIcons.star,
          badgeIcon: FontAwesomeIcons.award,
          badgeColor: Color(0xFFFEF08A),
          shadowColor: Color(0xFF0D9488),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = getConfig(habitId, religion, iconName);
    final iconSize = size * 0.44;
    final badgeSize = size * 0.36;
    final badgeIconSize = size * 0.18;
    final borderRadius = size * 0.32;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Outer Glowing Aura & Main Gradient Container
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: config.gradient,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: config.shadowColor.withValues(alpha: isCompleted ? 0.45 : 0.25),
                blurRadius: isCompleted ? size * 0.3 : size * 0.2,
                spreadRadius: isCompleted ? 1 : 0,
                offset: Offset(0, size * 0.08),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Center(
              child: FaIcon(
                config.mainIcon as dynamic,
                color: Colors.white,
                size: iconSize,
              ),
            ),
          ),
        ),

        // Optional Floating Accent Sub-badge
        if (showBadge)
          Positioned(
            right: -size * 0.08,
            bottom: -size * 0.08,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: badgeSize * 0.82,
                  height: badgeSize * 0.82,
                  decoration: BoxDecoration(
                    color: config.shadowColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: FaIcon(
                      (isCompleted ? FontAwesomeIcons.check : config.badgeIcon) as dynamic,
                      color: isCompleted ? Colors.green.shade700 : config.shadowColor,
                      size: badgeIconSize,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
