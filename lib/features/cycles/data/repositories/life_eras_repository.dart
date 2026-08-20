import 'dart:convert';

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
/// uma chave por usuária, carimbada com o mapa e a versão do algoritmo que a
/// produziram. Qualquer divergência recalcula e sobrescreve, então corrigir os
/// dados de nascimento invalida o cache sem nenhum código de invalidação.
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
      final cacheada = await _lerCache(userId, chart);
      if (cacheada != null) {
        return LifeErasReady(
          linha: cacheada,
          horaIncerta: chart.unknownBirthTime,
        );
      }

      final linha = calcularParaMapa(chart);
      await _gravarCache(userId, chart, linha);
      return LifeErasReady(
        linha: linha,
        horaIncerta: chart.unknownBirthTime,
      );
    } catch (e) {
      return LifeErasError(e);
    }
  }

  /// O cálculo puro, alimentado pelo mapa.
  ///
  /// Separado de [load] para poder ser exercitado sem SharedPreferences.
  static LinhaDoTempo calcularParaMapa(BirthChartModel chart) {
    // O fuso vem do mesmo resolvedor que o mapa usou (com horário de verão
    // histórico), para que o instante seja exatamente o do cálculo original.
    final resolvido = TimezoneResolver.resolve(
      date: chart.birthDate,
      hour: chart.birthTime.hour,
      minute: chart.birthTime.minute,
      latitude: chart.latitude,
      longitude: chart.longitude,
    );

    return calcularLinhaDoTempo(
      // `chart.moon.longitude` é TROPICAL: o SwephService roda com
      // SEFLG_MOSEPH e nunca com flag sideral. A conversão acontece dentro
      // do cálculo.
      longitudeLuaTropical: chart.moon.longitude,
      nascimentoUtc: resolvido.utc,
    );
  }

  /// Apaga o cache — usado quando a conta troca ou os dados são limpos.
  Future<void> clear(String userId) async {
    final prefs = await _prefs;
    await prefs.remove(_chave(userId));
  }

  Future<LinhaDoTempo?> _lerCache(
      String userId, BirthChartModel chart) async {
    final prefs = await _prefs;
    final bruto = prefs.getString(_chave(userId));
    if (bruto == null) return null;

    try {
      final json = jsonDecode(bruto) as Map<String, dynamic>;
      // O carimbo é o que faz a invalidação: mapa diferente, mapa recalculado
      // ou algoritmo novo derrubam o cache sozinhos.
      if (json['chartId'] != chart.id) return null;
      if (json['calcVersion'] != chart.calcVersion) return null;
      if (json['algoVersion'] != kLifeErasAlgoVersion) return null;
      return LinhaDoTempo.fromJson(json['linha'] as Map<String, dynamic>);
    } catch (_) {
      // Cache corrompido nunca deve derrubar a tela: recalcula.
      return null;
    }
  }

  Future<void> _gravarCache(
    String userId,
    BirthChartModel chart,
    LinhaDoTempo linha,
  ) async {
    final prefs = await _prefs;
    await prefs.setString(
      _chave(userId),
      jsonEncode({
        'chartId': chart.id,
        'calcVersion': chart.calcVersion,
        'algoVersion': kLifeErasAlgoVersion,
        'linha': linha.toJson(),
      }),
    );
  }
}
