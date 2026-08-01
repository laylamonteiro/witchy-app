import 'magical_moment_data.dart';

/// Conteúdo do Momento Mágico — português (idioma-base).
/// Paridade verificada em test/guided_rituals_parity_test.dart.

const Map<int, WeekdayText> weekdayTextsPt = {
  DateTime.monday: (
    theme: 'dia da Lua — emoções e intuição',
    goodFor: [
      'Emoções',
      'Intuição',
      'Sonhos',
      'Reconciliação',
      'Hábitos e rotina',
    ],
    suggestion:
        'Um bom dia para trabalhos de intuição e sonhos: anote o que sonhou, medite e cuide das suas emoções',
  ),
  DateTime.tuesday: (
    theme: 'dia de Marte — coragem e força',
    goodFor: [
      'Coragem',
      'Proteção',
      'Força',
      'Energia',
      'Assertividade',
    ],
    suggestion:
        'Aproveite a energia de Marte para feitiços de coragem e proteção — e para encarar aquilo que você vem adiando',
  ),
  DateTime.wednesday: (
    theme: 'dia de Mercúrio — comunicação e conhecimento',
    goodFor: [
      'Comunicação',
      'Estudos',
      'Viagens',
      'Memória',
      'Criatividade',
    ],
    suggestion:
        'Dia perfeito para estudar, escrever e resolver conversas pendentes. Feitiços de comunicação fluem melhor hoje',
  ),
  DateTime.thursday: (
    theme: 'dia de Júpiter — prosperidade e expansão',
    goodFor: [
      'Prosperidade',
      'Abundância',
      'Carreira e trabalho',
      'Sorte',
      'Otimismo',
    ],
    suggestion:
        'Júpiter expande o que você plantar: ótimo dia para feitiços de prosperidade, pedidos de emprego e novos projetos',
  ),
  DateTime.friday: (
    theme: 'dia de Vênus — amor e beleza',
    goodFor: [
      'Amor',
      'Amor próprio',
      'Beleza',
      'Amizades',
      'Fertilidade',
    ],
    suggestion:
        'Vênus rege o dia: feitiços de amor e amor próprio, banhos de beleza e encontros com quem faz bem',
  ),
  DateTime.saturday: (
    theme: 'dia de Saturno — limpeza e proteção',
    goodFor: [
      'Banimentos',
      'Limpeza',
      'Purificação',
      'Proteção',
      'Encerramentos',
    ],
    suggestion:
        'Saturno ajuda a encerrar e limpar: bom dia para banimentos, faxina energética e colocar limites',
  ),
  DateTime.sunday: (
    theme: 'dia do Sol — sucesso e vitalidade',
    goodFor: [
      'Sucesso',
      'Poder pessoal',
      'Saúde',
      'Vitalidade',
      'Empoderamento',
    ],
    suggestion:
        'O Sol favorece brilhar: feitiços de sucesso e vitalidade, água solar e atividades que recarreguem você',
  ),
};

const Map<MagicDayPeriod, DayPeriodText> dayPeriodTextsPt = {
  MagicDayPeriod.sunrise: (
    title: 'Nascer do sol',
    goodFor: 'Novos começos, novas energias, purificar, curar, estudar, iniciativa',
  ),
  MagicDayPeriod.day: (
    title: 'Durante o dia',
    goodFor: 'Expansão, inteligência, liderança, mente consciente',
  ),
  MagicDayPeriod.noon: (
    title: 'Meio-dia',
    goodFor: 'Poder, saúde, dinheiro, sucesso, força, proteção, oportunidade, vitalidade',
  ),
  MagicDayPeriod.sunset: (
    title: 'Pôr do sol',
    goodFor: 'Encontrar a verdade, deixar ir, banir, romper maus hábitos, encerramentos',
  ),
  MagicDayPeriod.night: (
    title: 'Noite',
    goodFor: 'Inventar, autodesenvolvimento, consciência, liberar estresse e preocupações, curar feridas',
  ),
  MagicDayPeriod.midnight: (
    title: 'Meia-noite',
    goodFor: 'Banimento, adivinhação, cura, aprimoramento pessoal',
  ),
};
