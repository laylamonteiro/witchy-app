import 'package:flutter/material.dart';

/// As vinte e quatro runas do Futhark Antigo DESENHADAS, traço a traço.
///
/// ## Por que desenhar
///
/// Cada runa do catálogo é um caractere do bloco Runic do Unicode (ᚠ, ᚢ,
/// ᚦ…) — o MESMO bloco que já dava quadradinho vazio nos emblemas das
/// ferramentas e que, por isso, virou desenho em agosto. Fonte com o bloco
/// Runic é raridade em aparelho Android e em navegador: onde ela não existe,
/// a pedra da mesa chegava com um retângulo no lugar da runa, e a mesa
/// inteira ficava ilegível. Desenho não passa por fonte nenhuma.
///
/// ## A chave é o NOME, nunca o caractere
///
/// O catálogo (`runes_data_pt/en/es.dart`) diz que `name` e `symbol` são
/// invariantes entre idiomas, e `name` é o que este mapa usa. Usar o
/// caractere como chave seria pedir ao aparelho justamente aquilo que pode
/// faltar nele; o nome é texto ASCII e existe em qualquer lugar.
///
/// ## Por que só reta
///
/// As runas do Futhark Antigo não têm uma curva sequer, e isso não é
/// estilo: elas foram feitas para ser ENTALHADAS em madeira e em pedra, com
/// faca. Curva não se entalha contra o veio da madeira, e traço paralelo ao
/// veio some — daí não haver nenhuma horizontal pura em nenhuma das vinte e
/// quatro. Cada desenho aqui é uma polilinha de segmentos retos, e nada
/// mais.
///
/// ## A conta da diagramação
///
/// As vinte e quatro são autoradas na MESMA caixa normalizada (0..1 nos dois
/// eixos), e as três medidas que fazem uma mesa de runas parecer uma mesa só
/// foram igualadas de propósito:
///
/// * **Altura**: TODAS ocupam exatamente de 0,08 a 0,92 — extensão vertical
///   0,84 sem exceção. Era o defeito mais fácil de cometer: Kenaz (`<`) e
///   Gebo (`X`) "querem" ser menores que uma runa com haste, e Ingwaz
///   (losango) quer ser um selo no meio da caixa. Na lista, onde as vinte e
///   quatro aparecem lado a lado, uma delas mais baixa lê como erro de
///   render, não como letra diferente.
/// * **Centro horizontal**: o meio da CAIXA de tinta — a menor moldura que
///   contém os pontos — cai em 0,50 ± 0,01. É a moldura, e não o centro de
///   massa do traço: nove das vinte e quatro são haste à esquerda com tudo o
///   mais pendurado à direita, e o centro de massa de Fehu, por exemplo,
///   está em 0,40. Centrar por ele empurraria a haste de Fehu para a
///   direita e quebraria a coluna de hastes que a lista alinha sozinha.
/// * **Margem**: os 0,08 de folga existem PARA o traço, não contra ele. O
///   remate redondo avança meia espessura além do ponto final — 0,057 no
///   pior caso, Isa, a mais grossa — e come 0,057 dos 0,08. O que fica
///   travado é que ainda sobram 0,023 e nenhuma runa VAZA da caixa: tinta
///   fora da caixa apareceria cortada dentro da pedra da mesa.
///
/// A ESPESSURA é o ponto delicado, e aqui a conta diverge de propósito da do
/// `archetype_glyph.dart`. Lá, onze desenhos figurativos independentes são
/// igualados por MASSA DE TINTA (comprimento × espessura), porque nada
/// obriga a coruja e o escudo a terem o mesmo peso de caneta. Runa é
/// ALFABETO: foram cortadas com a mesma faca, e igualar massa aqui daria a
/// Isa — um risco vertical só, 0,84 de tinta — uma espessura 4,4 vezes a de
/// Dagaz (3,70 de tinta, quatro traços), ou seja, uma barra gorda ao lado de
/// um rendilhado. Seriam duas ferramentas diferentes escrevendo a mesma
/// linha.
///
/// A compensação é então AMORTECIDA: o multiplicador de cada runa é
/// `(tinta média / tinta dela) ^ 0,30`, preso entre 0,86 e 1,20. Com
/// expoente 1 seria a igualação total (errada, pelo motivo acima); com 0
/// seria caneta rigorosamente fixa, e aí Isa chegaria à lista com 45% da
/// tinta da vizinha e leria como um traço esquecido. Em 0,30 a espessura
/// varia no máximo 40% entre os extremos — o bastante para Isa existir e
/// para Dagaz não borrar, e pouco o bastante para as vinte e quatro
/// continuarem parecendo saídas da mesma mão. Os multiplicadores estão em
/// [RuneArt.weight], um por runa, com a tinta medida ao lado.
///
/// ## Remate do traço
///
/// [StrokeCap.round] e [StrokeJoin.round], como no emblema da ferramenta
/// (`tool_emblem_art.dart`) e nos arquétipos. O remate reto seria o mais
/// fiel à faca, mas os tamanhos reais do app são pequenos — 76 na lista, 60
/// no chip do painel — e ali o canto quadrado engorda as pontas livres
/// (as duas antenas de Fehu, o ápice de Tiwaz) até virarem borrão, enquanto
/// o remate redondo mantém a ponta limpa. O redondo avança meia espessura
/// além do ponto final, e essa folga já está contada na margem de 0,08.
class RuneArt {
  RuneArt({required this.strokes, this.weight = 1.0});

