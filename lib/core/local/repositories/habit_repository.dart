import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../database_service.dart';
import '../models/habit_model.dart';

class HabitRepository {
  Box<HabitModel> get _box => Hive.box<HabitModel>(DatabaseService.habitsBox);

  List<HabitModel> getActiveHabits() {
    return _box.values.where((h) => !h.isArchived).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<HabitModel> getArchivedHabits() {
    return _box.values.where((h) => h.isArchived).toList()
      ..sort((a, b) => (b.archivedAt ?? b.updatedAt).compareTo(a.archivedAt ?? a.updatedAt));
  }

  HabitModel? getHabit(String habitId) {
    try {
      return _box.values.firstWhere((h) => h.habitId == habitId);
    } catch (_) {
      return null;
    }
  }

  Future<HabitModel> createHabit({
    required String title,
    required String targetType,
    required DateTime startDate,
    DateTime? endDate,
    required String colorHex,
    int freezeTokens = 3,
  }) async {
    final habit = HabitModel.create(
      habitId: const Uuid().v4(),
      title: title,
      targetType: targetType,
      startDate: startDate,
      endDate: endDate,
      colorHex: colorHex,
      freezeTokens: freezeTokens,
    );
    await _box.add(habit);
    return habit;
  }

  Future<void> updateHabit(HabitModel habit) async {
    habit.updatedAt = DateTime.now();
    await habit.save();
  }

  Future<void> archiveHabit(HabitModel habit, {String? reason}) async {
    habit.isArchived = true;
    habit.archivedAt = DateTime.now();
    habit.archiveReason = reason;
    habit.updatedAt = DateTime.now();
    await habit.save();
  }

  Future<void> deleteHabit(HabitModel habit) async {
    await habit.delete();
  }
}
