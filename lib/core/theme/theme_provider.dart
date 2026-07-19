import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'grimoire_colors.dart';

/// Guarda o tema (preset de cores) escolhido pelo usuário e o persiste.
///
/// A escolha é lida de forma síncrona no construtor (a partir do
/// [SharedPreferences] já inicializado), evitando "flash" do tema padrão.
class ThemeProvider extends ChangeNotifier {
  static const String _key = 'theme_preset';

  final SharedPreferences _prefs;
  String _presetId;

  ThemeProvider(this._prefs)
      : _presetId = _prefs.getString(_key) ?? AppThemes.defaultId;

  String get presetId => _presetId;

  GrimoireColors get colors => AppThemes.colorsById(_presetId);

  ThemeData get themeData => AppTheme.build(colors);

  Future<void> setPreset(String id) async {
    if (_presetId == id) return;
    _presetId = id;
    notifyListeners();
    await _prefs.setString(_key, id);
  }
}
