import 'sabbat_model.dart';

/// Textos de los Sabbats — contenido en español. Los nombres de los
/// Sabbats (Samhain, Yule...) son nombres propios invariantes.
/// Paridade verificada em test/content_models_parity_test.dart.
const Map<SabbatType, String> sabbatDescriptionsEs = {
  SabbatType.samhain: 'Año Nuevo de las Brujas. El velo entre mundos está fino. Honra a tus ancestros y seres queridos. Inicio del otoño/invierno, período de recogimiento.',
  SabbatType.yule: 'Solsticio de Invierno. La noche más larga del año. Renacimiento de la luz. En Brasil coincide con las fiestas juninas que mantienen la tradición del fuego sagrado.',
  SabbatType.imbolc: 'Festival de la luz creciente. La Tierra despierta con las primeras señales de la primavera. Tiempo de limpieza, purificación y preparación del nuevo crecimiento.',
  SabbatType.ostara: 'Equinoccio de Primavera. Equilibrio perfecto entre luz y oscuridad. La naturaleza despierta plenamente. Tiempo de nuevos comienzos.',
  SabbatType.beltane: 'Festival del fuego y la fertilidad. Celebración de la vida en plenitud. Coincide con el Día de los Difuntos en Brasil, pero energéticamente se trata de celebrar la vida y el amor.',
  SabbatType.litha: 'Solsticio de Verano. El día más largo, pico del poder solar. En Brasil coincide con las fiestas de fin de año. Momento de celebración y gratitud.',
  SabbatType.lammas: 'Primera cosecha. Tras el verano abundante, es tiempo de agradecer y compartir. Reconocemos el sacrificio necesario para la abundancia.',
  SabbatType.mabon: 'Equinoccio de Otoño. Segunda cosecha y segundo equilibrio del año. Preparación para el otoño. Tiempo de gratitud y equilibrio.',
};

const Map<SabbatType, String> sabbatSouthDatesEs = {
  SabbatType.samhain: '1 de mayo',
  SabbatType.yule: '21 de junio',
  SabbatType.imbolc: '1 de agosto',
  SabbatType.ostara: '21 de septiembre',
  SabbatType.beltane: '31 de octubre',
  SabbatType.litha: '21 de diciembre',
  SabbatType.lammas: '2 de febrero',
  SabbatType.mabon: '20 de marzo',
};

const Map<SabbatType, String> sabbatNorthDatesEs = {
  SabbatType.samhain: '31 de octubre',
  SabbatType.yule: '21 de diciembre',
  SabbatType.imbolc: '1 de febrero',
  SabbatType.ostara: '21 de marzo',
  SabbatType.beltane: '1 de mayo',
  SabbatType.litha: '21 de junio',
  SabbatType.lammas: '1 de agosto',
  SabbatType.mabon: '21 de septiembre',
};

const Map<SabbatType, List<String>> sabbatCrystalsEs = {
  SabbatType.samhain: ['Obsidiana', 'Ónix', 'Turmalina negra', 'Amatista'],
  SabbatType.yule: ['Cuarzo transparente', 'Citrino', 'Granate', 'Rubí'],
  SabbatType.imbolc: ['Amatista', 'Cuarzo rosa', 'Selenita', 'Piedra luna'],
  SabbatType.ostara: ['Cuarzo rosa', 'Aventurina', 'Aguamarina', 'Jaspe'],
  SabbatType.beltane: ['Cuarzo rosa', 'Esmeralda', 'Malaquita', 'Cornalina'],
  SabbatType.litha: ['Citrino', 'Ojo de tigre', 'Cuarzo transparente', 'Ámbar'],
  SabbatType.lammas: ['Citrino', 'Cornalina', 'Ágata', 'Peridoto'],
  SabbatType.mabon: ['Ámbar', 'Topacio', 'Citrino', 'Ágata'],
};

const Map<SabbatType, List<String>> sabbatHerbsEs = {
  SabbatType.samhain: ['Artemisa', 'Romero', 'Salvia', 'Rosa (pétalos)', 'Menta'],
  SabbatType.yule: ['Romero', 'Canela', 'Jengibre', 'Pino', 'Laurel'],
  SabbatType.imbolc: ['Lavanda', 'Manzanilla', 'Angélica', 'Albahaca'],
  SabbatType.ostara: ['Rosa', 'Lavanda', 'Menta', 'Albahaca'],
  SabbatType.beltane: ['Rosa', 'Lavanda', 'Menta', 'Albahaca'],
  SabbatType.litha: ['Manzanilla', 'Menta', 'Rosa', 'Lavanda'],
  SabbatType.lammas: ['Albahaca', 'Manzanilla', 'Romero'],
  SabbatType.mabon: ['Salvia', 'Romero', 'Manzanilla'],
};

