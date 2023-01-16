import 'package:floor/floor.dart';
import 'package:intl/intl.dart';

class DateTimeConverter extends TypeConverter<DateTime, String> {
  @override
  DateTime decode(String value) {
    DateFormat format = DateFormat("dd.MM.yyyy HH:mm");
    DateTime result = format.parse(value);
    return result;
  }

  @override
  String encode(DateTime value) {
    String day = value.day.toString().length == 1 ? '0${value.day.toString()}' : value.day.toString();
    String month = value.month.toString().length == 1 ? '0${value.month.toString()}' : value.month.toString();
    String date = '$day.$month.${value.year}';

    String hour = value.hour.toString().length == 1 ? '0${value.hour.toString()}' : value.hour.toString();
    String minute = value.minute.toString().length == 1 ? '0${value.minute.toString()}' : value.minute.toString();
    String time = '$hour:$minute';

    return '$date $time';
  }
}