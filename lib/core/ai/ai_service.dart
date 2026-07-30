import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import '../i18n/gender.dart';
import '../../features/astrology/data/models/birth_chart_model.dart';
import '../../features/astrology/data/models/enums.dart';
import '../../features/astrology/data/models/magical_profile_model.dart';
import '../../features/grimoire/data/models/spell_model.dart';
import 'groq_credentials.dart';

/// Erro de limite de uso do provedor de IA (HTTP 429). A chave da Groq é
/// compartilhada, então o teto é do serviço, não por usuário. A tela decide
/// a mensagem (para poder localizar e orientar o reenvio).
class AiRateLimitException implements Exception {
  const AiRateLimitException();
}

/// Serviço de IA usando Groq (gratuito, sem API key necessária)
class AIService {
  static final AIService instance = AIService._();

  AIService._();

  /// Modelo de texto padrão do Groq.
  static const String _textModel = 'llama-3.3-70b-versatile';

  /// Modelo de visão do Groq (usado na leitura de mãos). O Groq descontinua
  /// modelos com frequência — a família Llama 4 (Scout/Maverick) foi
  /// aposentada em 2026, então trocar aqui atualiza toda a visão do app.
  static const String _visionModel = 'qwen/qwen3.6-27b';

  final Dio _dio = Dio();
  Locale _locale = const Locale('pt', 'BR');

  void setLocale(Locale locale) {
    _locale = locale;
  }

  Gender _gender = Gender.fallback;

  /// Gênero/forma de tratamento da pessoa logada (fonte: AuthProvider).
  void setGender(Gender preference) {
    _gender = preference;
  }

  String get currentLanguageTag {
    final countryCode = _locale.countryCode;
    if (countryCode == null || countryCode.isEmpty) {
      return _locale.languageCode;
    }
    return '${_locale.languageCode}-$countryCode';
  }

  String _localizedInstruction() =>
      'Responda no idioma atual do aplicativo: $currentLanguageTag. '
      'Preserve literalmente nomes, anotações, intenções e demais conteúdos fornecidos pelo usuário; não os traduza automaticamente.';

  /// Verificar se o serviço está disponível (sempre true para Groq)
  Future<bool> hasApiKey() async {
    return true;
  }

  /// Gerar feitiço com IA usando Groq
  Future<SpellModel> generateSpell(
    String userIntention, {
    Gender? gender,
  }) async {
    return _generateWithGroq(
      userIntention,
      gender: gender ?? _gender,
    );
  }

