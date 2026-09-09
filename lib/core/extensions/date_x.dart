import 'package:intl/intl.dart';

/// Date helpers.
///
/// `serviceDate` is the canonical school-day key used across trips, attendance
/// and absences. It must always be produced by [toServiceDate] so that every
/// collection agrees on what "today" means.
extension DateTimeX on DateTime {
  String toServiceDate() => DateFormat('yyyy-MM-dd').format(this);

  String toClockTime(String localeCode) =>
      DateFormat.jm(localeCode).format(this);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  DateTime get startOfDay => DateTime(year, month, day);
}
