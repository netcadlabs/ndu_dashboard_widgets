import 'package:intl/intl.dart';

class DatetimeUtils {
  static String getTime(DateTime dateTime) {
    var formatter = new DateFormat('hh:mm:ss');
    String formattedDate = formatter.format(dateTime);
    return formattedDate;
  }
}
