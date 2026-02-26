import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/local/models/habit_model.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/habit_service.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/github_heatmap_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(habitRefreshProvider);
    final habitService = ref.read(habitServiceProvider);
    final habits = habitService.getActiveHabits();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department, color: cs.primary),
            const SizedBox(width: 8),
            const Text('Streak Tracker'),
          ],
        ),
      ),
      body: habits.isEmpty
          ? _EmptyState(onAdd: () => context.push('/habits/create'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: habits.length,
              itemBuilder: (context, i) {
                final habit = habits[i];
                return _HabitCard(
                  key: ValueKey(habit.habitId),
                  habit: habit,
                  habitService: habitService,
                  onChanged: () => ref.read(habitRefreshProvider.notifier).state++,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/habits/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_fire_department,
                size: 48,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No habits yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first habit to start building streaks',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Create Habit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitCard extends ConsumerStatefulWidget {
  const _HabitCard({
    super.key,
    required this.habit,
    required this.habitService,
    required this.onChanged,
  });

  final HabitModel habit;
  final HabitService habitService;
  final VoidCallback onChanged;

  @override
  ConsumerState<_HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends ConsumerState<_HabitCard> {
  bool _justIncreased = false;

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final color = _hexToColor(habit.colorHex);
    final cs = Theme.of(context).colorScheme;
    final completedKeys = widget.habitService.getCompletedDateKeys(habit.habitId);
    final todayDate = today();
    final isTodayDone = widget.habitService.isDateCompleted(habit.habitId, todayDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.track_changes,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        habit.targetType == 'ongoing' ? 'Ongoing' : 'Fixed duration',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                _StreakFire(
                  streak: habit.currentStreak,
                  isTodayDone: isTodayDone,
                  justIncreased: _justIncreased,
                  onAnimationComplete: () =>
                      setState(() => _justIncreased = false),
                ),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  onSelected: (v) => _onMenuSelected(context, v),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'archive', child: Text('Archive')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: cs.outlineVariant),
            const SizedBox(height: 12),

            // Checkbox row
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: isTodayDone,
                    onChanged: isTodayDone
                        ? (v) => _uncheckToday(context)
                        : (v) => _checkInToday(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Done today',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: isTodayDone ? TextDecoration.lineThrough : null,
                          color: isTodayDone ? cs.onSurfaceVariant : cs.onSurface,
                        ),
                  ),
                ),
                if (habit.freezeTokensRemaining > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.ac_unit, size: 14, color: cs.onTertiaryContainer),
                        const SizedBox(width: 4),
                        Text(
                          '${habit.freezeTokensRemaining}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: cs.onTertiaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Heatmap
            GithubHeatmapGrid(
              completedDateKeys: completedKeys,
              habitColorHex: habit.colorHex,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uncheckToday(BuildContext context) async {
    await widget.habitService.uncheckIn(widget.habit.habitId, today());
    if (mounted) setState(() {});
  }

  Future<void> _checkInToday(BuildContext context) async {
    final prevStreak = widget.habit.currentStreak;
    await widget.habitService.checkIn(widget.habit.habitId, today());
    if (mounted) {
      setState(() {
        if (widget.habit.currentStreak > prevStreak) {
          _justIncreased = true;
        }
      });
    }
  }

  Future<void> _onMenuSelected(BuildContext context, String value) async {
    if (value == 'archive') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Archive habit?'),
          content: const Text(
            'This habit will move to your profile history.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Archive')),
          ],
        ),
      );
      if (ok == true && mounted) {
        await widget.habitService.archiveHabit(widget.habit);
        if (mounted) widget.onChanged();
      }
    } else if (value == 'delete') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete habit?'),
          content: const Text('This will permanently delete the habit and its data.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (ok == true && mounted) {
        await widget.habitService.archiveHabit(widget.habit, reason: 'deleted');
        if (mounted) widget.onChanged();
      }
    }
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

class _StreakFire extends StatefulWidget {
  const _StreakFire({
    required this.streak,
    required this.isTodayDone,
    required this.justIncreased,
    required this.onAnimationComplete,
  });

  final int streak;
  final bool isTodayDone;
  final bool justIncreased;
  final VoidCallback onAnimationComplete;

  @override
  State<_StreakFire> createState() => _StreakFireState();
}

class _StreakFireState extends State<_StreakFire>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.4)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_controller);
  }

  @override
  void didUpdateWidget(covariant _StreakFire oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.justIncreased && !oldWidget.justIncreased && !_controller.isAnimating) {
      _controller.forward().then((_) {
        _controller.reverse();
        widget.onAnimationComplete();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.streak > 0 && widget.isTodayDone;
    final fireColor = isActive ? Colors.orange : Colors.grey;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: fireColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department,
              size: 16,
              color: fireColor,
            ),
            const SizedBox(width: 4),
            Text(
              '${widget.streak}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: fireColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
