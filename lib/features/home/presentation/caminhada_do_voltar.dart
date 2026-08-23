import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:flutter/widgets.dart' show NavigatorState;

import '../../../core/navigation/saida_do_app.dart';
import '../../../core/utils/saida_por_dois_toques.dart';

/// Como o app SAI — a borda que separa o que a caminhada decide do que a
/// plataforma faz. Existe para os testes: `kIsWeb` é constante na VM, e sem
/// esta troca o caminho da web seria inalcançável em `flutter_test`.
abstract class SaidaDaAba {
  const SaidaDaAba();

  /// Há para onde ir ao sair? Na web, uma aba que nasceu no app não tem
  /// nada antes dele — e nenhuma página fecha uma aba que não abriu.
  bool podeSair();

  void sair();
}

/// A saída de verdade: navegador na web, segundo plano no celular.
class SaidaDaAbaReal extends SaidaDaAba {
  const SaidaDaAbaReal();

  @override
  bool podeSair() => kIsWeb ? podeSairDaAba() : true;

  @override
  void sair() {
    if (kIsWeb) {
      // NUNCA `SystemNavigator.pop()` aqui: na web ele cai no `exit()` do
      // motor, que desliga o ouvinte de `popstate` e apaga a
      // entrada-guarda — deixando o voltar morto e a aba à mercê do
      // próximo gesto. Ver `core/navigation/saida_do_app.dart`.
      sairDaAba();
      return;
    }
    SystemNavigator.pop();
  }
}

/// A caminhada do voltar: o que fazer com um "voltar" que chegou à Home.
///
/// Fora do widget de propósito. O pedido é comportamental — "o voltar
/// desce até o Seu Dia ANTES de sair" — e comportamento se prova com
/// teste; dentro da HomePage ele dependia de contexto, de `kIsWeb` e do
/// relógio, e nada disso é alcançável em `flutter_test`.
///
/// A ordem é a de sempre: 1) telas cheias sobre a Home; 2) páginas
/// empilhadas dentro da aba ativa; 3) raiz de outra aba volta ao Seu Dia;
/// 4) só no Seu Dia, com um segundo voltar deliberado, sai.
class CaminhadaDoVoltar {
  CaminhadaDoVoltar({
    required this.raiz,
    required this.abaAtiva,
    required this.abaAtual,
    required this.irParaAba,
    required this.mostrarAviso,
    required this.regra,
    required this.vivo,
    this.saida = const SaidaDaAbaReal(),
    this.agora = _agoraDeVerdade,
  });

  /// O Navigator raiz (null quando a tela já saiu da árvore).
  final NavigatorState? Function() raiz;

  /// O Navigator da aba em foco.
  final NavigatorState? Function() abaAtiva;

  final int Function() abaAtual;
  final void Function(int) irParaAba;

  /// Mostra o "toque de novo para sair".
  final void Function() mostrarAviso;

  final SaidaPorDoisToques regra;

  /// A tela ainda está montada? Conferido depois de cada espera.
  final bool Function() vivo;

  final SaidaDaAba saida;

  /// Injetável para o teste poder controlar a rajada.
  @visibleForTesting
  final DateTime Function() agora;

  static DateTime _agoraDeVerdade() => DateTime.now();

  Future<void> resolver() async {
    // 1. Telas cheias empilhadas no Navigator raiz.
    //
    // Na prática o framework desempilha essas rotas ANTES de consultar o
    // `PopScope` da Home (o `maybePop` olha só a rota do topo), então este
    // passo raramente roda por um voltar do sistema — ele fica para quem
    // devolve o voltar para cá, e para as chamadas diretas.
    final navegadorRaiz = raiz();
    if (navegadorRaiz != null && navegadorRaiz.canPop()) {
      regra.esquecer();
      await navegadorRaiz.maybePop();
      return;
    }

    // 2. Páginas de detalhe dentro da aba ativa. `maybePop` (e não `pop`)
    // respeita o PopScope interno das páginas — ex.: o stepper da lição
    // volta passo a passo antes de sair, e a Escrita Livre salva ao sair.
    final navegadorDaAba = abaAtiva();
    if (navegadorDaAba != null && await navegadorDaAba.maybePop()) {
      regra.esquecer();
      return;
    }
    if (!vivo()) return;

    // 3. Raiz de outra aba: o voltar leva à tela principal (Seu Dia) —
    // nunca sai do app a partir daqui.
    if (abaAtual() != 0) {
      regra.esquecer();
      irParaAba(0);
      return;
    }

    // 4. Seu Dia, raiz. Onde não há para onde ir, a saída nem é oferecida:
    // o voltar simplesmente fica aqui.
    if (!saida.podeSair()) return;

    final decisao = regra.registrar(agora());
    if (decisao == DecisaoDeSaida.sair) {
      saida.sair();
      return;
    }
    // Rajada (`ignorar`): nada — nem sair, nem repetir o aviso que já está
    // na tela.
    if (decisao == DecisaoDeSaida.avisar) mostrarAviso();
  }
}
