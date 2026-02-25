import 'package:hive/hive.dart';

class UserProfileModel extends HiveObject {
  late String displayName;
  String? avatarPath;
  late DateTime createdAt;
  String? defaultTimezone;

  UserProfileModel();

  factory UserProfileModel.defaultProfile() {
    return UserProfileModel()
      ..displayName = 'Streak Tracker'
      ..createdAt = DateTime.now();
  }
}