  /// Os traços, cada um uma polilinha em unidades da caixa normalizada.
  ///
  /// Quando o primeiro e o último ponto coincidem (só Ingwaz, o losango), o
  /// caminho é fechado com `close()` em vez de repetir o ponto: com dois
  /// remates redondos sobrepostos, o vértice de cima do losango ganhava um
  /// calombo que nenhum dos outros vértices tinha.
  final List<List<Offset>> strokes;

  /// Multiplicador da espessura-base desta runa. Ver a conta acima.
  final double weight;

  /// O caminho pronto, em unidades da caixa. Construído uma vez: o mapa de
  /// desenhos vive enquanto o app vive, e refazer o `Path` a cada quadro de
  /// uma mesa de 24 pedras é trabalho jogado fora.
  late final Path path = _buildPath();

  Path _buildPath() {
    final path = Path();
    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      final fechado = stroke.length > 2 && stroke.first == stroke.last;
      final pontos = fechado ? stroke.sublist(0, stroke.length - 1) : stroke;
      path.moveTo(pontos.first.dx, pontos.first.dy);
      for (final p in pontos.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      if (fechado) path.close();
    }
    return path;
  }

  /// Espessura-base do traço, em unidades da caixa, antes do multiplicador.
  static const double baseStroke = 0.095;

  /// Quanto da caixa a tinta ocupa na vertical — as vinte e quatro vão de
  /// 0,08 a 0,92.
  static const double inkRatio = 0.84;

  /// Altura de maiúscula de uma fonte, como fração do corpo dela.
  ///
  /// Aproximação: a fonte que renderiza o bloco Runic muda de aparelho para
  /// aparelho (quando existe). Serve só para uma coisa — fazer o desenho
  /// chegar do MESMO tamanho aparente que o caractere que ele substitui, de
  /// modo que nenhuma das quatro telas precise reajustar número nenhum.
  static const double _capHeight = 0.70;

  /// A caixa de desenho que iguala, em tamanho aparente, um caractere
  /// escrito com [fontSize].
  static double boxForFontSize(double fontSize) =>
      fontSize * _capHeight / inkRatio;

