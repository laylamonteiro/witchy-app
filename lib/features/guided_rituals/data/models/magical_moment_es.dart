import 'magical_moment_data.dart';

/// Contenido del Momento Mágico — español.
/// Paridad verificada en test/guided_rituals_parity_test.dart.

const Map<int, WeekdayText> weekdayTextsEs = {
  DateTime.monday: (
    theme: 'día de la Luna — emociones e intuición',
    goodFor: [
      'Emociones',
      'Intuición',
      'Sueños',
      'Reconciliación',
      'Hábitos y rutina',
    ],
    suggestion:
        'Un buen día para trabajos de intuición y sueños: anota lo que soñaste, medita y cuida tus emociones.',
  ),
  DateTime.tuesday: (
    theme: 'día de Marte — coraje y fuerza',
    goodFor: [
      'Coraje',
      'Protección',
      'Fuerza',
      'Energía',
      'Asertividad',
    ],
    suggestion:
        'Aprovecha la energía de Marte para hechizos de coraje y protección — y para enfrentar lo que vienes postergando.',
  ),
  DateTime.wednesday: (
    theme: 'día de Mercurio — comunicación y conocimiento',
    goodFor: [
      'Comunicación',
      'Estudios',
      'Viajes',
      'Memoria',
      'Creatividad',
    ],
    suggestion:
        'Día perfecto para estudiar, escribir y resolver conversaciones pendientes. Los hechizos de comunicación fluyen mejor hoy.',
  ),
  DateTime.thursday: (
    theme: 'día de Júpiter — prosperidad y expansión',
    goodFor: [
      'Prosperidad',
      'Abundancia',
      'Carrera y trabajo',
      'Suerte',
      'Optimismo',
    ],
    suggestion:
        'Júpiter expande lo que plantes: gran día para hechizos de prosperidad, solicitudes de empleo y nuevos proyectos.',
  ),
  DateTime.friday: (
    theme: 'día de Venus — amor y belleza',
    goodFor: [
      'Amor',
      'Amor propio',
      'Belleza',
      'Amistades',
      'Fertilidad',
    ],
    suggestion:
        'Venus rige el día: hechizos de amor y amor propio, baños de belleza y encuentros con quien te hace bien.',
  ),
  DateTime.saturday: (
    theme: 'día de Saturno — limpieza y protección',
    goodFor: [
      'Destierros',
      'Limpieza',
      'Purificación',
      'Protección',
      'Cierres',
    ],
    suggestion:
        'Saturno ayuda a cerrar y limpiar: buen día para destierros, limpieza energética y poner límites.',
  ),
  DateTime.sunday: (
    theme: 'día del Sol — éxito y vitalidad',
    goodFor: [
      'Éxito',
      'Poder personal',
      'Salud',
      'Vitalidad',
      'Empoderamiento',
    ],
    suggestion:
        'El Sol favorece brillar: hechizos de éxito y vitalidad, agua solar y actividades que te recarguen.',
  ),
};

const Map<MagicDayPeriod, DayPeriodText> dayPeriodTextsEs = {
  MagicDayPeriod.sunrise: (
    title: 'Amanecer',
    goodFor: 'Nuevos comienzos, energías nuevas, purificar, sanar, estudiar, iniciativa.',
  ),
  MagicDayPeriod.day: (
    title: 'Durante el día',
    goodFor: 'Expansión, inteligencia, liderazgo, mente consciente.',
  ),
  MagicDayPeriod.noon: (
    title: 'Mediodía',
    goodFor: 'Poder, salud, dinero, éxito, fuerza, protección, oportunidad, vitalidad.',
  ),
  MagicDayPeriod.sunset: (
    title: 'Atardecer',
    goodFor: 'Encontrar la verdad, dejar ir, desterrar, romper malos hábitos, cierres.',
  ),
  MagicDayPeriod.night: (
    title: 'Noche',
    goodFor: 'Inventar, autodesarrollo, conciencia, liberar estrés y preocupaciones, sanar heridas.',
  ),
  MagicDayPeriod.midnight: (
    title: 'Medianoche',
    goodFor: 'Destierro, adivinación, sanación, superación personal.',
  ),
};
