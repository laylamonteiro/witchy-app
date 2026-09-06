import 'dart:math';

/// A inclinação do aparelho vira balanço do pêndulo — e SÓ isso. Nada daqui
/// encosta no sorteio da resposta (ver PendulumPage).
///
/// Pipeline: amostra do acelerômetro → [normalizar] (−1..1, zona morta suave)
/// → [FiltroDeInclinacao] (tira o ruído do sensor) → alvo da [MolaDoPendulo]
/// (a corrente: passa do alvo, volta, assenta) → [angulo] (θ vira radianos,
/// com um teto que depende da largura da área para a PONTA do cristal nunca
/// sair do card).
///
/// Tudo puro e sem Flutter, de propósito: o que decide se o cristal sai da
/// tela é aritmética, e aritmética se prova em teste de unidade.
class InclinacaoDoPendulo {
  const InclinacaoDoPendulo._();

  static const double gravidade = 9.80665;

  /// sin(30°): com ~30° de rolagem o pêndulo já está no limite. Antes o fundo
  /// de escala era 1 g (90°), e a mão nunca chegava lá. Uma constante só,
  /// para afinar a sensibilidade.
  static const double escalaCheia = 0.5;

  /// Abaixo disto é mão parada: nada de tremor no repouso.
  static const double zonaMorta = 0.02;

  /// Curvatura da saturação: ~1,7 de ganho perto do zero e chegada
  /// assintótica às bordas.
  static const double curvaDaSaturacao = 1.6;

  /// Teto em repouso (rad), para áreas largas onde a borda não limita.
  static const double tetoEmRepouso = 1.1;

  /// Teto amortecido (rad): consultando e com a resposta na tela, a
  /// inclinação só dá um sopro — o cristal precisa pousar/apontar no rótulo.
  /// É um ângulo ABSOLUTO (o valor de repouso que o pêndulo já tinha), não
  /// uma fração do máximo: a distância da ponta ao rótulo não pode depender
  /// da largura da tela.
  static const double tetoAmortecido = 0.12;

  /// Folga entre o cristal e a borda da área (px).
  static const double margem = 8;

  /// Componente x do acelerômetro (m/s², gravidade + tranco da mão) → −1..1.
  static double normalizar(double ax) {
    final t = (-ax / gravidade / escalaCheia).clamp(-1.0, 1.0);
    if (t.abs() <= zonaMorta) return 0;
    // Contínua na borda da zona morta: sem degrau ao começar a inclinar.
    return t.sign * (t.abs() - zonaMorta) / (1 - zonaMorta);
  }

  /// tanh(k·t)/tanh(k), com t preso a ±1: o overshoot da mola achata contra
  /// a borda em vez de sair da área, e o limite é exato.
  static double saturar(double t) =>
      _tanh(curvaDaSaturacao * t.clamp(-1.0, 1.0)) / _tanh(curvaDaSaturacao);

  /// Maior ângulo (rad) em que a PONTA do cristal ([raioDaPonta] a partir da
  /// fixação, mais meia largura do cristal e a [margem]) ainda cabe na área.
  static double anguloMaximo({
    required double larguraDaArea,
    required double raioDaPonta,
    required double larguraDoCristal,
    double margem = margem,
    double teto = tetoEmRepouso,
  }) {
    final alcance = larguraDaArea / 2 - larguraDoCristal / 2 - margem;
    if (alcance <= 0 || raioDaPonta <= 0) return 0;
    return min(teto, asin(min(1.0, alcance / raioDaPonta)));
  }

  /// θ da mola (unidades normalizadas) → ângulo em radianos.
  static double angulo(double theta, {required double anguloMaximo}) =>
      anguloMaximo * saturar(theta);

  static double _tanh(double x) {
    final e = exp(2 * x);
    return (e - 1) / (e + 1);
  }
}

/// Passa-baixa leve sobre a amostra normalizada. Só tira o ruído do sensor:
/// quem suaviza o movimento de verdade é a [MolaDoPendulo].
class FiltroDeInclinacao {
  FiltroDeInclinacao({this.alfa = 0.35});

  final double alfa;
  double _valor = 0;

  double get valor => _valor;

  double atualizar(double amostra) {
    _valor = _valor * (1 - alfa) + amostra * alfa;
    return _valor;
  }

  void zerar() => _valor = 0;
}

/// A corrente: um oscilador amortecido que persegue o alvo (a inclinação).
///
/// Um safanão da mão vira pico no acelerômetro → salto do alvo → o cristal
/// passa do ponto, volta e assenta, como uma correntinha de verdade. Com
/// ζ ≈ 0,25 o pico passa ~44 % do alvo e o pouso leva ~2 s.
class MolaDoPendulo {
  MolaDoPendulo({double frequenciaNatural = 7.0, double amortecimento = 0.25})
      : _k = frequenciaNatural * frequenciaNatural,
        _c = 2 * amortecimento * frequenciaNatural;

  final double _k;
  final double _c;
  double _theta = 0;
  double _omega = 0;

  /// Posição (unidades normalizadas; passa de ±1 no overshoot).
  double get theta => _theta;

  /// Velocidade angular.
  double get omega => _omega;

  /// Maior passo de integração (s). Quadros longos são fatiados para o
  /// integrador não disparar depois de uma pausa; um quadro absurdo (volta
  /// do segundo plano) é cortado em 1 s — a mola só precisa ter assentado.
  static const double passoMaximo = 0.05;
  static const double quadroMaximo = 1.0;

  /// Avança [dt] segundos rumo a [alvo] e devolve a nova posição.
  double avancar(double dt, double alvo) {
    var restante = dt.isFinite && dt > 0 ? min(dt, quadroMaximo) : 0.0;
    while (restante > 0) {
      final passo = min(passoMaximo, restante);
      restante -= passo;
      // Euler semi-implícito (velocidade antes da posição): estável e sem
      // ganhar energia do nada com estes passos.
      _omega += (-_k * (_theta - alvo) - _c * _omega) * passo;
      _theta += _omega * passo;
    }
    return _theta;
  }

  /// Assentou no alvo (posição e velocidade dentro da tolerância)?
  bool emRepousoEm(double alvo, {double tolerancia = 0.002}) =>
      (_theta - alvo).abs() < tolerancia && _omega.abs() < tolerancia * 10;

  void zerar() {
    _theta = 0;
    _omega = 0;
  }
}
