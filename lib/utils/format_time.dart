
import 'package:intl/intl.dart';

String start2EndDateTime(DateTime startTime, DateTime? endTime) {
  startTime = DateTime(
    startTime.year + 543,
    startTime.month,
    startTime.day,
    startTime.hour,
    startTime.minute,
  ).toLocal();
  if (endTime != null) {
    endTime = DateTime(
      endTime.year + 543,
      endTime.month,
      endTime.day,
      endTime.hour,
      endTime.minute,
    ).toLocal();
    final dayDuation = endTime.difference(startTime).inDays;
    if (dayDuation < 1) return "${formatDate(startTime)}, ${formatTime(startTime)} - ${formatTime(endTime)}";
    return "${formatDate(startTime)} - ${formatDate(endTime)}, ${formatTime(startTime)} - ${formatTime(endTime)}";
  }
  return DateFormat("dd/MM/yyyy ตั้งแต่ HH:mm น.", 'th').format(startTime);
}

String formatDateTime(DateTime dateTime) {
  dateTime = dateTime.toLocal();
  return DateFormat("dd/MM/yyyy HH:mm น.", 'th').format(dateTime);
}

String formatDate(DateTime dateTime) {
  dateTime = dateTime.toLocal();
  return DateFormat("dd/MM/yyyy", 'th').format(dateTime);
}

String formatTime(DateTime dateTime) {
  dateTime = dateTime.toLocal();
  return DateFormat("HH:mm น.", 'th').format(dateTime);
}
