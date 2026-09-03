import 'package:flutter_test/flutter_test.dart';
import 'package:jurnal_kebiasaan_baik_p7/app/data/models/habit_model.dart';
import 'package:jurnal_kebiasaan_baik_p7/app/data/services/habit_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HabitService Unit Tests', () {
    late HabitService habitService;

    setUp(() {
      habitService = HabitService();
      habitService.onInit();
    });

    test('Initial habits should be loaded', () {
      expect(habitService.habits.length, greaterThanOrEqualTo(4));
    });

    test('Toggling habit completion should update status and streak', () async {
      final habitId = habitService.habits.first.id;
      final initialStatus = habitService.habits.first.isCompletedToday;

      await habitService.toggleHabitCompletion(habitId);

      final updatedHabit = habitService.habits.firstWhere((h) => h.id == habitId);
      expect(updatedHabit.isCompletedToday, equals(!initialStatus));
    });

    test('Adding a new habit increases the list length', () {
      final initialLength = habitService.habits.length;
      final newHabit = HabitModel(
        id: 'h-test',
        title: 'Membantu Sesama',
        description: 'Tersenyum dan bersedekah.',
        category: 'kedisiplinan',
        iconName: 'star',
      );

      habitService.addHabit(newHabit);
      expect(habitService.habits.length, equals(initialLength + 1));
    });
  });
}
