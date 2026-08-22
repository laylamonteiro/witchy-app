import 'dart:async';

/// Deixa passar UMA execução por vez: enquanto uma está em voo, as outras
/// chamadas são descartadas em silêncio.
///
/// Existe por causa do voltar. `PopScope` chama o mesmo tratador a cada pop
/// RECUSADO, e o tratador do voltar é assíncrono — ele espera em `maybePop`.
/// Se, enquanto espera, alguma rota recusar um pop e devolver o voltar para
/// o mesmo tratador, ele entra de novo por baixo de si mesmo: no melhor caso
/// desempilha duas telas de uma vez, no pior recursa até a pilha estourar.
/// Foi como o WebBackKeeper morreu — e o guarda que existia no lugar
/// (`if (canPop)`) só cobria um dos arranjos, não o problema.
///
/// Descartar é de propósito, e não enfileirar: um segundo voltar durante o
/// primeiro não é uma segunda intenção, é a mesma intenção chegando duas
/// vezes. Enfileirar desempilharia duas telas.
class UmDeCadaVez {
  bool _emVoo = false;

  /// Verdadeiro enquanto uma execução está em andamento.
  bool get emVoo => _emVoo;

  /// Roda [acao] se nada estiver em voo; devolve `false` se descartou.
  ///
  /// A liberação é em `finally`: uma [acao] que estoure não pode deixar o
  /// portão fechado para sempre — seria um voltar que para de funcionar até
  /// o app reiniciar. A exceção continua indo para quem chamou.
  Future<bool> executar(Future<void> Function() acao) async {
    if (_emVoo) return false;
    _emVoo = true;
    try {
      await acao();
    } finally {
      _emVoo = false;
    }
    return true;
  }
}
