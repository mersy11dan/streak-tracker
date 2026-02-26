import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/color_picker_sheet.dart';

class CreateHabitScreen extends ConsumerStatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  ConsumerState<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends ConsumerState<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _targetType = 'ongoing';
  int _durationDays = 30;
  String _selectedColor = '#6750A4';
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Habit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Title input
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Habit name',
                hintText: 'e.g. Read 10 pages, Code 1 hour',
                prefixIcon: Icon(Icons.edit_outlined),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
            ),
            const SizedBox(height: 24),

            // Duration section
            Text(
              'Duration',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'ongoing',
                  label: Text('Ongoing'),
                  icon: Icon(Icons.all_inclusive),
                ),
                ButtonSegment(
                  value: 'fixedDuration',
                  label: Text('Fixed'),
                  icon: Icon(Icons.timer_outlined),
                ),
              ],
              selected: {_targetType},
              onSelectionChanged: (s) => setState(() => _targetType = s.first),
            ),
            if (_targetType == 'fixedDuration') ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _durationDays,
                decoration: const InputDecoration(
                  labelText: 'Duration',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 7, child: Text('7 days (1 week)')),
                  DropdownMenuItem(value: 15, child: Text('15 days')),
                  DropdownMenuItem(value: 30, child: Text('30 days (1 month)')),
                  DropdownMenuItem(value: 60, child: Text('60 days (2 months)')),
                  DropdownMenuItem(value: 90, child: Text('90 days (3 months)')),
                  DropdownMenuItem(value: 180, child: Text('180 days (6 months)')),
                  DropdownMenuItem(value: 365, child: Text('365 days (1 year)')),
                ],
                onChanged: (v) => setState(() => _durationDays = v ?? 30),
              ),
            ],
            const SizedBox(height: 24),

            // Color section
            Text(
              'Color',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showColorPicker(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: Border.all(color: cs.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _hexToColor(_selectedColor),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: _hexToColor(_selectedColor).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tap to choose color',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                    ),
                    Icon(Icons.palette_outlined, color: cs.onSurfaceVariant),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: const Text('Create Habit'),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ColorPickerSheet(
        selectedColor: _selectedColor,
        onColorSelected: (c) => setState(() => _selectedColor = c),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final now = DateTime.now();
    DateTime? endDate;
    if (_targetType == 'fixedDuration') {
      endDate = now.add(Duration(days: _durationDays));
    }

    final habitService = ref.read(habitServiceProvider);
    await habitService.createHabit(
      title: _titleController.text.trim(),
      targetType: _targetType,
      startDate: today(),
      endDate: endDate,
      colorHex: _selectedColor,
    );

    if (mounted) {
      ref.read(habitRefreshProvider.notifier).state++;
      context.pop();
    }
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
