import 'package:logger/logger.dart';

/// Global logger instance for the application.
///
/// Usage:
/// ```dart
/// import 'package:vgtec_app/services/logger_service.dart';
///
/// log.d('Debug message');   // Debug
/// log.i('Info message');    // Info
/// log.w('Warning message'); // Warning
/// log.e('Error message');   // Error
/// log.t('Trace message');   // Trace (verbose)
/// log.f('Fatal message');   // Fatal (wtf)
/// ```
final Logger log = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // Number of method calls to display
    errorMethodCount: 5, // Number of method calls for errors
    lineLength: 80, // Width of output
    colors: true, // Colorful output
    printEmojis: true, // Print emoji for each level
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Show time
  ),
  level: Level.debug, // Minimum level to show (can change for production)
);

/// Production logger with minimal output
final Logger logProd = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 3,
    lineLength: 60,
    colors: false,
    printEmojis: false,
    dateTimeFormat: DateTimeFormat.none,
  ),
  level: Level.warning, // Only show warnings and above in production
);

/// Simple logger without stack trace (for simple messages)
final Logger logSimple = Logger(
  printer: SimplePrinter(printTime: true, colors: true),
  level: Level.debug,
);