  /// A espessura em pixels de um desenho de peso [weight] numa caixa de lado
  /// [box], com piso de 1 pixel lógico — abaixo disso o traço vira fantasma
  /// em tela de baixa densidade.
  static double strokeWidthFor(double weight, double box) {
    final width = baseStroke * weight * box;
    return width < 1.0 ? 1.0 : width;
  }
}

/// O desenho da runa de nome [name], ou null se este arquivo não a conhece.
///
/// Null é AUSÊNCIA, não erro: quem chama volta a escrever o caractere do
/// catálogo (ver [RuneMark]), para que a runa nunca suma da tela — nem
/// quando um catálogo futuro trouxer um nome que ninguém desenhou ainda.
/// `test/rune_art_test.dart` trava que nenhuma das vinte e quatro do
/// catálogo de hoje cai nesse caminho, varrendo o catálogo e não uma lista
/// copiada à mão.
RuneArt? runeArtFor(String name) => _art[name];

/// Os nomes que têm desenho — para o teste conferir que o conjunto é
/// exatamente o do catálogo, sem sobra nem falta.
Iterable<String> get runeArtNames => _art.keys;

/// As vinte e quatro, na ordem do Futhark. A tinta anotada em cada uma é o
/// comprimento total dos segmentos em unidades da caixa; é dela que sai o
/// multiplicador de espessura.
final Map<String, RuneArt> _art = {
  // FEHU ᚠ — o gado. Haste e duas antenas subindo para a direita.
  // Tinta 1,68.
  'Fehu': RuneArt(weight: 1.04, strokes: const [
    [Offset(.30, .08), Offset(.30, .92)],
    [Offset(.30, .26), Offset(.68, .08)],
    [Offset(.30, .52), Offset(.68, .34)],
  ]),

  // URUZ ᚢ — o auroque. Haste esquerda inteira, o ombro descendo para a
  // direita e a perna direita até a base. Tinta 1,93.
  'Uruz': RuneArt(weight: 1.00, strokes: const [
    [Offset(.28, .92), Offset(.28, .08), Offset(.70, .30), Offset(.70, .92)],
  ]),

  // THURISAZ ᚦ — o espinho. Haste e o espinho triangular na metade DE CIMA:
  // ele nasce logo abaixo do topo e fecha acima do meio da haste. É isso que
  // o separa de Wunjo, cuja bandeirola sai da ponta da haste e é menor.
  // Tinta 1,75.
  'Thurisaz': RuneArt(weight: 1.03, strokes: const [
    [Offset(.30, .08), Offset(.30, .92)],
    [Offset(.30, .14), Offset(.70, .36), Offset(.30, .58)],
  ]),

  // ANSUZ ᚨ — a boca do deus. Haste e dois braços DESCENDO para a direita —
  // é só isso que a separa de Fehu, cujos braços sobem. Tinta 1,70.
  'Ansuz': RuneArt(weight: 1.04, strokes: const [
    [Offset(.30, .08), Offset(.30, .92)],
    [Offset(.30, .10), Offset(.68, .30)],
    [Offset(.30, .38), Offset(.68, .58)],
  ]),

  // RAIDHO ᚱ — a cavalgada. Haste, o ombro que volta à haste e a perna.
  // Tinta 2,29.
  //
  // DESENHADA DUAS VEZES no app, e de propósito: o emblema da ferramenta
  // Runas, em `lib/core/tools/tool_emblem_art.dart`, tem esta mesma forma.
  // Quem corrigir uma NÃO precisa sincronizar a outra. Lá ela é uma
  // marca sozinha, ao lado do pentagrama e do pêndulo, e a espessura dela
  // (0,10 da caixa) foi acertada contra esses dois; aqui ela é uma LETRA
  // entre vinte e três outras, e a espessura sai da compensação de tinta do
  // alfabeto (0,095 × 0,95 = 0,090). Unificar economizaria quatro pontos e
  // passaria a mexer no cartão da ferramenta toda vez que o alfabeto fosse
  // reequilibrado — caro pelo que se ganha.
  //
  // E elas APARECEM juntas, ao contrário do que esta nota dizia antes: o
  // cabeçalho da mesa de runas carrega o emblema da ferramenta o tempo
  // todo, e basta Raidho cair na tiragem para a letra ficar na pedra logo
  // abaixo dele. Nem por isso a diferença se lê. Nada ali convida a
  // comparar — o emblema tem 22 de lado e é lilás sobre a barra; a letra
  // chega bem maior, em ouro, entalhada numa pedra —, e os pontos que
  // separam os dois traçados (0,01 no ombro e na volta, 0,03 no pé da
  // perna) valem no máximo um TERÇO da espessura do próprio traço. Essa
  // razão não muda com o tamanho: não há tela em que a diferença cresça.
  'Raidho': RuneArt(weight: 0.95, strokes: const [
    [Offset(.30, .08), Offset(.30, .92)],
    [Offset(.30, .08), Offset(.68, .28), Offset(.30, .48), Offset(.70, .92)],
  ]),

  // KENAZ ᚲ — a tocha. Um ângulo só, aberto para a direita. Tinta 1,19: das
  // de pouca tinta, daí o traço grosso.
  'Kenaz': RuneArt(weight: 1.15, strokes: const [
    [Offset(.70, .08), Offset(.28, .50), Offset(.70, .92)],
  ]),

  // GEBO ᚷ — a dádiva. Um X, as duas diagonais inteiras. Tinta 2,06.
  'Gebo': RuneArt(weight: 0.98, strokes: const [
    [Offset(.20, .08), Offset(.80, .92)],
    [Offset(.80, .08), Offset(.20, .92)],
  ]),

  // WUNJO ᚹ — a alegria. Haste e a bandeirola triangular fechada no TOPO.
  // Tinta 1,73.
  'Wunjo': RuneArt(weight: 1.03, strokes: const [
    [Offset(.30, .08), Offset(.30, .92)],
    [Offset(.30, .08), Offset(.70, .28), Offset(.30, .46)],
  ]),

  // HAGALAZ ᚺ — o granizo. Duas hastes e a travessa INCLINADA entre elas.
  // A travessa é inclinada de propósito: horizontal pura não se entalha na
  // madeira, e nenhuma das vinte e quatro tem uma. Tinta 2,31.
  'Hagalaz': RuneArt(weight: 0.94, strokes: const [
    [Offset(.22, .08), Offset(.22, .92)],
    [Offset(.78, .08), Offset(.78, .92)],
    [Offset(.22, .36), Offset(.78, .64)],
  ]),

  // NAUTHIZ ᚾ — a necessidade. Uma haste e uma barra que a ATRAVESSA na
  // diagonal, sobrando dos dois lados. Tinta 1,45.
  'Nauthiz': RuneArt(weight: 1.09, strokes: const [
    [Offset(.50, .08), Offset(.50, .92)],
    [Offset(.24, .66), Offset(.76, .34)],
  ]),

  // ISA ᛁ — o gelo. UM traço vertical, e nada mais. É a runa de menos tinta
  // das vinte e quatro (0,84, metade da média) e por isso a de traço mais
  // grosso: no teto de 1,20 da compensação.
  'Isa': RuneArt(weight: 1.20, strokes: const [
    [Offset(.50, .08), Offset(.50, .92)],
  ]),

  // JERA ᛃ — a colheita, o ano que fecha. DOIS ganchos separados, encaixados
  // na diagonal: o de cima ocupa a metade esquerda com o bico virado para a
  // direita, o de baixo a metade direita com o bico virado para a esquerda.
  // Eles se encaram sem se tocar — o vão mais estreito entre os dois é de
  // 0,216 da caixa, que com as duas meias-espessuras ainda deixa 0,117 de
  // ar. É esse vão que faz a runa, e fechá-lo não daria outra runa: daria
  // um nó de quatro braços saindo de um ponto só, uma ampulheta deitada.
  // Nem Gebo, que é o X de duas diagonais inteiras, nem Ingwaz, que é o
  // losango fechado — e no tamanho da lista leria como borrão. Tinta 1,69.
  'Jera': RuneArt(weight: 1.04, strokes: const [
    [Offset(.26, .08), Offset(.62, .30), Offset(.26, .52)],
    [Offset(.74, .48), Offset(.38, .70), Offset(.74, .92)],
  ]),

  // EIHWAZ ᛇ — o teixo. Haste com um gancho CURTO para cima à direita e
  // outro para baixo à esquerda. Não confundir com Perthro, que é um copo
  // aberto; aqui os ganchos saem das DUAS pontas da haste, em sentidos
  // opostos. Tinta 1,16.
  'Eihwaz': RuneArt(weight: 1.16, strokes: const [
    [Offset(.50, .18), Offset(.50, .82)],
    [Offset(.50, .18), Offset(.74, .08)],
    [Offset(.50, .82), Offset(.26, .92)],
  ]),

  // PERTHRO ᛈ — o copo de sortes. Um caminho só, aberto para a DIREITA:
  // braço de cima, lombada vertical, braço de baixo. A lombada é longa e os
  // braços curtos — um copo alto, não uma taça aberta. Não confundir com
  // Eihwaz. Tinta 1,31.
  'Perthro': RuneArt(weight: 1.12, strokes: const [
    [Offset(.68, .08), Offset(.32, .24), Offset(.32, .76), Offset(.68, .92)],
  ]),

  // ALGIZ ᛉ — o alce, a proteção. Haste inteira e dois braços que sobem e
  // abrem a partir do meio dela. Tinta 1,90 — a média das vinte e quatro,
  // por isso o peso dela é 1,00.
  'Algiz': RuneArt(weight: 1.00, strokes: const [
    [Offset(.50, .08), Offset(.50, .92)],
    [Offset(.18, .10), Offset(.50, .52), Offset(.82, .10)],
  ]),

  // SOWILO ᛊ — o sol. Um raio de três segmentos iguais, cada um descendo um
  // terço da caixa: é o zigue-zague regular, sem um lance mais longo que os
  // outros. Tinta 1,40.
  'Sowilo': RuneArt(weight: 1.10, strokes: const [
    [Offset(.70, .08), Offset(.32, .36), Offset(.68, .64), Offset(.30, .92)],
  ]),

  // TIWAZ ᛏ — o deus Týr, a flecha. Haste inteira e a ponta em Λ no topo.
  // Tinta 1,63.
  'Tiwaz': RuneArt(weight: 1.05, strokes: const [
    [Offset(.50, .08), Offset(.50, .92)],
    [Offset(.22, .36), Offset(.50, .08), Offset(.78, .36)],
  ]),

  // BERKANO ᛒ — a bétula. Haste e DOIS triângulos empilhados à direita, que
  // se encostam no MEIO da haste. O meio de 0,08 a 0,92 é 0,50, e o encaixe
  // estava em 0,46, com os ápices em 0,68 e 0,70: o bojo de baixo saía 21%
  // mais alto e 0,02 mais largo que o de cima, e a runa chegava à lista como
  // um B torto — não é tradição nenhuma, era o desenho discordando do
  // próprio comentário. Os dois bojos agora são congruentes. Tinta 2,65.
  'Berkano': RuneArt(weight: 0.91, strokes: const [
    [Offset(.30, .08), Offset(.30, .92)],
    [Offset(.30, .08), Offset(.70, .29), Offset(.30, .50)],
    [Offset(.30, .50), Offset(.70, .71), Offset(.30, .92)],
  ]),

  // EHWAZ ᛖ — o cavalo. Duas hastes e um V entre elas, descendo do topo de
  // uma ao topo da outra: a letra M. Tinta 2,60.
  'Ehwaz': RuneArt(weight: 0.91, strokes: const [
    [Offset(.24, .08), Offset(.24, .92)],
    [Offset(.76, .08), Offset(.76, .92)],
    [Offset(.24, .08), Offset(.50, .46), Offset(.76, .08)],
  ]),

  // MANNAZ ᛗ — o humano. Duas hastes e um X entre elas, do topo de cada uma
  // até a metade da outra. É o que a separa de Ehwaz: lá as diagonais se
  // encontram embaixo sem cruzar, aqui elas se CRUZAM. Tinta 3,08.
  'Mannaz': RuneArt(weight: 0.87, strokes: const [
    [Offset(.22, .08), Offset(.22, .92)],
    [Offset(.78, .08), Offset(.78, .92)],
    [Offset(.22, .08), Offset(.78, .50)],
    [Offset(.78, .08), Offset(.22, .50)],
  ]),

  // LAGUZ ᛚ — a água. Haste e UM braço descendo do topo para a direita —
  // Ansuz com um braço só. Tinta 1,26.
  'Laguz': RuneArt(weight: 1.13, strokes: const [
    [Offset(.32, .08), Offset(.32, .92)],
    [Offset(.32, .08), Offset(.68, .30)],
  ]),

  // INGWAZ ᛜ — o deus Ing. Um LOSANGO fechado, e só. Tinta 2,11.
  'Ingwaz': RuneArt(weight: 0.97, strokes: const [
    [
      Offset(.50, .08),
      Offset(.82, .50),
      Offset(.50, .92),
      Offset(.18, .50),
      Offset(.50, .08),
    ],
  ]),

  // DAGAZ ᛞ — o dia. Duas hastes e as duas diagonais cruzadas entre elas:
  // uma ampulheta DEITADA presa entre dois postes. É a runa de mais tinta
  // das vinte e quatro (3,70) e por isso a de traço mais fino, no piso de
  // 0,86 da compensação.
  'Dagaz': RuneArt(weight: 0.86, strokes: const [
    [Offset(.22, .08), Offset(.22, .92)],
    [Offset(.78, .08), Offset(.78, .92)],
    [Offset(.22, .08), Offset(.78, .92)],
    [Offset(.22, .92), Offset(.78, .08)],
  ]),

  // OTHALA ᛟ — a herança, a terra do clã. Losango com duas pernas abertas.
  // As pernas não são pauzinhos colados embaixo: são DUAS RETAS INTEIRAS,
  // cada uma saindo de um vértice lateral do losango e indo até o pé oposto,
  // e é o cruzamento delas em (0,50; 0,63) que FAZ o vértice de baixo. Dito
  // de outro jeito: cada perna é a continuação reta do lado de baixo OPOSTO
  // do losango. É isso que dá o pé aberto, em vez de um losango com dois
  // riscos pendurados. Tinta 2,38.
  'Othala': RuneArt(weight: 0.94, strokes: const [
    [Offset(.22, .34), Offset(.50, .08), Offset(.78, .34)],
    [Offset(.22, .34), Offset(.78, .92)],
    [Offset(.78, .34), Offset(.22, .92)],
  ]),
};

