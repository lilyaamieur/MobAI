import 'dart:developer';

// track the flow of authentication activities (logins, sign-ups, errors, etc.) (for deubuggin , security ...)
class Logger {
  static void logInfo(String message) {
    log(message, level: 0); // level 0 is for info general
    print('Info: $message');
  }

  static void logWarning(String message) {
    log(message, level: 800); // level 800 is for warnings
    print('Warning: $message');
  }

  static void logError(String message) {
    log(message, level: 1000); // level 1000 is for error logs
    print('Error: $message');
  }

  // log a specific event with more details
  static void logEvent(String event, {Map<String, String>? data}) {
    final eventData = data != null ? ' | Data: $data' : '';
    log('Event: $event$eventData', level: 0);
    print('Event: $event');
  }
}
