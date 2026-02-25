import '../../../core/local/models/habit_model.dart';
import '../../../core/local/repositories/checkin_repository.dart';
import '../../../core/utils/date_utils.dart';

class StreakEngine {
  StreakEngine(this._checkInRepo);

  final CheckInRepository _checkInRepo;

  /// Recompute and update streak for a habit.
  Future<void> recomputeStreak(HabitModel habit) async {
    final completed = _checkInRepo.getCompletedDateKeys(habit.habitId);
    final start = DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day);

    var current = 0;
    var best = habit.bestStreak;
    var tokensRemaining = habit.freezeTokensRemaining;

    final todayDate = today();
    var d = todayDate;

    while (true) {
      if (d.isBefore(start)) break;

      if (habit.targetType == 'fixedDuration' && habit.endDate != null) {
        final end = DateTime(habit.endDate!.year, habit.endDate!.month, habit.endDate!.day);
        if (d.isAfter(end)) {
          d = d.subtract(const Duration(days: 1));
          continue;
        }
      }

      final key = toDateKey(d);
      final isCompleted = completed.contains(key);

      if (isCompleted) {
        current++;
        d = d.subtract(const Duration(days: 1));
        continue;
      }

      if (tokensRemaining > 0) {
        tokensRemaining--;
        current++;
        d = d.subtract(const Duration(days: 1));
        continue;
      }

      break;
    }

    habit.currentStreak = current;
    habit.bestStreak = current > best ? current : best;
    habit.freezeTokensRemaining = tokensRemaining;
  }
}
