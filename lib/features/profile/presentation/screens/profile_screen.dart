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
    final cs = Theme.of(context).colorScheme;

    final totalBestStreak = [...activeHabits, ...archivedHabits]
        .fold<int>(0, (max, h) => h.bestStreak > max ? h.bestStreak : max);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Profile header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: cs.primaryContainer,
                    child: Text(
                      profile.displayName.isNotEmpty
                          ? profile.displayName[0].toUpperCase()
                          : 'S',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: cs.onPrimaryContainer,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.displayName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Member since ${DateFormat('MMM yyyy').format(profile.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Active',
                  value: '${activeHabits.length}',
                  icon: Icons.track_changes,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Archived',
                  value: '${archivedHabits.length}',
                  icon: Icons.inventory_2_outlined,
                  color: cs.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Best Streak',
                  value: '$totalBestStreak',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Active habits
          Text(
            'Active habits',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          if (activeHabits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No active habits', style: TextStyle(color: cs.onSurfaceVariant)),
              ),
            )
          else
            ...activeHabits.map((h) => _HabitSummaryTile(habit: h)),
          const SizedBox(height: 24),

          // Archived habits
          Text(
            'Archived habits',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          if (archivedHabits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No archived habits yet', style: TextStyle(color: cs.onSurfaceVariant)),
              ),
            )
          else
            ...archivedHabits.map((h) => _ArchivedHabitTile(habit: h)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
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
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.track_changes, color: color, size: 20),
        ),
        title: Text(habit.title),
        subtitle: Row(
          children: [
            const Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
            const SizedBox(width: 4),
            Text('${habit.currentStreak} day streak'),
          ],
        ),
        trailing: habit.freezeTokensRemaining > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.tertiaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${habit.freezeTokensRemaining}',
                  style: TextStyle(fontSize: 11, color: cs.onTertiaryContainer),
                ),
              )
            : null,
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.inventory_2_outlined, color: color.withValues(alpha: 0.5), size: 20),
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
