import '../../../wheel_of_year/data/models/sabbat_model.dart' show SabbatType;
import 'sun_content_data.dart';

/// Conocimiento solar — español.

const String sunIntroEs =
    'Si la Luna rige los misterios de la noche, el Sol es la fuerza viva del '
    'día: vitalidad, coraje, éxito, sanación y protección. La magia solar '
    'trabaja con lo visible y consciente — la acción, el cuerpo, el brillo '
    'personal — y complementa la magia lunar, que cuida de lo invisible y lo '
    'intuitivo\n\n'
    'El Sol también marca la rueda del año: los solsticios y equinoccios son '
    'las cuatro grandes fiestas solares de la brujería. Y cada hora del día '
    'carga una energía propia, del amanecer al atardecer — saber usarlas es '
    'tener un instrumento más en tu grimorio';

const List<SolarSabbat> sunSabbatsEs = [
  (
    sabbat: SabbatType.yule,
    meaning:
        'Solsticio de Invierno: la noche más larga y el renacimiento de la luz'
  ),
  (
    sabbat: SabbatType.ostara,
    meaning:
        'Equinoccio de Primavera: luz y sombra en equilibrio, todo despierta'
  ),
  (
    sabbat: SabbatType.litha,
    meaning: 'Solsticio de Verano: el auge del poder solar, el día más largo'
  ),
  (
    sabbat: SabbatType.mabon,
    meaning:
        'Equinoccio de Otoño: el segundo equilibrio, gratitud por la cosecha'
  ),
];

const List<String> sunCorrespondencesEs = [
  'Citrino',
  'Ojo de tigre',
  'Ámbar',
  'Cornalina',
  'Girasol',
  'Caléndula',
  'Romero',
  'Manzanilla',
  'Oro',
  'Dorado',
  'Amarillo',
  'Naranja',
];

const List<SolarDeity> sunDeitiesEs = [
  (
    name: 'Ra',
    description:
        'El dios-sol egipcio que cruza el cielo en su barca, muriendo y renaciendo cada día'
  ),
  (
    name: 'Apolo',
    description:
        'Dios griego de la luz, las artes, la sanación y la profecía — el brillo que revela la verdad'
  ),
  (
    name: 'Amaterasu',
    description:
        'La gran diosa solar del sintoísmo, cuya salida de la cueva devolvió la luz al mundo'
  ),
  (
    name: 'Sunna',
    description:
        'La personificación nórdica del Sol, que guía su carro en fuga perpetua por el cielo'
  ),
  (
    name: 'Brigid',
    description:
        'Señora celta del fuego, la forja y la inspiración — honrada cuando la luz comienza a crecer'
  ),
];
