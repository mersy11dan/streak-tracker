import 'package:hive/hive.dart';

import '../models/habit_model.dart';

class HabitAdapter extends TypeAdapter<HabitModel> {
  @override
  final int typeId = 0;

  @override
  HabitModel read(BinaryReader reader) {
    final model = HabitModel()
      ..habitId = reader.readString()
      ..title = reader.readString()
      ..targetType = reader.readString()
      ..startDate = DateTime.fromMillisecondsSinceEpoch(reader.readInt())
      ..endDate = reader.readBool() ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null
      ..colorHex = reader.readString()
      ..isArchived = reader.readBool()
      ..archivedAt = reader.readBool() ? DateTime.fromMillisecondsSinceEpoch(reader.readInt()) : null
      ..archiveReason = reader.readBool() ? reader.readString() : null
      ..currentStreak = reader.readInt()
      ..bestStreak = reader.readInt()
      ..freezeTokensRemaining = reader.readInt()
      ..freezeTokensUsed = reader.readInt()
      ..createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt())
      ..updatedAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    return model;
  }

  @override
  void write(BinaryWriter writer, HabitModel obj) {
    writer.writeString(obj.habitId);
    writer.writeString(obj.title);
    writer.writeString(obj.targetType);
    writer.writeInt(obj.startDate.millisecondsSinceEpoch);
    writer.writeBool(obj.endDate != null);
    if (obj.endDate != null) writer.writeInt(obj.endDate!.millisecondsSinceEpoch);
    writer.writeString(obj.colorHex);
    writer.writeBool(obj.isArchived);
    writer.writeBool(obj.archivedAt != null);
    if (obj.archivedAt != null) writer.writeInt(obj.archivedAt!.millisecondsSinceEpoch);
    writer.writeBool(obj.archiveReason != null);
    if (obj.archiveReason != null) writer.writeString(obj.archiveReason!);
    writer.writeInt(obj.currentStreak);
    writer.writeInt(obj.bestStreak);
    writer.writeInt(obj.freezeTokensRemaining);
    writer.writeInt(obj.freezeTokensUsed);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeInt(obj.updatedAt.millisecondsSinceEpoch);
  }
}
