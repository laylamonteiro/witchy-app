import 'dart:math';
import 'dart:ui' show Offset;

/// A órbita do cristal: um pêndulo CÔNICO visto de pouco acima.
///
/// Antes, o cristal ia de um lado para o outro num plano só — e o olho lia um
/// leque, não um pêndulo. Aqui a corda descreve um cone em torno da vertical:
/// a cada volta o peso passa pela frente, pelo lado, pelo fundo e pelo outro
/// lado. Projetado, ele percorre uma ELIPSE, que é como um círculo aparece
/// para quem olha de cima — e é isso que o olho lê como "está girando".
///
/// A projeção é uma câmera ortográfica de verdade: a cena inteira é inclinada
/// em torno do eixo horizontal, o que encolhe a altura por `cos(alfa)` na
/// mesma medida em que joga a profundidade para dentro dela. Escrever só o
/// achatamento, sem a compressão que vem junto, faria a corrente APARENTAR
/// ESTICAR uns 3% em parte da volta — e corrente que estica é a única coisa
/// que denuncia na hora que aquilo não é um pêndulo.
///
/// Como a inclinação da câmera nasce e morre junto com a órbita, assentar
/// devolve exatamente o arco de sempre. Ver [projetar].
///
/// Tudo puro e sem Flutter, como `InclinacaoDoPendulo` — o que decide se o
/// cristal sai da tela é aritmética, e aritmética se prova em teste de unidade.
class OrbitaDoPendulo {
  const OrbitaDoPendulo._();

  /// Meia-abertura do cone (rad). É a MESMA amplitude do balanço planar de
  /// antes: no extremo lateral a ponta alcança exatamente o ponto de sempre,
  /// então nada passa a sair do card que já não saísse.
  static const double abertura = 0.6;

  /// Quanto a câmera está acima da cena: `sin(alfa)`. Vira a razão
  /// altura/largura da elipse. 0,30 é olhar de uns 17° de cima — o ponto de
  /// vista que a cena já sugere, com a fixação lá no alto.
  static const double achatamento = 0.30;

  /// Perto/longe no tamanho do cristal: na frente da órbita ele cresce, ao
  /// fundo encolhe. É o que vende a profundidade sem precisar de sombra.
  static const double relevo = 0.06;

  /// Onde o peso está, para que lado a ponta aponta e de que tamanho o cristal
  /// aparece.
  ///
  /// [fase] é a volta em radianos, sempre no mesmo sentido — um círculo não
  /// volta atrás. Em 0 e π o peso está nos extremos laterais (onde o balanço
  /// antigo chegava); em π/2 está na frente, mais baixo e maior; em 3π/2 está
  /// ao fundo, mais alto e menor.
  ///
  /// [envelope] é quanto da órbita ainda resta: 1 enquanto o pêndulo procura,
  /// 0 quando assentou. [anguloNoPlano] é o que não vem da órbita — o alvo da
  /// resposta e a inclinação do aparelho.
  ///
  /// Com [envelope] em 0 o cone fecha, a câmera desinclina e o resultado é,
  /// termo a termo, o arco simples de sempre:
  /// `peso = fixacao + (sin θ, cos θ)·corda` e `anguloAparente = θ`. É o que
  /// garante que o cristal assentado aponte EXATAMENTE para o rótulo da
  /// resposta, e não aproximadamente.
  static ProjecaoDaOrbita projetar({
    required Offset fixacao,
    required double corda,
    required double fase,
    required double envelope,
    required double anguloNoPlano,
  }) {
    // O cone abre com a órbita e fecha com ela.
    final meiaAbertura = abertura * envelope;
    final raio = sin(meiaAbertura);
    // A câmera sobe junto: `sin(alfa)` é o achatamento, e `cos(alfa)` é a
    // compressão vertical que vem no mesmo pacote. Sem as duas, a projeção
    // deixa de ser rígida e a corrente estica.
    final seno = achatamento * envelope;
    final cosseno = sqrt(1 - seno * seno);

    // A direção da corda no espaço, com y para baixo e z para dentro da tela.
    final x = raio * cos(fase);
    final y = cos(meiaAbertura);
    final z = raio * sin(fase);
    // Girada no plano da tela pelo que não é órbita (alvo + inclinação). A
    // convenção é a do resto do pêndulo: 0 é reto para baixo.
    final giroX = x * cos(anguloNoPlano) + y * sin(anguloNoPlano);
    final giroY = -x * sin(anguloNoPlano) + y * cos(anguloNoPlano);

    final peso = Offset(
      fixacao.dx + giroX * corda,
      fixacao.dy + (giroY * cosseno + z * seno) * corda,
    );
    return ProjecaoDaOrbita(
      peso: peso,
      // O cristal segue a corrente DESENHADA, não a abertura do cone: durante
      // a volta os dois divergem, e no quarto de volta a diferença já vira
      // quase 10 px de cristal descolado do fio, lá na ponta.
      anguloAparente: atan2(peso.dx - fixacao.dx, peso.dy - fixacao.dy),
      escala: 1 + relevo * sin(fase) * envelope,
    );
  }
}

/// O que [OrbitaDoPendulo.projetar] devolve: onde desenhar o peso, para onde
/// virar o cristal e de que tamanho.
class ProjecaoDaOrbita {
  const ProjecaoDaOrbita({
    required this.peso,
    required this.anguloAparente,
    required this.escala,
  });

  /// Centro do peso na área de desenho.
  final Offset peso;

  /// Direção da corrente na tela (rad), na mesma convenção do resto do
  /// pêndulo: 0 é reto para baixo, negativo para a esquerda.
  final double anguloAparente;

  /// Fator de tamanho do cristal, 1 quando ele está na distância de repouso.
  final double escala;
}
