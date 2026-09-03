import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class AppDateFormatter {
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (!_initialized) {
      try {
        await initializeDateFormatting('id_ID', null);
        await initializeDateFormatting('id', null);
        _initialized = true;
      } catch (_) {}
    }
  }

  /// Safe Indonesian Date Formatter that handles LocaleDataException gracefully
  static String formatIndonesian(DateTime date, String pattern) {
    try {
      return DateFormat(pattern, 'id_ID').format(date);
    } catch (_) {
      try {
        return DateFormat(pattern).format(date);
      } catch (_) {
        return '${date.day}/${date.month}/${date.year}';
      }
    }
  }
}
