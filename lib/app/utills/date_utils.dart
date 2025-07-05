import 'package:intl/intl.dart';

class DateTimeUtils {
  static String getFormattedBirthDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat('dd MMM yyyy');
    return formatter.format(dateTime);
  }

  static String getTimeStamp(DateTime dateTime) {
    final DateFormat formatter = DateFormat('HH:mm a');
    return formatter.format(dateTime);
  }

  static String formatTime(int time, {String format = 'HH:mm:ss'}) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(time, isUtc: true);
    return DateFormat(format).format(dateTime);
  }
}
