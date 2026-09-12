import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';

/// Um traço do desenho: o caminho, o peso relativo e a opacidade.
class ArchetypeStroke {
  const ArchetypeStroke(this.path, {this.weight = 1.0, this.alpha = 1.0});

  /// O caminho em unidades da caixa de [ArchetypeGlyphArt.box].
  final Path path;

  /// Multiplicador da espessura-base — é aqui que mora a compensação de peso
  /// entre um desenho denso e um de linha única.
  final double weight;

  /// Opacidade do traço sobre o acento do tema.
  final double alpha;
}

/// Um ponto cheio: pupila, miolo da flor, gota do alambique, disco da lua
/// nova. Sempre um círculo, para que a massa dele (área × opacidade) entre na
/// mesma conta dos traços.
class ArchetypeDot {
  const ArchetypeDot(this.center, this.radius, {this.alpha = 1.0});

  final Offset center;
  final double radius;
  final double alpha;
}

/// Os onze arquétipos DESENHADOS, no espírito das vinhetas de estação
/// (`season_vignette.dart`) e dos emblemas de ferramenta: traço aberto, fino,
/// no acento do tema.
///
/// Por que desenhar: o emoji do arquétipo depende da fonte do aparelho. A
/// Bruxa era uma sequência ZWJ (🧙 + ZWJ + ♀ + VS16) que se parte em dois
/// desenhos onde o sistema não sabe uni-la, e 🤱 e 🕸️ são Emoji 5/11 — no
/// piso do app (Android 7) nenhum dos dois existe. Desenho não passa por
/// fonte nenhuma e aparece igual em todo aparelho e no navegador.
///
/// O emoji NÃO sai do catálogo: ele continua sendo a chave que o conteúdo do
/// teste usa (`ArchetypeQuizOption.archetypeEmoji`) e de onde
/// `archetypeIdForEmoji` tira o id gravado no aparelho. Aqui se ACRESCENTA
/// um desenho por id; nada é substituído no dado.
///
/// ## A conta da diagramação
///
/// Os onze são autorados na MESMA caixa quadrada de [ArchetypeGlyphArt.box]
/// unidades, com [ArchetypeGlyphArt.margin] de folga que nenhum deles invade
/// (a folga real de todos é 3,0). Trocar de arquétipo não muda o tamanho
/// aparente: o maior lado da tinta de cada um fica entre 15,2 e 17,0 de 24.
///
/// O maior lado sozinho MENTE para desenho deitado, e é preciso olhar também
/// a ÁREA da tinta. O olho da Vidente media 15,6 de lado — no meio da faixa
/// dos outros dez — e ocupava 126 de área contra 227 de média, porque só
/// tinha 8 de altura: na lista ele lia como um desenho menor que o vizinho.
/// O olho e a coruja (os dois deitados) foram abertos na vertical até a área
/// dos onze ficar entre 86% e 112% da média. Quem responde por "mesmo
/// tamanho aparente" é a raiz quadrada dessa área, o lado do quadrado
/// equivalente: 14,3 a 16,3 nos onze.
///
/// O peso é igualado por MASSA DE TINTA (comprimento do traço × espessura ×
/// opacidade, mais a área dos pontos cheios), não por contagem de linhas —
/// senão a teia, que tem quase o dobro de traço do escudo, pesaria o dobro.
/// A compensação está nos multiplicadores [ArchetypeStroke.weight]: o escudo
/// (uma linha só, 45 unidades de tinta) vai a 1,45 da espessura-base; a teia
/// e a flor (79 e 82 unidades) descem a 0,78 e 0,82 e ainda perdem
/// opacidade. Com isso as onze massas ficam a no máximo 14% da média.
///
/// O centro é ÓPTICO: cada desenho foi deslocado para que o centro de massa
/// da tinta caia no meio da caixa — o chapéu, que tem a aba pesada embaixo,
/// sobe; o alambique, com o bulbo em baixo e à esquerda, sobe e anda para a
/// direita. Quando centrar pela massa jogaria a silhueta para um canto (arco
/// e flecha), o deslocamento é limitado para a caixa da tinta não derivar
/// mais que 1,2 unidade do meio.
///
/// A espessura é PROPORCIONAL ao tamanho pedido, não fixa: um traço que
/// funciona no prêmio de 56 sumiria na linha de lista. Ver
/// [ArchetypeGlyphArt.strokeWidthFor], que ainda garante um piso de 1 pixel
/// para o desenho não virar fantasma nos tamanhos pequenos.
///
/// As cores vêm de `context.gc`: `lilac` é o acento de cada uma das SEIS
/// paletas e foi escolhido com contraste contra o fundo do próprio tema —
/// inclusive o claro (Lavanda-névoa, onde ele é um roxo escuro). Nenhuma cor
/// fixa serviria aos dois lados.
class ArchetypeGlyphArt {
  const ArchetypeGlyphArt({required this.strokes, this.dots = const []});

