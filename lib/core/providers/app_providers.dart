import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/repositories/checkin_repository.dart';
import '../local/repositories/habit_repository.dart';
import '../local/repositories/profile_repository.dart';
import '../../features/habits/data/habit_service.dart';
import '../../features/habits/domain/streak_engine.dart';

final habitRefreshProvider = StateProvider<int>((ref) => 0);

final habitRepositoryProvider = Provider<HabitRepository>((ref) => HabitRepository());
final checkInRepositoryProvider = Provider<CheckInRepository>((ref) => CheckInRepository());
final profileRepositoryProvider = Provider<ProfileRepository>((ref) => ProfileRepository());

final streakEngineProvider = Provider<StreakEngine>((ref) {
  return StreakEngine(ref.watch(checkInRepositoryProvider));
});

final habitServiceProvider = Provider<HabitService>((ref) {
  return HabitService(
    ref.watch(habitRepositoryProvider),
    ref.watch(checkInRepositoryProvider),
    ref.watch(streakEngineProvider),
  );
});
