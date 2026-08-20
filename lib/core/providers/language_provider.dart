import 'dart:ui' as ui;

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
    final savedTag = _prefs.getString(preferencesKey);
    // Sem preferência salva, o idioma inicial segue o do dispositivo
    // (com fallback pt-BR); a escolha manual é persistida em setLocale.
    _locale = savedTag != null ? _localeFromTag(savedTag) : _fromDevice();
    AIService.instance.setLocale(_locale);
    ContentLocale.instance.setLocale(_locale);

    // Na web (e em cold start), o locale real do dispositivo pode chegar
    // DEPOIS da construção — a leitura inicial devolveria en-US e um
    // aparelho em português abriria em inglês. Enquanto não houver escolha
    // manual, reagimos quando o sistema reporta o idioma de verdade.
    ui.PlatformDispatcher.instance.onLocaleChanged = _onDeviceLocaleChanged;
  }

  /// Idioma a partir do dispositivo: varre a LISTA de locales (mais confiável
  /// que o `.locale` único) e pega o primeiro cujo idioma o app suporta;
  /// nada casando, cai no pt-BR. Um aparelho em português SEMPRE resulta em
  /// pt-BR aqui (o pt casa antes de qualquer fallback).
  static Locale _fromDevice() {
    for (final device in ui.PlatformDispatcher.instance.locales) {
      for (final supported in supportedLocales) {
        if (supported.languageCode == device.languageCode) {
          return _normalize(device);
        }
      }
    }
    return fallbackLocale;
  }

  void _onDeviceLocaleChanged() {
    // Escolha manual manda: não sobrescreve o que a pessoa fixou.
    if (_prefs.getString(preferencesKey) != null) return;
    final detected = _fromDevice();
    if (detected == _locale) return;
    _locale = detected;
    AIService.instance.setLocale(_locale);
    ContentLocale.instance.setLocale(_locale);
    notifyListeners();
  }

  Locale get locale => _locale;
  String get languageTag => _languageTag(_locale);

  Future<void> setLocale(Locale locale) async {
    final normalized = _normalize(locale);
    // Persiste mesmo quando o idioma escolhido coincide com o do dispositivo
    // (primeiro uso sem preferência salva): a escolha manual "fixa" o idioma.
    final alreadySaved =
        _prefs.getString(preferencesKey) == _languageTag(normalized);
    if (_locale == normalized && alreadySaved) return;

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
