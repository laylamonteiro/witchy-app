import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Guarda as seções JÁ GERADAS de uma leitura em andamento.
///
/// O relatório nasce seção a seção (7 chamadas na lunação). Sem isto, uma
/// falha na última — queda de rede, 429 da IA — jogava fora as seis
/// anteriores, e a nova tentativa refazia tudo. Não cobrava de novo (o
/// crédito só é consumido no fim), mas gastava sete chamadas para
/// aproveitar zero. E o pior caso caía justamente sobre quem tem muito
/// registro: a pessoa que mais esperou pela leitura.
///
/// Vive em SharedPreferences, e não no banco, de propósito: é um rascunho
/// de vida curta, apagado assim que o relatório fica pronto. Não precisa
/// sobreviver a uma reinstalação nem ser sincronizado — o que precisa
/// sobreviver é o CRÉDITO, e esse já vive em `cycle_readings`, com sync.
class CycleReadingDraftStore {
  const CycleReadingDraftStore();

  static const String _prefix = 'cycle_reading_draft_';

  static String _key(String creditId) => '$_prefix$creditId';

  /// As seções já prontas deste crédito.
  ///
  /// [materialFingerprint] identifica o material que as gerou. Se ele mudar
  /// — a pessoa desligou os sonhos na tela de privacidade, ou registrou algo
  /// novo no período —, o rascunho é DESCARTADO: misturar seções escritas
  /// com material diferente produziria um relatório que cita o que já não
  /// deveria estar lá.
  Future<Map<String, String>> load(
    String creditId,
    String materialFingerprint,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key(creditId));
      if (raw == null) return {};
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      if (decoded['fingerprint'] != materialFingerprint) {
        await clear(creditId);
        return {};
      }
      final sections = decoded['sections'];
      if (sections is! Map) return {};
      return {
        for (final entry in sections.entries)
          if (entry.value is String && (entry.value as String).isNotEmpty)
            '${entry.key}': entry.value as String,
      };
    } catch (_) {
      // Rascunho ilegível nunca pode impedir a geração: segue do zero.
      return {};
    }
  }

  /// Grava o que já ficou pronto. Chamado a cada seção concluída — é a
  /// gravação incremental que torna a retomada possível.
  Future<void> save(
    String creditId,
    String materialFingerprint,
    Map<String, String> sections,
  ) async {
    if (sections.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key(creditId),
        jsonEncode({
          'fingerprint': materialFingerprint,
          'sections': sections,
        }),
      );
    } catch (_) {
      // Falhar ao guardar o rascunho só custa retrabalho numa eventual
      // segunda tentativa — nunca a leitura em curso.
    }
  }

  /// Apaga o rascunho: relatório pronto, ou regeneração pedida (nesse caso
  /// reaproveitar seria devolver exatamente o texto que ela quis trocar).
  Future<void> clear(String creditId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key(creditId));
    } catch (_) {}
  }
}
