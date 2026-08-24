import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../utils/um_de_cada_vez.dart';

/// O porteiro do voltar: na web, o fim da linha para todo `popRoute` que o
/// motor manda.
///
/// POR QUE ELE EXISTE. `WidgetsBinding.handlePopRoute()` percorre os
/// observadores do BINDING e, se NENHUM devolver `true`, chama
/// `SystemNavigator.pop()` (binding.dart:1116-1132, Flutter 3.47). Na web esse
/// atalho é o `exit()` do motor, que ANTES de tentar sair faz `tearDown()`:
/// desliga o ouvinte de `popstate` — para sempre, porque o motor nunca recria
/// o histórico — e apaga a entrada-guarda. Dali em diante o app continua na
/// tela, com toda a aparência de saudável, e o voltar seguinte vai direto para
/// o navegador, que fecha a aba a partir de QUALQUER tela. Basta uma passagem,
/// e o documento não se recupera enquanto não recarregar.
///
/// POR QUE NÃO BASTA `PopScope`. Cobrir isso tela a tela é o que já foi
/// tentado e falhou: ficam de fora os quadros em que nenhum `PopScope` está
/// montado — o boot antes do primeiro `runApp`, a [BootErrorApp] (que tem
/// `MaterialApp` próprio), o `ErrorWidget.builder` (que substitui a subárvore e
/// leva o `PopScope` junto) e os quadros de troca de sessão. Um observador do
/// binding vive FORA da árvore de widgets: fecha a porta uma vez só, e vale
/// inclusive para toda tela que alguém escrever depois.
///
/// O QUE ELE FAZ COM O GESTO. Exatamente o que o `_WidgetsAppState` faria:
/// `maybePop` no Navigator raiz, que respeita o `PopScope` da rota do topo — é
/// por ali que a `CaminhadaDoVoltar` da Home recebe o voltar. A única diferença
/// está no fim: **na web ele devolve `true` mesmo quando não havia nada para
/// desempilhar**, e é essa linha que torna o `exit()` inalcançável.
///
/// **Fora da web é inerte de propósito** (primeira linha de [didPopRoute]): no
/// celular o `SystemNavigator.pop()` está CERTO — manda o app para segundo
/// plano, é reversível, e engoli-lo prenderia a Bruxa dentro do app sem saída.
class PorteiroDoVoltar with WidgetsBindingObserver {
  PorteiroDoVoltar({
    required this.raiz,
    this.naWeb = kIsWeb,
    void Function(String linha)? registrar,
  }) : _registrar = registrar ?? _noConsole;

  /// O Navigator raiz. Nulo enquanto ele não montou — e também quando quem
  /// está na tela é outro `MaterialApp` (a tela de erro de boot).
  final NavigatorState? Function() raiz;

  /// Só o teste passa este valor. Ele existe para que os DOIS lados da regra
  /// sejam exercitados: a suíte roda na VM, onde `kIsWeb` é sempre `false`, e
  /// sem esta troca o único caminho que importa seria inalcançável em
  /// `flutter_test`.
  final bool naWeb;

  final void Function(String) _registrar;

  /// Um voltar por vez. `maybePop` é assíncrono e o `PopScope` da Home chama o
  /// tratador a cada pop RECUSADO: sem portão, dois voltares em voo
  /// desempilham duas telas de uma vez. Ver [UmDeCadaVez].
  final UmDeCadaVez _umPorVez = UmDeCadaVez();

  /// Quantos voltares chegaram ao app nesta sessão. Se a aba sumir e este
  /// número não tiver subido, o voltar não passou pelo Dart — e quem fechou
  /// foi o navegador, não o app.
  int voltaresTratados = 0;

  static PorteiroDoVoltar? _instalado;

  @visibleForTesting
  static PorteiroDoVoltar? get instancia => _instalado;

  /// Instala o porteiro — uma vez, logo depois do `ensureInitialized()` e ANTES
  /// do `runApp`, para valer inclusive quando o boot falha e quem sobe é a
  /// [BootErrorApp].
  static PorteiroDoVoltar instalar({required NavigatorState? Function() raiz}) {
    final jaExiste = _instalado;
    if (jaExiste != null) return jaExiste;
    final porteiro = PorteiroDoVoltar(raiz: raiz);
    WidgetsBinding.instance.addObserver(porteiro);
    return _instalado = porteiro;
  }

  @visibleForTesting
  void desinstalar() {
    WidgetsBinding.instance.removeObserver(this);
    if (identical(_instalado, this)) _instalado = null;
  }

  @override
  Future<bool> didPopRoute() async {
    if (!naWeb) return false;

    voltaresTratados++;
    final navegador = raiz();
    _registrar(
      '#$voltaresTratados — navegador raiz '
      '${navegador == null ? 'ausente' : 'presente'}',
    );

    if (navegador != null) {
      try {
        await _umPorVez.executar(() async {
          await navegador.maybePop();
        });
      } catch (erro, pilha) {
        // Uma exceção NÃO pode escapar: `handlePopRoute` a registra e SEGUE
        // para o próximo observador, que devolveria `false` e chamaria o
        // `SystemNavigator.pop()` — exatamente o que este porteiro existe
        // para impedir.
        FlutterError.reportError(FlutterErrorDetails(
          exception: erro,
          stack: pilha,
          library: 'grimório de bolso',
          context: ErrorDescription('ao tratar um voltar do navegador'),
        ));
      }
    }

    // SEMPRE `true` na web, inclusive sem navegador e inclusive depois de um
    // erro: é esta linha que torna o `exit()` do motor inalcançável. O motor
    // ignora a resposta (`history.dart` passa `(_) {}` como callback), então
    // isto não custa nada a ele.
    return true;
  }

  /// Só o console, de propósito: `debugLog` reescreve o buffer inteiro no
  /// armazenamento, e na web isso é a THREAD PRINCIPAL — a mesma cuja ocupação
  /// é uma das causas possíveis do defeito. Gastá-la dentro do tratador do
  /// voltar seria trabalhar contra a própria correção.
  static void _noConsole(String linha) => debugPrint('[VOLTAR] $linha');
}
