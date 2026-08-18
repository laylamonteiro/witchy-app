import '../../content/content_locale.dart';
import '../../i18n/gender.dart';
import 'ai_prompts_en.dart';
import 'ai_prompts_es.dart';
import 'ai_prompts_pt.dart';

/// Prompts de sistema, mensagens auxiliares e erros do `AIService`.
///
/// O conteúdo por idioma vive em `ai_prompts_pt/en/es.dart` — as três
/// instâncias DEVEM preencher os mesmos campos (paridade verificada em
/// `test/ai_prompts_parity_test.dart`).
///
/// Invariantes entre idiomas (a UI depende deles):
/// - Feitiço: as chaves do JSON (`name`, `purpose`, `type`, `category`,
///   `moonPhase`, `ingredients`, `steps`, `duration`, `observations`) e os
///   valores de enum (ex.: `attraction`, `fullMoon`) são SEMPRE em inglês.
/// - Sonhos e quiromancia: os marcadores de linha `◈` (elemento/ponto) e `✦`
///   (síntese) são reconhecidos por `DreamInterpretationText`.
/// - Clima Mágico Diário: o prompt de cada idioma exige EXATAMENTE os
///   cabeçalhos `##` de `dailyWeatherFallbackHeadings{Pt,En,Es}` — o cache é
///   validado por `DailyWeatherContent.looksComplete`, que procura os pares
///   "Ritual Sugerido"/"Cuidados do Dia" no idioma correspondente.
class AiPrompts {
  const AiPrompts({
    required this.localizedInstruction,
    required this.spellGenerationSystemPrompt,
    required this.magicalProfileSystemPrompt,
    required this.dailyWeatherSystemPrompt,
    required this.affirmationSystemPrompt,
    required this.mysticAdvisorSystemPrompt,
    required this.palmistrySystemPrompt,
    required this.tarotSpreadSystemPrompt,
    required this.tarotQuestionIntro,
    required this.runeSpreadSystemPrompt,
    required this.oracleSpreadSystemPrompt,
    required this.numerologySystemPrompt,
    required this.dreamInterpreterSystemPrompt,
    required this.palmUserMessage,
    required this.palmDebugUserMessage,
    required this.encyIdentifySystemPrompt,
    required this.encyIdentifyUserMessage,
    required this.encyGenerateSystemPrompt,
    required this.encyGenerateUserMessage,
    required this.affirmationUserPrompt,
    required this.dreamUserPrompt,
    required this.cycleReadingSystemPrompt,
    required this.cycleReadingSectionInstruction,
    required this.dreamTeaserSystemPrompt,
    required this.defaultSpellName,
    required this.errorInvalidRequest,
    required this.errorBadRequest,
    required this.errorAuthentication,
    required this.errorRateLimit,
    required this.errorServiceUnavailable,
    required this.errorConnection,
    required this.errorProcessing,
    required this.errorImageTooLarge,
    required this.errorPalmUnavailable,
    required this.errorUnknown,
  });

  /// Reforço de idioma injetado no início de todo prompt de sistema
  /// (recebe a tag do idioma atual, ex.: `pt-BR`).
  final String Function(String languageTag) localizedInstruction;

  /// Persona geradora de feitiços (retorna JSON estrito).
  final String Function(Gender gender) spellGenerationSystemPrompt;

  /// Bruxa ancestral que interpreta o mapa astral (Perfil Mágico, 12 seções).
  final String Function(Gender gender) magicalProfileSystemPrompt;

  /// Bruxa sábia do Clima Mágico Diário (7 seções com cabeçalhos exatos).
  final String Function(Gender gender) dailyWeatherSystemPrompt;

  /// Conselheiro Místico criador de afirmações.
  final String Function(Gender gender) affirmationSystemPrompt;

  /// Conselheiro Místico que responde dúvidas de bruxaria/misticismo.
  final String Function(Gender gender) mysticAdvisorSystemPrompt;

  /// Quiromante (leitura de mãos por imagem; marcadores ◈ e ✦).
  final String Function(Gender gender) palmistrySystemPrompt;

