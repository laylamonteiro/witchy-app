/// Guarda de idioma das respostas da IA.
///
/// O modelo escreve no idioma pedido, mas escorrega: um "sometimes" no meio
/// do Clima Mágico Diário, um trecho em cirílico no meio da interpretação de
/// um sonho. É raro e não quebra nada — só quebra a confiança de quem lê.
///
/// Esta guarda NÃO tenta adivinhar o idioma do texto (leitura mística tem
/// nome de planta em latim, termo consagrado em inglês e nome próprio de
/// qualquer lugar). Ela procura duas coisas objetivas:
///
///  1. letras de escritas que nenhum idioma do app usa (cirílico, grego,
///     árabe, hebraico, devanágari, CJK…);
///  2. palavras-marcador de OUTRO idioma do app — palavras curtas e
///     frequentes que existem em um idioma e não nos outros ("sometimes",
///     "también", "você").
///
/// O que a própria pessoa escreveu nunca conta: os prompts mandam preservar
/// nomes, anotações e intenções literalmente, então uma palavra que veio do
/// texto dela não é intrusa — é o conteúdo dela de volta.
class LanguageGuard {
  const LanguageGuard._();

  /// Blocos Unicode de escritas que nenhum dos idiomas do app (pt/en/es)
  /// usa. Uma letra dessas no meio da leitura é sempre defeito de geração.
  static const String _blocosEstrangeiros =
      'Ͱ-Ͽ' // grego
      'Ѐ-ӿ' // cirílico
      '԰-֏' // armênio
      '֐-׿' // hebraico
      '؀-ۿ' // árabe
      'ऀ-ॿ' // devanágari
      '฀-๿' // tailandês
      '぀-ヿ' // hiragana/katakana
      '一-鿿' // han
      '가-힯'; // hangul

  static final RegExp _escritaEstrangeira = RegExp('[$_blocosEstrangeiros]');

  /// Tudo que não é letra separa palavras. As letras consideradas são as
  /// latinas (com acentos) e as das escritas acima — as que a guarda
  /// precisa enxergar juntas para reconhecer a palavra intrusa inteira.
  static final RegExp _separador =
      RegExp('[^A-Za-zÀ-ɏ$_blocosEstrangeiros]+');

  /// Palavras que só existem em UM dos idiomas do app. Nada de palavra que
  /// o vizinho também usa ("nunca", "porque", "cada" são pt E es): um falso
  /// positivo aqui manda uma leitura boa para reescrita à toa.
  static const Map<String, Set<String>> _marcadores = {
    'pt': {
      'você', 'vocês', 'não', 'então', 'também', 'muito', 'muita', 'coração',
      'através', 'além', 'porém', 'isso', 'isto', 'aquilo', 'sonho', 'sonhos',
      'noite', 'fogo', 'água', 'terra', 'mulher', 'homem', 'hoje', 'amanhã',
      'ontem', 'sempre', 'lua', 'estrela', 'caminho', 'força', 'sabedoria',
      'conselho',
    },
    'en': {
      'the', 'and', 'with', 'without', 'this', 'that', 'these', 'those',
      'they', 'them', 'their', 'there', 'here', 'when', 'where', 'which',
      'while', 'what', 'your', 'yours', 'you', 'from', 'will', 'would',
      'should', 'could', 'shall', 'might', 'must', 'because', 'however',
      'therefore', 'although', 'though', 'sometimes', 'always', 'never',
      'often', 'usually', 'about', 'through', 'throughout', 'before',
      'after', 'during', 'between', 'among', 'into', 'onto', 'upon', 'over',
      'under', 'above', 'below', 'again', 'another', 'other', 'others',
      'something', 'someone', 'everything', 'everyone', 'nothing', 'anything',
      'anyone', 'myself', 'yourself', 'herself', 'himself', 'itself',
      'themselves', 'remember', 'moon', 'dream', 'dreams', 'strength',
      'wisdom', 'healing', 'path', 'night', 'earth', 'water', 'fire',
      'woman', 'today', 'tomorrow', 'yesterday',
    },
    'es': {
      'pero', 'muy', 'también', 'usted', 'ustedes', 'ella', 'ellos', 'ellas',
      'hacia', 'hacer', 'hoy', 'ayer', 'mañana', 'puede', 'tiene', 'tienes',
      'eres', 'cuando', 'aunque', 'entonces', 'ahora', 'después', 'así',
      'más', 'mismo', 'misma', 'mujer', 'hombre', 'corazón', 'sueño',
      'sueños', 'noche', 'tierra', 'fuego', 'agua', 'camino', 'fuerza',
      'sabiduría', 'consejo', 'luna', 'estrella',
    },
  };

  /// Quantas intrusas no máximo entram na lista mandada de volta ao modelo:
  /// a lista é uma pista, não um relatório.
  static const int _limite = 12;

  /// As palavras de outro idioma encontradas em [texto], já sem as que
  /// vieram do próprio [textoDoUsuario].
  ///
  /// [idioma] é o código do idioma da resposta esperada ('pt', 'pt-BR',
  /// 'en', 'es'); um idioma desconhecido devolve lista vazia — sem
  /// referência, não há intrusa que se possa afirmar.
  static List<String> intrusos(
    String texto, {
    required String idioma,
    String textoDoUsuario = '',
  }) {
    final alvo = _codigo(idioma);
    if (texto.trim().isEmpty || !_marcadores.containsKey(alvo)) return const [];

    final proibidas = <String>{
      for (final entrada in _marcadores.entries)
        if (entrada.key != alvo) ...entrada.value,
    };
    final doUsuario = _palavras(textoDoUsuario);

    final achados = <String>{};
    for (final palavra in texto.split(_separador)) {
      if (achados.length >= _limite) break;
      if (palavra.isEmpty) continue;
      final normalizada = palavra.toLowerCase();
      if (doUsuario.contains(normalizada)) continue;
      if (_escritaEstrangeira.hasMatch(palavra) ||
          proibidas.contains(normalizada)) {
        achados.add(palavra);
      }
    }
    return achados.toList();
  }

  /// O texto está no idioma pedido, sem palavra intrusa?
  static bool estaNoIdioma(
    String texto, {
    required String idioma,
    String textoDoUsuario = '',
  }) =>
      intrusos(texto, idioma: idioma, textoDoUsuario: textoDoUsuario).isEmpty;

  /// 'pt-BR' → 'pt'; 'PT' → 'pt'.
  static String _codigo(String idioma) {
    final corte = idioma.indexOf(RegExp('[-_]'));
    final base = corte > 0 ? idioma.substring(0, corte) : idioma;
    return base.toLowerCase();
  }

  static Set<String> _palavras(String texto) => {
        for (final palavra in texto.toLowerCase().split(_separador))
          if (palavra.isNotEmpty) palavra,
      };
}
