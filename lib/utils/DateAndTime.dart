import 'package:intl/intl.dart';

class DateAndTime {
  static String toTimeReadable(int unix, bool is12hr) {
    var formatToReadable = is12hr ? DateFormat('h:mm a') : DateFormat('HH:mm');
    var date =
        new DateTime.fromMillisecondsSinceEpoch(unix * 1000, isUtc: true);
    date = date.add(Duration(hours: 8)); //phone already formatted like this
    var formattedTime = formatToReadable.format(date);
    return (formattedTime);
  }

  static bool isTheSameMonth(int savedMillis) {
    var savedMonth = DateTime.fromMillisecondsSinceEpoch(savedMillis).month;

    var currentMonth = DateTime.now().month;
    return savedMonth == currentMonth;
  }
}
