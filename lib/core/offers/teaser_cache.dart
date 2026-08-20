import 'package:shared_preferences/shared_preferences.dart';

/// Cache local das amostras de degustação geradas por IA.
///
/// O custo de IA da degustação é real: a amostra de um registro é gerada
/// UMA vez e reaproveitada para sempre — nunca regerada num rebuild nem em
/// visitas seguintes ao mesmo registro.
abstract final class TeaserAiCache {
  static String _key(String slot, String recordId) =>
      'teaser_cache_${slot}_$recordId';

  static Future<String?> get(String slot, String recordId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key(slot, recordId));
  }

  static Future<void> put(String slot, String recordId, String sample) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(slot, recordId), sample);
  }
}
