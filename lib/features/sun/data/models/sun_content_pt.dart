import '../../../wheel_of_year/data/models/sabbat_model.dart' show SabbatType;
import 'sun_content_data.dart';

/// Conhecimento solar — português (idioma-base).

const String sunIntroPt =
    'Se a Lua rege os mistérios da noite, o Sol é a força viva do dia: '
    'vitalidade, coragem, sucesso, cura e proteção. A magia solar trabalha '
    'com o que é visível e consciente — a ação, o corpo, o brilho pessoal — '
    'e complementa a magia lunar, que cuida do invisível e do intuitivo.\n\n'
    'O Sol também marca a roda do ano: os solstícios e equinócios são as '
    'quatro festas solares da bruxaria. E cada hora do dia carrega uma '
    'energia própria, do nascer ao pôr do sol — saber usá-las é ter mais um '
    'instrumento no seu grimório.';

const List<SolarSabbat> sunSabbatsPt = [
  (
    sabbat: SabbatType.yule,
    meaning:
        'Solstício de Inverno: a noite mais longa e o renascimento da luz.'
  ),
  (
    sabbat: SabbatType.ostara,
    meaning: 'Equinócio de Primavera: luz e sombra em equilíbrio, tudo desperta.'
  ),
  (
    sabbat: SabbatType.litha,
    meaning: 'Solstício de Verão: o auge do poder solar, o dia mais longo.'
  ),
  (
    sabbat: SabbatType.mabon,
    meaning: 'Equinócio de Outono: o segundo equilíbrio, gratidão pela colheita.'
  ),
];

const List<String> sunCorrespondencesPt = [
  'Citrino',
  'Olho de tigre',
  'Âmbar',
  'Cornalina',
  'Girassol',
  'Calêndula',
  'Alecrim',
  'Camomila',
  'Ouro',
  'Dourado',
  'Amarelo',
  'Laranja',
];

const List<SolarDeity> sunDeitiesPt = [
  (
    name: 'Rá',
    description:
        'O deus-sol egípcio que atravessa o céu em sua barca, morrendo e renascendo a cada dia.'
  ),
  (
    name: 'Apolo',
    description:
        'Deus grego da luz, das artes, da cura e da profecia — o brilho que revela a verdade.'
  ),
  (
    name: 'Amaterasu',
    description:
        'A grande deusa solar do xintoísmo, cuja saída da caverna devolveu a luz ao mundo.'
  ),
  (
    name: 'Sunna',
    description:
        'A personificação nórdica do Sol, que guia sua carruagem em fuga perpétua pelo céu.'
  ),
  (
    name: 'Brigid',
    description:
        'Senhora celta do fogo, da forja e da inspiração — honrada quando a luz começa a crescer.'
  ),
];