/// A runa na tela: o desenho quando existe, o caractere do catálogo quando
/// não existe.
///
/// Esta é a RESERVA HONESTA, e ela mora num lugar só para que as quatro
/// telas não tenham quatro versões dela. Um nome que [runeArtFor] não
/// conheça — um catálogo futuro com uma runa nova, um Futhark mais jovem —
/// continua chegando ao olho como o caractere de sempre: pode virar
/// quadradinho no aparelho sem a fonte, mas nunca vira NADA.
///
/// [fontSize] é o corpo que o caractere teria, e não o lado do desenho: é o
/// número que cada tela já usava. [RuneArt.boxForFontSize] converte, de
/// modo que trocar escrita por desenho não mexeu em nenhuma medida das
/// telas.
///
/// [halo] é o entalhe. Na pedra, o caractere era desenhado em ouro com uma
/// sombra difusa da cor do fundo do tema por baixo — é ela que faz a runa
/// parecer cavada na pedra, e não pintada em cima. O desenho repete a mesma
/// receita: o mesmo traço, na cor do halo e borrado, passa primeiro; o traço
/// cheio passa por cima. Sem [halo] o traço é chapado, que é o certo fora da
/// pedra (no chip do painel, por exemplo).
///
/// MUDO para o leitor de tela nos dois casos: nos quatro lugares em que a
/// runa aparece, o nome dela está escrito ao lado — anunciar também a runa
/// faria o leitor dizer a mesma coisa duas vezes. É a mesma regra do
/// `ToolDrawingArt` e do `ArchetypeGlyph`. Hoje isso ainda MELHORA o que
/// existia: o `Text` do caractere entrava na árvore de semântica e o leitor
/// de tela tentava pronunciar ᚠ.
class RuneMark extends StatelessWidget {
  const RuneMark({
    super.key,
    required this.name,
    required this.symbol,
    required this.fontSize,
    required this.color,
    this.halo,
  });

