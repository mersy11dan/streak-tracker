import 'package:contribution_heatmap/contribution_heatmap.dart';
import 'package:flutter/material.dart';

import '../../core/utils/date_utils.dart';

/// Maps habit color hex to the closest HeatmapColor preset.
HeatmapColor _hexToHeatmapColor(String hex) {
  hex = hex.toUpperCase().replaceAll('#', '');
  if (hex.isEmpty) return HeatmapColor.green;
  final r = int.parse(hex.length >= 2 ? hex.substring(0, 2) : '0', radix: 16);
  final g = int.parse(hex.length >= 4 ? hex.substring(2, 4) : '0', radix: 16);
  final b = int.parse(hex.length >= 6 ? hex.substring(4, 6) : '0', radix: 16);

  // Map to closest preset
  final presets = [
    (HeatmapColor.blue, 0x3B82F6),
    (HeatmapColor.green, 0x22C55E),
    (HeatmapColor.purple, 0x8B5CF6),
    (HeatmapColor.red, 0xEF4444),
    (HeatmapColor.orange, 0xF97316),
    (HeatmapColor.teal, 0x14B8A6),
    (HeatmapColor.pink, 0xEC4899),
    (HeatmapColor.indigo, 0x6366F1),
    (HeatmapColor.amber, 0xF59E0B),
    (HeatmapColor.cyan, 0x06B6D4),
  ];

  var best = HeatmapColor.green;
  var minDist = 999999.0;

  for (final (color, presetRgb) in presets) {
    final pr = (presetRgb >> 16) & 0xFF;
    final pg = (presetRgb >> 8) & 0xFF;
    final pb = presetRgb & 0xFF;
    final dist = (r - pr) * (r - pr) + (g - pg) * (g - pg) + (b - pb) * (b - pb);
    if (dist < minDist) {
      minDist = dist.toDouble();
      best = color;
    }
  }
  return best;
}

/// GitHub-style contribution heatmap using contribution_heatmap package.
class GithubHeatmapGrid extends StatelessWidget {
  const GithubHeatmapGrid({
    super.key,
    required this.completedDateKeys,
    required this.habitColorHex,
    this.cellSize = 12,
    this.spacing = 3,
  });

  final Set<String> completedDateKeys;
  final String habitColorHex;
  final double cellSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);
    final days = dateRange(startOfYear, endOfYear);

    final entries = days
        .where((d) => completedDateKeys.contains(toDateKey(d)))
        .map((d) => ContributionEntry(d, 1))
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ContributionHeatmap(
        entries: entries,
        minDate: startOfYear,
        maxDate: endOfYear,
        cellSize: cellSize,
        cellSpacing: spacing,
        weekdayLabel: WeekdayLabel.full,
        heatmapColor: _hexToHeatmapColor(habitColorHex),
      ),
    );
  }
}
