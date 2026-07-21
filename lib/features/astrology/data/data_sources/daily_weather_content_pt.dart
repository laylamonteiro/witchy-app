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

/// Texto de fallback (markdown) usado quando a geração por IA falha.
String dailyWeatherFallbackTextPt(DailyMagicalWeather weather) {
  return '''## Energia do Dia

${weather.generalInterpretation}

## A Lua Hoje

A Lua está em ${weather.moonSign.displayName}, trazendo energias do elemento ${weather.moonSign.element.displayName}.
Fase atual: ${weather.moonPhase}.

## Oportunidades Mágicas

${weather.recommendedPractices.map((p) => '- $p').join('\n')}

## Cristais e Aliados

- Quartzo transparente (equilíbrio geral)
- Ametista (proteção espiritual)
- Pedra da Lua (conexão lunar)

## Mensagem das Estrelas

Permita que as energias celestiais guiem seu caminho hoje. Confie em sua intuição e siga o fluxo do universo.
''';
}
