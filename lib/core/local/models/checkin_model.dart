import 'package:hive/hive.dart';

class CheckInModel extends HiveObject {
  late String habitId;
  late String dateKey; // yyyyMMdd
  late DateTime date;
  late bool completed;
  String? note;
  late DateTime createdAt;

  CheckInModel();

  factory CheckInModel.create({
    required String habitId,
    required String dateKey,
    required DateTime date,
    String? note,
  }) {
    return CheckInModel()
      ..habitId = habitId
      ..dateKey = dateKey
      ..date = date
      ..completed = true
      ..note = note
      ..createdAt = DateTime.now();
  }
}
