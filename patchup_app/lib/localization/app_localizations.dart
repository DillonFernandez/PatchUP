import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Localization class for handling translations
class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  // Localization delegate for Flutter localization system
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Accessor for localization instance in widget tree
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Load language JSON file and parse translations
  Future<bool> load() async {
    final langCode = locale.languageCode;
    final path =
        'assets/language/${langCode == "si"
            ? "si"
            : langCode == "ta"
            ? "ta"
            : "en"}.json';
    final jsonString = await rootBundle.loadString(path);
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    return true;
  }

  // Translate a key to the localized string
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

// Delegate class for localization loading and support
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  // Supported language codes
  @override
  bool isSupported(Locale locale) =>
      ['en', 'si', 'ta'].contains(locale.languageCode);

  // Load localization for given locale
  @override
  Future<AppLocalizations> load(Locale locale) async {
    var localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  // Reloading is not required for this delegate
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
