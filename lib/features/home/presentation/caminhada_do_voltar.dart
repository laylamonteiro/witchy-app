import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:flutter/widgets.dart' show NavigatorState;

import '../../../core/utils/saida_por_dois_toques.dart';

/// Como o app SAI — a borda que separa o que a caminhada decide do que a
/// plataforma faz. Existe para os testes: `kIsWeb` é constante na VM, e sem
/// esta troca o caminho da web seria inalcançável em `flutter_test`.
abstract class SaidaDaAba {
  const SaidaDaAba();

  /// Há para onde ir ao sair? Na web nunca: ver [SaidaDaAbaReal].
  bool podeSair();

  void sair();
}

/// A saída de verdade: segundo plano no celular, e NADA na web.
///
/// NA WEB O VOLTAR NÃO SAI DO APP. Ponto. Isto já morou atrás de uma
/// importação condicional (`saida_do_app.dart` + stub + web), onde havia um
/// `history.go(-2)` autorizado por `history.length > 3`. A pergunta que essa
/// conta tentava responder — "existe uma página real antes do app nesta aba?"
/// — é INDECIDÍVEL de dentro da página, e a conta respondia outra coisa:
///
///  * `SingleEntryBrowserHistory.setRouteName` sempre chama
///    `_setupFlutterEntry(replace: true)`, ou seja, `replaceState` (engine
///    3.47.0, `web_ui/.../navigation/history.dart`). O histórico do app NUNCA
///    cresce: as duas entradas do motor são as mesmas do primeiro quadro até o
///    último. Logo `length` media exclusivamente o que já existia na aba ANTES
///    do app;
///  * e media mal: numa aba nova o Chrome ainda conta a página inicial, e um
///    retorno de login social soma entradas próprias.
///
/// O resultado era uma moeda ao ar. Quem abrisse o app por um link — uma
/// busca, o WhatsApp, o Instagram — passava no teste, e então o segundo voltar
/// deliberado no Seu Dia executava o `go(-2)` e a tirava do Grimório: "sai
/// depois de 2 voltares" é o relato de 23/08 inteiro, com o aviso de "toque de
/// novo para sair" possivelmente escondido atrás da barra de baixo.
///
/// E o outro caminho é pior: `SystemNavigator.pop()` na web cai no `exit()` do
/// motor, que ANTES de tentar sair faz `tearDown()` — desliga o ouvinte de
/// `popstate` para sempre e apaga a entrada-guarda, deixando o voltar morto
/// pelo resto do documento. É contra ele que existe o `PorteiroDoVoltar`.
///
/// Nenhuma página fecha uma aba que ela não abriu, e "sair" de um app que É a
/// própria aba não é serviço nenhum: quem quer sair fecha a aba. Por isso a
/// regra aqui é uma linha só, e não uma importação condicional — que, além de
/// cerimônia (os dois lados devolviam o mesmo), tornava esta decisão
/// inalcançável pela suíte, que roda na VM e sempre pegava o stub.
class SaidaDaAbaReal extends SaidaDaAba {
  const SaidaDaAbaReal({this.naWeb = kIsWeb});

  /// Só o teste passa este valor. Ele existe para que os DOIS lados da regra
  /// sejam exercitados: a suíte roda na VM, onde `kIsWeb` é sempre `false`, e
  /// sem esta troca o lado da web seria inalcançável em `flutter_test`.
  final bool naWeb;

  @override
  bool podeSair() => !naWeb;

  @override
  void sair() {
    // Na web não há saída: quem chega aqui já foi barrado por [podeSair], e
    // mesmo que não fosse, não há nada seguro a fazer.
    if (naWeb) return;
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
    required this.mostrarFimDaCaminhada,
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

  /// Mostra o "toque de novo para sair" — só o celular chega aqui hoje.
  final void Function() mostrarAviso;

  /// Diz que a caminhada acabou e não há para onde ir: o fim da linha na web.
  ///
  /// Existe para o voltar não ficar MUDO no Seu Dia, que é indistinguível de
  /// "o app travou" — a Bruxa desliza, nada muda na tela, e ela não tem como
  /// saber se chegou ao fim ou se o app parou de responder.
  final void Function() mostrarFimDaCaminhada;

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

    // 4. Seu Dia, raiz — o fim da caminhada.
    if (!saida.podeSair()) {
      // Na web é SEMPRE aqui que ela termina: o app não fecha a aba que não
      // abriu (ver [SaidaDaAbaReal]). Silêncio neste ponto é indistinguível
      // de "o app travou", então ele diz onde está.
      mostrarFimDaCaminhada();
      return;
    }

    if (regra.registrar(agora()) == DecisaoDeSaida.sair) {
      saida.sair();
      return;
    }
    mostrarAviso();
  }
}
