import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl_script_recognizer/base.dart';
import 'package:intl_script_recognizer/date_format.dart';

void main() async {
  final isr = IntlScriptRecognizer();

  // Use Hong Kong instead of Taiwan for resolving Trad. Chinese
  isr.assign(
      {const Locale.fromSubtags(languageCode: "zh", scriptCode: "Hant"): "HK"},
      replaceExisted: true);

  await initializeDateFormatting("en_US", null);
  print(isr
      .constructDateFormatWithPattern(
          const Locale("zh", "Hant"), DateFormat.yMMMEd)
      .format(DateTime(2020, 1, 1)));
}
