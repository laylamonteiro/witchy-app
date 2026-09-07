import 'dart:math';

/// A inclinação do aparelho vira balanço do pêndulo — e SÓ isso. Nada daqui
/// encosta no sorteio da resposta (ver PendulumPage).
///
/// Pipeline: amostra do acelerômetro → [PoseNeutraDoPendulo] (gira a leitura
/// para o referencial de como a pessoa segura o celular) → [normalizar]
/// (−1..1, zona morta suave)
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
    double margem = InclinacaoDoPendulo.margem,
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

/// Um vetor 3D mínimo (m/s²) — só o que a calibração da pose precisa.
class Vetor3 {
  const Vetor3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  double get norma => sqrt(x * x + y * y + z * z);

  Vetor3 get unitario {
    final n = norma;
    return n == 0 ? this : Vetor3(x / n, y / n, z / n);
  }

  double ponto(Vetor3 o) => x * o.x + y * o.y + z * o.z;

  Vetor3 cruzado(Vetor3 o) =>
      Vetor3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);

  Vetor3 vezes(double k) => Vetor3(x * k, y * k, z * k);

  Vetor3 mais(Vetor3 o) => Vetor3(x + o.x, y + o.y, z + o.z);

  @override
  String toString() => 'Vetor3($x, $y, $z)';
}

/// A pose neutra: a orientação em que a pessoa está segurando o celular.
///
/// A inclinação era "quanto da gravidade aponta para a direita da tela" (o
/// eixo x bruto do acelerômetro). Funciona com o celular deitado na mesa ou
/// em pé na mão — mas deitada de lado na cama, com o celular de frente para
/// o rosto, a gravidade JÁ aponta para a direita da tela, e o cristal ia
/// todo para lá. Aqui a leitura é girada para o referencial em que a pose de
/// quem segura o celular é o "em pé": inclinar EM RELAÇÃO a essa pose move o
/// cristal; a pose em si, não.
///
/// A referência é capturada ao abrir a página (meio segundo de leituras),
/// refeita a cada "Perguntar" (a pessoa está na pose de consulta) e, sozinha,
/// quando o celular fica numa orientação muito diferente por um tempo
/// (sentou-se na cama, deitou de lado): a corrente então balança até o novo
/// centro, como um pêndulo que se acomoda. Continua sem tocar no sorteio.
class PoseNeutraDoPendulo {
  PoseNeutraDoPendulo({
    this.tempoDeCaptura = 0.5,
    this.limiarDeNovaPose = pi / 4,
    this.esperaDaNovaPose = 1.5,
    this.alfaDaGravidade = 0.15,
  });

  /// Quanto tempo de leituras (s) antes de fixar a primeira referência.
  final double tempoDeCaptura;

  /// Ângulo (rad) entre a gravidade e a referência a partir do qual uma
  /// orientação SUSTENTADA vira pose nova. Uma inclinação deliberada de 30°
  /// fica abaixo e continua movendo o cristal.
  final double limiarDeNovaPose;

  /// Por quanto tempo (s) a orientação nova precisa se manter.
  final double esperaDaNovaPose;

  /// Passa-baixa da gravidade estimada: o tranco da mão não entra na
  /// referência (τ ≈ 0,2 s a 30 Hz).
  final double alfaDaGravidade;

  /// Leitura de um celular em pé (retrato, tela de frente): +g no eixo y.
  static const Vetor3 emPe = Vetor3(0, 1, 0);

  /// Abaixo disto a leitura não é gravidade (queda livre, sensor mudo): não
  /// serve de referência.
  static const double gravidadeMinima = InclinacaoDoPendulo.gravidade / 2;

  Vetor3? _gravidade;
  Vetor3? _referencia;
  double _tempoLendo = 0;
  double _tempoForaDaPose = 0;

  bool get calibrada => _referencia != null;

  /// A pose neutra atual (unitária), ou null antes da captura.
  Vetor3? get referencia => _referencia;

  /// Esquece tudo: a referência volta a ser capturada do zero (sensor
  /// religado, volta do segundo plano).
  void reiniciar() {
    _gravidade = null;
    _referencia = null;
    _tempoLendo = 0;
    _tempoForaDaPose = 0;
  }

  /// Fixa a pose de agora como neutra (o toque em Perguntar).
  void recalibrar() {
    final g = _gravidade;
    if (g == null || g.norma < gravidadeMinima) return;
    _referencia = g.unitario;
    _tempoForaDaPose = 0;
  }

  /// Recebe uma [leitura] do acelerômetro (m/s²) e [dt] segundos desde a
  /// anterior. Devolve a componente x (m/s²) da leitura GIRADA para o
  /// referencial da pose neutra — exatamente o que
  /// [InclinacaoDoPendulo.normalizar] espera —, ou null enquanto a
  /// referência ainda não existe (aí o pêndulo fica no centro).
  double? atualizar(Vetor3 leitura, {required double dt}) {
    final passo = dt.isFinite && dt > 0 ? min(dt, 1.0) : 0.0;
    final anterior = _gravidade;
    final gravidade = anterior == null
        ? leitura
        : anterior.vezes(1 - alfaDaGravidade).mais(
              leitura.vezes(alfaDaGravidade),
            );
    _gravidade = gravidade;

    var referencia = _referencia;
    if (referencia == null) {
      _tempoLendo += passo;
      if (_tempoLendo < tempoDeCaptura || gravidade.norma < gravidadeMinima) {
        return null;
      }
      referencia = _referencia = gravidade.unitario;
    } else if (gravidade.norma >= gravidadeMinima) {
      final angulo = acos(
        gravidade.unitario.ponto(referencia).clamp(-1.0, 1.0),
      );
      if (angulo > limiarDeNovaPose) {
        _tempoForaDaPose += passo;
        if (_tempoForaDaPose >= esperaDaNovaPose) {
          referencia = _referencia = gravidade.unitario;
          _tempoForaDaPose = 0;
        }
      } else {
        _tempoForaDaPose = 0;
      }
    }
    return girar(leitura, de: referencia, para: emPe).x;
  }

  /// A rotação mínima que leva [de] a [para] (ambos tratados como unitários),
  /// aplicada a [v] — fórmula de Rodrigues. Com [de] exatamente oposto a
  /// [para] (celular de cabeça para baixo como pose neutra) a rotação mínima
  /// é ambígua: gira meia-volta em torno de z, o eixo da tela — é o limite
  /// das poses vizinhas (todas em pé, giradas no plano da tela), então não há
  /// salto ao passar por ela.
  static Vetor3 girar(Vetor3 v, {required Vetor3 de, required Vetor3 para}) {
    final a = de.unitario;
    final b = para.unitario;
    final eixo = a.cruzado(b);
    final seno = eixo.norma;
    final cosseno = a.ponto(b);
    if (seno < 1e-6) {
      if (cosseno >= 0) return v;
      return Vetor3(-v.x, -v.y, v.z);
    }
    final k = eixo.vezes(1 / seno);
    return v
        .vezes(cosseno)
        .mais(k.cruzado(v).vezes(seno))
        .mais(k.vezes(k.ponto(v) * (1 - cosseno)));
  }
}
