import '../../../core/local/models/habit_model.dart';
import '../../../core/local/repositories/checkin_repository.dart';
import '../../../core/local/repositories/habit_repository.dart';
import '../../../core/utils/date_utils.dart';
import '../domain/streak_engine.dart';

class HabitService {
  HabitService(
    this._habitRepo,
    this._checkInRepo,
    this._streakEngine,
  );

  final HabitRepository _habitRepo;
  final CheckInRepository _checkInRepo;
  final StreakEngine _streakEngine;

  List<HabitModel> getActiveHabits() => _habitRepo.getActiveHabits();
  List<HabitModel> getArchivedHabits() => _habitRepo.getArchivedHabits();
  HabitModel? getHabit(String habitId) => _habitRepo.getHabit(habitId);

  Future<HabitModel> createHabit({
    required String title,
    required String targetType,
    required DateTime startDate,
    DateTime? endDate,
    required String colorHex,
    int freezeTokens = 3,
  }) async {
    return _habitRepo.createHabit(
      title: title,
      targetType: targetType,
      startDate: startDate,
      endDate: endDate,
      colorHex: colorHex,
      freezeTokens: freezeTokens,
    );
  }

  Future<void> checkIn(String habitId, DateTime date, {String? note}) async {
    final habit = _habitRepo.getHabit(habitId);
    if (habit == null || habit.isArchived) return;

    final key = toDateKey(date);
    await _checkInRepo.createOrUpdateCheckIn(
      habitId: habitId,
      dateKey: key,
      date: date,
      note: note,
    );
    await _streakEngine.recomputeStreak(habit);
    await _habitRepo.updateHabit(habit);
  }

  Future<void> uncheckIn(String habitId, DateTime date) async {
    final habit = _habitRepo.getHabit(habitId);
    if (habit == null) return;

    final key = toDateKey(date);
    await _checkInRepo.removeCheckIn(habitId, key);
    await _streakEngine.recomputeStreak(habit);
    await _habitRepo.updateHabit(habit);
  }

  bool isDateCompleted(String habitId, DateTime date) =>
      _checkInRepo.isDateCompleted(habitId, date);

  Set<String> getCompletedDateKeys(String habitId) =>
      _checkInRepo.getCompletedDateKeys(habitId);

  Future<void> archiveHabit(HabitModel habit, {String? reason}) =>
      _habitRepo.archiveHabit(habit, reason: reason);

  Future<void> deleteHabit(HabitModel habit) => _habitRepo.deleteHabit(habit);
}
