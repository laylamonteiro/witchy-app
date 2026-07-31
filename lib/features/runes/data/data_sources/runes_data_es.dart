import '../models/rune_model.dart';

/// Las 24 runas del Futhark Antiguo — contenido en español.
///
/// Los nombres y símbolos son invariantes entre idiomas; solo se traducen las
/// palabras clave y las descripciones. Mantén el mismo orden que
/// `runes_data_pt.dart` — la paridad se verifica en
/// `test/content_parity_test.dart`.
const List<Rune> runesEs = [
  Rune(
    name: 'Fehu',
    symbol: 'ᚠ',
    keywords: ['Prosperidad', 'Riqueza', 'Abundancia'],
    description: 'Fehu representa la riqueza móvil, la prosperidad y la '
        'abundancia. Simboliza el ganado, que era una forma de riqueza en la '
        'antigüedad. En las lecturas, sugiere ganancias materiales, comienzos '
        'prósperos y la energía necesaria para manifestar tus objetivos.',
  ),
  Rune(
    name: 'Uruz',
    symbol: 'ᚢ',
    keywords: ['Fuerza', 'Vitalidad', 'Salud'],
    description:
        'Uruz es la fuerza bruta de la naturaleza, la vitalidad del uro salvaje. '
        'Representa fuerza física y mental, resistencia y buena salud. '
        'Indica un período de gran energía, sanación o la necesidad '
        'de enfrentar los desafíos con valentía.',
  ),
  Rune(
    name: 'Thurisaz',
    symbol: 'ᚦ',
    keywords: ['Protección', 'Defensa', 'Desafío'],
    description:
        'Thurisaz es la espina o el martillo de Thor. Representa protección, '
        'pero también conflicto y desafío. Sugiere la necesidad de defenderse '
        'o de enfrentar obstáculos. Puede indicar una situación que requiere '
        'cautela y preparación.',
  ),
  Rune(
    name: 'Ansuz',
    symbol: 'ᚨ',
    keywords: ['Comunicación', 'Sabiduría', 'Inspiración'],
    description:
        'Ansuz está ligada a Odín y representa la comunicación divina, la '
        'sabiduría y la inspiración. Simboliza señales, mensajes y conocimiento. '
        'En las lecturas, sugiere que estás recibiendo orientación, '
        'o que debes prestar atención a las señales a tu alrededor.',
  ),
  Rune(
    name: 'Raidho',
    symbol: 'ᚱ',
    keywords: ['Viaje', 'Movimiento', 'Progreso'],
    description:
        'Raidho es la runa del viaje y del movimiento. Representa viajes '
        'físicos y espirituales, progreso y evolución. Sugiere que estás '
        'en un camino de crecimiento, o que es hora de avanzar '
        'en alguna dirección.',
  ),
  Rune(
    name: 'Kenaz',
    symbol: 'ᚲ',
    keywords: ['Conocimiento', 'Creatividad', 'Iluminación'],
    description:
        'Kenaz es la antorcha que ilumina la oscuridad. Representa conocimiento, '
        'creatividad, inspiración y transformación a través del aprendizaje. '
        'Indica un período de descubrimientos, ideas creativas o '
        'desarrollo de habilidades.',
  ),
  Rune(
    name: 'Gebo',
    symbol: 'ᚷ',
    keywords: ['Regalo', 'Alianza', 'Intercambio'],
    description:
        'Gebo representa los regalos, la generosidad y los intercambios '
        'equilibrados. Simboliza alianzas, relaciones y reciprocidad. '
        'Sugiere que estás en un período de dar y recibir, '
        'o que una alianza importante está en primer plano.',
  ),
  Rune(
    name: 'Wunjo',
    symbol: 'ᚹ',
    keywords: ['Alegría', 'Armonía', 'Plenitud'],
    description:
        'Wunjo es la runa de la alegría, la armonía y la realización. Representa '
        'felicidad, satisfacción y períodos de paz. Indica que estás '
        'o estarás en un estado de armonía y plenitud con la vida.',
  ),
  Rune(
    name: 'Hagalaz',
    symbol: 'ᚺ',
    keywords: ['Disrupción', 'Cambio', 'Purificación'],
    description: 'Hagalaz es el granizo: una fuerza disruptiva de la naturaleza. '
        'Representa cambios repentinos, sucesos inesperados y purificación. '
        'Puede indicar un período de desafíos que conducen a la transformación '
        'y al crecimiento.',
  ),
  Rune(
    name: 'Nauthiz',
    symbol: 'ᚾ',
    keywords: ['Necesidad', 'Resistencia', 'Superación'],
    description: 'Nauthiz representa la necesidad, la restricción y la '
        'resistencia. Simboliza tiempos difíciles que exigen paciencia y '
        'perseverancia. Sugiere que enfrentas limitaciones, pero que puedes '
        'superarlas con determinación.',
  ),
  Rune(
    name: 'Isa',
    symbol: 'ᛁ',
    keywords: ['Pausa', 'Estancamiento', 'Introspección'],
    description:
        'Isa es el hielo: inmóvil y preservador. Representa pausa, estancamiento '
        'y la necesidad de introspección. Sugiere un período de espera, '
        'reflexión o congelamiento de una situación. No siempre es negativa; '
        'a veces necesitamos detenernos para evaluar.',
  ),
  Rune(
    name: 'Jera',
    symbol: 'ᛃ',
    keywords: ['Cosecha', 'Ciclos', 'Recompensa'],
    description: 'Jera representa la cosecha y los ciclos naturales del tiempo. '
        'Simboliza las recompensas por los esfuerzos pasados y la importancia '
        'del momento oportuno. Sugiere que cosecharás lo que sembraste, o que '
        'es importante respetar los ciclos naturales de las cosas.',
  ),
  Rune(
    name: 'Eihwaz',
    symbol: 'ᛇ',
    keywords: ['Protección', 'Resistencia', 'Transformación'],
    description:
        'Eihwaz es el tejo: árbol de la vida y de la muerte. Representa '
        'protección, resistencia y transformación profunda. Simboliza la '
        'capacidad de sobrevivir y adaptarse, incluso en condiciones difíciles.',
  ),
  Rune(
    name: 'Perthro',
    symbol: 'ᛈ',
    keywords: ['Misterio', 'Destino', 'Oculto'],
    description:
        'Perthro es el cubilete de dados: representa el misterio, el destino y '
        'lo desconocido. Simboliza secretos, cosas ocultas y el elemento '
        'de azar en la vida. Sugiere que hay fuerzas en juego más allá de lo que '
        'puedes ver o controlar.',
  ),
  Rune(
    name: 'Algiz',
    symbol: 'ᛉ',
    keywords: ['Protección', 'Defensa', 'Conexión Divina'],
    description: 'Algiz representa la protección divina y la conexión '
        'espiritual. Simboliza la mano alzada en protección o las astas del '
        'alce. Sugiere que estás protegido, o que debes buscar orientación '
        'espiritual y confiar en tu intuición.',
  ),
  Rune(
    name: 'Sowilo',
    symbol: 'ᛊ',
    keywords: ['Éxito', 'Vitalidad', 'Iluminación'],
    description: 'Sowilo es el sol: fuente de vida y energía. Representa éxito, '
        'vitalidad, claridad e iluminación. Es una runa extremadamente positiva '
        'que indica victoria, realización y energía solar radiante.',
  ),
  Rune(
    name: 'Tiwaz',
    symbol: 'ᛏ',
    keywords: ['Justicia', 'Honor', 'Liderazgo'],
    description:
        'Tiwaz está ligada al dios Tyr y representa la justicia, el honor y el '
        'liderazgo. Simboliza el sacrificio por un bien mayor y la victoria '
        'a través de la integridad. Sugiere que debes actuar con honor '
        'y liderar con el ejemplo.',
  ),
  Rune(
    name: 'Berkano',
    symbol: 'ᛒ',
    keywords: ['Crecimiento', 'Fertilidad', 'Renovación'],
    description: 'Berkano es el abedul: árbol del renacimiento y la fertilidad. '
        'Representa nuevos comienzos, crecimiento, cuidado y nutrición. '
        'Simboliza procesos de crecimiento gradual, tanto físicos como '
        'espirituales.',
  ),
  Rune(
    name: 'Ehwaz',
    symbol: 'ᛖ',
    keywords: ['Alianza', 'Confianza', 'Movimiento'],
    description:
        'Ehwaz representa el caballo: símbolo de alianza y confianza. '
        'Simboliza la relación entre caballo y jinete, sugiriendo cooperación, '
        'lealtad y avance conjunto. Indica alianzas armoniosas y '
        'progreso a través de la colaboración.',
  ),
  Rune(
    name: 'Mannaz',
    symbol: 'ᛗ',
    keywords: ['Humanidad', 'Autoconciencia', 'Comunidad'],
    description:
        'Mannaz representa la humanidad y la autoconciencia. Simboliza '
        'la mente humana, la sociedad y nuestra conexión con los demás. '
        'Sugiere reflexionar sobre tu papel en la comunidad y desarrollar '
        'la conciencia.',
  ),
  Rune(
    name: 'Laguz',
    symbol: 'ᛚ',
    keywords: ['Agua', 'Intuición', 'Fluir'],
    description:
        'Laguz es el agua: fuente de la vida y del inconsciente. Representa '
        'la intuición, las emociones y el flujo natural de la vida. Sugiere que '
        'debes confiar en tus instintos y fluir, adaptándote '
        'a las circunstancias.',
  ),
  Rune(
    name: 'Ingwaz',
    symbol: 'ᛜ',
    keywords: ['Fertilidad', 'Potencial', 'Gestación'],
    description:
        'Ingwaz está ligada al dios Ing y representa la fertilidad y el '
        'potencial. Simboliza períodos de gestación: cuando algo se desarrolla '
        'internamente antes de manifestarse. Sugiere que es un tiempo de '
        'preparación y cultivo.',
  ),
  Rune(
    name: 'Dagaz',
    symbol: 'ᛞ',
    keywords: ['Día', 'Despertar', 'Transformación'],
    description:
        'Dagaz es el día: el amanecer después de la noche. Representa '
        'transformación, despertar y nuevos comienzos. Simboliza el momento de '
        'claridad en que todo se ilumina. Indica un punto de inflexión '
        'importante o una revelación transformadora.',
  ),
  Rune(
    name: 'Othala',
    symbol: 'ᛟ',
    keywords: ['Herencia', 'Hogar', 'Ancestros'],
    description: 'Othala representa la herencia ancestral, el hogar y la '
        'propiedad. Simboliza raíces, tradiciones familiares y legados. Sugiere '
        'conexión con tus raíces, asuntos de hogar y familia, o la recepción de '
        'una herencia (material o espiritual).',
  ),
];