  final List<ArchetypeStroke> strokes;
  final List<ArchetypeDot> dots;

  /// Lado da caixa quadrada normalizada em que os onze são autorados.
  static const double box = 24;

  /// Folga que nenhum desenho invade, em unidades da caixa. Contada sobre a
  /// tinta, ou seja, já incluindo a metade da espessura do traço.
  static const double margin = 2;

  /// Espessura-base do traço, em unidades da caixa, antes do multiplicador
  /// de cada desenho.
  static const double baseStroke = 1.25;

  /// Quanto da caixa a tinta ocupa (o maior lado dos onze, ~16,2 de 24).
  ///
  /// Serve para trocar um emoji por um desenho SEM mudar o tamanho aparente:
  /// o emoji preenche quase todo o corpo da fonte, então uma caixa do
  /// tamanho do `fontSize` antigo entregaria um desenho um terço menor.
  static const double inkRatio = 0.675;

  /// A caixa que faz o desenho parecer do mesmo tamanho de um emoji escrito
  /// com [fontSize].
  static double boxForEmojiSize(double fontSize) => fontSize / inkRatio;

  /// A espessura, em pixels, de um traço de peso [weight] num desenho de
  /// lado [size].
  ///
  /// Proporcional ao tamanho — é o que faz o mesmo desenho ler a 56 e a 20 —
  /// com piso de 1 pixel lógico: abaixo disso o traço some em tela de baixa
  /// densidade. O piso só entra em tamanhos bem pequenos e cabe folgado
  /// dentro da margem (a 20 de lado a margem vale 1,7 pixel e a metade do
  /// traço, 0,5).
  static double strokeWidthFor(double weight, double size) {
    final width = baseStroke * weight * size / box;
    return width < 1.0 ? 1.0 : width;
  }

  /// A tinta mínima de um traço em pixels — espessura × opacidade.
  static const double minInk = .85;

  /// A opacidade de um traço de peso [weight] e opacidade [alpha] num desenho
  /// de lado [size].
  ///
  /// O piso de [strokeWidthFor] segura a ESPESSURA, mas a opacidade passava
  /// inteira — e as duas multiplicam. O resultado é que o piso não protegia
  /// justamente quem ele existe para proteger: na linha de lista (caixa de
  /// 20,7) a coroa da lua nova chegava como 1 pixel a 55% de opacidade,
  /// contra 1,49 do escudo na linha de cima. Meia tinta, e a coroa é a única
  /// coisa que separa aquela lua de um círculo qualquer — a Rainha Sombria
  /// virava um O.
  ///
  /// Então o piso vale para a TINTA: o que a espessura não pôde dar, a
  /// opacidade dá. A hierarquia entre o traço cheio e o apagado é luxo de
  /// tamanho grande — no prêmio do teste ela passa intacta, porque lá a
  /// espessura sozinha já entrega tinta de sobra. Existir não é luxo.
  static double alphaFor(double weight, double alpha, double size) {
    final width = strokeWidthFor(weight, size);
    // A espessura nunca é menor que o piso de 1 pixel, e [minInk] é menor
    // que 1 — então o que se devolve aqui nunca passa de 1.
    return width * alpha >= minInk ? alpha : minInk / width;
  }
}

const double _c = ArchetypeGlyphArt.box / 2;

double _px(double angle, double radius) => _c + radius * math.cos(angle);
double _py(double angle, double radius) => _c + radius * math.sin(angle);

/// O desenho do arquétipo [id], ou null se o id não é de nenhum dos onze.
///
/// Null é AUSÊNCIA, não erro: quem chama cai de volta no emoji do verbete em
/// vez de mostrar um quadrado vazio. `test/archetype_glyph_test.dart` trava
/// que nenhum dos onze ids do catálogo cai nesse caminho.
ArchetypeGlyphArt? archetypeGlyphArt(String id) => _art[id];

