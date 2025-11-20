import 'enums.dart';

class House {
  final int number; // 1-12
  final ZodiacSign sign; // Signo na cúspide
  final int degree; // Grau da cúspide
  final int minute; // Minuto da cúspide
  final double cuspLongitude; // Longitude da cúspide

  const House({
    required this.number,
    required this.sign,
    required this.degree,
    required this.minute,
    required this.cuspLongitude,
  });

  String get meaning {
    switch (number) {
      case 1:
        return 'Personalidade, aparência, como você se apresenta ao mundo';
      case 2:
        return 'Recursos, valores, posses materiais';
      case 3:
        return 'Comunicação, aprendizado, irmãos';
      case 4:
        return 'Lar, família, raízes, emoções profundas';
      case 5:
        return 'Criatividade, romance, prazer, filhos';
      case 6:
        return 'Saúde, rotina, trabalho diário';
      case 7:
        return 'Parcerias, relacionamentos, casamento';
      case 8:
        return 'Transformação, sexualidade, magia, ocultismo';
      case 9:
        return 'Filosofia, viagens, espiritualidade, sabedoria';
      case 10:
        return 'Carreira, status social, propósito público';
      case 11:
        return 'Amizades, comunidade, sonhos, ideais';
      case 12:
        return 'Inconsciente, espiritualidade, isolamento, mediunidade';
      default:
        return '';
    }
  }

  String get magicalMeaning {
    switch (number) {
      case 1:
        return 'Sua máscara mágica - como você se apresenta como bruxa';
      case 2:
        return 'Suas ferramentas mágicas - cristais, ervas, recursos';
      case 3:
        return 'Comunicação com espíritos, feitiços falados';
      case 4:
        return 'Altar do lar, magia doméstica, ancestrais';
      case 5:
        return 'Criatividade mágica, prazer nos rituais';
      case 6:
        return 'Rituais diários, limpezas, saúde energética';
      case 7:
        return 'Parcerias mágicas, trabalho em covens';
      case 8:
        return 'Magia sexual, transformação profunda, ocultismo';
      case 9:
        return 'Estudos esotéricos, viagens astrais';
      case 10:
        return 'Seu propósito como bruxa no mundo';
      case 11:
        return 'Comunidade mágica, círculos, intenções';
      case 12:
        return 'Mediunidade, sonhos proféticos, magia oculta';
      default:
        return '';
    }
  }

  String get cuspString => '${sign.symbol} ${degree}°${minute}\'';

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'sign': sign.name,
      'degree': degree,
      'minute': minute,
      'cuspLongitude': cuspLongitude,
    };
  }

  factory House.fromJson(Map<String, dynamic> json) {
    return House(
      number: json['number'],
      sign: ZodiacSign.values.firstWhere((e) => e.name == json['sign']),
      degree: json['degree'],
      minute: json['minute'],
      cuspLongitude: json['cuspLongitude'],
    );
  }
}
