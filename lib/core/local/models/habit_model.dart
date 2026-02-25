import 'package:hive/hive.dart';

class HabitModel extends HiveObject {
  late String habitId;
  late String title;
  late String targetType; // 'ongoing' | 'fixedDuration'
  late DateTime startDate;
  DateTime? endDate;
  late String colorHex;
  late bool isArchived;
  DateTime? archivedAt;
  String? archiveReason;
  late int currentStreak;
  late int bestStreak;
  late int freezeTokensRemaining;
  late int freezeTokensUsed;
  late DateTime createdAt;
  late DateTime updatedAt;

  HabitModel();

  factory HabitModel.create({
    required String habitId,
    required String title,
    required String targetType,
    required DateTime startDate,
    DateTime? endDate,
    required String colorHex,
    int freezeTokens = 3,
  }) {
    final now = DateTime.now();
    return HabitModel()
      ..habitId = habitId
      ..title = title
      ..targetType = targetType
      ..startDate = startDate
      ..endDate = endDate
      ..colorHex = colorHex
      ..isArchived = false
      ..currentStreak = 0
      ..bestStreak = 0
      ..freezeTokensRemaining = freezeTokens
      ..freezeTokensUsed = 0
      ..createdAt = now
      ..updatedAt = now;
  }
}