  /// Taróloga da tradição Rider-Waite (tiragem já sorteada pelo app).
  final String Function(Gender gender) tarotSpreadSystemPrompt;

  /// Interpretação de uma tiragem de runas já sorteada pelo app.
  final String Function(Gender gender) runeSpreadSystemPrompt;

  /// Interpretação de uma tiragem do Oráculo já sorteada pelo app.
  final String Function(Gender gender) oracleSpreadSystemPrompt;

  /// Introdução da pergunta de quem consulta na mensagem de usuário do
  /// Tarot — o texto da pergunta em si é passado verbatim, nunca traduzido.
  final String tarotQuestionIntro;

  /// Especialista em numerologia pitagórica (números já calculados pelo app).
  final String Function(Gender gender) numerologySystemPrompt;

  /// Intérprete de sonhos (marcadores ◈ e ✦).
  final String Function(Gender gender) dreamInterpreterSystemPrompt;

  /// Mensagem de usuário enviada junto com a foto da palma.
  final String palmUserMessage;

  /// Mensagem de usuário do diagnóstico admin da leitura de mãos.
  final String palmDebugUserMessage;

  /// Identificação de item da enciclopédia por foto (visão). Recebe a chave
  /// da categoria (`crystal`/`herb`/`color`, invariante) e retorna JSON
  /// estrito `{"identified": bool, "name": string, "confidence": string}`.
  final String Function(String categoryKey) encyIdentifySystemPrompt;

  /// Mensagem de usuário enviada junto com a foto a identificar.
  final String encyIdentifyUserMessage;

  /// Geração da página da enciclopédia pessoal. Recebe a chave da categoria
  /// e o nome confirmado pela usuária; o JSON de saída usa SEMPRE chaves e
  /// valores de enum em inglês (invariante, igual ao feitiço).
  final String Function(String categoryKey, String name)
      encyGenerateSystemPrompt;

  /// Mensagem de usuário da geração da página (nome do item).
  final String Function(String name) encyGenerateUserMessage;

  /// Mensagem de usuário da afirmação (categoria + contexto opcional).
  final String Function(String category, String? userContext)
      affirmationUserPrompt;

  /// Mensagem de usuário da interpretação de sonho (relato + emoções).
  final String Function(String dreamDescription, String? feelings)
      dreamUserPrompt;

  /// Leitura do Ciclo (produto pago): persona que narra o período a partir
  /// do JSON de fatos montado no aparelho (`CycleReadingComposer`). Tom de
  /// acolhimento, nunca previsão determinista; respeita `unknownBirthTime`.
  /// Cada seção é gerada numa chamada CURTA separada — a instrução da vez
  /// vem de [cycleReadingSectionInstruction].
  final String Function(Gender gender) cycleReadingSystemPrompt;

  /// Instrução de UMA seção da Leitura do Ciclo. Chaves invariantes
  /// (`CycleReadingSections`): `portrait`, `threads`, `sky`, `practice`,
  /// `rituals`, `affirmation`, `seal`.
  final String Function(String sectionKey) cycleReadingSectionInstruction;

  /// Degustação da interpretação de sonhos: responde APENAS 2 frases — o
  /// conteúdo completo nem chega a existir no aparelho (fail-closed).
  final String Function(Gender gender) dreamTeaserSystemPrompt;

  /// Nome padrão quando o JSON do feitiço vem sem `name`.
  final String defaultSpellName;

  // Mensagens de erro exibidas/propagadas ao usuário.
  final String errorInvalidRequest;
  final String Function(String message) errorBadRequest;
  final String errorAuthentication;
  final String errorRateLimit;
  final String errorServiceUnavailable;
  final String Function(String? message) errorConnection;
  final String Function(Object error) errorProcessing;
  final String errorImageTooLarge;
  final String errorPalmUnavailable;
  final String errorUnknown;
}

/// Prompts do idioma atual do aplicativo (fallback: português).
AiPrompts get aiPrompts => ContentLocale.instance.select(
      pt: aiPromptsPt,
      en: aiPromptsEn,
      es: aiPromptsEs,
    );
