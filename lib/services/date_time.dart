import 'package:intl/intl.dart';

enum GREETINGS { GOOD_MORNING, GOOD_AFTERNOON, GOOD_EVENING, GOOD_NIGHT }

class DateTimeService {
  String getFormattedDate() {
    return DateFormat('EEEE dd').format(DateTime.now());
  }

  String getFormattedTime() {
    return DateFormat('hh:mm a').format(DateTime.now());
  }

  String getFormattedTimeforAPI(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  String getGreetings() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return GREETINGS.GOOD_MORNING
          .toString()
          .split(".")[1]
          .split("_")
          .join(" ")
          .toLowerCase();
    } else if (hour < 17) {
      return GREETINGS.GOOD_AFTERNOON
          .toString()
          .split(".")[1]
          .split("_")
          .join(" ")
          .toLowerCase();
    } else if (hour < 20) {
      return GREETINGS.GOOD_EVENING
          .toString()
          .split(".")[1]
          .split("_")
          .join(" ")
          .toLowerCase();
    } else {
      return GREETINGS.GOOD_NIGHT
          .toString()
          .split(".")[1]
          .split("_")
          .join(" ")
          .toLowerCase();
    }
  }
}
