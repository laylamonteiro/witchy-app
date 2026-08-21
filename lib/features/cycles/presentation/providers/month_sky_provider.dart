import 'package:flutter/foundation.dart';

import '../../data/models/month_sky_event.dart';
import '../../data/services/month_sky_calculator.dart';

/// O céu do mês para a aba Ciclos.
///
/// A conta varre o mês dia a dia no efeméride e refina por bisseção: é
/// barata, mas não é de graça, e o mês não muda enquanto a pessoa navega.
/// Guarda o resultado em memória por mês — trocar de aba não refaz nada.
class MonthSkyProvider extends ChangeNotifier {
  List<MonthSkyEvent>? _eventos;
  List<MonthSkyEvent>? get eventos => _eventos;

  bool _carregando = false;
  bool get carregando => _carregando;

  /// Falhou (efeméride indisponível, por exemplo). A aba simplesmente não
  /// mostra o bloco — é informação a mais, nunca o motivo de uma tela vazia.
  bool _falhou = false;
  bool get falhou => _falhou;

  /// Chave do mês já calculado, no formato aaaa-MM.
  String? _mesCarregado;

  Future<void> sync(DateTime quando) async {
    final chave = '${quando.year}-${quando.month}';
    if (chave == _mesCarregado && _eventos != null) return;
    if (_carregando) return;

    _mesCarregado = chave;
    _carregando = true;
    _falhou = false;
    notifyListeners();

    try {
      _eventos = await MonthSkyCalculator.doMes(quando);
    } catch (e) {
      _eventos = null;
      _falhou = true;
      // Deixa recalcular numa próxima tentativa.
      _mesCarregado = null;
      debugPrint('Falha ao calcular o céu do mês: $e');
    }

    _carregando = false;
    notifyListeners();
  }
}
