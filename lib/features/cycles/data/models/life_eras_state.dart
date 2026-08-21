import '../../domain/life_timeline.dart';

/// O que a aba Ciclos tem para mostrar sobre as Eras da vida.
///
/// Selado de propósito: os três casos cobrem tudo que pode acontecer, e o
/// `switch` na interface fica exaustivo — não dá para esquecer de tratar um.
sealed class LifeErasState {
  const LifeErasState();
}

/// Linha do tempo pronta.
class LifeErasReady extends LifeErasState {
  const LifeErasReady({
    required this.linha,
    required this.horaIncerta,
  });

  final LinhaDoTempo linha;

  /// A pessoa não sabia a hora de nascimento, e o mapa assumiu meio-dia.
  ///
  /// Para este cálculo isso é grave: a Lua anda até 15° por dia e um setor
  /// lunar tem 13°20', então doze horas de incerteza podem trocar a Era
  /// regente e deslocar as fronteiras em vários anos. A linha do tempo é
  /// mostrada assim mesmo, mas sempre acompanhada do aviso.
  final bool horaIncerta;
}

/// Falta o mapa astral — sem ele não há longitude da Lua para calcular.
class LifeErasIncomplete extends LifeErasState {
  const LifeErasIncomplete();
}

/// Algo quebrou no caminho (mapa corrompido, fuso irresolvível).
class LifeErasError extends LifeErasState {
  const LifeErasError(this.erro);

  final Object erro;
}
