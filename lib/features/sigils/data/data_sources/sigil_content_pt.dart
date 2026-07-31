/// Conteúdo estático da feature de Sigilos — português (idioma-base).
///
/// Contém apenas o CONTEÚDO didático/interpretativo do método (explicações,
/// etapas da técnica, sugestões de intenção). Chrome de UI (títulos de AppBar,
/// botões, labels curtos, snackbars) permanece nos ARBs do l10n.
///
/// Mantenha os três arquivos (`sigil_content_pt/en/es.dart`) com a mesma
/// estrutura e o mesmo número de itens nas listas — a paridade é verificada
/// em `test/sigil_content_parity_test.dart`.
///
/// IMPORTANTE: nada aqui participa da construção do sigilo em si — a Roda das
/// Bruxas e o processamento das letras da intenção digitada pelo usuário são
/// invariantes e vivem em `sigil_wheel_model.dart`.
library;

/// O que é um sigilo (explicação didática do card de introdução).
const String sigilWhatIsDescPt =
    'Sigilos são símbolos mágicos criados para manifestar intenções. '
    'Ao transformar palavras em símbolos abstratos, você cria uma marca '
    'energética que carrega o poder da sua vontade, sem revelar sua intenção '
    'para outras pessoas.';

/// Como o método funciona (introdução da etapa 1).
const String sigilHowIntroPt =
    'Defina sua intenção, escolha uma palavra que a represente, e o app '
    'criará automaticamente seu sigilo único.';

/// Sugestões de palavras de intenção.
const List<String> sigilIntentionExamplesPt = [
  'Prosperidade',
  'Proteção',
  'Cura',
  'Confiança',
  'Intuição',
];

/// Dica sobre a escolha da palavra de intenção.
const String sigilWordTipPt =
    'Dica: Escolha palavras positivas e específicas que ressoem com você.';

/// Introdução à explicação da simplificação das letras (etapa 2).
const String sigilSimplifiedIntroPt =
    'Sua palavra foi simplificada seguindo a tradição dos sigilos:';

/// Etapas da técnica de simplificação (descrevem o processamento — o
/// processamento em si é invariante e vive em `SigilWheel`).
const List<String> sigilSimplificationStepsPt = [
  '1. Acentos foram normalizados',
  '2. Espaços e símbolos foram removidos',
  '3. Letras duplicadas foram eliminadas (mantém apenas a primeira ocorrência)',
];

/// Nota sobre a Roda das Bruxas (etapa 2).
const String sigilWheelNotePt =
    'Esta sequência simplificada será conectada na Roda das Bruxas para '
    'formar o símbolo mágico do seu sigilo.';

/// Como usar o sigilo pronto (etapa 3) — título + descrição de cada passo.
const List<({String title, String description})> sigilUsageStepsPt = [
  (
    title: '1. Copie este desenho',
    description:
        'Reproduza o traçado em seu caderno, altar, vela, ou papel ritual.',
  ),
  (
    title: '2. Personalize',
    description:
        'Simplifique, gire, ou adicione detalhes. Torná-lo seu faz parte da magia.',
  ),
  (
    title: '3. Ative o sigilo',
    description:
        'Use em meditação, queime em ritual, ou carregue consigo para focar sua intenção.',
  ),
];

/// Lembrete interpretativo final (etapa 3).
const String sigilRememberNotePt =
    'Lembre-se: a magia está na sua intenção e no ato de criar, não apenas '
    'no desenho final.';
