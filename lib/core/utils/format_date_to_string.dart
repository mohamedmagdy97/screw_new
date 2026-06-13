import 'package:intl/intl.dart';

extension DateTimeFormatExtension on DateTime {
  String toSmartFormat() {
    final now = DateTime.now();
    final difference = now.difference(this);

    // لو التاريخ النهاردة
    if (difference.inDays == 0) {
      return DateFormat('hh:mm a').format(this); // "10:45 AM"
    }

    // لو امبارح
    if (difference.inDays == 1) {
      return 'Yesterday';//, ${DateFormat('hh:mm a').format(this)}";
    }

    // لو خلال آخر أسبوع
    if (difference.inDays < 7) {
      return DateFormat('EEEE').format(this); // "Monday, 3:20 PM"
      // return DateFormat('EEEE, hh:mm a').format(this); // "Monday, 3:20 PM"
    }

    // لو أقدم من كده
    return DateFormat('MMM d, yyyy').format(this); // "Sep 28, 2025 – 10:00 AM"
    // return DateFormat('MMM d, yyyy – hh:mm a').format(this); // "Sep 28, 2025 – 10:00 AM"
  }
}
