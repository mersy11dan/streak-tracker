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
  String _selectedColor = '#6366F1';
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Habit name',
                hintText: 'e.g. Read 10 pages, Code 1 hour',
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
            ),
            const SizedBox(height: 24),
            Text(
              'Duration',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'ongoing', label: Text('Ongoing')),
                ButtonSegment(value: 'fixedDuration', label: Text('Fixed')),
              ],
              selected: {_targetType},
              onSelectionChanged: (s) => setState(() => _targetType = s.first),
            ),
            if (_targetType == 'fixedDuration') ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _durationDays,
                decoration: const InputDecoration(labelText: 'Duration'),
                items: [
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
            Text(
              'Color',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showColorPicker(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _hexToColor(_selectedColor),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _hexToColor(_selectedColor).withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('Tap to change color'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Habit'),
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
