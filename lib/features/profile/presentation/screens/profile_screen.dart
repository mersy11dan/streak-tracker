import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/local/models/habit_model.dart';
import '../../../../core/providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(habitRefreshProvider);
    final habitService = ref.read(habitServiceProvider);
    final profile = ref.watch(profileRepositoryProvider).getOrCreateProfile();
    final activeHabits = habitService.getActiveHabits();
    final archivedHabits = habitService.getArchivedHabits();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      profile.displayName.isNotEmpty
                          ? profile.displayName[0].toUpperCase()
                          : 'S',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.displayName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '${activeHabits.length} active habits',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Active habits',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (activeHabits.isEmpty)
            const SizedBox(
              height: 60,
              child: Center(child: Text('No active habits')),
            )
          else
            ...activeHabits.map((h) => _HabitSummaryTile(habit: h)),
          const SizedBox(height: 24),
          Text(
            'Archived habits',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (archivedHabits.isEmpty)
            const SizedBox(
              height: 60,
              child: Center(child: Text('No archived habits yet')),
            )
          else
            ...archivedHabits.map((h) => _ArchivedHabitTile(habit: h)),
        ],
      ),
    );
  }
}

class _HabitSummaryTile extends StatelessWidget {
  const _HabitSummaryTile({required this.habit});

  final HabitModel habit;

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(habit.colorHex);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 8,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(habit.title),
        subtitle: Text('${habit.currentStreak} day streak'),
        trailing: Icon(habit.freezeTokensRemaining > 0 ? Icons.ac_unit : null),
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

class _ArchivedHabitTile extends StatelessWidget {
  const _ArchivedHabitTile({required this.habit});

  final HabitModel habit;

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(habit.colorHex);
    final start = DateFormat('MMM d').format(habit.startDate);
    final end = habit.archivedAt != null
        ? DateFormat('MMM d').format(habit.archivedAt!)
        : 'ongoing';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 8,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(habit.title),
        subtitle: Text('$start – $end · Best: ${habit.bestStreak} days'),
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
