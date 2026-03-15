import 'package:intl/intl.dart';

class DateUtils {
  static String formatDate(DateTime date) =>
      DateFormat('EEE, MMM d').format(date);

  static String formatTime(DateTime date) =>
      DateFormat('h:mm a').format(date);

  static String formatMonthYear(DateTime date) =>
      DateFormat('MMMM yyyy').format(date);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  static List<DateTime> currentWeek() {
    final now = DateTime.now();
    return List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
  }

  /// Returns "Morning", "Afternoon", "Evening", or "Bedtime"
  static String timeOfDay(DateTime dt) {
    final h = dt.hour;
    if (h >= 5 && h < 12) return 'Morning';
    if (h >= 12 && h < 17) return 'Afternoon';
    if (h >= 17 && h < 21) return 'Evening';
    return 'Bedtime';
  }
}
