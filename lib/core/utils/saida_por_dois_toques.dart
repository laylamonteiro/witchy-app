/// O que fazer com um "voltar" que chegou na raiz do app.
enum DecisaoDeSaida {
  /// Primeiro voltar: avisa que o próximo sai.
  avisar,

  /// Segundo voltar dentro da janela: sai.
  sair,
}

/// A regra do "voltar duas vezes para sair" — **só no celular**.
///
/// Na web ela não é consultada: o passo 4 da `CaminhadaDoVoltar` termina antes,
/// porque `SaidaDaAbaReal.podeSair()` é `false` ali (nenhuma página fecha uma
/// aba que não abriu). No celular sair é ir para segundo plano — reversível, um
/// toque traz de volta — e o toque duplo de sempre é o esperado.
///
/// Esta classe já teve uma defesa contra RAJADA: um piso de tempo entre um
/// voltar e outro, para o embalo do dedo não atravessar a caminhada inteira e
/// fechar a aba. Ela saiu em 25/08, e vale registrar por quê: a teoria era que
/// uma deslizada repetida atropelava a entrada-guarda do motor, e o fonte
/// desmente — o re-empurrão da guarda é SÍNCRONO, a primeira instrução do
/// tratador de `popstate` (engine 3.47.0). Na prática o piso nunca defendeu de
/// nada; só descartava um segundo voltar deliberado. O que de fato fecha a aba
/// é o Chrome pulando as entradas do documento, e isso nenhuma regra de tempo
/// alcança.
class SaidaPorDoisToques {
  SaidaPorDoisToques({this.janela = const Duration(seconds: 2)});

  /// Quanto tempo o aviso vale. O aviso aparece na tela por esta mesma duração
  /// — "armado" e "aviso visível" são a mesma coisa, de propósito: uma saída
  /// armada com a tela limpa é o jeito de sair sem querer.
  final Duration janela;

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
    _avisoEm = null;
    return DecisaoDeSaida.sair;
  }

  /// Esquece o aviso — chamado quando o voltar fez OUTRA coisa (desempilhou uma
  /// tela, trocou de aba). Sem isto, um aviso dado antes de a pessoa navegar
  /// continuaria valendo e o voltar seguinte sairia do app numa tela que não é
  /// a raiz.
  void esquecer() => _avisoEm = null;
}
