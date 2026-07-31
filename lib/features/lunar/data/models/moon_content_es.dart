import '../../../grimoire/data/models/spell_model.dart' show MoonPhase;
import 'moon_content_data.dart';

/// Conocimiento lunar — español.

const String moonIntroEs =
    'La Luna es el gran reloj de la brujería. Su ciclo de unos 29,5 días '
    'marca el ritmo de los trabajos mágicos: lo que crece con ella, crece con '
    'más fuerza; lo que mengua con ella, se disuelve con más facilidad. '
    'Practicantes de todas las tradiciones observan la fase, la hora e '
    'incluso la posición de la Luna para elegir el momento justo de cada '
    'hechizo.\n\n'
    'Más que calendario, la Luna es símbolo: rige las mareas, las emociones, '
    'la intuición y los misterios del inconsciente. Trabajar alineada con '
    'ella es trabajar a favor de la corriente — y no en contra.';

const Map<MoonPhase, MoonPhaseKnowledge> moonPhaseKnowledgeEs = {
  MoonPhase.newMoon: (
    favors:
        'El cielo oscuro es la página en blanco del ciclo: momento de plantar intenciones, comenzar proyectos y recogerse para escuchar la intuición.',
    goodFor: ['Intenciones', 'Nuevos comienzos', 'Introspección', 'Destierros finales'],
  ),
  MoonPhase.waxingCrescent: (
    favors:
        'La primera luz creciente da tracción a lo plantado: hora de dar los primeros pasos y alimentar lo que debe crecer.',
    goodFor: ['Atracción', 'Crecimiento', 'Coraje inicial', 'Prosperidad'],
  ),
  MoonPhase.firstQuarter: (
    favors:
        'Mitad luz, mitad sombra: la fase de la decisión y la acción. Supera obstáculos y ajusta el rumbo de tus trabajos.',
    goodFor: ['Acción', 'Decisiones', 'Fuerza de voluntad', 'Superar bloqueos'],
  ),
  MoonPhase.waxingGibbous: (
    favors:
        'Casi llena, la Luna pide refinamiento: persiste, pule los detalles y prepara la cosecha que llega con la luna llena.',
    goodFor: ['Persistencia', 'Refinamiento', 'Paciencia', 'Ajustes finales'],
  ),
  MoonPhase.fullMoon: (
    favors:
        'El auge del poder lunar lo ilumina todo: manifiesta intenciones, carga cristales e instrumentos, haz agua de luna y practica la adivinación.',
    goodFor: ['Manifestación', 'Cargar cristales', 'Agua de luna', 'Adivinación'],
  ),
  MoonPhase.waningGibbous: (
    favors:
        'Justo después del pico, la energía invita a la gratitud y a compartir: agradece lo que floreció y enseña lo que aprendiste.',
    goodFor: ['Gratitud', 'Compartir', 'Enseñar', 'Cosecha'],
  ),
  MoonPhase.lastQuarter: (
    favors:
        'La luz que disminuye ayuda a soltar: libera hábitos, perdona, cierra ciclos y haz limpiezas profundas.',
    goodFor: ['Liberación', 'Perdón', 'Limpieza', 'Cierres'],
  ),
  MoonPhase.waningCrescent: (
    favors:
        'El fin del ciclo pide descanso y silencio: destierra lo que queda, descansa el cuerpo y prepara el terreno de la próxima luna nueva.',
    goodFor: ['Destierro', 'Descanso', 'Protección', 'Silencio'],
  ),
};

const EsbatsContent moonEsbatsEs = (
  what:
      'Los esbats son las celebraciones de la luna llena — las reuniones "de trabajo" de la brujería, en contraste con los sabbats, que celebran el Sol y la rueda del año. En cada esbat se honra a la Luna en el auge de su poder y se realizan los hechizos más importantes del mes. Hay 12 o 13 esbats al año, y muchas tradiciones dan nombre a cada luna llena (Luna del Lobo, Luna de las Flores, Luna de la Cosecha...).',
  how:
      'Para celebrar: prepara el altar con velas blancas o plateadas, ofrece agua o leche a la Luna, carga tus cristales e instrumentos bajo la luz lunar, haz agua de luna y reserva un momento de adivinación. Incluso un ritual simple — encender una vela y agradecer — ya es un esbat.',
);

const List<String> moonCorrespondencesEs = [
  'Piedra luna',
  'Selenita',
  'Cuarzo transparente',
  'Amatista',
  'Jazmín',
  'Artemisa',
  'Lavanda',
  'Manzanilla',
  'Plata',
  'Plateado',
  'Blanco',
];
