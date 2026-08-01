import '../../../grimoire/data/models/spell_model.dart' show MoonPhase;
import 'moon_content_data.dart';

/// Conhecimento lunar — português (idioma-base).

const String moonIntroPt =
    'A Lua é o grande relógio da bruxaria. Seu ciclo de cerca de 29,5 dias '
    'marca o ritmo dos trabalhos mágicos: o que cresce com ela, cresce com '
    'mais força; o que míngua com ela, se dissolve com mais facilidade. '
    'Praticantes de todas as tradições observam a fase, o horário e até a '
    'posição da Lua para escolher o momento certo de cada feitiço\n\n'
    'Mais do que calendário, a Lua é símbolo: rege as marés, as emoções, a '
    'intuição e os mistérios do inconsciente. Trabalhar alinhada a ela é '
    'trabalhar a favor da corrente — e não contra';

const Map<MoonPhase, MoonPhaseKnowledge> moonPhaseKnowledgePt = {
  MoonPhase.newMoon: (
    favors:
        'O céu escuro é a página em branco do ciclo: momento de plantar intenções, começar projetos e se recolher para ouvir a intuição',
    goodFor: ['Intenções', 'Novos começos', 'Introspecção', 'Banimentos finais'],
  ),
  MoonPhase.waxingCrescent: (
    favors:
        'A primeira luz crescente dá tração ao que foi plantado: hora de dar os primeiros passos e alimentar o que deve crescer',
    goodFor: ['Atração', 'Crescimento', 'Coragem inicial', 'Prosperidade'],
  ),
  MoonPhase.firstQuarter: (
    favors:
        'Metade luz, metade sombra: a fase da decisão e da ação. Supere obstáculos e ajuste a rota dos seus trabalhos',
    goodFor: ['Ação', 'Decisões', 'Força de vontade', 'Superar bloqueios'],
  ),
  MoonPhase.waxingGibbous: (
    favors:
        'Quase cheia, a Lua pede refinamento: persista, lapide os detalhes e prepare a colheita do que vem na cheia',
    goodFor: ['Persistência', 'Refinamento', 'Paciência', 'Ajustes finais'],
  ),
  MoonPhase.fullMoon: (
    favors:
        'O auge do poder lunar ilumina tudo: manifeste intenções, carregue cristais e instrumentos, faça água de lua e pratique adivinhação',
    goodFor: ['Manifestação', 'Carregar cristais', 'Água de lua', 'Adivinhação'],
  ),
  MoonPhase.waningGibbous: (
    favors:
        'Logo após o pico, a energia convida à gratidão e à partilha: agradeça o que floresceu e ensine o que aprendeu',
    goodFor: ['Gratidão', 'Partilha', 'Ensinar', 'Colheita'],
  ),
  MoonPhase.lastQuarter: (
    favors:
        'A luz que diminui ajuda a soltar: libere hábitos, perdoe, encerre ciclos e faça limpezas profundas',
    goodFor: ['Liberação', 'Perdão', 'Limpeza', 'Encerramentos'],
  ),
  MoonPhase.waningCrescent: (
    favors:
        'O fim do ciclo pede descanso e silêncio: bana o que restou, descanse o corpo e prepare o terreno da próxima lua nova',
    goodFor: ['Banimento', 'Descanso', 'Proteção', 'Silêncio'],
  ),
};

const String moonEsbatsIntroPt =
    'Esbats são as celebrações da lua cheia — os encontros "de trabalho" da '
    'bruxaria, em contraste com os sabbats, que celebram o Sol e a roda do '
    'ano. Em cada esbat honra-se a Lua no auge do poder e realizam-se os '
    'feitiços mais importantes do mês';

const List<EsbatItem> moonEsbatItemsPt = [
  (
    emoji: '🌕',
    title: 'Quando',
    text:
        'Na noite da lua cheia — há 12 ou 13 por ano, e muitas tradições dão nome a cada uma (Lua do Lobo, Lua das Flores, Lua da Colheita...)',
  ),
  (
    emoji: '🕯️',
    title: 'O altar',
    text:
        'Prepare velas brancas ou prateadas e ofereça água ou leite à Lua',
  ),
  (
    emoji: '💎',
    title: 'Carregar energia',
    text:
        'Deixe cristais e instrumentos sob o luar para renovar o poder deles',
  ),
  (
    emoji: '🫙',
    title: 'Água de lua',
    text: 'Prepare a água de lua no auge do poder lunar',
  ),
  (
    emoji: '🔮',
    title: 'Adivinhação',
    text: 'Reserve um momento para tarot, runas ou o oráculo que preferir',
  ),
  (
    emoji: '✨',
    title: 'Simplicidade',
    text: 'Mesmo acender uma vela e agradecer já é um esbat',
  ),
];

const List<LunarDeity> moonDeitiesPt = [
  (
    name: 'Selene',
    description:
        'A própria Lua na Grécia antiga: a titânide que cruza o céu noturno em sua carruagem de prata',
  ),
  (
    name: 'Ártemis',
    description:
        'Deusa grega da caça e da lua crescente, protetora da natureza selvagem e da independência',
  ),
  (
    name: 'Hécate',
    description:
        'Senhora das encruzilhadas, da magia e da lua escura — a grande bruxa entre as deusas',
  ),
  (
    name: 'Ísis',
    description:
        'Grande maga do Egito, ligada à lua, aos mistérios e à cura',
  ),
  (
    name: 'Iemanjá',
    description:
        'Rainha do mar nas tradições afro-brasileiras, ligada à lua, às marés e à maternidade',
  ),
];

const List<String> moonCorrespondencesPt = [
  'Pedra da lua',
  'Selenita',
  'Quartzo transparente',
  'Ametista',
  'Jasmim',
  'Artemísia',
  'Lavanda',
  'Camomila',
  'Prata',
  'Prateado',
  'Branco',
];
