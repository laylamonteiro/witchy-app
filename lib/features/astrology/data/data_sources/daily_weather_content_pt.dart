import '../models/enums.dart';
import '../models/transit_model.dart';

/// Conteúdo do Clima Mágico Diário — português (idioma-base).
///
/// Os SÍMBOLOS públicos (títulos de fallback da prévia, placeholder premium e
/// função de texto de fallback) são invariantes entre idiomas; apenas o texto
/// é traduzido. Mantenha a paridade nos três arquivos
/// (`daily_weather_content_pt/en/es.dart`) — verificada em
/// `test/daily_weather_content_parity_test.dart`.
///
/// Nota: campos interpolados vindos do `TransitInterpreter`
/// (`generalInterpretation`, `moonPhase`, `recommendedPractices`) são
/// inseridos como estão — eles são localizados na própria fonte.

/// Títulos de seção usados na prévia Free quando o markdown gerado não tem
/// cabeçalhos próprios. Espelham a estrutura editorial da previsão.
const List<String> dailyWeatherFallbackHeadingsPt = [
  'Energia do Dia',
  'A Lua Hoje',
  'Oportunidades Mágicas',
  'Cuidados do Dia',
  'Ritual Sugerido',
  'Cristais e Aliados',
  'Mensagem das Estrelas',
];

/// Frase-placeholder exibida desfocada no lugar do corpo Premium da previsão.
const String dailyWeatherPremiumPlaceholderPt =
    'As influências do dia revelam orientações e práticas mágicas personalizadas para este momento.';

/// Texto de fallback (markdown) usado quando a geração por IA falha. Mantém
/// as MESMAS 7 seções do texto da IA (Energia, Lua, Oportunidades, Cuidados,
/// Ritual, Cristais, Mensagem) para que o clima diário fique completo mesmo
/// sem a IA.
String dailyWeatherFallbackTextPt(DailyMagicalWeather weather) {
  final elemento = weather.moonSign.element.displayName;

  final desafios = weather.aspects
      .where((a) => a.energyLevel == EnergyLevel.challenging)
      .take(2)
      .map((a) => '- ${a.description}: aja com calma e evite reagir no impulso.')
      .toList();
  final cuidados = desafios.isNotEmpty
      ? desafios.join('\n')
      : '- Sem tensões marcantes hoje. Ainda assim, evite decisões apressadas e reserve um momento de pausa para se centrar.';

  return '''## Energia do Dia

${weather.generalInterpretation}

## A Lua Hoje

A Lua está em ${weather.moonSign.displayName}, trazendo energias do elemento $elemento.
Fase atual: ${weather.moonPhase}.

## Oportunidades Mágicas

${weather.recommendedPractices.map((p) => '- $p').join('\n')}

## Cuidados do Dia

$cuidados

## Ritual Sugerido

Acenda uma vela e faça três respirações profundas, sintonizando-se com o elemento $elemento da Lua em ${weather.moonSign.displayName}. Formule uma intenção simples e clara para o dia e visualize-a se realizando.

## Cristais e Aliados

- Quartzo transparente (equilíbrio geral)
- Ametista (proteção espiritual)
- Pedra da Lua (conexão lunar)

## Mensagem das Estrelas

Permita que as energias celestiais guiem seu caminho hoje. Confie em sua intuição e siga o fluxo do universo.
''';
}
