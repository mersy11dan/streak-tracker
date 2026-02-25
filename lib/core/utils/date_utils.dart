/// Format date as yyyyMMdd for storage keys.
String toDateKey(DateTime date) {
  return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
}

/// Parse yyyyMMdd string to DateTime (local date at midnight).
DateTime fromDateKey(String key) {
  final y = int.parse(key.substring(0, 4));
  final m = int.parse(key.substring(4, 6));
  final d = int.parse(key.substring(6, 8));
  return DateTime(y, m, d);
}

/// Get today's date at midnight (no time component).
DateTime today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// Check if two dates are the same calendar day.
bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Get list of dates from [start] to [end] inclusive.
List<DateTime> dateRange(DateTime start, DateTime end) {
  final list = <DateTime>[];
  var d = DateTime(start.year, start.month, start.day);
  final e = DateTime(end.year, end.month, end.day);
  while (!d.isAfter(e)) {
    list.add(d);
    d = d.add(const Duration(days: 1));
  }
  return list;
}
