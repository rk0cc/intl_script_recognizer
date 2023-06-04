/// An extension library for processing [IntlScriptRecognizer] with [DateFormat].
library date_format;

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'src/recognizer.dart';

/// Factory method from [DateFormat] that using pre-defined pattern.
typedef DateFormatPatternFactory = DateFormat Function(dynamic locale);

/// An extension for parsing [DateFormat] in [IntlScriptRecognizer].
extension DateFormatRecognizerExtension on IntlScriptRecognizer {
  /// Construct [DateFormat.new] by given [locale] and [newPattern].
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
      Locale? locale, DateFormatPatternFactory patternFactory) {
    return patternFactory(resolve(locale));
  }

  /// Construct [DateFormat.new] with [resolveFromContext].
  DateFormat dateFormatFromContext(BuildContext context, [String? newPattern]) {
    return DateFormat(newPattern, resolveFromContext(context));
  }

  /// Construct [DateFormat] with pre-defined pattern.
  DateFormat dateFormatWithPatternFromContext(
      BuildContext context, DateFormatPatternFactory patternFactory) {
    return patternFactory(resolveFromContext(context));
  }
}
