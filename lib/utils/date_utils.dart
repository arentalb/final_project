
DateTime getDateWithOffset({int offsetDays = 0}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return today.add(Duration(days: offsetDays));
}
