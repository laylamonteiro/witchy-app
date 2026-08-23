/// O que fazer com um "voltar" que chegou na raiz do app.
enum DecisaoDeSaida {
  /// Primeiro voltar: avisa que o próximo sai.
  avisar,

  /// Voltar que faz parte da MESMA rajada do anterior — o dedo ainda está
  /// deslizando. Não sai, e empurra a janela para a frente.
  ignorar,

  /// Segundo voltar, deliberado e dentro da janela: sai.
  sair,
}

/// A regra do "voltar duas vezes para sair", com defesa contra rajada.
///
/// O gesto de voltar do Android repete fácil: a Bruxa desliza da borda três,
/// quatro vezes seguidas. Sem um piso de tempo entre um voltar e outro, a
/// caminhada inteira — desempilhar as telas, descer para o Seu Dia, avisar e
/// sair — cabia dentro de meio segundo de rajada, e a ABA FECHAVA antes de
/// ela ver o Seu Dia (relato de 23/08 no webapp; no celular o mesmo embalo
/// fechava o app).
///
/// Sair é destrutivo na web (a aba se fecha e o app some da tela), então a
/// saída tem de ser uma DECISÃO, nunca o embalo do dedo:
/// - o primeiro voltar na raiz avisa;
/// - qualquer voltar antes de [intervaloDeliberado] é rajada: ignorado, e
///   ainda empurra a janela para a frente — uma rajada infinita nunca sai;
/// - um voltar entre [intervaloDeliberado] e [janela] é decisão: sai;
/// - passada a [janela], o aviso caducou e tudo recomeça.
class SaidaPorDoisToques {
  SaidaPorDoisToques({
    this.janela = const Duration(seconds: 4),
    this.intervaloDeliberado = const Duration(milliseconds: 800),
  });

  /// Quanto tempo o aviso vale. Generosa de propósito: o aviso aparece por
  /// alguns segundos e a pessoa precisa poder ler antes de decidir.
  final Duration janela;

  /// Antes disto, dois voltares são o mesmo gesto chegando duas vezes.
  final Duration intervaloDeliberado;

  DateTime? _avisoEm;

  /// Há um aviso de saída de pé?
  bool get avisando => _avisoEm != null;

  /// Registra um voltar na raiz e diz o que fazer com ele.
  DecisaoDeSaida registrar(DateTime agora) {
    final aviso = _avisoEm;
    if (aviso == null || agora.difference(aviso) > janela) {
      _avisoEm = agora;
      return DecisaoDeSaida.avisar;
    }
    if (agora.difference(aviso) < intervaloDeliberado) {
      // Rajada: o dedo ainda está deslizando. A janela anda junto para que
      // uma sequência rápida nunca termine em saída.
      _avisoEm = agora;
      return DecisaoDeSaida.ignorar;
    }
    _avisoEm = null;
    return DecisaoDeSaida.sair;
  }

  /// Esquece o aviso — chamado quando o voltar fez OUTRA coisa (desempilhou
  /// uma tela, trocou de aba). Sem isto, um aviso dado antes de a pessoa
  /// navegar continuaria valendo e o voltar seguinte sairia do app numa tela
  /// que não é a raiz.
  void esquecer() => _avisoEm = null;
}
