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

/// Serviço de IA usando Groq (gratuito, sem API key necessária)
class AIService {
  static final AIService instance = AIService._();

  AIService._();

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
        'model': 'llama-3.3-70b-versatile',
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
        'model': 'llama-3.3-70b-versatile',
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

      final content = response.data['choices'][0]['message']['content'];
      return content;
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
        'model': 'llama-3.3-70b-versatile',
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

      final content = response.data['choices'][0]['message']['content'];
      return content;
    } catch (e) {
      rethrow;
    }
  }

  String _buildChartSummary(BirthChartModel chart, MagicalProfile profile) {
    final buffer = StringBuffer();

    buffer.writeln('DADOS DO MAPA ASTRAL:');
    buffer.writeln('');
    buffer.writeln('SOL: ${chart.sun.positionString}');
    buffer.writeln('LUA: ${chart.moon.positionString}');
    if (chart.ascendant != null) {
      buffer.writeln('ASCENDENTE: ${chart.ascendant!.positionString}');
    }
    buffer.writeln('MERCÚRIO: ${chart.mercury.positionString}');
    buffer.writeln('VÊNUS: ${chart.venus.positionString}');
    buffer.writeln('MARTE: ${chart.mars.positionString}');
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
[2-3 parágrafos descrevendo a essência mágica baseada no Sol, como a pessoa expressa sua magia naturalmente, qual é seu propósito mágico]

## Seus Dons Intuitivos
[2-3 parágrafos sobre os dons intuitivos baseados na Lua, como a intuição se manifesta, momentos em que a magia flui naturalmente]

## Sua Forma de Comunicar Magia
[1-2 parágrafos sobre como a pessoa se comunica magicamente, baseado em Mercúrio - encantamentos, escritos mágicos, comunicação com o divino]

## Amor, Beleza e Conexões
[1-2 parágrafos sobre Vênus - como a pessoa conecta amor e magia, estética do altar, relacionamentos mágicos]

## Sua Energia Protetora
[1-2 parágrafos sobre Marte - como a pessoa se protege magicamente, estilo de banimentos, energia de ação mágica]

## O Caminho da Transformação
[2 parágrafos sobre a Casa 8 - magia profunda, transformação, mistérios, sexualidade mágica]

## O Portal Espiritual
[2 parágrafos sobre a Casa 12 - conexão com o divino, mediunidade, sonhos proféticos, karma]

## Suas Maiores Forças
[Lista em bullets das principais forças mágicas desta pessoa]

## Práticas Que Ressoam Com Você
[Lista em bullets de práticas mágicas específicas recomendadas]

## Seus Aliados Mágicos
[Lista em bullets de cristais, ervas, cores e ferramentas que ressoam com este mapa]

## O Trabalho de Sombra
[1-2 parágrafos sobre desafios a serem trabalhados, pontos de crescimento]

## Mensagem Final
[1 parágrafo inspirador e acolhedor, encorajando a jornada mágica]

DIRETRIZES:
- Use linguagem acolhedora, mística mas acessível
- Seja específica nas interpretações, não genérica
- Conecte cada posição planetária com práticas mágicas concretas
- Mencione fases lunares, sabbats e momentos propícios quando relevante
- O tom deve ser de ${GenderText.wiseGuide(gender)}
- Use "você" para se dirigir à pessoa
- ${GenderText.aiInstruction(gender)}
- ${GenderText.preservationInstruction()}
- Não repita informações genéricas sobre signos - seja específica para esta configuração única
- Total: aproximadamente 800-1000 palavras''';
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
- Seja específica para os trânsitos e aspectos fornecidos
- Use linguagem acolhedora e acessível
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
        'model': 'llama-3.3-70b-versatile',
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
        'model': 'llama-3.3-70b-versatile',
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
