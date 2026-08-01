/// Contenido estático de la feature de Sigilos — español.
///
/// Aquí vive solo el CONTENIDO didáctico/interpretativo del método
/// (explicaciones, etapas de la técnica, sugerencias de intención). El chrome
/// de UI (títulos de AppBar, botones, labels cortos, snackbars) permanece en
/// los ARBs del l10n.
///
/// Mantén los tres archivos (`sigil_content_pt/en/es.dart`) con la misma
/// estructura y el mismo número de ítems en cada lista — la paridad se
/// verifica en `test/sigil_content_parity_test.dart`.
library;

/// Qué es un sigilo (explicación didáctica de la tarjeta de introducción).
const String sigilWhatIsDescEs =
    'Los sigilos son símbolos mágicos creados para manifestar intenciones. '
    'Al transformar palabras en símbolos abstractos, creas una marca '
    'energética que lleva el poder de tu voluntad sin revelar tu intención '
    'a otras personas';

/// Cómo funciona el método (introducción de la etapa 1).
const String sigilHowIntroEs =
    'Define tu intención, elige una palabra que la represente, y la app '
    'creará automáticamente tu sigilo único';

/// Sugerencias de palabras de intención.
const List<String> sigilIntentionExamplesEs = [
  'Prosperidad',
  'Protección',
  'Sanación',
  'Confianza',
  'Intuición',
];

/// Consejo sobre la elección de la palabra de intención.
const String sigilWordTipEs =
    'Consejo: Elige palabras positivas y específicas que resuenen contigo';

/// Introducción a la explicación de la simplificación de letras (etapa 2).
const String sigilSimplifiedIntroEs =
    'Tu palabra fue simplificada siguiendo la tradición de los sigilos:';

/// Etapas de la técnica de simplificación (describen el procesamiento — el
/// procesamiento en sí es invariante y vive en `SigilWheel`).
const List<String> sigilSimplificationStepsEs = [
  '1. Se normalizaron los acentos',
  '2. Se eliminaron espacios y símbolos',
  '3. Se eliminaron las letras duplicadas (solo se mantiene la primera aparición)',
];

/// Nota sobre la Rueda de las Brujas (etapa 2).
const String sigilWheelNoteEs =
    'Esta secuencia simplificada se conectará en la Rueda de las Brujas '
    'para formar el símbolo mágico de tu sigilo';

/// Cómo usar el sigilo terminado (etapa 3) — título + descripción por paso.
const List<({String title, String description})> sigilUsageStepsEs = [
  (
    title: '1. Copia este dibujo',
    description:
        'Reproduce el trazado en tu cuaderno, altar, vela o papel ritual',
  ),
  (
    title: '2. Personaliza',
    description:
        'Simplifica, gira o añade detalles. Hacerlo tuyo es parte de la magia',
  ),
  (
    title: '3. Activa el sigilo',
    description:
        'Úsalo en meditación, quémalo en ritual o llévalo contigo para enfocar tu intención',
  ),
];

/// Recordatorio interpretativo final (etapa 3).
const String sigilRememberNoteEs =
    'Recuerda: la magia está en tu intención y en el acto de crear, no solo '
    'en el dibujo final';
