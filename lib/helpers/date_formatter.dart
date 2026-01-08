import 'package:intl/intl.dart' as intl;

class DateFormatter {
  static String daySeparator(DateTime dt) {
    final dateLocal = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      dateLocal.year,
      dateLocal.month,
      dateLocal.day,
    );
    final int diff = today.difference(messageDate).inDays;
    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'أمس';

    if (dateLocal.year == now.year) {
      return intl.DateFormat('d MMM').format(dateLocal);
    }
    return intl.DateFormat('d MMM y').format(dateLocal);
  }

  static String daySeparatorMain(DateTime dt) {
    final dateLocal = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      dateLocal.year,
      dateLocal.month,
      dateLocal.day,
    );
    final int diff = today.difference(messageDate).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';

    if (dateLocal.year == now.year) {
      return intl.DateFormat('d MMM').format(dateLocal);
    }
    return intl.DateFormat('d MMM y').format(dateLocal);
  }

  static String formatTime(DateTime dt) {
    return intl.DateFormat.jm().format(dt);
  }

  static String formatFullDate(DateTime dt) {
    return intl.DateFormat.yMMMd().add_jm().format(dt);
  }
}
