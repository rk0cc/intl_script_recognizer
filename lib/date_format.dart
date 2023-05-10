/// An extension library for processing [IntlScriptRecognizer] with [DateFormat].
library date_format;

import 'dart:ui';

import 'package:intl/intl.dart';

import 'src/recognizer.dart';

/// An extension for parsing [DateFormat] in [IntlScriptRecognizer].
extension DateFormatRecognizerExtension on IntlScriptRecognizer {
  /// Construct a new [DateFormat] by given [locale] and [newPattern].
  DateFormat constructDateFormat(Locale? locale, [String? newPattern]) {
    return DateFormat(newPattern, resolve(locale));
  }

  /// Construct a new [DateFormat] with pre-defined format factory
  /// [Function] like below:
  ///
  /// ```dart
  /// final preDefDFStr = IntlScriptRecognizer()
  ///   .constructDateFormatWithPattern(const Locale("zh", "Hant"), DateFormat.yMMMMd)
  ///   .format(DateTime.now())
  /// ```
  DateFormat constructDateFormatWithPattern(
      Locale? locale, DateFormat Function(String? formatted) patternFactory) {
    return patternFactory(resolve(locale));
  }
}
