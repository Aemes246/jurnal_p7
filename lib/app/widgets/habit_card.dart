import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../data/models/habit_model.dart';
import '../data/services/auth_service.dart';
import '../data/services/habit_service.dart';
import '../theme/app_colors.dart';
import 'habit_icon_badge.dart';

class HabitCard extends StatelessWidget {
  final HabitModel habit;
  final VoidCallback onToggle;
  final VoidCallback? onTap;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
    this.onTap,
  });

  Color _getCategoryColor(String category, String id) {
    switch (id) {
      case 'h1':
        return const Color(0xFFF59E0B); // Bangun Pagi - Amber
      case 'h2':
        return const Color(0xFF0D9488); // Beribadah - Teal
      case 'h3':
        return const Color(0xFF10B981); // Berolahraga - Emerald
      case 'h4':
        return const Color(0xFF84CC16); // Makan Sehat - Lime
      case 'h5':
        return const Color(0xFF8B5CF6); // Gemar Belajar - Purple
      case 'h6':
        return const Color(0xFFF97316); // Bermasyarakat - Coral
      case 'h7':
        return const Color(0xFF4F46E5); // Tidur Cepat - Indigo
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catColor = _getCategoryColor(habit.category, habit.id);

    final authService = Get.isRegistered<AuthService>() ? Get.find<AuthService>() : null;
    final habitService = Get.isRegistered<HabitService>() ? Get.find<HabitService>() : null;

    final religion = authService?.currentUser.value?.religion ?? 'Islam';
    final selectedDate = habitService?.selectedDate.value ?? DateTime.now();
    final isDone = habitService?.isHabitCompletedForDate(habit.id, selectedDate) ?? habit.isCompletedToday;

    final prayerProgress = habit.id == 'h2' && habitService != null
        ? habitService.getPrayerProgress(religion, targetDate: selectedDate)
        : null;

    final isFuture = habitService?.isFutureDate(selectedDate) ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isFuture
            ? const Color(0xFFF1F5F9)
            : (isDone ? catColor.withValues(alpha: 0.08) : theme.cardTheme.color),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFuture
              ? const Color(0xFFCBD5E1)
              : (isDone ? catColor.withValues(alpha: 0.5) : const Color(0xFFE2E8F0)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: catColor.withValues(alpha: isDone ? 0.12 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // Modern Dynamic Habit Icon Badge
                HabitIconBadge(
                  habitId: habit.id,
                  iconName: habit.iconName,
                  religion: religion,
                  size: 52,
                  isCompleted: isDone,
                ),
                const SizedBox(width: 16),

                // Habit Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isFuture
                                  ? const Color(0xFF64748B).withValues(alpha: 0.15)
                                  : catColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'POIN: +${habit.points}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isFuture ? AppColors.textMuted : catColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FaIcon(
                            FontAwesomeIcons.fireFlameCurved,
                            size: 13,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${habit.currentStreak} Hari',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        habit.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isFuture
                              ? AppColors.textSecondary
                              : (isDone ? AppColors.textPrimary : theme.textTheme.bodyLarge?.color),
                        ),
                      ),
                      const SizedBox(height: 3),
                      
                      // Custom Subtitle for Future date vs '2. Beribadah' vs other habits
                      if (isFuture) ...[
                        const Text(
                          '🔒 Belum dapat diisi (Tanggal Masa Mendatang)',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ] else if (habit.id == 'h2' && prayerProgress != null) ...[
                        Text(
                          isDone
                              ? '✔ Selesai 5 Waktu (5/5 Lengkap)'
                              : (prayerProgress.completedCount > 0
                                  ? '⚡ Progress: ${prayerProgress.displayProgress} (${prayerProgress.completedPrayers.map((p) => p.replaceFirst('Sholat ', '')).join(', ')})'
                                  : 'Ibadah 5 Waktu (Subuh, Dzuhur, Ashar, Maghrib, Isya)'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isDone ? FontWeight.bold : FontWeight.w600,
                            color: isDone
                                ? Colors.teal.shade700
                                : (prayerProgress.completedCount > 0 ? Colors.blue.shade700 : AppColors.textSecondary),
                          ),
                        ),
                      ] else ...[
                        Text(
                          isDone
                              ? '✔ Terisi & Diverifikasi Bukti Foto'
                              : habit.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
                            color: isDone ? catColor : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Action Indicator Badge
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: isFuture
                          ? const Color(0xFFE2E8F0)
                          : (isDone ? catColor : catColor.withValues(alpha: 0.12)),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isDone && !isFuture
                          ? [
                              BoxShadow(
                                color: catColor.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(
                          isFuture
                              ? FontAwesomeIcons.lock
                              : (isDone ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.penToSquare),
                          size: 13,
                          color: isFuture ? AppColors.textSecondary : (isDone ? Colors.white : catColor),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isFuture
                              ? 'Terkunci'
                              : (isDone
                                  ? 'Selesai'
                                  : (habit.id == 'h2' && prayerProgress != null && prayerProgress.completedCount > 0
                                      ? 'Isi (${prayerProgress.completedCount}/${prayerProgress.targetCount})'
                                      : 'Isi Bukti')),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isFuture ? AppColors.textSecondary : (isDone ? Colors.white : catColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
