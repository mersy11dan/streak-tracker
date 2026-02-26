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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Streak Tracker'),
      ),
      body: habits.isEmpty
          ? _EmptyState(onAdd: () => context.push('/habits/create'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/habits/create'),
        icon: const Icon(Icons.add),
        label: const Text('Add Habit'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
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
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Habit'),
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
  int? _prevStreak;
  bool _justIncreased = false;

  @override
  void didUpdateWidget(covariant _HabitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.habit.currentStreak > (oldWidget.habit.currentStreak)) {
      _prevStreak = oldWidget.habit.currentStreak;
      _justIncreased = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final color = _hexToColor(habit.colorHex);
    final completedKeys = widget.habitService.getCompletedDateKeys(habit.habitId);
    final todayDate = today();
    final isTodayDone = widget.habitService.isDateCompleted(habit.habitId, todayDate);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _StreakFire(
                            streak: habit.currentStreak,
                            isTodayDone: isTodayDone,
                            justIncreased: _justIncreased,
                            onAnimationComplete: () =>
                                setState(() => _justIncreased = false),
                          ),
                          if (habit.freezeTokensRemaining > 0) ...[
                            const SizedBox(width: 8),
                            _StreakChip(
                              label: '${habit.freezeTokensRemaining} freeze',
                              color: Colors.amber,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) => _onMenuSelected(context, v),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'archive', child: Text('Archive habit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete habit')),
                  ],
                  child: const Icon(Icons.more_vert),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: isTodayDone,
              onChanged: isTodayDone
                  ? (v) => _uncheckToday(context)
                  : (v) => _checkInToday(context),
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                'Done today',
                style: TextStyle(
                  decoration: isTodayDone ? TextDecoration.lineThrough : null,
                  color: isTodayDone
                      ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                      : null,
                ),
              ),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            const SizedBox(height: 16),
            GithubHeatmapGrid(
              completedDateKeys: completedKeys,
              habitColorHex: habit.colorHex,
              onDayTap: (d) => _onDayTap(context, d),
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
    await widget.habitService.checkIn(widget.habit.habitId, today());
    if (mounted) setState(() {});
  }

  Future<void> _onMenuSelected(BuildContext context, String value) async {
    if (value == 'archive') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Archive habit?'),
          content: const Text(
            'This habit will move to your profile history. You can still see your streak.',
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
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
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

  Future<void> _onDayTap(BuildContext context, DateTime date) async {
    final isDone = widget.habitService.isDateCompleted(widget.habit.habitId, date);
    if (isDone) {
      await widget.habitService.uncheckIn(widget.habit.habitId, date);
    } else {
      await widget.habitService.checkIn(widget.habit.habitId, date);
    }
    if (mounted) setState(() {});
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
    if (widget.justIncreased && !_controller.isAnimating) {
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
          color: fireColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department,
              size: 18,
              color: fireColor,
            ),
            const SizedBox(width: 4),
            Text(
              '${widget.streak} day streak',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: fireColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
