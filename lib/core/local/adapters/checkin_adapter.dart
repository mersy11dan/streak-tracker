import 'package:hive/hive.dart';

import '../models/checkin_model.dart';

class CheckInAdapter extends TypeAdapter<CheckInModel> {
  @override
  final int typeId = 1;

  @override
  CheckInModel read(BinaryReader reader) {
    return CheckInModel()
      ..habitId = reader.readString()
      ..dateKey = reader.readString()
      ..date = DateTime.fromMillisecondsSinceEpoch(reader.readInt())
      ..completed = reader.readBool()
      ..note = reader.readBool() ? reader.readString() : null
      ..createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
  }

  @override
  void write(BinaryWriter writer, CheckInModel obj) {
    writer.writeString(obj.habitId);
    writer.writeString(obj.dateKey);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeBool(obj.completed);
    writer.writeBool(obj.note != null);
    if (obj.note != null) writer.writeString(obj.note!);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}
