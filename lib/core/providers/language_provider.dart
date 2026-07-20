import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ai/ai_service.dart';
import '../content/content_locale.dart';

class LanguageProvider extends ChangeNotifier {
  static const String preferencesKey = 'selected_locale';
  static const Locale fallbackLocale = Locale('pt', 'BR');
  static const List<Locale> supportedLocales = [
    fallbackLocale,
    Locale('es'),
    Locale('en'),
  ];

  final SharedPreferences _prefs;
  Locale _locale = fallbackLocale;

  LanguageProvider(this._prefs) {
    _locale = _localeFromTag(_prefs.getString(preferencesKey));
    AIService.instance.setLocale(_locale);
    ContentLocale.instance.setLocale(_locale);
  }

  Locale get locale => _locale;
  String get languageTag => _languageTag(_locale);

  Future<void> setLocale(Locale locale) async {
    final normalized = _normalize(locale);
    if (_locale == normalized) return;

    _locale = normalized;
    AIService.instance.setLocale(_locale);
    ContentLocale.instance.setLocale(_locale);
    await _prefs.setString(preferencesKey, _languageTag(_locale));
    notifyListeners();
  }

  static Locale resolve(Locale? locale, Iterable<Locale> supportedLocales) {
    if (locale == null) return fallbackLocale;

    for (final supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode &&
          supported.countryCode == locale.countryCode) {
        return supported;
      }
    }

    for (final supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode) {
        return supported;
      }
    }

    return fallbackLocale;
  }

  static Locale _normalize(Locale locale) => resolve(locale, supportedLocales);

  static Locale _localeFromTag(String? tag) {
    switch (tag) {
      case 'en':
        return const Locale('en');
      case 'es':
        return const Locale('es');
      case 'pt-BR':
      case 'pt_BR':
      default:
        return fallbackLocale;
    }
  }

  static String _languageTag(Locale locale) {
    if (locale.countryCode == null || locale.countryCode!.isEmpty) {
      return locale.languageCode;
    }
    return '${locale.languageCode}-${locale.countryCode}';
  }
}
