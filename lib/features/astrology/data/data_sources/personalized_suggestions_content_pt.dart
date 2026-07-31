import '../models/enums.dart';
import 'personalized_suggestions_content.dart';

/// Conteúdo da página de sugestões personalizadas — português.
const PersonalizedSuggestionsContent personalizedSuggestionsContentPt =
    PersonalizedSuggestionsContent(
  ui: {
    'premiumUnlockSubtitle': 'Desbloqueie sugestões personalizadas completas',
    'chartNeededTitle': 'Mapa Astral Necessário',
    'chartNeededBody':
        'Para receber sugestões personalizadas baseadas nos trânsitos astrológicos, você precisa criar seu mapa astral primeiro.',
    'fillChartButton': 'Preencher Mapa Astral',
    'today': 'Hoje',
    'infoBanner':
        'Sugestões baseadas nos trânsitos planetários e seu mapa astral',
    'mercuryRetrogradeActive': 'Mercúrio Retrógrado Ativo!',
    'retrogradePlanets': 'Planetas Retrógrados',
    'retrogradeCountOne': '{count} planeta em movimento retrógrado',
    'retrogradeCountMany': '{count} planetas em movimento retrógrado',
    'retrogradeInSign': '{title} em {sign}',
    'effectsLabel': 'Efeitos:',
    'tipsLabel': 'Dicas:',
    'suggestedPracticesLabel': 'Práticas Sugeridas:',
    'relevantAspectsLabel': 'Aspectos Relevantes:',
    'noSuggestionsTitle': 'Sem Sugestões Especiais',
    'noSuggestionsBody':
        'Não há trânsitos significativos afetando seu mapa natal neste dia. Continue suas práticas regulares.',
    'errorLoadChart':
        'Erro ao carregar mapa astral. Por favor, crie seu mapa astral primeiro.',
    'errorGenerate': 'Erro ao gerar sugestões. Tente novamente mais tarde.',
  },
  retrogradeInfo: {
    Planet.mercury: RetrogradePlanetInfo(
      title: 'Mercúrio Retrógrado',
      effects:
          'Comunicação confusa, atrasos em viagens, problemas tecnológicos',
      tips:
          'Revise contratos, evite iniciar projetos novos, faça backup de dados',
    ),
    Planet.venus: RetrogradePlanetInfo(
      title: 'Vênus Retrógrada',
      effects: 'Questões de relacionamento, gastos impulsivos, autoestima',
      tips:
          'Reavalie relacionamentos, evite cirurgias estéticas, reflita sobre valores',
    ),
    Planet.mars: RetrogradePlanetInfo(
      title: 'Marte Retrógrado',
      effects: 'Energia baixa, frustrações, agressividade reprimida',
      tips: 'Evite conflitos, não inicie batalhas legais, pratique paciência',
    ),
    Planet.jupiter: RetrogradePlanetInfo(
      title: 'Júpiter Retrógrado',
      effects: 'Expansão interior, reavaliação de crenças e filosofias',
      tips: 'Momento de introspecção espiritual, revise metas de longo prazo',
    ),
    Planet.saturn: RetrogradePlanetInfo(
      title: 'Saturno Retrógrado',
      effects: 'Responsabilidades passadas retornam, karma sendo trabalhado',
      tips: 'Resolva assuntos pendentes, trabalhe disciplina interior',
    ),
    Planet.uranus: RetrogradePlanetInfo(
      title: 'Urano Retrógrado',
      effects: 'Mudanças internas antes de externas, revelações pessoais',
      tips: 'Liberte-se de padrões antigos, aceite mudanças graduais',
    ),
    Planet.neptune: RetrogradePlanetInfo(
      title: 'Netuno Retrógrado',
      effects: 'Véus se levantam, ilusões reveladas, intuição aguçada',
      tips: 'Medite, trabalhe sonhos, cuidado com escapismo',
    ),
    Planet.pluto: RetrogradePlanetInfo(
      title: 'Plutão Retrógrado',
      effects: 'Transformação profunda, confronto com sombras',
      tips: 'Trabalho de sombra, deixe ir o que não serve mais',
    ),
  },
);
