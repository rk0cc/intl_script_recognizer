# An adapter helps `intl` package recognize correct language when `Locale` specified script language

---

<p align="center">
    <a href="https://pub.dev/packages/intl_script_recognizer"><img src="https://img.shields.io/pub/v/intl_script_recognizer?color=%2333FF33&label=Latest%20version%3A&style=flat-square" alt="Pub version"/></a>
    <a href="https://github.com/sponsors/rk0cc"><img alt="GitHub Sponsors" src="https://img.shields.io/github/sponsors/rk0cc?color=%2333FF33&style=flat-square"></a>
<a href="https://github.com/rk0cc/intl_script_recognizer/actions/workflows/flutter_test.yml"><img alt="Unit test" src="https://github.com/rk0cc/intl_script_recognizer/actions/workflows/flutter_test.yml/badge.svg?branch=main&event=push"/></a>
</p>

---

The pattern of locale for [intl package](https://pub.dev/packages/intl) is `(language)_(COUNTRY)` only.
However, Flutter's [Locale](https://api.flutter.dev/flutter/dart-ui/Locale-class.html) format is
`(language)_(Script)_(COUNTRY)` which triggered fallback to `(language)` only. Therefore, this package
aims to handle correct language system by define country code with corresponded scripting.

## Get started

Install `intl` and this package by using command:

```bash
flutter pub add intl intl_script_recognizer
```

or modify `dependencies` in `pubspec.yaml` directly:

```yaml
# pubspec.yaml
depencencies:
    intl: any
    intl_script_recognizer: ^1.0.0  # ^2.0.0 if using Dart 3 or above
```

Then, import dependencies into your project:

```dart
import 'package:intl/intl.dart';
import 'package:intl_script_recognizer/base.dart';
```

If `DateFormat` is required, it is highly recommended to import date format extension package:

```dart
import 'package:intl_script_recognizer/date_format.dart';
```

## License

BSD-3
