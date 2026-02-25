import 'package:hive_flutter/hive_flutter.dart';

import 'adapters/checkin_adapter.dart';
import 'adapters/habit_adapter.dart';
import 'adapters/user_profile_adapter.dart';
import 'models/checkin_model.dart';
import 'models/habit_model.dart';
import 'models/user_profile_model.dart';

class DatabaseService {
  static const String habitsBox = 'habits';
  static const String checkinsBox = 'checkins';
  static const String profileBox = 'profile';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(HabitAdapter());
    Hive.registerAdapter(CheckInAdapter());
    Hive.registerAdapter(UserProfileAdapter());
    await Hive.openBox<HabitModel>(habitsBox);
    await Hive.openBox<CheckInModel>(checkinsBox);
    await Hive.openBox<UserProfileModel>(profileBox);
  }
}
