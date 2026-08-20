import 'package:flutter/foundation.dart';

import '../../../astrology/data/models/birth_chart_model.dart';
import '../../data/models/life_eras_state.dart';
import '../../data/repositories/life_eras_repository.dart';

/// Estado das Eras para a aba Ciclos.
///
/// Guarda o resultado em memória e só refaz o trabalho quando o mapa muda:
/// a aba é reconstruída a cada troca de sub-aba e a cada `notifyListeners` do
/// `AstrologyProvider`, e refazer leitura de disco em toda reconstrução seria
/// desperdício puro.
class LifeErasProvider extends ChangeNotifier {
  LifeErasProvider({LifeErasRepository? repository})
      : _repository = repository ?? LifeErasRepository();

  final LifeErasRepository _repository;

  LifeErasState? _state;
  LifeErasState? get state => _state;

  bool _carregando = false;
  bool get carregando => _carregando;

  /// Carimbo do que gerou o [_state] atual — se não mudar, não recarrega.
  String? _assinatura;

  static String _assinar(String userId, BirthChartModel? chart) => chart == null
      ? '$userId|sem-mapa'
      : '$userId|${chart.id}|${chart.calcVersion}';

  /// Garante que [state] corresponde a [chart]. Chamar à vontade: repetições
  /// com o mesmo mapa não custam nada.
  Future<void> sync({
    required String userId,
    required BirthChartModel? chart,
  }) async {
    final assinatura = _assinar(userId, chart);
    if (assinatura == _assinatura && _state != null) return;
    if (_carregando) return;

    _assinatura = assinatura;
    _carregando = true;
    notifyListeners();

    _state = await _repository.load(userId: userId, chart: chart);

    _carregando = false;
    notifyListeners();
  }

  /// Força o recálculo na próxima [sync] — usado quando a pessoa corrige os
  /// dados de nascimento sem que o id do mapa mude.
  void invalidar() {
    _assinatura = null;
    _state = null;
  }
}
