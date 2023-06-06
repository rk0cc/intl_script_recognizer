import 'dart:collection';

import 'package:flutter/widgets.dart';

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
final class IntlScriptRecognizer {
  static IntlScriptRecognizer? _instance;

  Set<String> _customRegion = {};

  final HashMap<Locale, String> _localCountryMapper = HashMap();

  /// Return current instance of [IntlScriptRecognizer]. If no
  /// instance created yet, it will construct a new instance first.
  ///
  /// This factory is designed for app implementation in global
  /// scope that all applied preference can be reused.
  factory IntlScriptRecognizer() {
    if (_instance == null) {
      _newInstance();
    }

    return _instance!;
  }

  /// Construct a delicated [IntlScriptRecognizer] that it no longer memorize
  /// instance and return current instance by calling [IntlScriptRecognizer.new].
  ///
  /// The [customRegion] must be defined in construction and [applyCustomRegion]
  /// will be disabled and throw [UnsupportedError].
  ///
  /// The delicated [IntlScriptRecognizer] is mainly for package which
  /// depending on this package that preventing implementer can be apply globally.
  factory IntlScriptRecognizer.delicated({Set<String> customRegion}) =
      _DelicatedIntlScriptRecognizer;

  /// A last resort [Function] that construct a new instance and replace
  /// the current one which remains default setting only.
  ///
  /// This method should be called after invoking [IntlScriptRecognizer.new]
  /// and throws [StateError] if no instance created yet.
  /// 
  /// It only affected from [IntlScriptRecognizer.new]. And any from
  /// [IntlScriptRecognizer.delicated] will no affected since they no
  /// longer store instance once they constructed.
  static void factoryReset() {
    if (_instance != null) {
      _newInstance();
    } else {
      throw StateError("No instance created yet");
    }
  }

  /// Create new instance, assign and ready to uses.
  static void _newInstance() {
    _instance = IntlScriptRecognizer._();
  }

  /// Constructor of [IntlScriptRecognizer] with default preference in
  /// Traditional Chinese.
  IntlScriptRecognizer._() {
    assign({
      const Locale.fromSubtags(languageCode: "zh", scriptCode: "Hant"): "TW"
    });
  }

  void _customRegionApplier(Set<String> customRegion) {
    final invalidCode = customRegion
        .where((element) => !RegExp(r"^[A-Z]{2}$").hasMatch(element));
    if (invalidCode.isNotEmpty) {
      throw FormatException(
          "The country code should be 2 captical letter in a single string",
          invalidCode.toSet());
    }

    _customRegion = Set<String>.from(customRegion).difference(_countryCode);
  }

  /// Define custom country code which may not recognized as country code yet or
  /// using as testing purpose.
  ///
  /// [customRegion] can be `null` or a [Set] of [String] which contains
  /// two capital letter to satisify [ISO 3166](https://www.iso.org/iso-3166-country-codes.html)
  /// alpha-2 standard.
  ///
  /// Applying empty [Set] into [customRegion] will throws [ArgumentError], and [FormatException]
  /// if does not obey the format of country code.
  ///
  /// When [customRegion] contains country code that it defined in ISO 3166 already,
  /// the duplicated country codes will be excluded.
  ///
  /// The applied [customRegion] belongs with current instance only which
  /// will be purged once [factoryReset] called.
  ///
  /// This method does not allows for [IntlScriptRecognizer.delicated] to prevent unwanted
  /// modification that [UnsupportedError] will be thrown if called.
  void applyCustomRegion(Set<String>? customRegion) {
    if (customRegion != null) {
      if (customRegion.isEmpty) {
        throw ArgumentError.value(customRegion, "customRegion",
            "It must be either `null` or non-empty set of string");
      }

      _customRegionApplier(customRegion);
    } else {
      _customRegion = <String>{};
    }
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
    } else if (cloneAC.values.any(
        (element) => !_countryCode.union(_customRegion).contains(element))) {
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

  /// Perform [resolve] from [Localizations.maybeLocaleOf].
  String? resolveFromContext(BuildContext context) {
    return resolve(Localizations.maybeLocaleOf(context));
  }
}

/// [IntlScriptRecognizer] for delicated mode.
final class _DelicatedIntlScriptRecognizer extends IntlScriptRecognizer {
  /// Construct a new recognizer.
  _DelicatedIntlScriptRecognizer({Set<String> customRegion = const <String>{}})
      : super._() {
    if (customRegion.isNotEmpty) {
      _customRegionApplier(customRegion);
    }
  }

