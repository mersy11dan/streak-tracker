import 'package:hive_flutter/hive_flutter.dart';

import '../database_service.dart';
import '../models/user_profile_model.dart';

class ProfileRepository {
  Box<UserProfileModel> get _box => Hive.box<UserProfileModel>(DatabaseService.profileBox);

  UserProfileModel getOrCreateProfile() {
    if (_box.isEmpty) {
      final profile = UserProfileModel.defaultProfile();
      _box.add(profile);
      return profile;
    }
    return _box.values.first;
  }

  Future<void> updateDisplayName(String name) async {
    final profile = getOrCreateProfile();
    profile.displayName = name;
    await profile.save();
  }
}