const Map<SabbatType, List<String>> sabbatColorsEs = {
  SabbatType.samhain: ['Negro', 'Naranja', 'Púrpura oscuro', 'Dorado oscuro'],
  SabbatType.yule: ['Rojo', 'Verde', 'Dorado', 'Blanco'],
  SabbatType.imbolc: ['Blanco', 'Rosa claro', 'Amarillo claro', 'Verde claro'],
  SabbatType.ostara: ['Verde', 'Amarillo', 'Rosa', 'Lila'],
  SabbatType.beltane: ['Rojo', 'Verde vibrante', 'Dorado', 'Rosa'],
  SabbatType.litha: ['Amarillo', 'Naranja', 'Dorado', 'Rojo'],
  SabbatType.lammas: ['Dorado', 'Marrón', 'Naranja', 'Verde oscuro'],
  SabbatType.mabon: ['Naranja', 'Rojo', 'Marrón', 'Dorado oscuro'],
};

const Map<SabbatType, List<String>> sabbatFoodsEs = {
  SabbatType.samhain: ['Calabaza', 'Manzanas', 'Panes caseros', 'Sopas', 'Castañas', 'Granada'],
  SabbatType.yule: ['Vino caliente', 'Pan de jengibre', 'Frutas secas', 'Maíz', 'Naranja'],
  SabbatType.imbolc: ['Leche y derivados', 'Panes con semillas', 'Miel', 'Tés'],
  SabbatType.ostara: ['Huevos', 'Ensaladas verdes', 'Panes con hierbas', 'Miel', 'Semillas'],
  SabbatType.beltane: ['Fresas', 'Frutos rojos', 'Vino', 'Pasteles de miel'],
  SabbatType.litha: ['Frutas frescas', 'Ensaladas', 'Jugos', 'Girasol (semillas)'],
  SabbatType.lammas: ['Panes', 'Maíz', 'Cerveza', 'Frutas de estación', 'Granos'],
  SabbatType.mabon: ['Manzanas', 'Uvas', 'Vino', 'Calabazas', 'Nueces', 'Setas'],
};

const Map<SabbatType, List<String>> sabbatRitualsEs = {
  SabbatType.samhain: ['Crea un altar para los ancestros con fotos y ofrendas', 'Haz una cena silenciosa en honor a quienes partieron', 'Practica la adivinación (tarot, runas, péndulo)', 'Enciende velas negras y naranjas'],
  SabbatType.yule: ['Decora tu casa con elementos naturales', 'Enciende velas para traer la luz de vuelta', 'Toma un baño de hierbas purificador', 'Medita sobre el ciclo de muerte y renacimiento'],
  SabbatType.imbolc: ['Limpia y purifica tu casa', 'Enciende velas blancas o amarillas', 'Siembra semillas (literales o simbólicas)', 'Haz un baño ritual con leche y miel'],
  SabbatType.ostara: ['Pinta huevos con símbolos mágicos', 'Siembra flores y hierbas', 'Haz un ritual de equilibrio y armonía', 'Crea saquitos de prosperidad'],
  SabbatType.beltane: ['Enciende una hoguera o velas rojas', 'Baila y celebra la vida', 'Haz ofrendas a las hadas y elementales', 'Crea un altar de flores'],
  SabbatType.litha: ['Contempla el amanecer o el atardecer', 'Cosecha hierbas mágicas (están en su apogeo)', 'Traza un círculo de protección alrededor de tu casa', 'Celebra con frutas y flores amarillas/doradas'],
  SabbatType.lammas: ['Hornea pan como ofrenda', 'Agradece los logros del año', 'Haz muñecas de maíz (corn dolly)', 'Dona alimentos a quien lo necesita'],
  SabbatType.mabon: ['Crea una cornucopia de gratitud', 'Haz un ritual de equilibrio', 'Conserva alimentos (mermeladas, tés)', 'Medita sobre lo que necesita ser liberado'],
};
