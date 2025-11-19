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
        return 'Ano Novo Bruxo (1º maio no Brasil, 31 out. no hemisfério norte). Véu entre mundos está fino. Honre ancestrais e entes queridos. Início do outono/inverno, período de recolhimento.';
      case SabbatType.yule:
        return 'Solstício de Inverno (21 junho no Brasil, 21 dez. no hemisfério norte). A noite mais longa do ano. Renascimento da luz. Coincide com festas juninas que mantêm a tradição do fogo sagrado.';
      case SabbatType.imbolc:
        return 'Festival da luz crescente (1º agosto no Brasil, 1º fev. no hemisfério norte). Despertar da Terra, primeiros sinais da primavera. Tempo de limpeza, purificação e preparação para o novo crescimento.';
      case SabbatType.ostara:
        return 'Equinócio de Primavera (21 setembro no Brasil, 21 mar. no hemisfério norte). Equilíbrio perfeito entre luz e escuridão. A natureza desperta plenamente. Tempo de novos começos.';
      case SabbatType.beltane:
        return 'Festival do fogo e fertilidade (31 outubro no Brasil, 1º mai. no hemisfério norte). Celebração da vida em plenitude. Coincide com Finados, mas energeticamente é sobre celebrar a vida e o amor.';
      case SabbatType.litha:
        return 'Solstício de Verão (21 dezembro no Brasil, 21 jun. no hemisfério norte). O dia mais longo, pico do poder solar. Coincide com festas de fim de ano. Momento de celebração e gratidão.';
      case SabbatType.lammas:
        return 'Primeira colheita (2 fevereiro no Brasil, 1º ago. no hemisfério norte). Após o verão abundante, é tempo de agradecer e compartilhar. Reconhecemos o sacrifício necessário para a abundância.';
      case SabbatType.mabon:
        return 'Equinócio de Outono (20 março no Brasil, 21 set. no hemisfério norte). Segunda colheita e segundo equilíbrio do ano. Preparação para o outono. Tempo de gratidão e equilíbrio.';
    }
  }

  List<String> get crystals {
    switch (this) {
      case SabbatType.samhain:
        return ['Obsidiana', 'Ônix', 'Turmalina negra', 'Ametista'];
      case SabbatType.yule:
        return ['Quartzo transparente', 'Citrino', 'Granada', 'Rubi'];
      case SabbatType.imbolc:
        return ['Ametista', 'Quartzo rosa', 'Selenita', 'Pedra da lua'];
      case SabbatType.ostara:
        return ['Quartzo rosa', 'Aventurina', 'Água-marinha', 'Jaspe'];
      case SabbatType.beltane:
        return ['Quartzo rosa', 'Esmeralda', 'Malaquita', 'Carnélia'];
      case SabbatType.litha:
        return ['Citrino', 'Olho de tigre', 'Quartzo transparente', 'Âmbar'];
      case SabbatType.lammas:
        return ['Citrino', 'Cornalina', 'Ágata', 'Peridoto'];
      case SabbatType.mabon:
        return ['Âmbar', 'Topázio', 'Citrino', 'Ágata'];
    }
  }

  List<String> get herbs {
    switch (this) {
      case SabbatType.samhain:
        return ['Artemísia', 'Alecrim', 'Sálvia', 'Rosa (pétalas)', 'Hortelã'];
      case SabbatType.yule:
        return ['Alecrim', 'Canela', 'Gengibre', 'Pinheiro', 'Louro'];
      case SabbatType.imbolc:
        return ['Lavanda', 'Camomila', 'Angélica', 'Manjericão'];
      case SabbatType.ostara:
        return ['Rosa', 'Lavanda', 'Hortelã', 'Manjericão'];
      case SabbatType.beltane:
        return ['Rosa', 'Lavanda', 'Hortelã', 'Manjericão'];
      case SabbatType.litha:
        return ['Camomila', 'Hortelã', 'Rosa', 'Lavanda'];
      case SabbatType.lammas:
        return ['Manjericão', 'Camomila', 'Alecrim'];
      case SabbatType.mabon:
        return ['Sálvia', 'Alecrim', 'Camomila'];
    }
  }

  List<String> get colors {
    switch (this) {
      case SabbatType.samhain:
        return ['Preto', 'Laranja', 'Roxo escuro', 'Dourado escuro'];
      case SabbatType.yule:
        return ['Vermelho', 'Verde', 'Dourado', 'Branco'];
      case SabbatType.imbolc:
        return ['Branco', 'Rosa claro', 'Amarelo claro', 'Verde claro'];
      case SabbatType.ostara:
        return ['Verde', 'Amarelo', 'Rosa', 'Lilás'];
      case SabbatType.beltane:
        return ['Vermelho', 'Verde vibrante', 'Dourado', 'Rosa'];
      case SabbatType.litha:
        return ['Amarelo', 'Laranja', 'Dourado', 'Vermelho'];
      case SabbatType.lammas:
        return ['Dourado', 'Marrom', 'Laranja', 'Verde escuro'];
      case SabbatType.mabon:
        return ['Laranja', 'Vermelho', 'Marrom', 'Dourado escuro'];
    }
  }

  List<String> get foods {
    switch (this) {
      case SabbatType.samhain:
        return ['Abóbora', 'Maçãs', 'Pães caseiros', 'Sopas', 'Castanhas', 'Romã'];
      case SabbatType.yule:
        return ['Quentão', 'Pães de gengibre', 'Frutas secas', 'Milho', 'Laranja'];
      case SabbatType.imbolc:
        return ['Leite e derivados', 'Pães com sementes', 'Mel', 'Chás'];
      case SabbatType.ostara:
        return ['Ovos', 'Saladas verdes', 'Pães com ervas', 'Mel', 'Sementes'];
      case SabbatType.beltane:
        return ['Morangos', 'Frutas vermelhas', 'Vinho', 'Bolos de mel'];
      case SabbatType.litha:
        return ['Frutas frescas', 'Saladas', 'Sucos', 'Girassol (sementes)'];
      case SabbatType.lammas:
        return ['Pães', 'Milho', 'Cerveja', 'Frutas da estação', 'Grãos'];
      case SabbatType.mabon:
        return ['Maçãs', 'Uvas', 'Vinho', 'Abóboras', 'Nozes', 'Cogumelos'];
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

  // Datas para hemisfério sul (Brasil)
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
        return DateTime(year, 2, 2); // 2 de fevereiro
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