/// Os ids que têm desenho — para o teste conferir que a lista é exatamente a
/// do catálogo, sem sobra nem falta.
Iterable<String> get archetypeGlyphIds => _art.keys;

final Map<String, ArchetypeGlyphArt> _art = {
  // A BRUXA — chapéu pontudo com uma estrela na copa.
  // A massa de um chapéu está na aba; o desenho inteiro subiu 0,48 para o
  // centro de massa cair no meio da caixa.
  'a_bruxa': ArchetypeGlyphArt(strokes: [
    ArchetypeStroke(
      Path()
        ..moveTo(4.65, 15.92)
        ..quadraticBezierTo(11.95, 18.62, 19.25, 15.92),
      weight: 1.2,
      alpha: .95,
    ),
    ArchetypeStroke(
      Path()
        ..moveTo(7.15, 15.53)
        ..quadraticBezierTo(9.45, 9.43, 12.95, 4.33)
        ..quadraticBezierTo(14.45, 9.93, 16.95, 15.53),
      weight: 1.2,
      alpha: .95,
    ),
    // A estrela é uma cintilação de dois riscos cruzados, e não uma estrela
    // de cinco pontas: a cinco pontas com 2 unidades de raio vira borrão na
    // linha de lista, onde a caixa inteira tem 20 pixels.
    ArchetypeStroke(
      Path()
        ..moveTo(11.15, 8.03)
        ..lineTo(11.15, 11.83)
        ..moveTo(9.45, 9.93)
        ..lineTo(12.85, 9.93),
      weight: 1.05,
      alpha: .9,
    ),
  ]),

  // A CURANDEIRA — ramo com duas folhas. É o desenho de menos tinta dos onze
  // (46), então é também o de traço mais grosso depois do escudo.
  'a_curandeira': ArchetypeGlyphArt(strokes: [
    ArchetypeStroke(
      Path()
        ..moveTo(10.45, 20.00)
        ..quadraticBezierTo(11.95, 14.30, 12.95, 7.60),
      weight: 1.32,
      alpha: .95,
    ),
    // As folhas nascem EM CIMA do caule: os pontos de partida são pontos da
    // própria curva do caule, não valores aproximados a olho.
    ArchetypeStroke(
      Path()
        ..moveTo(11.73, 14.54)
        ..quadraticBezierTo(6.25, 14.90, 5.45, 9.80)
        ..quadraticBezierTo(10.15, 11.50, 11.73, 14.54)
        ..close(),
      weight: 1.32,
      alpha: .95,
    ),
    ArchetypeStroke(
      Path()
        ..moveTo(12.40, 11.02)
        ..quadraticBezierTo(17.75, 11.40, 18.75, 6.40)
        ..quadraticBezierTo(13.95, 8.40, 12.40, 11.02)
        ..close(),
      weight: 1.32,
      alpha: .95,
    ),
  ]),

  // A VIDENTE — olho em amêndoa, íris e pupila. Simétrico nos dois eixos:
  // não precisou de deslocamento nenhum.
  //
  // A ABERTURA é conta, não gosto. O olho é o único desenho DEITADO dos
  // onze, e por isso o maior lado não responde por ele: com a amêndoa
  // antiga o lado media 15,6 — no meio da faixa dos outros dez — e a tinta
  // ocupava 126 de área contra 227 de média. Na lista ele lia como um
  // desenho menor que o vizinho, que é exatamente o defeito que a caixa
  // única existe para não ter. A pálpebra subiu (ponto de controle em 0,90
  // em vez de 5,30: a quadrática só vai até a metade do caminho do
  // controle, então o ápice sai em 6,45 e não em 8,65), a íris e a pupila
  // cresceram junto para o olho continuar sendo um olho, e o peso desceu de
  // 1,12 para 0,95 porque a tinta aumentou. Área agora 204 — 86% da média,
  // dentro da faixa dos outros dez.
  'a_vidente': ArchetypeGlyphArt(
    strokes: [
      ArchetypeStroke(
        Path()
          ..moveTo(4.30, 12.00)
          ..quadraticBezierTo(12.00, 0.90, 19.70, 12.00)
          ..quadraticBezierTo(12.00, 23.10, 4.30, 12.00)
          ..close(),
        weight: .95,
        alpha: .95,
      ),
      ArchetypeStroke(
        Path()
          ..addOval(Rect.fromCircle(
              center: const Offset(12.00, 12.00), radius: 3.70)),
        weight: .95,
        alpha: .95,
      ),
    ],
    dots: const [ArchetypeDot(Offset(12.00, 12.00), 1.45)],
  ),

  // A GUARDIÃ — escudo. Um contorno só, o menor número de traços dos onze:
  // por isso leva a espessura mais alta (1,45), senão pesaria metade do que
  // pesa a teia ao lado dele na mesma lista.
  'a_guardia': ArchetypeGlyphArt(strokes: [
    ArchetypeStroke(
      Path()
        ..moveTo(12.00, 5.39)
        ..lineTo(19.10, 7.99)
        ..cubicTo(19.10, 14.39, 16.00, 17.69, 12.00, 20.09)
        ..cubicTo(8.00, 17.69, 4.90, 14.39, 4.90, 7.99)
        ..close(),
      weight: 1.45,
      alpha: .95,
    ),
  ]),

  // A SÁBIA — a coruja pelas duas faces, o bico e os tufos. Sem contorno de
  // cabeça em volta: ele acrescentaria 30 unidades de tinta e empurraria o
  // peso para longe dos outros dez sem acrescentar leitura.
  //
  // Duas circunferências lado a lado dão um desenho DEITADO, e a coruja
  // caiu no mesmo buraco do olho: 192 de área contra 227 de média. Quem
  // resolve não é alargar (a largura já é 16,0, no teto dos onze) — é usar
  // a altura que sobrava. Os tufos subiram de 6,26 para 5,50 e o bico
  // desceu de 17,06 para 17,80, que é o que uma coruja tem mesmo: tufo
  // comprido e bico entre os olhos. Área 212, 90% da média; o peso desceu
  // de 0,95 para 0,86 porque tufo e bico mais longos são mais tinta.
  'a_sabia': ArchetypeGlyphArt(
    strokes: [
      ArchetypeStroke(
        Path()
          ..addOval(
              Rect.fromCircle(center: const Offset(8.60, 12.06), radius: 4.00)),
        weight: .86,
        alpha: .95,
      ),
      ArchetypeStroke(
        Path()
          ..addOval(Rect.fromCircle(
              center: const Offset(15.40, 12.06), radius: 4.00)),
        weight: .86,
        alpha: .95,
      ),
      ArchetypeStroke(
        Path()
          ..moveTo(10.85, 13.90)
          ..lineTo(12.00, 17.80)
          ..lineTo(13.15, 13.90),
        weight: .86,
        alpha: .95,
      ),
      ArchetypeStroke(
        Path()
          ..moveTo(4.90, 5.50)
          ..lineTo(6.55, 8.85)
          ..moveTo(19.10, 5.50)
          ..lineTo(17.45, 8.85),
        weight: .86,
        alpha: .9,
      ),
    ],
    dots: const [
      ArchetypeDot(Offset(8.60, 12.06), 1.00),
      ArchetypeDot(Offset(15.40, 12.06), 1.00),
    ],
  ),

  // A DONZELA — flor de cinco pétalas. Junto com a teia, o desenho de mais
  // tinta (82 unidades): traço a 0,82 da base e opacidade a 0,88 para não
  // pesar mais que o escudo de linha única.
  'a_donzela': ArchetypeGlyphArt(
    strokes: [ArchetypeStroke(_flor(), weight: .82, alpha: .88)],
    dots: const [ArchetypeDot(Offset(_c, _c), 1.15)],
  ),

  // A MÃE — a lua crescente acolhendo um círculo. A massa do crescente fica
  // toda à esquerda, então o conjunto andou 1,88 para a direita.
  'a_mae': ArchetypeGlyphArt(strokes: [
    ArchetypeStroke(
      Path()
        ..moveTo(14.48, 4.40)
        ..cubicTo(8.28, 5.60, 5.88, 8.60, 5.88, 12.00)
        ..cubicTo(5.88, 15.40, 8.28, 18.40, 14.48, 19.60)
        ..cubicTo(10.88, 17.40, 9.08, 14.90, 9.08, 12.00)
        ..cubicTo(9.08, 9.10, 10.88, 6.60, 14.48, 4.40)
        ..close(),
      weight: 1.02,
      alpha: .95,
    ),
    ArchetypeStroke(
      Path()
        ..addOval(
            Rect.fromCircle(center: const Offset(16.28, 12.00), radius: 3.30)),
      weight: 1.02,
      alpha: .95,
    ),
  ]),

  // A CAÇADORA — arco e flecha. A corda é o traço mais fino e mais apagado
  // do conjunto: é ela que, no peso cheio, puxava a massa para a esquerda e
  // empurrava a flecha contra a borda direita da caixa.
  'a_cacadora': ArchetypeGlyphArt(strokes: [
    ArchetypeStroke(
      Path()
        ..moveTo(9.93, 4.40)
        ..cubicTo(5.53, 7.40, 5.53, 16.60, 9.93, 19.60),
      weight: 1.15,
      alpha: .95,
    ),
    ArchetypeStroke(
      Path()
        ..moveTo(9.93, 4.40)
        ..lineTo(9.93, 19.60),
      weight: .95,
      alpha: .7,
    ),
    ArchetypeStroke(
      Path()
        ..moveTo(7.13, 12.00)
        ..lineTo(19.73, 12.00),
      weight: 1.2,
      alpha: .95,
    ),
    ArchetypeStroke(
      Path()
        ..moveTo(17.43, 9.70)
        ..lineTo(19.73, 12.00)
        ..lineTo(17.43, 14.30),
      weight: 1.2,
      alpha: .95,
    ),
  ]),

  // A TECELÃ — teia radial, e o caso que obrigou a conta de peso a existir.
  // Com dez raios e dois anéis fechados ela pesaria mais que o dobro do
  // escudo. São SEIS raios, um anel só (e de cordas com barriga, que é o que
  // faz a teia parecer teia), traço a 0,78 da base e opacidade menor no
  // anel. As pontas dos raios passam do anel de propósito: são os fios de
  // amarração, e é o que faz o desenho ler como teia e não como estrela.
  'a_tecela': ArchetypeGlyphArt(strokes: [
    ArchetypeStroke(_teiaRaios(), weight: .78, alpha: .85),
    ArchetypeStroke(_teiaFios(), weight: .78, alpha: .78),
  ]),

  // A ALQUIMISTA — alambique: bulbo, nível do líquido, bico recurvado e a
  // gota no fim dele.
  'a_alquimista': ArchetypeGlyphArt(
    strokes: [
      ArchetypeStroke(
        Path()
          ..addOval(
              Rect.fromCircle(center: const Offset(9.55, 13.97), radius: 4.20)),
        weight: 1.3,
        alpha: .95,
      ),
      ArchetypeStroke(
        Path()
          ..moveTo(10.65, 9.97)
          ..cubicTo(12.15, 4.77, 16.35, 4.37, 18.75, 6.57)
          ..cubicTo(20.35, 8.17, 19.85, 10.77, 19.25, 11.97),
        weight: 1.3,
        alpha: .95,
      ),
      ArchetypeStroke(
        Path()
          ..moveTo(6.05, 15.37)
          ..lineTo(13.05, 15.37),
        weight: 1.3,
        alpha: .8,
      ),
    ],
    dots: const [ArchetypeDot(Offset(19.05, 13.27), .95)],
  ),

  // A RAINHA SOMBRIA — a lua nova: o disco que não está iluminado, e o anel
  // que o faz existir.
  //
  // O disco NÃO é preto nem branco: é o próprio acento do tema a 13% de
  // opacidade. Sobre fundo escuro ele clareia de leve, sobre o fundo claro
  // da Lavanda-névoa ele escurece de leve — nos dois casos vira matéria, e
  // não buraco. Preto sumiria nas cinco paletas escuras e branco sumiria na
  // clara. A luzinha de coroa no alto à esquerda é o que separa esta lua de
  // um círculo qualquer.
  'a_rainha_sombria': ArchetypeGlyphArt(
    strokes: [
      ArchetypeStroke(
        Path()
          ..addOval(
              Rect.fromCircle(center: const Offset(12.16, 12.37), radius: 7.20)),
        alpha: .95,
      ),
      ArchetypeStroke(
        Path()
          ..moveTo(6.16, 7.37)
          ..cubicTo(7.76, 5.57, 10.06, 4.37, 12.56, 4.27),
        weight: .8,
        alpha: .55,
      ),
    ],
    dots: const [ArchetypeDot(Offset(12.16, 12.37), 6.70, alpha: .13)],
  ),
};