  /// This feature is disabled for delicated mode.
  @override
  void applyCustomRegion(Set<String>? customRegion) {
    throw UnsupportedError("This feature is disabled for delicated mode");
  }
}

/// A [String] of country code.
const Set<String> _countryCode = <String>{
  "AD",
  "AE",
  "AF",
  "AG",
  "AI",
  "AL",
  "AM",
  "AO",
  "AQ",
  "AR",
  "AS",
  "AT",
  "AU",
  "AW",
  "AX",
  "AZ",
  "BA",
  "BB",
  "BD",
  "BE",
  "BF",
  "BG",
  "BH",
  "BI",
  "BJ",
  "BL",
  "BM",
  "BN",
  "BO",
  "BQ",
  "BR",
  "BS",
  "BT",
  "BV",
  "BW",
  "BY",
  "BZ",
  "CA",
  "CC",
  "CD",
  "CF",
  "CG",
  "CH",
  "CI",
  "CK",
  "CL",
  "CM",
  "CN",
  "CO",
  "CR",
  "CU",
  "CV",
  "CW",
  "CX",
  "CY",
  "CZ",
  "DE",
  "DJ",
  "DK",
  "DM",
  "DO",
  "DZ",
  "EC",
  "EE",
  "EG",
  "EH",
  "ER",
  "ES",
  "ET",
  "FI",
  "FJ",
  "FK",
  "FM",
  "FO",
  "FR",
  "GA",
  "GB",
  "GD",
  "GE",
  "GF",
  "GG",
  "GH",
  "GI",
  "GL",
  "GM",
  "GN",
  "GP",
  "GQ",
  "GR",
  "GS",
  "GT",
  "GU",
  "GW",
  "GY",
  "HK",
  "HM",
  "HN",
  "HR",
  "HT",
  "HU",
  "ID",
  "IE",
  "IL",
  "IM",
  "IN",
  "IO",
  "IQ",
  "IR",
  "IS",
  "IT",
  "JE",
  "JM",
  "JO",
  "JP",
  "KE",
  "KG",
  "KH",
  "KI",
  "KM",
  "KN",
  "KP",
  "KR",
  "KW",
  "KY",
  "KZ",
  "LA",
  "LB",
  "LC",
  "LI",
  "LK",
  "LR",
  "LS",
  "LT",
  "LU",
  "LV",
  "LY",
  "MA",
  "MC",
  "MD",
  "ME",
  "MF",
  "MG",
  "MH",
  "MK",
  "ML",
  "MM",
  "MN",
  "MO",
  "MP",
  "MQ",
  "MR",
  "MS",
  "MT",
  "MU",
  "MV",
  "MW",
  "MX",
  "MY",
  "MZ",
  "NA",
  "NC",
  "NE",
  "NF",
  "NG",
  "NI",
  "NL",
  "NO",
  "NP",
  "NR",
  "NU",
  "NZ",
  "OM",
  "PA",
  "PE",
  "PF",
  "PG",
  "PH",
  "PK",
  "PL",
  "PM",
  "PN",
  "PR",
  "PS",
  "PT",
  "PW",
  "PY",
  "QA",
  "RE",
  "RO",
  "RS",
  "RU",
  "RW",
  "SA",
  "SB",
  "SC",
  "SD",
  "SE",
  "SG",
  "SH",
  "SI",
  "SJ",
  "SK",
  "SL",
  "SM",
  "SN",
  "SO",
  "SR",
  "SS",
  "ST",
  "SV",
  "SX",
  "SY",
  "SZ",
  "TC",
  "TD",
  "TF",
  "TG",
  "TH",
  "TJ",
  "TK",
  "TL",
  "TM",
  "TN",
  "TO",
  "TR",
  "TT",
  "TV",
  "TW",
  "TZ",
  "UA",
  "UG",
  "UM",
  "US",
  "UY",
  "UZ",
  "VA",
  "VC",
  "VE",
  "VG",
  "VI",
  "VN",
  "VU",
  "WF",
  "WS",
  "YE",
  "YT",
  "ZA",
  "ZM",
  "ZW"
};
