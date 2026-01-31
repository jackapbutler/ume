import 'package:intl/intl.dart';

abstract class Formatter {
  Formatter._();

  static String formatDateTime(DateTime dateTime) {
    final DateFormat dateFormat = DateFormat('hh:mm a');
    return dateFormat.format(dateTime);
  }
}

String prettyTimeSinceNow(DateTime? dateTime) {
  if (dateTime == null) {
    return 'Unknown';
  } else {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inDays >= 1) {
      return '${difference.inDays}d ago'; // Show in days if more than a day
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago'; // Show in hours if less than a day
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago'; // Show in minutes if less than an hour
    } else {
      return 'Just now'; // Show "Just now" if it's very recent
    }
  }
}
