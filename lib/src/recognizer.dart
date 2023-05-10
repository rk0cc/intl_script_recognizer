import 'dart:collection';
import 'dart:ui' show Locale;

import 'package:country_code/country_code.dart';

/// Recognize the correct language on `intl` package when [Locale]
/// object offered [Locale.languageCode] and [Locale.scriptCode] only.
///
/// For example, if applying Traditional Chinese (`zh_Hant`) into
/// `intl` package (e.g. `DateFormat`), it takes the fallback result
/// (`zh`) which is Simplified Chinese. As a result, the
/// formatted [String] becomes `2023年5月10日 周三` instead of
/// `2023年5月10日 週三` which `周` is simplified character of `週`
/// and both refer to day of week.
///
/// By default, it mapped Traditional Chinese (`zh_Hant`) to `intl`'s
/// recognizable locale [String] : `zh_TW` already.
class IntlScriptRecognizer {
  static IntlScriptRecognizer? _instance;

  final HashMap<Locale, String> _localCountryMapper = HashMap();

  /// Return current instance of [IntlScriptRecognizer]. For no
  /// instance created yet, it will construct a new instance first.
  factory IntlScriptRecognizer() {
    if (_instance == null) {
      _newInstance();
    }

    return _instance!;
  }

  /// A last resort [Function] that construct a new instance and replace
  /// the current one which remains default setting only.
  ///
  /// This method should be called after invoking [IntlScriptRecognizer.new]
  /// and throws [StateError] if no instance created yet.
  static void factoryReset() {
    if (_instance != null) {
      _instance = IntlScriptRecognizer._();
    } else {
      throw StateError("No instance created yet");
    }
  }

  static void _newInstance() {
    _instance = IntlScriptRecognizer._();
  }

  IntlScriptRecognizer._() {
    assign({
      const Locale.fromSubtags(languageCode: "zh", scriptCode: "Hant"): "TW"
    });
  }

  /// Assign the [Map] of [applyContent] which contains [Locale] with script code
  /// only as a key and a [String] of country code as value.
  ///
  /// If does not apply script code or applied country code into [Locale], it
  /// throws [ArgumentError]. The same error will be thrown when the value of
  /// country code is invalid.
  ///
  /// The country code will be modified if [replaceExisted] is enabled and
  /// the given [Locale] has been assigned already. By default, this option
  /// is disabled.
  void assign(Map<Locale, String> applyContent, {bool replaceExisted = false}) {
    final Map<Locale, String> cloneAC = Map.from(applyContent)
        .map((key, value) => MapEntry(key, value.toUpperCase()));

    if (cloneAC.keys.any((element) =>
        element.countryCode != null || element.scriptCode == null)) {
      throw ArgumentError(
          "The Locale object must provide script code and do not apply country code.");
    } else if (cloneAC.values.map(CountryCode.tryParse).contains(null)) {
      throw ArgumentError(
          "At least one of the country codes is invalid and unable to resolved.");
    }

    if (!replaceExisted) {
      cloneAC.removeWhere((key, _) => _localCountryMapper.containsKey(key));
    }

    _localCountryMapper.addAll(cloneAC);
  }

  /// Determine the given [locale] is [assign] already.
  bool isAssigned(Locale locale) {
    return _localCountryMapper.containsKey(locale);
  }

  /// Remove the [assign] data of [locale].
  void unassign(Locale locale) {
    _localCountryMapper.remove(locale);
  }

  /// Resolving `intl` recognizable [String] by the given [locale].
  ///
  /// The pattern of returned [String] for resolved [locale] should
  /// be either `(language)` or `(language)_(COUNTRY)`.
  ///
  /// The flow of [resolve] should be followed in this order:
  ///
  /// 1. If [locale] is nulled already, it just return null back.
  /// 1. If [locale] provided it's country code already, the generated [String] will refer it directly.
  /// 1. Otherwise, it try to find the corresponded country code by [isAssigned] and apply as a country code.
  /// 1. When the given [locale]'s country code is undefined, no country code is applied.
  ///
  /// For example, using default [assign]ed value: `zh_Hant` to apply DateFormat setting:
  ///
  /// ```dart
  /// final resolvedStr = IntlScriptRecognizer.resolve(const Locale("zh", "Hant")));
  ///
  /// print(DateFormat.yMMMMd(resolvedStr) // Applied as `zh_TW` instead
  ///     .add_E()
  ///     .format(DateTime.now()));
  /// ```
  ///
  /// The returned DateFormat result will obey the given country code instead of fallback
  /// by `intl` library.
  String? resolve(Locale? locale) {
    if (locale == null) {
      return null;
    }

    StringBuffer buf = StringBuffer()..write(locale.languageCode);
    if (locale.countryCode != null) {
      buf.write("_${locale.countryCode}");
    } else if (isAssigned(locale)) {
      buf.write("_${_localCountryMapper[locale]}");
    }

    return buf.toString();
  }
}