/// Cinco pétalas em volta do centro. Simétrica de cinco lados, então o centro
/// de massa já cai no meio da caixa sem deslocamento.
Path _flor() {
  const tip = 7.6;
  const ctrl = 4.7;
  const spread = .62;
  final path = Path();
  for (var i = 0; i < 5; i++) {
    final angle = -math.pi / 2 + i * 2 * math.pi / 5;
    path
      ..moveTo(_c, _c)
      ..quadraticBezierTo(_px(angle - spread, ctrl), _py(angle - spread, ctrl),
          _px(angle, tip), _py(angle, tip))
      ..quadraticBezierTo(
          _px(angle + spread, ctrl), _py(angle + spread, ctrl), _c, _c)
      ..close();
  }
  return path;
}

/// Os seis raios da teia, do miolo até fora do anel.
Path _teiaRaios() {
  final path = Path();
  for (var i = 0; i < 6; i++) {
    final angle = -math.pi / 2 + i * math.pi / 3;
    path
      ..moveTo(_px(angle, 1.6), _py(angle, 1.6))
      ..lineTo(_px(angle, 8.0), _py(angle, 8.0));
  }
  return path;
}

/// O anel da teia: seis cordas com barriga para dentro, e não uma
/// circunferência — fio de teia não é reto nem redondo, ele cede.
Path _teiaFios() {
  final path = Path();
  for (var i = 0; i < 6; i++) {
    final from = -math.pi / 2 + i * math.pi / 3;
    final to = from + math.pi / 3;
    final middle = (from + to) / 2;
    path
      ..moveTo(_px(from, 6.7), _py(from, 6.7))
      ..quadraticBezierTo(_px(middle, 5.3), _py(middle, 5.3), _px(to, 6.7),
          _py(to, 6.7));
  }
  return path;
}

