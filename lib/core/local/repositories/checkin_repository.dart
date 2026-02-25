import 'package:hive_flutter/hive_flutter.dart';

import '../database_service.dart';
import '../models/checkin_model.dart';
import '../../utils/date_utils.dart';

class CheckInRepository {
  Box<CheckInModel> get _box => Hive.box<CheckInModel>(DatabaseService.checkinsBox);

  CheckInModel? getCheckIn(String habitId, String dateKey) {
    try {
      return _box.values.firstWhere(
        (c) => c.habitId == habitId && c.dateKey == dateKey,
      );
    } catch (_) {
      return null;
    }
  }

  List<CheckInModel> getCheckInsForHabit(String habitId) {
    return _box.values.where((c) => c.habitId == habitId).toList();
  }

  Set<String> getCompletedDateKeys(String habitId) {
    return _box.values
        .where((c) => c.habitId == habitId && c.completed)
        .map((c) => c.dateKey)
        .toSet();
  }

  Future<CheckInModel> createOrUpdateCheckIn({
    required String habitId,
    required String dateKey,
    required DateTime date,
    String? note,
  }) async {
    final existing = getCheckIn(habitId, dateKey);
    if (existing != null) {
      existing.note = note;
      existing.completed = true;
      await existing.save();
      return existing;
    }
    final checkIn = CheckInModel.create(
      habitId: habitId,
      dateKey: dateKey,
      date: date,
      note: note,
    );
    await _box.add(checkIn);
    return checkIn;
  }

  Future<void> removeCheckIn(String habitId, String dateKey) async {
    final c = getCheckIn(habitId, dateKey);
    if (c != null) await c.delete();
  }

  bool isDateCompleted(String habitId, DateTime date) {
    final key = toDateKey(date);
    final c = getCheckIn(habitId, key);
    return c != null && c.completed;
  }
}
