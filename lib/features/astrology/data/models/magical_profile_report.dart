/// A Análise Personalizada como um RELATÓRIO de seções, não um texto corrido.
///
/// Antes era um único markdown de doze parágrafos curtos rolando numa tela
/// só: quem abria via uma parede de texto e saía sem ler. Agora cada tema é
/// um card, e cada card abre uma leitura que desliza em páginas.
///
/// O texto guardado continua sendo UM markdown (nada mudou no banco). O que
/// mudou é a forma: cada seção começa com um marcador de chave — `## [essence]`
/// — em vez de um título escrito. A chave é invariante e o título vem do
/// l10n, então trocar o idioma do app renomeia os cards sem regerar nada; o
/// corpo, esse sim, fica no idioma em que foi tecido.
///
/// Perfis gerados antes desta mudança não têm marcador. Eles continuam
/// abrindo: o parser cai no formato antigo (`## Título escrito`) e usa os
/// títulos que vieram no próprio texto.
library;

/// As chaves das seções — identidade persistida dentro do markdown salvo.
/// Renomear uma quebra a leitura de todo perfil já gerado.
abstract final class MagicalProfileSections {
  static const essence = 'essence';
  static const intuition = 'intuition';
  static const voice = 'voice';
  static const love = 'love';
  static const power = 'power';
  static const transformation = 'transformation';
  static const spirit = 'spirit';
  static const allies = 'allies';
  static const practice = 'practice';
  static const shadow = 'shadow';

  /// A ordem de leitura: do que a pessoa é para o que ela faz e, por último,
  /// o que dói. A sombra vem no fim de propósito — é onde a leitura pode
  /// machucar, e ninguém deve tropeçar nela na primeira tela.
  static const ordered = [
    essence,
    intuition,
    voice,
    love,
    power,
    transformation,
    spirit,
    allies,
    practice,
    shadow,
  ];

  /// O cabeçalho que o app escreve antes do corpo devolvido pela IA.
  static String header(String key) => '## [$key]';
}

/// Uma página da leitura de uma seção: subtítulo + corpo.
class ProfileSlide {
  const ProfileSlide({required this.title, required this.body});

  /// Pode vir vazio (formato antigo, sem subtítulos).
  final String title;
  final String body;
}

/// Uma seção da análise: a chave (quando o texto foi gerado no formato novo),
/// o título que veio escrito (formato antigo) e as páginas.
class ProfileSection {
  const ProfileSection({
    required this.key,
    required this.legacyTitle,
    required this.slides,
  });

  final String? key;
  final String? legacyTitle;
  final List<ProfileSlide> slides;
}

final _cabecalhoComChave = RegExp(r'^##[ \t]+\[([a-z]+)\][ \t]*$');
final _cabecalhoEscrito = RegExp(r'^##[ \t]+(.+?)[ \t]*$');
final _subtitulo = RegExp(r'^###[ \t]+(.+?)[ \t]*$');

/// Quebra o markdown salvo nas seções que a tela mostra.
///
/// Aceita os dois formatos (com marcador de chave e o antigo, com o título
/// escrito) e nunca devolve seção sem corpo: um cabeçalho seguido de nada é
/// descartado, porque um card que abre vazio é pior que um card a menos.
List<ProfileSection> parseMagicalProfile(String markdown) {
  final linhas = markdown.split('\n');

  // Primeira passada: este texto está no formato novo?
  //
  // Sem esta pergunta, um `##` que a IA escrevesse por conta própria dentro de
  // uma seção virava um cabeçalho "de formato antigo", e a tela inteira
  // desviava para a leitura corrida — sumindo com a grade de dez cards e com
  // todo botão de tecer de novo. O prompt pede o formato; nada garante que a
  // resposta obedeça.
  final formatoNovo = linhas.any(_cabecalhoComChave.hasMatch);

  final secoes = <ProfileSection>[];

  String? chaveAtual;
  String? tituloAtual;
  final corpo = <String>[];

  void fechar() {
    if (chaveAtual == null && tituloAtual == null) return;
    final slides = _fatiar(corpo.join('\n'));
    if (slides.isNotEmpty) {
      secoes.add(ProfileSection(
        key: chaveAtual,
        legacyTitle: tituloAtual,
        slides: slides,
      ));
    }
    chaveAtual = null;
    tituloAtual = null;
    corpo.clear();
  }

  for (final linha in linhas) {
    final comChave = _cabecalhoComChave.firstMatch(linha);
    if (comChave != null) {
      fechar();
      chaveAtual = comChave.group(1);
      continue;
    }
    final escrito = _cabecalhoEscrito.firstMatch(linha);
    if (escrito != null) {
      if (formatoNovo) {
        // Rebaixado a subtítulo em vez de quebrar o documento: o texto
        // continua na seção a que pertence e vira mais uma página dela, com
        // o destaque que tinha. Nada se perde.
        corpo.add('### ${escrito.group(1)}');
        continue;
      }
      fechar();
      tituloAtual = escrito.group(1);
      continue;
    }
    corpo.add(linha);
  }
  fechar();

  return secoes;
}

/// As páginas de uma seção.
///
/// Com subtítulos `### `, cada um vira uma página — é o formato que a
/// geração pede. Sem eles (perfis antigos), o corpo inteiro vira uma página
/// só: fatiar por parágrafo criaria páginas de duas linhas, que deslizam sem
/// dizer nada.
List<ProfileSlide> _fatiar(String corpo) {
  final linhas = corpo.split('\n');
  final slides = <ProfileSlide>[];

  String? titulo;
  final buffer = <String>[];

  void fechar() {
    final texto = buffer.join('\n').trim();
    buffer.clear();
    if (texto.isEmpty) {
      titulo = null;
      return;
    }
    slides.add(ProfileSlide(title: titulo ?? '', body: texto));
    titulo = null;
  }

  for (final linha in linhas) {
    final sub = _subtitulo.firstMatch(linha);
    if (sub != null) {
      fechar();
      titulo = sub.group(1);
      continue;
    }
    buffer.add(linha);
  }
  fechar();

  return slides;
}

/// Tira uma seção do markdown guardado — usado para tecê-la de novo no
/// lugar da anterior, sem mexer nas outras.
String removeMagicalProfileSection(String markdown, String key) {
  final linhas = markdown.split('\n');
  final mantidas = <String>[];
  var dentro = false;

  for (final linha in linhas) {
    final comChave = _cabecalhoComChave.firstMatch(linha);
    if (comChave != null) {
      dentro = comChave.group(1) == key;
      if (dentro) continue;
    } else if (dentro && !_cabecalhoEscrito.hasMatch(linha)) {
      continue;
    } else if (dentro) {
      dentro = false;
    }
    mantidas.add(linha);
  }

  return mantidas.join('\n').trim();
}
