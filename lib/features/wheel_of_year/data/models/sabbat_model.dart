enum SabbatType {
  samhain,
  yule,
  imbolc,
  ostara,
  beltane,
  litha,
  lammas,
  mabon,
}

extension SabbatTypeExtension on SabbatType {
  String get name {
    switch (this) {
      case SabbatType.samhain:
        return 'Samhain';
      case SabbatType.yule:
        return 'Yule';
      case SabbatType.imbolc:
        return 'Imbolc';
      case SabbatType.ostara:
        return 'Ostara';
      case SabbatType.beltane:
        return 'Beltane';
      case SabbatType.litha:
        return 'Litha';
      case SabbatType.lammas:
        return 'Lammas';
      case SabbatType.mabon:
        return 'Mabon';
    }
  }

  String get emoji {
    switch (this) {
      case SabbatType.samhain:
        return '🎃';
      case SabbatType.yule:
        return '❄️';
      case SabbatType.imbolc:
        return '🕯️';
      case SabbatType.ostara:
        return '🌸';
      case SabbatType.beltane:
        return '🔥';
      case SabbatType.litha:
        return '☀️';
      case SabbatType.lammas:
        return '🌾';
      case SabbatType.mabon:
        return '🍂';
    }
  }

  String get description {
    switch (this) {
      case SabbatType.samhain:
        return 'Ano Novo Bruxo. Véu entre mundos está fino. Honre ancestrais e entes queridos.';
      case SabbatType.yule:
        return 'Solstício de Inverno. A noite mais longa do ano. Renascimento da luz.';
      case SabbatType.imbolc:
        return 'Festival da luz e purificação. Primeiras sementes de novos projetos.';
      case SabbatType.ostara:
        return 'Equinócio de Primavera. Equilíbrio entre luz e escuridão. Renovação e fertilidade.';
      case SabbatType.beltane:
        return 'Festival do fogo e fertilidade. Celebração da vida e paixão.';
      case SabbatType.litha:
        return 'Solstício de Verão. O dia mais longo. Pico do poder solar.';
      case SabbatType.lammas:
        return 'Primeira colheita. Gratidão pelos frutos do trabalho.';
      case SabbatType.mabon:
        return 'Equinócio de Outono. Segunda colheita. Gratidão e equilíbrio.';
    }
  }

  List<String> get rituals {
    switch (this) {
      case SabbatType.samhain:
        return [
          'Crie um altar para ancestrais com fotos e oferendas',
          'Faça uma ceia silenciosa em honra aos que partiram',
          'Pratique divinação (tarô, runas, pêndulo)',
          'Acenda velas pretas e laranja',
        ];
      case SabbatType.yule:
        return [
          'Decore sua casa com elementos naturais',
          'Acenda velas para trazer a luz de volta',
          'Faça um banho de ervas purificador',
          'Medite sobre o ciclo de morte e renascimento',
        ];
      case SabbatType.imbolc:
        return [
          'Limpe e purifique sua casa',
          'Acenda velas brancas ou amarelas',
          'Plante sementes (literais ou simbólicas)',
          'Faça um ritual de banho com leite e mel',
        ];
      case SabbatType.ostara:
        return [
          'Pinte ovos com símbolos mágicos',
          'Plante flores e ervas',
          'Faça um ritual de equilíbrio e harmonia',
          'Crie sachês de prosperidade',
        ];
      case SabbatType.beltane:
        return [
          'Acenda uma fogueira ou velas vermelhas',
          'Dance e celebre a vida',
          'Faça oferendas às fadas e elementais',
          'Crie um altar de flores',
        ];
      case SabbatType.litha:
        return [
          'Assista ao nascer ou pôr do sol',
          'Colha ervas mágicas (estão no auge)',
          'Faça um círculo de proteção ao redor de sua casa',
          'Celebre com frutas e flores amarelas/douradas',
        ];
      case SabbatType.lammas:
        return [
          'Asse pão como oferenda',
          'Agradeça pelas conquistas do ano',
          'Faça bonecas de milho (corn dolly)',
          'Doe alimentos para quem precisa',
        ];
      case SabbatType.mabon:
        return [
          'Crie uma cornucópia de gratidão',
          'Faça um ritual de equilíbrio',
          'Preserve alimentos (geleias, chás)',
          'Medite sobre o que precisa ser liberado',
        ];
    }
  }

  // Datas para hemisfério sul
  DateTime getDateForYear(int year) {
    switch (this) {
      case SabbatType.samhain:
        return DateTime(year, 5, 1); // 1º de maio
      case SabbatType.yule:
        return _getSolsticeEquinox(year, 6, 20, 22); // ~21 de junho
      case SabbatType.imbolc:
        return DateTime(year, 8, 1); // 1º de agosto
      case SabbatType.ostara:
        return _getSolsticeEquinox(year, 9, 20, 23); // ~21 de setembro
      case SabbatType.beltane:
        return DateTime(year, 10, 31); // 31 de outubro
      case SabbatType.litha:
        return _getSolsticeEquinox(year, 12, 20, 23); // ~21 de dezembro
      case SabbatType.lammas:
        return DateTime(year, 2, 1); // 1º de fevereiro
      case SabbatType.mabon:
        return _getSolsticeEquinox(year, 3, 19, 21); // ~20 de março
    }
  }

  // Helper para solstícios e equinócios (aproximação)
  DateTime _getSolsticeEquinox(int year, int month, int minDay, int maxDay) {
    // Retorna o dia médio (aproximação simples)
    final day = ((minDay + maxDay) / 2).round();
    return DateTime(year, month, day);
  }
}

class Sabbat {
  final SabbatType type;
  final DateTime date;

  Sabbat({
    required this.type,
    required this.date,
  });

  String get name => type.name;
  String get emoji => type.emoji;
  String get description => type.description;
  List<String> get rituals => type.rituals;

  int daysUntil(DateTime now) {
    return date.difference(now).inDays;
  }

  bool isPast(DateTime now) {
    return date.isBefore(now);
  }
}
