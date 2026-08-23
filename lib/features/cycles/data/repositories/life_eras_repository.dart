import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../astrology/data/models/birth_chart_model.dart';
import '../../../astrology/data/services/timezone_resolver.dart';
import '../../domain/cycle_time.dart';
import '../../domain/life_eras_calculator.dart';
import '../../domain/life_timeline.dart';
import '../models/life_eras_state.dart';

/// Entrega a linha do tempo das Eras a partir do mapa astral já salvo.
///
/// **Não existe tabela nem sync para isto, e é de propósito.** A linha do
/// tempo é matemática pura derivada de dois valores que o mapa já persiste e
/// já sincroniza (`birth_charts`): a longitude tropical da Lua e o instante do
/// nascimento. Guardar o resultado numa tabela própria criaria uma segunda
/// fonte de verdade que pode divergir do mapa — e o mapa se recalcula sozinho
/// quando `kChartCalcVersion` sobe.
///
/// O cache local existe só para não refazer a conta a cada abertura de tela:
/// uma chave por usuária, carimbada com as ENTRADAS do cálculo — a longitude
/// da Lua e o instante do nascimento. Carimbar pelo id do mapa seria mais
/// barato e menos seguro: `AstrologyProvider.updateBirthChart` é público e
/// pode gravar dados novos sob o mesmo id, e aí o cache ficaria velho em
/// silêncio. Com as próprias entradas, cache velho é impossível por
/// construção: se elas não mudaram, a linha do tempo é a mesma.
class LifeErasRepository {
  LifeErasRepository({SharedPreferences? prefs}) : _prefsOverride = prefs;

  /// Injetável para teste; produção resolve pelo singleton.
  final SharedPreferences? _prefsOverride;

  Future<SharedPreferences> get _prefs async =>
      _prefsOverride ?? await SharedPreferences.getInstance();

  static String _chave(String userId) => 'life_eras_$userId';

  /// Estado das Eras para [userId], derivado de [chart].
  ///
  /// [chart] nulo significa que a pessoa ainda não montou o mapa astral —
  /// a interface manda para a tela de dados de nascimento.
  Future<LifeErasState> load({
    required String userId,
    required BirthChartModel? chart,
  }) async {
    if (chart == null) return const LifeErasIncomplete();

    try {
      final entrada = entradaDoMapa(chart);

      final cacheada = await _lerCache(userId, entrada);
      if (cacheada != null) {
        return LifeErasReady(
          linha: cacheada,
          horaIncerta: chart.unknownBirthTime,
        );
      }

      final linha = calcularLinhaDoTempo(
        longitudeLuaTropical: entrada.longitudeLua,
        nascimentoUtc: entrada.nascimentoUtc,
      );
      await _gravarCache(userId, entrada, linha);
      return LifeErasReady(
        linha: linha,
        horaIncerta: chart.unknownBirthTime,
      );
    } catch (e) {
      // A causa morria aqui: a tela mostra um cartão genérico e o campo
      // `erro` de LifeErasError não tem leitor nenhum no app inteiro. Quando
      // alguém reclamar, o log é o que vai existir.
      debugPrint('Eras: falha ao montar a linha do tempo: $e');
      return LifeErasError(e);
    }
  }

  /// As duas entradas do cálculo, extraídas do mapa.
  ///
  /// Tudo que a linha do tempo precisa saber sobre a pessoa cabe aqui — e é
  /// por isso que elas servem de carimbo do cache.
  static ({double longitudeLua, DateTime nascimentoUtc}) entradaDoMapa(
    BirthChartModel chart,
  ) {
    // O fuso vem do mesmo resolvedor que o mapa usou (com horário de verão
    // histórico), para que o instante seja exatamente o do cálculo original.
    final resolvido = TimezoneResolver.resolve(
      date: chart.birthDate,
      hour: chart.birthTime.hour,
      minute: chart.birthTime.minute,
      latitude: chart.latitude,
      longitude: chart.longitude,
    );

    return (
      // `chart.moon.longitude` é TROPICAL: o SwephService roda com
      // SEFLG_MOSEPH e nunca com flag sideral. A conversão acontece dentro
      // do cálculo.
      longitudeLua: chart.moon.longitude,
      nascimentoUtc: resolvido.utc,
    );
  }

  /// O cálculo puro, alimentado pelo mapa.
  ///
  /// Separado de [load] para poder ser exercitado sem SharedPreferences.
  static LinhaDoTempo calcularParaMapa(BirthChartModel chart) {
    final entrada = entradaDoMapa(chart);
    return calcularLinhaDoTempo(
      longitudeLuaTropical: entrada.longitudeLua,
      nascimentoUtc: entrada.nascimentoUtc,
    );
  }

  /// Apaga o cache — usado quando a conta troca ou os dados são limpos.
  Future<void> clear(String userId) async {
    final prefs = await _prefs;
    await prefs.remove(_chave(userId));
  }

  Future<LinhaDoTempo?> _lerCache(
    String userId,
    ({double longitudeLua, DateTime nascimentoUtc}) entrada,
  ) async {
    final prefs = await _prefs;
    final bruto = prefs.getString(_chave(userId));
    if (bruto == null) return null;

    try {
      final json = jsonDecode(bruto) as Map<String, dynamic>;
      // Entrada diferente ou algoritmo novo derrubam o cache sozinhos.
      // Comparar como num: se o JSON gravado tiver a longitude sem casa
      // decimal, ela volta como int e um `!=` cru derrubaria o cache sempre.
      final longitudeGravada = (json['longitudeLua'] as num?)?.toDouble();
      if (longitudeGravada != entrada.longitudeLua) return null;
      if (json['nascimentoUtc'] !=
          entrada.nascimentoUtc.millisecondsSinceEpoch) {
        return null;
      }
      if (json['algoVersion'] != kLifeErasAlgoVersion) return null;
      return LinhaDoTempo.fromJson(json['linha'] as Map<String, dynamic>);
    } catch (_) {
      // Cache corrompido nunca deve derrubar a tela: recalcula.
      return null;
    }
  }

  Future<void> _gravarCache(
    String userId,
    ({double longitudeLua, DateTime nascimentoUtc}) entrada,
    LinhaDoTempo linha,
  ) async {
    final prefs = await _prefs;
    await prefs.setString(
      _chave(userId),
      jsonEncode({
        'longitudeLua': entrada.longitudeLua,
        'nascimentoUtc': entrada.nascimentoUtc.millisecondsSinceEpoch,
        'algoVersion': kLifeErasAlgoVersion,
        'linha': linha.toJson(),
      }),
    );
  }
}
