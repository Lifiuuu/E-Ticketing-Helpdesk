import 'package:intl/intl.dart';

class DateFormatter {
  static String formatFull(DateTime date) {
    // Mengubah tanggal menjadi format: 19 April 2026, 01:08
    return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(date);
  }

  static String formatShort(DateTime date) {
    // Mengubah tanggal menjadi format: 19/04/26
    return DateFormat('dd/MM/yy').format(date);
  }
}