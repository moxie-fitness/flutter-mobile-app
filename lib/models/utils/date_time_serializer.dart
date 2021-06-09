import 'package:intl/intl.dart';
import 'package:jaguar_serializer/jaguar_serializer.dart';

class DateTimeSerializer implements FieldProcessor<DateTime, String> {
  final String pattern;

  final String locale;

  const DateTimeSerializer({this.pattern, this.locale});

  /// Called to process field before decoding
  DateTime deserialize(String value) {
    if (value == null) return null;
    var dte = new DateFormat('yyyy-MM-ddTHH:mm:ss').parseUTC(value);
    var local = dte.toLocal();
    return local;
  }

  /// Called to process field before encoding
  String serialize(DateTime value) {
    if (value == null) return null;
    return new DateFormat('yyyy-MM-dd HH:mm:ss', locale).format(value);
  }
}
