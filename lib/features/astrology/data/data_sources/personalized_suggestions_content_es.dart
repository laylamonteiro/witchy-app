import '../models/enums.dart';
import 'personalized_suggestions_content.dart';

/// Contenido de la página de sugerencias personalizadas — español.
const PersonalizedSuggestionsContent personalizedSuggestionsContentEs =
    PersonalizedSuggestionsContent(
  ui: {
    'premiumUnlockSubtitle': 'Desbloquea sugerencias personalizadas completas',
    'chartNeededTitle': 'Carta Natal Necesaria',
    'chartNeededBody':
        'Para recibir sugerencias personalizadas basadas en los tránsitos astrológicos, primero necesitas crear tu carta natal.',
    'fillChartButton': 'Completar Carta Natal',
    'today': 'Hoy',
    'infoBanner':
        'Sugerencias basadas en los tránsitos planetarios y tu carta natal',
    'mercuryRetrogradeActive': '¡Mercurio Retrógrado Activo!',
    'retrogradePlanets': 'Planetas Retrógrados',
    'retrogradeCountOne': '{count} planeta en movimiento retrógrado',
    'retrogradeCountMany': '{count} planetas en movimiento retrógrado',
    'retrogradeInSign': '{title} en {sign}',
    'effectsLabel': 'Efectos:',
    'tipsLabel': 'Consejos:',
    'suggestedPracticesLabel': 'Prácticas Sugeridas:',
    'relevantAspectsLabel': 'Aspectos Relevantes:',
    'noSuggestionsTitle': 'Sin Sugerencias Especiales',
    'noSuggestionsBody':
        'No hay tránsitos significativos afectando tu carta natal en este día. Continúa con tus prácticas habituales.',
    'errorLoadChart':
        'Error al cargar la carta natal. Por favor, crea primero tu carta natal.',
    'errorGenerate':
        'Error al generar sugerencias. Inténtalo de nuevo más tarde.',
  },
  retrogradeInfo: {
    Planet.mercury: RetrogradePlanetInfo(
      title: 'Mercurio Retrógrado',
      effects:
          'Comunicación confusa, retrasos en viajes, problemas tecnológicos',
      tips:
          'Revisa contratos, evita iniciar proyectos nuevos, haz copias de seguridad de tus datos',
    ),
    Planet.venus: RetrogradePlanetInfo(
      title: 'Venus Retrógrado',
      effects: 'Temas de relaciones, gastos impulsivos, autoestima',
      tips:
          'Reevalúa relaciones, evita cirugías estéticas, reflexiona sobre tus valores',
    ),
    Planet.mars: RetrogradePlanetInfo(
      title: 'Marte Retrógrado',
      effects: 'Energía baja, frustraciones, agresividad reprimida',
      tips:
          'Evita conflictos, no inicies batallas legales, practica la paciencia',
    ),
    Planet.jupiter: RetrogradePlanetInfo(
      title: 'Júpiter Retrógrado',
      effects: 'Expansión interior, reevaluación de creencias y filosofías',
      tips:
          'Momento de introspección espiritual, revisa tus metas a largo plazo',
    ),
    Planet.saturn: RetrogradePlanetInfo(
      title: 'Saturno Retrógrado',
      effects:
          'Responsabilidades pasadas que regresan, karma en proceso de trabajo',
      tips: 'Resuelve asuntos pendientes, trabaja la disciplina interior',
    ),
    Planet.uranus: RetrogradePlanetInfo(
      title: 'Urano Retrógrado',
      effects: 'Cambios internos antes que externos, revelaciones personales',
      tips: 'Libérate de patrones antiguos, acepta cambios graduales',
    ),
    Planet.neptune: RetrogradePlanetInfo(
      title: 'Neptuno Retrógrado',
      effects: 'Los velos se levantan, ilusiones reveladas, intuición aguda',
      tips: 'Medita, trabaja con los sueños, cuidado con el escapismo',
    ),
    Planet.pluto: RetrogradePlanetInfo(
      title: 'Plutón Retrógrado',
      effects: 'Transformación profunda, confrontación con las sombras',
      tips: 'Trabajo de sombra, suelta lo que ya no te sirve',
    ),
  },
);