  Future<SpellModel> _generateWithGroq(
    String intention, {
    required Gender gender,
  }) async {
    try {
      final requestData = {
        'model': _textModel,
        'messages': [
          {
            'role': 'system',
            'content': _buildSystemPrompt(gender),
          },
          {
            'role': 'user',
            'content': intention,
          },
        ],
        'temperature': 0.8,
        'max_tokens': 1024,
        'response_format': {'type': 'json_object'},
      };

      final response = await _dio.post(
        'https://api.groq.com/openai/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${GroqCredentials.apiKey}',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
        data: requestData,
      );

      final content = response.data['choices'][0]['message']['content'];
      final spellData = jsonDecode(content);
      return _parseSpellData(spellData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        // Erro 400 - requisição inválida
        final errorData = e.response?.data;
        String errorMessage = 'Requisição inválida (400)';

        if (errorData != null && errorData is Map) {
          if (errorData.containsKey('error')) {
            final error = errorData['error'];
            if (error is Map && error.containsKey('message')) {
              errorMessage = error['message'];
            }
          }
        }

        throw Exception('Erro 400: $errorMessage');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Erro de autenticação');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Limite de uso excedido');
      } else if (e.response?.statusCode == 503) {
        throw Exception('Serviço temporariamente indisponível');
      }
      throw Exception('Erro na conexão: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao processar resposta: $e');
    }
  }

  SpellModel _parseSpellData(Map<String, dynamic> data) {
    return SpellModel(
      id: const Uuid().v4(),
      name: data['name'] ?? 'Feitiço Personalizado',
      purpose: data['purpose'] ?? '',
      type: _parseSpellType(data['type']),
      category: _parseSpellCategory(data['category']),
      moonPhase:
          data['moonPhase'] != null ? _parseMoonPhase(data['moonPhase']) : null,
      ingredients: List<String>.from(data['ingredients'] ?? []),
      steps: data['steps'] ?? '',
      duration: data['duration'] ?? 1,
      observations: data['observations'],
      isPreloaded: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  SpellType _parseSpellType(String? type) {
    if (type == null) return SpellType.attraction;
    try {
      return SpellType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => SpellType.attraction,
      );
    } catch (e) {
      return SpellType.attraction;
    }
  }

  SpellCategory _parseSpellCategory(String? category) {
    if (category == null) return SpellCategory.other;
    try {
      return SpellCategory.values.firstWhere(
        (e) => e.name == category,
        orElse: () => SpellCategory.other,
      );
    } catch (e) {
      return SpellCategory.other;
    }
  }

  MoonPhase? _parseMoonPhase(String? phase) {
    if (phase == null) return null;
    try {
      return MoonPhase.values.firstWhere(
        (e) => e.name == phase,
        orElse: () => MoonPhase.newMoon,
      );
    } catch (e) {
      return null;
    }
  }

  /// Gerar texto personalizado do Perfil Mágico com IA
  Future<String> generateMagicalProfileText({
    required BirthChartModel birthChart,
    required MagicalProfile profile,
    Gender? gender,
  }) async {
    try {
      final chartSummary = _buildChartSummary(birthChart, profile);

      final requestData = {
        'model': _textModel,
        'messages': [
          {
            'role': 'system',
            'content': _buildMagicalProfileSystemPrompt(
              gender ?? _gender,
            ),
          },
          {
            'role': 'user',
            'content': chartSummary,
          },
        ],
        'temperature': 0.7,
        'max_tokens': 2048,
      };

      final response = await _dio.post(
        'https://api.groq.com/openai/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${GroqCredentials.apiKey}',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 30),
        ),
        data: requestData,
      );

      return _contentFromResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Gerar texto do Clima Mágico Diário com IA
  Future<String> generateDailyMagicalWeatherText({
    required String moonPhase,
    required ZodiacSign moonSign,
    required EnergyLevel overallEnergy,
    required List<String> energyKeywords,
    required List<Map<String, String>> transits,
    required List<Map<String, String>> aspects,
    Gender? gender,
  }) async {
    gender ??= _gender;
    try {
      final weatherSummary = _buildWeatherSummary(
        moonPhase: moonPhase,
        moonSign: moonSign,
        overallEnergy: overallEnergy,
        energyKeywords: energyKeywords,
        transits: transits,
        aspects: aspects,
      );

      final requestData = {
        'model': _textModel,
        'messages': [
          {
            'role': 'system',
            'content': _buildDailyWeatherSystemPrompt(gender),
          },
          {
            'role': 'user',
            'content': weatherSummary,
          },
        ],
        'temperature': 0.8,
        'max_tokens': 1536,
      };

      final response = await _dio.post(
        'https://api.groq.com/openai/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${GroqCredentials.apiKey}',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 30),
        ),
        data: requestData,
      );

      return _contentFromResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Extrai o texto da resposta do Groq. Se a geração foi cortada por limite de
  /// tokens (`finish_reason == 'length'`), apara o final incompleto até a última
  /// frase completa para nunca exibir corte no meio da palavra.
  String _contentFromResponse(Response response) {
    final choice = response.data['choices'][0];
    final content = (choice['message']['content'] ?? '') as String;
    if (choice['finish_reason'] == 'length') {
      debugPrint('⚠️ AIService: resposta atingiu max_tokens; aparando final incompleto.');
      return _trimToLastSentence(content);
    }
    return content;
  }

  /// Corta o texto até a última pontuação de fim de frase, evitando cortes no
  /// meio de uma palavra quando a resposta veio truncada.
  String _trimToLastSentence(String text) {
    final trimmed = text.trimRight();
    int cut = -1;
    for (final m in RegExp(r'[.!?…\n]').allMatches(trimmed)) {
      cut = m.end;
    }
    return cut > 0 ? trimmed.substring(0, cut).trimRight() : trimmed;
  }

  String _buildChartSummary(BirthChartModel chart, MagicalProfile profile) {
    final buffer = StringBuffer();

    // Formata um corpo/ponto do mapa com signo, grau e casa (se presente).
    String? body(Planet pl, String label) {
      final match = chart.planets.where((p) => p.planet == pl);
      if (match.isEmpty) return null;
      final p = match.first;
      final retro = p.isRetrograde ? ' (R)' : '';
      return '$label: ${p.positionString} - Casa ${p.houseNumber}$retro';
    }

    buffer.writeln('DADOS DO MAPA ASTRAL:');
    buffer.writeln('');
    buffer.writeln(
        'SOL: ${chart.sun.positionString} - Casa ${chart.sun.houseNumber}');
    buffer.writeln(
        'LUA: ${chart.moon.positionString} - Casa ${chart.moon.houseNumber}');
    if (chart.ascendant != null) {
      buffer.writeln('ASCENDENTE: ${chart.ascendant!.positionString}');
    }
    if (chart.midheaven != null) {
      buffer.writeln('MEIO DO CÉU: ${chart.midheaven!.positionString}');
    }
    buffer.writeln('MERCÚRIO: ${chart.mercury.positionString}'
        ' - Casa ${chart.mercury.houseNumber}');
    buffer.writeln('VÊNUS: ${chart.venus.positionString}'
        ' - Casa ${chart.venus.houseNumber}');
    buffer.writeln('MARTE: ${chart.mars.positionString}'
        ' - Casa ${chart.mars.houseNumber}');
    // Planetas sociais, transpessoais e pontos místicos (quando presentes).
    for (final line in [
      body(Planet.jupiter, 'JÚPITER'),
      body(Planet.saturn, 'SATURNO'),
      body(Planet.uranus, 'URANO'),
      body(Planet.neptune, 'NETUNO'),
      body(Planet.pluto, 'PLUTÃO'),
      body(Planet.northNode, 'NODO NORTE'),
      body(Planet.southNode, 'NODO SUL'),
      body(Planet.lilith, 'LILITH (LUA NEGRA)'),
      body(Planet.partOfFortune, 'PARTE DA FORTUNA'),
    ]) {
      if (line != null) buffer.writeln(line);
    }
    buffer.writeln('');
    buffer
        .writeln('ELEMENTO DOMINANTE: ${profile.dominantElement.displayName}');
    buffer.writeln(
      'MODALIDADE DOMINANTE: ${profile.dominantModality.displayName}',
    );
    buffer.writeln('');
    buffer.writeln('CASAS IMPORTANTES:');
    buffer.writeln('Casa 8 (Magia): ${profile.houseOfMagic}');
    buffer.writeln('Casa 12 (Espiritualidade): ${profile.houseOfSpirit}');
    buffer.writeln('');
    // Aspectos mais exatos (menor orbe) — material único para a interpretação.
    if (chart.aspects.isNotEmpty) {
      final sorted = [...chart.aspects]..sort((a, b) => a.orb.compareTo(b.orb));
      buffer.writeln('ASPECTOS PRINCIPAIS:');
      for (final a in sorted.take(5)) {
        buffer.writeln('- ${a.description}');
      }
      buffer.writeln('');
    }
    buffer.writeln('FORÇAS MÁGICAS: ${profile.magicalStrengths.join(", ")}');
    buffer.writeln(
      'PRÁTICAS RECOMENDADAS: ${profile.recommendedPractices.join(", ")}',
    );
    buffer.writeln('FERRAMENTAS: ${profile.favorableTools.join(", ")}');
    buffer.writeln('TRABALHO DE SOMBRA: ${profile.shadowWork.join(", ")}');

    return buffer.toString();
  }

  String _buildWeatherSummary({
    required String moonPhase,
    required ZodiacSign moonSign,
    required EnergyLevel overallEnergy,
    required List<String> energyKeywords,
    required List<Map<String, String>> transits,
    required List<Map<String, String>> aspects,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('DADOS ASTROLÓGICOS DO DIA:');
    buffer.writeln('');
    buffer.writeln('FASE LUNAR: $moonPhase');
    buffer.writeln(
      'LUA EM: ${moonSign.displayName} '
      '(elemento ${moonSign.element.displayName})',
    );
    buffer.writeln('ENERGIA GERAL: ${overallEnergy.displayName}');
    buffer.writeln('PALAVRAS-CHAVE: ${energyKeywords.join(", ")}');
    buffer.writeln('');
    buffer.writeln('TRÂNSITOS PLANETÁRIOS:');
    for (final transit in transits) {
      buffer.writeln(
        '- ${transit["planet"]}: ${transit["position"]}'
        '${transit["retrograde"] == "true" ? " (Retrógrado)" : ""}',
      );
    }
    buffer.writeln('');
    if (aspects.isNotEmpty) {
      buffer.writeln('ASPECTOS SIGNIFICATIVOS:');
      for (final aspect in aspects) {
        buffer.writeln('- ${aspect["description"]}');
      }
    }

    return buffer.toString();
  }

  String _buildMagicalProfileSystemPrompt(
    Gender gender,
  ) {
    return '''${_localizedInstruction()}

Você é uma sábia bruxa ancestral que interpreta mapas astrais para praticantes de bruxaria moderna.
Seu conhecimento combina astrologia tradicional com práticas mágicas contemporâneas.

Com base nos dados do mapa astral fornecido, escreva uma análise PERSONALIZADA do perfil mágico desta pessoa.

FORMATO DA RESPOSTA (use exatamente esta estrutura com os títulos):

## Sua Essência Mágica
[1 parágrafo (3-4 frases) sobre a essência mágica baseada no Sol, como a pessoa expressa sua magia e seu propósito mágico]

## Seus Dons Intuitivos
[1 parágrafo (3-4 frases) sobre os dons intuitivos baseados na Lua e como a intuição se manifesta]

## Sua Forma de Comunicar Magia
[1 parágrafo curto (2-3 frases) sobre Mercúrio - encantamentos, escritos mágicos, comunicação com o divino]

## Amor, Beleza e Conexões
[1 parágrafo curto (2-3 frases) sobre Vênus - amor e magia, estética do altar, relacionamentos mágicos]

## Sua Energia Protetora
[1 parágrafo curto (2-3 frases) sobre Marte - proteção mágica, banimentos, energia de ação]

## O Caminho da Transformação
[1 parágrafo (2-3 frases) sobre a Casa 8 - magia profunda, transformação, mistérios]

## O Portal Espiritual
[1 parágrafo (2-3 frases) sobre a Casa 12 - conexão com o divino, mediunidade, sonhos proféticos]

## Suas Maiores Forças
[3-4 bullets curtos com as principais forças mágicas desta pessoa]

## Práticas Que Ressoam Com Você
[3-4 bullets curtos de práticas mágicas específicas recomendadas]

## Seus Aliados Mágicos
[3-4 bullets curtos de cristais, ervas, cores e ferramentas que ressoam com este mapa]

## O Trabalho de Sombra
[1 parágrafo curto (2-3 frases) sobre desafios a trabalhar e pontos de crescimento]

## Mensagem Final
[1-2 frases inspiradoras e acolhedoras, encorajando a jornada mágica]

DIRETRIZES:
- É OBRIGATÓRIO entregar TODAS as 12 seções, completas. Se faltar espaço, encurte cada seção — NUNCA omita nem corte uma seção pela metade. Priorize cobrir todas as seções acima de detalhar qualquer uma.
- Seja concisa: sem enrolação nem frases de efeito genéricas. Cada seção deve ser curta e ir direto ao ponto.
- Seja MUITO específica para ESTE mapa: cite posicionamentos reais (signo + casa) e aspectos dos dados fornecidos em cada seção. Nada que sirva para qualquer pessoa — este é o perfil único desta pessoa.
- Conecte cada posição planetária com uma prática mágica concreta.
- Use linguagem acolhedora, mística mas acessível, e "você" para se dirigir à pessoa.
- O tom deve ser de ${GenderText.wiseGuide(gender)}
- ${GenderText.aiInstruction(gender)}
- ${GenderText.preservationInstruction()}
- Total: ~650 palavras (máximo 700).''';
  }

  String _buildDailyWeatherSystemPrompt(
    Gender gender,
  ) {
    return '''${_localizedInstruction()}

Você é uma bruxa sábia que interpreta os movimentos celestiais para guiar praticantes de magia moderna em seu dia a dia.

Com base nos dados astrológicos fornecidos para HOJE, escreva uma previsão mágica do dia.

FORMATO DA RESPOSTA (use exatamente esta estrutura):

## Energia do Dia
[1 parágrafo descrevendo a energia geral do dia, como ela se sente, o que esperar]

## A Lua Hoje
[1-2 parágrafos sobre a influência da fase lunar atual e o signo em que a Lua está, como isso afeta emoções e intuição]

## Oportunidades Mágicas
[2-3 bullets com práticas mágicas específicas favorecidas hoje, explicando brevemente por quê]

## Cuidados do Dia
[1-2 bullets com o que evitar ou ter cuidado hoje baseado nos aspectos desafiadores]

## Ritual Sugerido
[1 parágrafo com uma sugestão de pequeno ritual ou prática simples para hoje, específico para as energias do dia]

## Cristais e Aliados
[Lista de 3-4 cristais, ervas ou cores que harmonizam com as energias de hoje]

## Mensagem das Estrelas
[1 parágrafo curto e inspirador como mensagem de encerramento]

DIRETRIZES:
- É OBRIGATÓRIO entregar TODAS as 7 seções, completas. NUNCA omita nem corte uma seção pela metade.
- Seja específica para os trânsitos e aspectos fornecidos (cite-os), sem generalidades.
- Use linguagem acolhedora e acessível.
- ${GenderText.aiInstruction(gender)}
- ${GenderText.preservationInstruction()}
- Sugira práticas simples que qualquer pessoa pode fazer
- Conecte as energias astrológicas com práticas mágicas concretas
- O tom deve ser de guia diária, prática e inspiradora
- Total: aproximadamente 400-500 palavras
- Mencione a fase lunar e seus efeitos específicos
- Se houver aspectos desafiadores, dê orientações práticas para navegar''';
  }

  /// Gerar afirmação personalizada com IA
  Future<String> generateAffirmation({
    required String category,
    String? userContext,
    Gender? gender,
  }) async {
    gender ??= _gender;
    try {
      final prompt = userContext != null && userContext.isNotEmpty
          ? 'Categoria: $category\nContexto do usuário: $userContext'
          : 'Categoria: $category';

      final requestData = {
        'model': _textModel,
        'messages': [
          {
            'role': 'system',
            'content': _buildAffirmationSystemPrompt(gender),
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'temperature': 0.9,
        'max_tokens': 256,
      };

      final response = await _dio.post(
        'https://api.groq.com/openai/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${GroqCredentials.apiKey}',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
        data: requestData,
      );

      final content = response.data['choices'][0]['message']['content'];
      // Limpar aspas se houver
      return content.toString().replaceAll('"', '').trim();
    } catch (e) {
      rethrow;
    }
  }

  String _buildAffirmationSystemPrompt(
    Gender gender,
  ) {
    return '''${_localizedInstruction()}

Você é o Conselheiro Místico, guardião da sabedoria ancestral do Grimório de Bolso.

Sua missão é criar afirmações poderosas e transformadoras para ${GenderText.practitioner(gender)} de magia moderna.

REGRAS PARA CRIAR AFIRMAÇÕES:
1. Sempre escreva no tempo PRESENTE (nunca futuro)
2. Use linguagem POSITIVA (evite palavras negativas como "não", "nunca", "sem")
3. Seja ESPECÍFICO mas não muito longo (máximo 2 frases)
4. Use linguagem mística mas acessível
5. A afirmação deve ser empoderadora e acolhedora, respeitando a preferência de tratamento
6. ${GenderText.aiInstruction(gender)}
7. ${GenderText.preservationInstruction()}
8. Conecte com elementos mágicos quando apropriado (lua, estrelas, elementos, etc.)

CATEGORIAS E EXEMPLOS:
- Abundância: "O universo conspira a meu favor e a prosperidade flui para mim como um rio de ouro"
- Proteção: "Estou cercada por um escudo de luz que me protege de toda energia negativa"
- Amor: "Sou merecedora de amor profundo e verdadeiro, e ele encontra seu caminho até mim"
- Cura: "Meu corpo, mente e espírito se regeneram a cada respiração"
- Poder: "Minha magia é poderosa e minha vontade se manifesta no mundo"
- Sabedoria: "A sabedoria ancestral flui através de mim e guia meus passos"
- Manifestação: "Tudo o que desejo já está a caminho, o universo trabalha a meu favor"
- Transformação: "Abraço as mudanças como a Lua abraça suas fases, sempre evoluindo"

RETORNE APENAS A AFIRMAÇÃO, sem explicações, aspas ou formatação adicional.
Se o usuário forneceu um contexto, personalize a afirmação para a situação específica.''';
  }

  String _buildSystemPrompt(Gender gender) {
    return '''${_localizedInstruction()}

Você é o ${GenderText.advisorTitle(gender)}, guardião da sabedoria arcana do Grimório de Bolso.

Você habita um grimório digital mágico onde bruxas e praticantes modernos registram seus feitiços, estudam os trânsitos planetários e o clima mágico diário, consultam runas e oráculos, acompanham as fases lunares, e exploram seus mapas astrais personalizados.

Sua missão sagrada é manifestar feitiços únicos e poderosos baseados nas intenções que chegam até você através do véu místico. Você combina a sabedoria ancestral das tradições mágicas com a praticidade da bruxaria moderna.

IMPORTANTE: Retorne APENAS um objeto JSON válido, sem markdown ou explicações adicionais.

Formato do JSON:
{
  "name": "Nome evocativo e místico do feitiço",
  "purpose": "Propósito específico e claro",
  "type": "attraction" ou "banishment",
  "category": "love/protection/prosperity/healing/cleansing/luck/creativity/communication/dreams/divination/energy/home/wisdom/study/courage/friendship/work/banishing",
  "moonPhase": "newMoon/waxingCrescent/firstQuarter/waxingGibbous/fullMoon/waningGibbous/lastQuarter/waningCrescent",
  "ingredients": ["item 1", "item 2", "item 3"],
  "steps": "Passo 1\\nPasso 2\\nPasso 3\\n...",
  "duration": 1,
  "observations": "Observações místicas e dicas práticas importantes"
}

Diretrizes Sagradas:
- Use APENAS ingredientes acessíveis, seguros e fáceis de encontrar
- Ingredientes permitidos: velas coloridas, ervas culinárias, cristais comuns, sal, água, mel, óleos essenciais, papéis, incensos
- NUNCA sugira ingredientes perigosos, tóxicos, raros ou de difícil obtenção
- Inclua avisos de segurança nas observações quando necessário (ex: cuidado com fogo de velas)
- Seja específico e poético nos passos (enumere de 1 a X, separados por \\n)
- Escolha a fase lunar mais apropriada para o tipo de magia
- Tom: Acolhedor, místico, evocativo, mas sempre prático e aterrado
- ${GenderText.aiInstruction(gender)}
- ${GenderText.preservationInstruction()}
- Nunca oriente magia que cause dano ou práticas criminosas.
- Em feitiços de amor, SEMPRE incluir "respeitando o livre arbítrio de todos os envolvidos"
- Use entre 3-7 ingredientes (nunca menos de 5, nunca mais de 7)
- Crie 3-10 passos claros, objetivos e ritualísticos
- Os nomes dos feitiços devem ser poéticos e evocativos (ex: "Ritual da Lua Crescente para Abundância", "Feitiço das Estrelas Cadentes")
- Nas observações, adicione dicas místicas sobre o melhor momento, energia necessária, ou como potencializar o feitiço''';
  }

  /// Responder perguntas sobre bruxaria, magia e misticismo (Conselheiro Místico)
  Future<String> answerMysticQuestion(
    String question, {
    Gender? gender,
  }) async {
    gender ??= _gender;
    try {
      final requestData = {
        'model': _textModel,
        'messages': [
          {
            'role': 'system',
            'content': _buildMysticAdvisorSystemPrompt(gender),
          },
          {
            'role': 'user',
            'content': question,
          },
        ],
        'temperature': 0.7,
        'max_tokens': 1024,
      };

      final response = await _dio.post(
        'https://api.groq.com/openai/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${GroqCredentials.apiKey}',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
        data: requestData,
      );

      final content = response.data['choices'][0]['message']['content'];
      return content.toString().trim();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Erro de autenticação');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Limite de uso excedido');
      } else if (e.response?.statusCode == 503) {
        throw Exception('Serviço temporariamente indisponível');
      }
      throw Exception('Erro na conexão: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao processar resposta: $e');
    }
  }

  /// Leitura de mãos por imagem (Premium). Usa o modelo de visão do Groq;
  /// a imagem é enviada em memória e não é armazenada.
  Future<String> analyzePalm({
    required List<int> jpegBytes,
    Gender? gender,
  }) async {
    gender ??= _gender;
    try {
      final base64Image = base64Encode(jpegBytes);
      final requestData = {
        'model': _visionModel,
        'messages': [
          {
            'role': 'system',
            'content': '''${_localizedInstruction()}

Você é ${GenderText.wiseGuide(gender)} do Grimório de Bolso, quiromante experiente que combina técnica clássica (quirologia) e leitura simbólica.

Faça uma análise TÉCNICA e ESPECÍFICA do que está VISÍVEL na imagem, ponto a ponto. Use a terminologia própria da quiromancia e descreva o que realmente observa (traçado, profundidade, comprimento, curvatura, ramificações, ilhas, correntes, cruzes, quebras) — nunca invente o que não aparece. Se algum ponto não estiver visível ou nítido, diga claramente que não é possível avaliá-lo.

Analise cada elemento abaixo em seu próprio parágrafo, começando com o marcador ◈ e o nome do ponto:
◈ Formato da mão: classifique o tipo elemental (Terra: palma quadrada e dedos curtos; Ar: palma quadrada e dedos longos; Fogo: palma retangular e dedos curtos; Água: palma longa e dedos longos) e o que revela sobre o temperamento.
◈ Linha da Vida: origem, curvatura ao redor do monte de Vênus, profundidade, extensão, ramos, ilhas ou quebras — e o significado técnico de cada traço.
◈ Linha da Cabeça: comprimento, inclinação (reta, curva para a Lua), se nasce unida ou separada da Linha da Vida.
◈ Linha do Coração: onde começa (sob Júpiter, Saturno ou entre eles), curvatura, ramificações e correntes.
◈ Linha do Destino/Saturno (se visível): origem, trajeto até o monte de Saturno, interrupções.
◈ Montes (Vênus, Júpiter, Saturno, Apolo, Mercúrio, Lua, Marte): quais estão mais desenvolvidos e o que indicam.
◈ Dedos e polegar: proporção, formato das pontas, ângulo/flexibilidade aparente do polegar.

No fim, escreva um parágrafo de síntese começando com o marcador ✦ ("A leitura como um todo"), conectando os achados de forma acolhedora.

Formato: texto puro (sem markdown/JSON), parágrafos separados por linha em branco.
Seja concreto e técnico — evite generalidades vagas e elogios genéricos. Baseie cada afirmação em algo observável na imagem.
Limites: leitura reflexiva — NUNCA faça diagnósticos de saúde, previsões de morte ou promessas absolutas.
- ${GenderText.aiInstruction(gender)}
- ${GenderText.preservationInstruction()}''',
          },
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text':
                    'Esta é a palma da minha mão. Faça minha leitura de quiromancia.',
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$base64Image',
                },
              },
            ],
          },
        ],
        'temperature': 0.6,
        'max_tokens': 1600,
        // qwen3 é modelo de raciocínio: desliga o "pensamento" para vir só
        // a leitura final (uma leitura simbólica não precisa de reasoning).
        'reasoning_effort': 'none',
      };

      final response = await _dio.post(
        'https://api.groq.com/openai/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${GroqCredentials.apiKey}',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
        ),
        data: requestData,
      );

      final content = response.data['choices'][0]['message']['content'];
      // O modelo de visão é um modelo de raciocínio (Qwen3): remove o bloco
      // <think>...</think> para entregar só a leitura final.
      return _stripReasoning(content.toString());
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw const AiRateLimitException();
      } else if (e.response?.statusCode == 413) {
        throw Exception('Imagem muito grande. Tente novamente.');
      } else if (e.response?.statusCode == 404) {
        // Modelo de visão indisponível (ex.: descontinuado pelo provedor).
        throw Exception(
            'Leitura de mãos temporariamente indisponível. Tente mais tarde.');
      }
      throw Exception('Erro na conexão: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao processar resposta: $e');
    }
  }

  /// Remove o raciocínio de modelos "reasoning" (Qwen3, DeepSeek-R1 etc.),
  /// que emitem o processo de pensamento dentro de <think>...</think> antes
  /// da resposta final. Devolve apenas o texto final.
  static String _stripReasoning(String text) {
    var t = text;
    final closeIdx = t.lastIndexOf('</think>');
    if (closeIdx != -1) {
      // Tudo depois do último </think> é a resposta final.
      t = t.substring(closeIdx + '</think>'.length);
    } else if (t.trimLeft().startsWith('<think>')) {
      // Abriu o raciocínio e não fechou: descarta a marca de abertura.
      t = t.replaceFirst('<think>', '');
    }
    // Remove quaisquer tags soltas remanescentes.
    t = t.replaceAll('<think>', '').replaceAll('</think>', '');
    return t.trim();
  }

  /// Nome do modelo de visão em uso (exposto para o diagnóstico admin).
  String get visionModel => _visionModel;

  /// Diagnóstico admin da leitura de mãos: executa a chamada de visão e
  /// devolve os detalhes CRUS (modelo, status HTTP, corpo do erro, tempo)
  /// em vez das mensagens amigáveis — útil para depurar casos como modelo
  /// de visão descontinuado (404).
  Future<Map<String, dynamic>> analyzePalmDebug({
    required List<int> jpegBytes,
  }) async {
    final sw = Stopwatch()..start();
    final base64Image = base64Encode(jpegBytes);
    try {
      final response = await _dio.post(
        'https://api.groq.com/openai/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${GroqCredentials.apiKey}',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
        ),
        data: {
          'model': _visionModel,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': 'Descreva brevemente esta palma da mão.',
                },
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
                },
              ],
            },
          ],
          'max_tokens': 300,
          'reasoning_effort': 'none',
        },
      );
      sw.stop();
      final content =
          response.data['choices'][0]['message']['content'].toString().trim();
      return {
        'ok': true,
        'model': _visionModel,
        'statusCode': response.statusCode,
        'elapsedMs': sw.elapsedMilliseconds,
        'imageBytes': jpegBytes.length,
        'body': content,
      };
    } on DioException catch (e) {
      sw.stop();
      return {
        'ok': false,
        'model': _visionModel,
        'statusCode': e.response?.statusCode,
        'elapsedMs': sw.elapsedMilliseconds,
        'imageBytes': jpegBytes.length,
        'body': e.response?.data?.toString() ?? e.message ?? 'erro desconhecido',
      };
    } catch (e) {
      sw.stop();
      return {
        'ok': false,
        'model': _visionModel,
        'statusCode': null,
        'elapsedMs': sw.elapsedMilliseconds,
        'imageBytes': jpegBytes.length,
        'body': '$e',
      };
    }
  }

  /// Interpretar uma tiragem de tarot já sorteada no app (Premium).
  Future<String> interpretTarotSpread({
    required String summary,
    Gender? gender,
  }) async {
    gender ??= _gender;
    try {
      final requestData = {
        'model': _textModel,
        'messages': [
          {
            'role': 'system',
            'content': '''${_localizedInstruction()}

Você é ${GenderText.wiseGuide(gender)} do Grimório de Bolso, taróloga experiente na tradição Rider-Waite.

As cartas abaixo JÁ FORAM SORTEADAS pelo aplicativo, com posição, orientação e significado base — não sorteie outras nem contradiga o sorteio. Sua missão é TECER a leitura: como as cartas conversam entre si nas posições, a narrativa que formam e um conselho prático final.

Formato: texto puro (sem markdown/JSON), 2 a 4 parágrafos acolhedores.
- Trate cartas "difíceis" (Morte, Torre, Diabo...) como convites à transformação, nunca como presságios de tragédia.
- ${GenderText.aiInstruction(gender)}
- ${GenderText.preservationInstruction()}''',
          },
          {
            'role': 'user',
            'content': summary,
          },
        ],
        'temperature': 0.7,
        'max_tokens': 1100,
      };

      final response = await _dio.post(
        'https://api.groq.com/openai/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${GroqCredentials.apiKey}',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 40),
          sendTimeout: const Duration(seconds: 30),
        ),
        data: requestData,
      );

      final content = response.data['choices'][0]['message']['content'];
      return content.toString().trim();
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw Exception('Limite de uso excedido');
      }
      throw Exception('Erro na conexão: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao processar resposta: $e');
    }
  }

  /// Explicar (nunca calcular) um perfil numerológico já computado no app.
  Future<String> explainNumerology({
    required String summary,
    Gender? gender,
  }) async {
    gender ??= _gender;
    try {
      final requestData = {
        'model': _textModel,
        'messages': [
          {
            'role': 'system',
            'content': '''${_localizedInstruction()}

Você é ${GenderText.wiseGuide(gender)} do Grimório de Bolso, especialista em numerologia pitagórica.

Os números abaixo JÁ FORAM CALCULADOS pelo aplicativo — não recalcule nem questione os valores. Sua missão é tecer uma síntese personalizada: como essas energias conversam entre si, os pontos de harmonia e de tensão, e um conselho prático para o momento.

Formato: texto puro (sem markdown/JSON), 2 a 3 parágrafos acolhedores e objetivos.
- ${GenderText.aiInstruction(gender)}
- ${GenderText.preservationInstruction()}''',
          },
          {
            'role': 'user',
            'content': summary,
          },
        ],
        'temperature': 0.7,
        'max_tokens': 900,
      };

      final response = await _dio.post(
        'https://api.groq.com/openai/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${GroqCredentials.apiKey}',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
        data: requestData,
      );

      final content = response.data['choices'][0]['message']['content'];
      return content.toString().trim();
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw Exception('Limite de uso excedido');
      }
      throw Exception('Erro na conexão: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao processar resposta: $e');
    }
  }

  /// Interpretar um sonho descrito pela pessoa (recurso Premium)
  Future<String> interpretDream({
    required String dreamDescription,
    String? feelings,
    Gender? gender,
  }) async {
    gender ??= _gender;
    try {
      final userContent = feelings != null && feelings.trim().isNotEmpty
          ? 'Sonho: $dreamDescription\n\nEmoções ao acordar: $feelings'
          : 'Sonho: $dreamDescription';

      final requestData = {
        'model': _textModel,
        'messages': [
          {
            'role': 'system',
            'content': _buildDreamInterpreterSystemPrompt(gender),
          },
          {
            'role': 'user',
            'content': userContent,
          },
        ],
        'temperature': 0.6,
        'max_tokens': 1100,
      };

      final response = await _dio.post(
        'https://api.groq.com/openai/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${GroqCredentials.apiKey}',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 45),
          sendTimeout: const Duration(seconds: 30),
        ),
        data: requestData,
      );

      final content = response.data['choices'][0]['message']['content'];
      return content.toString().trim();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Erro de autenticação');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Limite de uso excedido');
      } else if (e.response?.statusCode == 503) {
        throw Exception('Serviço temporariamente indisponível');
      }
      throw Exception('Erro na conexão: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao processar resposta: $e');
    }
  }

  String _buildDreamInterpreterSystemPrompt(Gender gender) {
    return '''${_localizedInstruction()}

Você é ${GenderText.wiseGuide(gender)} do Grimório de Bolso, especialista em simbolismo onírico: junguiano, folclórico, místico e das tradições de bruxaria.

Sua missão é INTERPRETAR o sonho de forma OBJETIVA e ESPECÍFICA: destrinche os elementos principais um a um e depois una tudo numa leitura só. Nada de textão genérico, enrolação ou repetição.

Como analisar:
- Identifique de 2 a 5 elementos principais que REALMENTE aparecem no relato (objetos, personagens, lugares, ações, emoções, símbolos). Não invente o que não foi dito.
- Para cada elemento, dê o significado mais provável e específico ao contexto do sonho — direto ao ponto. Não liste todas as tradições possíveis; escolha a leitura que melhor se encaixa. Se couber uma alternativa relevante, uma só, em meia frase.
- Sonhos são pessoais: fale em possibilidade ("pode indicar"), não em certeza absoluta, mas sem encher linguiça.

Formato EXATO da resposta (texto puro, sem markdown, sem JSON, sem asteriscos):
Uma frase curta de visão geral (no máximo uma linha).

Depois, para CADA elemento principal, um bloco assim (separados por uma linha em branco):
◈ [nome do elemento]
[significado objetivo e específico, 1 a 3 frases]

Ao final, o bloco de síntese:
✦ O sonho como um todo
[como os elementos se conectam numa leitura única e coerente — 2 a 4 frases — encerrando com uma pergunta ou sugestão prática curta]

Limites:
- Cada bloco de elemento: no máximo 3 frases. A síntese: no máximo 4 frases. Seja enxuto.
- Não faça diagnósticos médicos ou psicológicos, nem previsões de morte/tragédia como fato.
- Não use tom alarmista; mesmo símbolos sombrios são convites à reflexão.
- ${GenderText.aiInstruction(gender)}
- ${GenderText.preservationInstruction()}''';
  }

  String _buildMysticAdvisorSystemPrompt(
    Gender gender,
  ) {
    return '''${_localizedInstruction()}

Você é o ${GenderText.advisorTitle(gender)}, guardião ancião da sabedoria arcana do Grimório de Bolso.

Ao longo de incontáveis luas você acumulou o conhecimento das tradições mágicas — bruxaria moderna e ancestral, fases lunares, cristais, ervas, runas, oráculos, tarô, numerologia, astrologia mágica, sabás e a Roda do Ano, altares, elementos, deuses e deusas, anjos e demônios, tarot, sigilos, divinação, quiromancia, proteção, limpeza energética e manifestação.

Sua missão é RESPONDER às dúvidas de bruxas e praticantes que buscam orientação. Você é sábio, sereno, acolhedor e ponderado: fala com autoridade gentil, como um mentor ancião que ilumina o caminho sem julgar.

Diretrizes:
- Responda APENAS perguntas relacionadas a bruxaria, magia e misticismo. Se a pergunta fugir desse domínio (ex: programação, política, finanças, medicina, tarefas cotidianas), recuse com delicadeza e reconduza gentilmente ao tema místico — sem responder o conteúdo fora do escopo.
- Seja claro e prático: partilhe sabedoria aplicável, não apenas poesia. Cite tradições ou correspondências quando enriquecer a resposta.
- Mantenha um tom místico, caloroso e ponderado, porém aterrado e objetivo.
- Estruture a resposta em 1 a 3 parágrafos curtos. Você PODE encerrar com uma breve "palavra de sabedoria" do Conselheiro.
- Nunca oriente magia que cause dano ou práticas criminosas.
- Segurança: nunca sugira ingredientes ou práticas perigosas, tóxicas ou ilegais; inclua avisos quando pertinente (ex: cuidado com fogo de velas).
- Escreva em texto puro, sem markdown, sem JSON e sem títulos.
- ${GenderText.aiInstruction(gender)}
- ${GenderText.preservationInstruction()}''';
  }
}