/// O desenho do arquétipo [id] num quadrado de [size].
///
/// MUDO para o leitor de tela em todos os usos de hoje: em cada um deles o
/// nome do arquétipo está escrito ao lado (o card da lista, o cabeçalho do
/// verbete, o prêmio do teste), e é ele que fala. Anunciar o desenho também
/// faria o leitor dizer a mesma coisa duas vezes — que era, aliás, o defeito
/// do emoji: `🧙‍♀️ A Bruxa` na barra do verbete era lido como "mulher maga,
/// A Bruxa".
class ArchetypeGlyph extends StatelessWidget {
  const ArchetypeGlyph({
    super.key,
    required this.id,
    required this.size,
    this.color,
  });

  final String id;
  final double size;

  /// O acento do tema, quando nulo.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final art = archetypeGlyphArt(id);
    // Sem desenho não se inventa um: o espaço fica reservado e quem chama
    // decide o que colocar nele. Na prática nenhum id do catálogo cai aqui.
    if (art == null) return SizedBox.square(dimension: size);
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _ArchetypeGlyphPainter(
          art: art,
          color: color ?? context.gc.lilac,
        ),
      ),
    );
  }
}

class _ArchetypeGlyphPainter extends CustomPainter {
  const _ArchetypeGlyphPainter({required this.art, required this.color});

  final ArchetypeGlyphArt art;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    if (side <= 0) return;
    final scale = side / ArchetypeGlyphArt.box;
    canvas.save();
    canvas.scale(scale);
    for (final stroke in art.strokes) {
      canvas.drawPath(
        stroke.path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          // A espessura é decidida em PIXELS (é lá que existe o piso de 1) e
          // devolvida a unidades da caixa, senão a escala do canvas a
          // multiplicaria de novo.
          ..strokeWidth =
              ArchetypeGlyphArt.strokeWidthFor(stroke.weight, side) / scale
          // A opacidade também é decidida em PIXELS: quando o piso da
          // espessura não basta para o traço existir, ela devolve o resto.
          ..color = color.withValues(
            alpha: ArchetypeGlyphArt.alphaFor(
                stroke.weight, stroke.alpha, side),
          ),
      );
    }
    for (final dot in art.dots) {
      canvas.drawCircle(
        dot.center,
        dot.radius,
        Paint()
          ..style = PaintingStyle.fill
          ..color = color.withValues(alpha: dot.alpha),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ArchetypeGlyphPainter old) =>
      old.art != art || old.color != color;
}