  /// O nome invariante da runa ('Fehu', 'Uruz'…), que é a chave do desenho.
  final String name;

  /// O caractere do catálogo, usado só quando não há desenho para [name].
  final String symbol;

  /// O corpo que o caractere teria. O desenho é dimensionado para casar com
  /// ele.
  final double fontSize;

  final Color color;

  /// A cor da sombra do entalhe, já com a opacidade dela. Nula = traço
  /// chapado.
  final Color? halo;

  @override
  Widget build(BuildContext context) {
    final art = runeArtFor(name);
    if (art == null) {
      return ExcludeSemantics(
        child: Text(
          symbol,
          style: TextStyle(
            fontSize: fontSize,
            height: 1,
            fontWeight: FontWeight.bold,
            color: color,
            shadows: halo == null
                ? null
                : [Shadow(color: halo!, blurRadius: fontSize * 0.08)],
          ),
        ),
      );
    }
    final box = RuneArt.boxForFontSize(fontSize);
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(box),
        painter: _RunePainter(art: art, color: color, halo: halo),
      ),
    );
  }
}

class _RunePainter extends CustomPainter {
  const _RunePainter({required this.art, required this.color, this.halo});

  final RuneArt art;
  final Color color;
  final Color? halo;

  @override
  void paint(Canvas canvas, Size size) {
    final box = size.shortestSide;
    if (box <= 0) return;
    final width = RuneArt.strokeWidthFor(art.weight, box);
    canvas.save();
    // A caixa é 0..1: a escala do canvas faz o resto. A espessura é decidida
    // em PIXELS (é lá que mora o piso de 1) e devolvida a unidades da caixa,
    // senão a escala a multiplicaria de novo.
    canvas.scale(box);

    void risco(Color cor, {MaskFilter? blur}) {
      canvas.drawPath(
        art.path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = width / box
          ..color = cor
          ..maskFilter = blur,
      );
    }

    final sombra = halo;
    if (sombra != null) {
      // O borrão é proporcional à caixa, e não fixo como era no `Text`: na
      // pedra de 180 do verbete o raio fixo de 3 sumia, e o entalhe voltava
      // a parecer traço colado por cima.
      final raio = box * 0.085;
      risco(
        sombra,
        blur: MaskFilter.blur(
          BlurStyle.normal,
          // O sigma é em pixels; dividido pela escala para o `canvas.scale`
          // não borrar proporcionalmente ao quadrado do tamanho.
          Shadow.convertRadiusToSigma(raio < 2 ? 2 : raio) / box,
        ),
      );
    }
    risco(color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RunePainter old) =>
      old.art != art || old.color != color || old.halo != halo;
}
