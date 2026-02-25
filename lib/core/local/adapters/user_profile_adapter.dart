import 'package:hive/hive.dart';

import '../models/user_profile_model.dart';

class UserProfileAdapter extends TypeAdapter<UserProfileModel> {
  @override
  final int typeId = 2;

  @override
  UserProfileModel read(BinaryReader reader) {
    return UserProfileModel()
      ..displayName = reader.readString()
      ..avatarPath = reader.readBool() ? reader.readString() : null
      ..createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt())
      ..defaultTimezone = reader.readBool() ? reader.readString() : null;
  }

  @override
  void write(BinaryWriter writer, UserProfileModel obj) {
    writer.writeString(obj.displayName);
    writer.writeBool(obj.avatarPath != null);
    if (obj.avatarPath != null) writer.writeString(obj.avatarPath!);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeBool(obj.defaultTimezone != null);
    if (obj.defaultTimezone != null) writer.writeString(obj.defaultTimezone!);
  }
}
