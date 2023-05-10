import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl_script_recognizer/base.dart';
import 'package:intl_script_recognizer/date_format.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting("en_US");
    IntlScriptRecognizer();
  });

  group("Assign test", () {
    test("Thrown when parsing invalid arguments", () {
      const Locale validLocale =
          Locale.fromSubtags(languageCode: "zh", scriptCode: "Hans");

      expect(
          () => IntlScriptRecognizer().assign({
                const Locale.fromSubtags(
                    languageCode: "li", scriptCode: "Lina"): "XX",
                validLocale: "CN"
              }),
          throwsArgumentError);
      expect(
          () => IntlScriptRecognizer().assign({const Locale("en", "GB"): "US"}),
          throwsArgumentError);
      expect(() => IntlScriptRecognizer().assign({const Locale("jp"): "JP"}),
          throwsArgumentError);
      expect(IntlScriptRecognizer().isAssigned(validLocale), isFalse);
    });

    test("Process assign and replace", () {
      const hans = Locale.fromSubtags(languageCode: "zh", scriptCode: "Hans");
      const hant =
          const Locale.fromSubtags(languageCode: "zh", scriptCode: "Hant");

      IntlScriptRecognizer().assign({
        hans: "SG",
        hant: "MO" // Does not assigned
      });

      expect(
          [hans, hant]
              .map(IntlScriptRecognizer().isAssigned)
              .every((element) => true),
          isTrue);
      expect(IntlScriptRecognizer().resolve(hans), "zh_SG");
      expect(IntlScriptRecognizer().resolve(hant), "zh_TW");

      IntlScriptRecognizer().assign({hant: "HK"}, replaceExisted: true);
      expect(IntlScriptRecognizer().resolve(hant), "zh_HK");
    });

    tearDown(() {
      IntlScriptRecognizer.factoryReset();
    });
  });

  test("Implementation with intl package", () {
    expect(
        IntlScriptRecognizer()
            .constructDateFormatWithPattern(
                const Locale.fromSubtags(
                    languageCode: "zh", scriptCode: "Hant"),
                DateFormat.yMMMMd)
            .add_E()
            .format(DateTime(2020, 1, 1)),
        "2020年1月1日 週三");
  });
}
