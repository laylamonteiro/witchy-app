import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import '../i18n/gender.dart';
import '../services/debug_log_service.dart';
import '../utils/accents.dart';
import '../../features/astrology/data/models/birth_chart_model.dart';
import '../../features/astrology/data/models/enums.dart';
import '../../features/astrology/data/models/magical_profile_model.dart';
import '../../features/grimoire/data/models/spell_model.dart';
import 'gemini_credentials.dart';
import 'groq_credentials.dart';
import 'prompts/ai_prompts.dart';

/// Erro de limite de uso do provedor de IA (HTTP 429). A chave da Groq é
/// compartilhada, então o teto é do serviço, não por usuário. A tela decide
/// a mensagem (para poder localizar e orientar o reenvio).
class AiRateLimitException implements Exception {
  const AiRateLimitException();
}

/// Serviço de IA: Gemini como provedor principal (texto e visão) quando a
/// chave está configurada, com o Groq como fallback automático em caso de
/// falha ou de chave ausente. Os logs de debug (tag AI) registram qual
/// provedor respondeu cada chamada.
class AIService {
  static final AIService instance = AIService._();

  AIService._();

  /// Modelo de texto do Groq (fallback).
  static const String _textModel = 'llama-3.3-70b-versatile';

  /// Modelo de texto principal (Google Gemini) — o mesmo GA da visão.
  static const String _geminiTextModel = 'gemini-3.6-flash';

  /// Modelo de visão do Groq (fallback). O Groq descontinua modelos com
  /// frequência — a família Llama 4 (Scout/Maverick) foi aposentada em 2026
  /// e o preview que sobrou é fraco em identificação fina; por isso a visão
  /// principal é o Gemini (abaixo) quando a chave está configurada.
  static const String _visionModel = 'qwen/qwen3.6-27b';

  /// Modelo de visão principal (Google Gemini): identificação de plantas e
  /// pedras de verdade, e leitura de mãos com detalhe real. O 2.5-flash
  /// fechou para chaves novas ("no longer available to new users") — o
  /// 3.6-flash é o modelo GA vigente.
  static const String _geminiVisionModel = 'gemini-3.6-flash';

  /// O Gemini está configurado? (Sem a chave, a visão cai para o Groq.)
  static bool get _hasGemini => GeminiCredentials.apiKey.isNotEmpty;

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

  /// Prompts/mensagens no idioma atual (via [ContentLocale], mantido em
  /// sincronia com [_locale] pelo LanguageProvider).
  AiPrompts get _prompts => aiPrompts;

  /// Reforço de idioma prefixado em todo prompt de sistema — mantido mesmo
  /// com os prompts já traduzidos, para fixar o idioma da resposta.
  String _localizedInstruction() =>
      _prompts.localizedInstruction(currentLanguageTag);

  /// Verificar se o serviço está disponível (sempre true para Groq)
  Future<bool> hasApiKey() async {
    return true;
  }

  /// Gerar feitiço com IA
  Future<SpellModel> generateSpell(
    String userIntention, {
    Gender? gender,
  }) async {
    return _generateSpellWithAi(
      userIntention,
      gender: gender ?? _gender,
    );
  }

  Future<SpellModel> _generateSpellWithAi(
    String intention, {
    required Gender gender,
  }) async {
    try {
      final content = await _textRequest(
        systemPrompt: _buildSystemPrompt(gender),
        userText: intention,
        tag: 'feitiço',
        temperature: 0.8,
        maxTokens: 1024,
        jsonResponse: true,
        receiveTimeout: const Duration(seconds: 30),
      );
      final spellData = _extractJsonObject(content);
      return _parseSpellData(spellData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        // Erro 400 - requisição inválida
        final errorData = e.response?.data;
        String errorMessage = _prompts.errorInvalidRequest;

        if (errorData != null && errorData is Map) {
          if (errorData.containsKey('error')) {
            final error = errorData['error'];
            if (error is Map && error.containsKey('message')) {
              errorMessage = error['message'];
            }
          }
        }

        throw Exception(_prompts.errorBadRequest(errorMessage));
      } else if (e.response?.statusCode == 401) {
        throw Exception(_prompts.errorAuthentication);
      } else if (e.response?.statusCode == 429) {
        throw Exception(_prompts.errorRateLimit);
      } else if (e.response?.statusCode == 503) {
        throw Exception(_prompts.errorServiceUnavailable);
      }
      throw Exception(_prompts.errorConnection(e.message));
    } catch (e) {
      throw Exception(_prompts.errorProcessing(e));
    }
  }

  SpellModel _parseSpellData(Map<String, dynamic> data) {
    return SpellModel(
      id: const Uuid().v4(),
      name: data['name'] ?? _prompts.defaultSpellName,
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

      return await _textRequest(
        systemPrompt: _buildMagicalProfileSystemPrompt(gender ?? _gender),
        userText: chartSummary,
        tag: 'perfil mágico',
        temperature: 0.7,
        maxTokens: 2048,
      );
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

      return await _textRequest(
        systemPrompt: _buildDailyWeatherSystemPrompt(gender),
        userText: weatherSummary,
        tag: 'clima do dia',
        temperature: 0.8,
        maxTokens: 1536,
      );
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
    return '${_localizedInstruction()}\n\n'
        '${_prompts.magicalProfileSystemPrompt(gender)}';
  }

  /// Prompt do Clima Mágico Diário. O prompt de cada idioma exige EXATAMENTE
  /// os cabeçalhos de `dailyWeatherFallbackHeadings{Pt,En,Es}` — o cache é
  /// validado por `DailyWeatherContent.looksComplete` no idioma da geração.
  String _buildDailyWeatherSystemPrompt(
    Gender gender,
  ) {
    return '${_localizedInstruction()}\n\n'
        '${_prompts.dailyWeatherSystemPrompt(gender)}';
  }

  /// Gerar afirmação personalizada com IA
  Future<String> generateAffirmation({
    required String category,
    String? userContext,
    Gender? gender,
  }) async {
    gender ??= _gender;
    try {
      final prompt = _prompts.affirmationUserPrompt(category, userContext);

      final content = await _textRequest(
        systemPrompt: _buildAffirmationSystemPrompt(gender),
        userText: prompt,
        tag: 'afirmação',
        temperature: 0.9,
        maxTokens: 256,
        receiveTimeout: const Duration(seconds: 30),
      );
      // Limpar aspas se houver
      return content.replaceAll('"', '').trim();
    } catch (e) {
      rethrow;
    }
  }

  String _buildAffirmationSystemPrompt(
    Gender gender,
  ) {
    return '${_localizedInstruction()}\n\n'
        '${_prompts.affirmationSystemPrompt(gender)}';
  }

  String _buildSystemPrompt(Gender gender) {
    return '${_localizedInstruction()}\n\n'
        '${_prompts.spellGenerationSystemPrompt(gender)}';
  }

  /// Responder perguntas sobre bruxaria, magia e misticismo (Conselheiro Místico)
  Future<String> answerMysticQuestion(
    String question, {
    Gender? gender,
  }) async {
    gender ??= _gender;
    try {
      final content = await _textRequest(
        systemPrompt: _buildMysticAdvisorSystemPrompt(gender),
        userText: question,
        tag: 'conselheiro',
        temperature: 0.7,
        maxTokens: 1024,
        receiveTimeout: const Duration(seconds: 30),
      );
      return content.trim();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception(_prompts.errorAuthentication);
      } else if (e.response?.statusCode == 429) {
        throw Exception(_prompts.errorRateLimit);
      } else if (e.response?.statusCode == 503) {
        throw Exception(_prompts.errorServiceUnavailable);
      }
      throw Exception(_prompts.errorConnection(e.message));
    } catch (e) {
      throw Exception(_prompts.errorProcessing(e));
    }
  }

  /// Chamada de TEXTO: Gemini como provedor principal (mesma chave da
  /// visão). Sem chave configurada — ou em falha do Gemini (limite,
  /// instabilidade, resposta vazia) — cai para o Groq automaticamente,
  /// então o recurso nunca fica refém de um provedor só. O provedor que
  /// respondeu fica nos logs de debug (tag AI).
  Future<String> _textRequest({
    required String systemPrompt,
    required String userText,
    required String tag,
    double temperature = 0.7,
    int maxTokens = 1024,
    bool jsonResponse = false,
    Duration receiveTimeout = const Duration(seconds: 60),
  }) async {
    if (_hasGemini) {
      try {
        final response = await _dio.post(
          'https://generativelanguage.googleapis.com/v1beta/models/'
          '$_geminiTextModel:generateContent',
          options: Options(
            headers: {
              'x-goog-api-key': GeminiCredentials.apiKey,
              'Content-Type': 'application/json',
            },
            receiveTimeout: receiveTimeout,
            sendTimeout: const Duration(seconds: 30),
          ),
          data: {
            if (systemPrompt.isNotEmpty)
              'system_instruction': {
                'parts': [
                  {'text': systemPrompt},
                ],
              },
            'contents': [
              {
                'role': 'user',
                'parts': [
                  {'text': userText},
                ],
              },
            ],
            'generationConfig': {
              'temperature': temperature,
              // Folga: no 3.x o "pensamento" mínimo consome tokens de
              // saída junto com a resposta.
              'maxOutputTokens': maxTokens + 512,
              'thinkingConfig': {'thinkingLevel': 'low'},
              if (jsonResponse) 'responseMimeType': 'application/json',
            },
          },
        );
        final candidate = response.data['candidates'][0];
        final parts =
            (candidate['content']['parts'] as List?) ?? const [];
        var text = parts.map((p) => '${p['text'] ?? ''}').join().trim();
        if (text.isEmpty) {
          throw const FormatException('resposta vazia');
        }
        if (!jsonResponse && candidate['finishReason'] == 'MAX_TOKENS') {
          text = _trimToLastSentence(text);
        }
        unawaited(debugLog('AI', '$tag: gemini'));
        return text;
      } on DioException catch (e) {
        unawaited(debugLog(
            'AI',
            '$tag: gemini falhou '
            '(HTTP ${e.response?.statusCode ?? e.message}) — usando groq'));
      } catch (e) {
        unawaited(debugLog('AI', '$tag: gemini falhou ($e) — usando groq'));
      }
    }

    final response = await _dio.post(
      'https://api.groq.com/openai/v1/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${GroqCredentials.apiKey}',
          'Content-Type': 'application/json',
        },
        receiveTimeout: receiveTimeout,
        sendTimeout: const Duration(seconds: 30),
      ),
      data: {
        'model': _textModel,
        'messages': [
          if (systemPrompt.isNotEmpty)
            {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userText},
        ],
        'temperature': temperature,
        'max_tokens': maxTokens,
        if (jsonResponse) 'response_format': {'type': 'json_object'},
      },
    );
    unawaited(debugLog('AI', '$tag: groq'));
    return _contentFromResponse(response);
  }

  /// Chamada de visão (texto + foto): Gemini quando a chave está
  /// configurada; sem ela, cai para o modelo preview do Groq. A imagem é
  /// enviada em memória e não é armazenada por nenhum dos serviços.
  Future<String> _visionRequest({
    required String systemPrompt,
    required String userText,
    required List<int> jpegBytes,
    double temperature = 0.2,
    int maxTokens = 1024,
  }) async {
    final base64Image = base64Encode(jpegBytes);
    final timeouts = Options(
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
    );

    if (_hasGemini) {
      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        '$_geminiVisionModel:generateContent',
        options: timeouts.copyWith(headers: {
          'x-goog-api-key': GeminiCredentials.apiKey,
          'Content-Type': 'application/json',
        }),
        data: {
          if (systemPrompt.isNotEmpty)
            'system_instruction': {
              'parts': [
                {'text': systemPrompt},
              ],
            },
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': userText},
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image,
                  },
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': temperature,
            'maxOutputTokens': maxTokens,
            // A família 3.x "pensa" por padrão e os pensamentos consomem os
            // tokens de saída. Ela usa thinkingLevel (o thinkingBudget
            // legado do 2.5 causa 400 INVALID_ARGUMENT aqui) — "low" é o
            // mínimo aceito.
            'thinkingConfig': {'thinkingLevel': 'low'},
          },
        },
      );
      final parts =
          (response.data['candidates'][0]['content']['parts'] as List?) ??
              const [];
      return parts.map((p) => '${p['text'] ?? ''}').join().trim();
    }

    final response = await _dio.post(
      'https://api.groq.com/openai/v1/chat/completions',
      options: timeouts.copyWith(headers: {
        'Authorization': 'Bearer ${GroqCredentials.apiKey}',
        'Content-Type': 'application/json',
      }),
      data: {
        'model': _visionModel,
        'messages': [
          if (systemPrompt.isNotEmpty)
            {'role': 'system', 'content': systemPrompt},
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': userText},
              {
                'type': 'image_url',
                'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
              },
            ],
          },
        ],
        'temperature': temperature,
        'max_tokens': maxTokens,
        // qwen3 é modelo de raciocínio: desliga o "pensamento" para vir só
        // a resposta final.
        'reasoning_effort': 'none',
      },
    );
    // O fallback é um modelo de raciocínio (Qwen3): remove o bloco
    // <think>...</think> para entregar só a resposta final.
    return _stripReasoning(
        '${response.data['choices'][0]['message']['content']}');
  }

  /// Leitura de mãos por imagem (Premium).
  Future<String> analyzePalm({
    required List<int> jpegBytes,
    Gender? gender,
  }) async {
    gender ??= _gender;
    try {
      return await _visionRequest(
        systemPrompt: '${_localizedInstruction()}\n\n'
            '${_prompts.palmistrySystemPrompt(gender)}',
        userText: _prompts.palmUserMessage,
        jpegBytes: jpegBytes,
        temperature: 0.6,
        maxTokens: 1600,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw const AiRateLimitException();
      } else if (e.response?.statusCode == 413) {
        throw Exception(_prompts.errorImageTooLarge);
      } else if (e.response?.statusCode == 404) {
        // Modelo de visão indisponível (ex.: descontinuado pelo provedor).
        throw Exception(_prompts.errorPalmUnavailable);
      }
      throw Exception(_prompts.errorConnection(e.message));
    } catch (e) {
      throw Exception(_prompts.errorProcessing(e));
    }
  }

  /// Identifica um item da enciclopédia pessoal por foto (visão, Premium).
  /// [categoryKey]: `crystal` | `herb` | `color` (invariante).
  /// Retorna `{"identified": bool, "name": String, "confidence": String}`.
  /// A imagem é enviada em memória e não é armazenada pelo serviço.
  ///
  /// Auto-consistência: o modelo de visão disponível é fraco em espécies e
  /// alucina confiança (a mesma foto rendia nomes diferentes, sempre "high").
  /// Pedimos até 3 opiniões independentes e só aceitamos um nome com
  /// CONSENSO entre duas delas; sem consenso, respondemos honestamente que
  /// não identificamos — a página já convida a digitar o nome.
  Future<Map<String, dynamic>> identifyEncyclopediaItem({
    required List<int> jpegBytes,
    required String categoryKey,
  }) async {
    Object? lastError;
    Future<Map<String, dynamic>?> vote() async {
      try {
        return await _identifyOnce(
          jpegBytes: jpegBytes,
          categoryKey: categoryKey,
        );
      } catch (e) {
        // 503/429 transitórios não derrubam a identificação inteira: o voto
        // perdido é reposto pela rodada extra abaixo.
        lastError = e;
        return null;
      }
    }

    // Dois votos em PARALELO: no caso comum (concordância), a latência é a
    // de UMA chamada.
    final votes = (await Future.wait([vote(), vote()]))
        .whereType<Map<String, dynamic>>()
        .toList();
    var winner = _identifyConsensus(votes);

    if (winner == null && votes.isNotEmpty) {
      // Desempate — ou reposição de um voto perdido por erro transitório.
      final extra = await vote();
      if (extra != null) votes.add(extra);
      winner = _identifyConsensus(votes);
    }

    if (winner != null) return winner;
    if (votes.isEmpty) {
      throw lastError ?? Exception(_prompts.errorUnknown);
    }
    // Uma única opinião válida (as outras falharam): melhor entregá-la do
    // que errar por excesso de rigor.
    if (votes.length == 1) return votes.single;
    return {'identified': false, 'name': '', 'confidence': 'low'};
  }

  /// Consenso entre os votos até agora: dois nomes equivalentes elegem o
  /// vencedor; dois "não sei" encerram como não identificado. Null = ainda
  /// sem decisão (peça mais um voto).
  Map<String, dynamic>? _identifyConsensus(List<Map<String, dynamic>> votes) {
    if (votes.length < 2) return null;

    String normalize(Object? name) {
      final lower = removeAccents('$name').toLowerCase();
      return lower
          .replaceAll(RegExp(r'[-_]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
    }

    bool sameName(String a, String b) {
      if (a.isEmpty || b.isEmpty) return false;
      if (a == b) return true;
      // "flor de seda" vs "flor de seda comum": um contém o outro.
      return a.length >= 4 && b.length >= 4 && (a.contains(b) || b.contains(a));
    }

    final identified =
        votes.where((v) => v['identified'] == true).toList(growable: false);
    for (var i = 0; i < identified.length; i++) {
      for (var j = i + 1; j < identified.length; j++) {
        final a = identified[i];
        final b = identified[j];
        if (sameName(normalize(a['name']), normalize(b['name']))) {
          return {
            'identified': true,
            'name': a['name'],
            // Consenso de primeira mantém a confiança declarada; consenso
            // que precisou de desempate fica em "medium" no máximo.
            'confidence':
                votes.length == 2 ? (a['confidence'] ?? 'medium') : 'medium',
          };
        }
      }
    }

    final unsure = votes.length - identified.length;
    if (unsure >= 2) {
      return {'identified': false, 'name': '', 'confidence': 'low'};
    }
    return null;
  }

  Future<Map<String, dynamic>> _identifyOnce({
    required List<int> jpegBytes,
    required String categoryKey,
  }) async {
    try {
      final content = await _visionRequest(
        systemPrompt: '${_localizedInstruction()}\n\n'
            '${_prompts.encyIdentifySystemPrompt(categoryKey)}',
        userText: _prompts.encyIdentifyUserMessage,
        jpegBytes: jpegBytes,
        temperature: 0.2,
        // Folga para o "pensamento" mínimo do Gemini 3.x + o JSON.
        maxTokens: 640,
      );
      return _extractJsonObject(content);
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw const AiRateLimitException();
      } else if (e.response?.statusCode == 413) {
        throw Exception(_prompts.errorImageTooLarge);
      } else if (e.response?.statusCode == 404) {
        throw Exception(_prompts.errorPalmUnavailable);
      }
      throw Exception(_prompts.errorConnection(e.message));
    } catch (e) {
      throw Exception(_prompts.errorProcessing(e));
    }
  }

  /// Gera o verbete completo de um item da enciclopédia pessoal a partir do
  /// nome confirmado pela usuária. Chaves/enums do JSON sempre em inglês.
  Future<Map<String, dynamic>> generateEncyclopediaEntry({
    required String name,
    required String categoryKey,
    List<int>? jpegBytes,
  }) async {
    try {
      // Com a foto em mãos, o verbete é gerado pelo caminho de visão: a
      // descrição se ancora no exemplar REAL fotografado (cores e traços
      // visíveis), não numa descrição genérica da espécie.
      if (jpegBytes != null && _hasGemini) {
        final content = await _visionRequest(
          systemPrompt: '${_localizedInstruction()}\n\n'
              '${_prompts.encyGenerateSystemPrompt(categoryKey, name)}',
          userText: _prompts.encyGenerateUserMessage(name),
          jpegBytes: jpegBytes,
          temperature: 0.5,
          maxTokens: 1600,
        );
        return _extractJsonObject(content);
      }

      final content = await _textRequest(
        systemPrompt: '${_localizedInstruction()}\n\n'
            '${_prompts.encyGenerateSystemPrompt(categoryKey, name)}',
        userText: _prompts.encyGenerateUserMessage(name),
        tag: 'página enciclopédia',
        temperature: 0.5,
        maxTokens: 1200,
        jsonResponse: true,
      );
      return _extractJsonObject(content);
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw const AiRateLimitException();
      }
      throw Exception(_prompts.errorConnection(e.message));
    } catch (e) {
      throw Exception(_prompts.errorProcessing(e));
    }
  }

  /// Extrai o primeiro objeto JSON de um texto (modelos de visão nem sempre
  /// respeitam "só JSON": pode vir cercado de prosa ou cercas de código).
  static Map<String, dynamic> _extractJsonObject(String text) {
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start == -1 || end <= start) {
      throw const FormatException('Resposta sem JSON');
    }
    final decoded = jsonDecode(text.substring(start, end + 1));
    return Map<String, dynamic>.from(decoded as Map);
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
  String get visionModel => _hasGemini ? _geminiVisionModel : _visionModel;

  /// Diagnóstico admin da leitura de mãos: executa a chamada de visão e
  /// devolve os detalhes CRUS (modelo, status HTTP, corpo do erro, tempo)
  /// em vez das mensagens amigáveis — útil para depurar casos como modelo
  /// de visão descontinuado (404).
  Future<Map<String, dynamic>> analyzePalmDebug({
    required List<int> jpegBytes,
  }) async {
    final sw = Stopwatch()..start();
    final provider = _hasGemini ? 'gemini' : 'groq (fallback)';
    try {
      final content = await _visionRequest(
        systemPrompt: '',
        userText: _prompts.palmDebugUserMessage,
        jpegBytes: jpegBytes,
        maxTokens: 640,
      );
      sw.stop();
      return {
        'ok': true,
        'model': visionModel,
        'statusCode': 200,
        'elapsedMs': sw.elapsedMilliseconds,
        'imageBytes': jpegBytes.length,
        'body': 'provider: $provider\n\n$content',
      };
    } on DioException catch (e) {
      sw.stop();
      return {
        'ok': false,
        'model': visionModel,
        'statusCode': e.response?.statusCode,
        'elapsedMs': sw.elapsedMilliseconds,
        'imageBytes': jpegBytes.length,
        'body': 'provider: $provider\n\n'
            '${e.response?.data?.toString() ?? e.message ?? _prompts.errorUnknown}',
      };
    } catch (e) {
      sw.stop();
      return {
        'ok': false,
        'model': visionModel,
        'statusCode': null,
        'elapsedMs': sw.elapsedMilliseconds,
        'imageBytes': jpegBytes.length,
        'body': 'provider: $provider\n\n$e',
      };
    }
  }

  /// Interpretar uma tiragem de tarot já sorteada no app (Premium).
  Future<String> interpretTarotSpread({
    required String summary,
    String? question,
    Gender? gender,
  }) async {
    gender ??= _gender;
    // A pergunta é conteúdo da pessoa usuária: entra verbatim, nunca traduzida.
    final trimmedQuestion = question?.trim();
    final userContent = trimmedQuestion == null || trimmedQuestion.isEmpty
        ? summary
        : '$summary\n${_prompts.tarotQuestionIntro}\n"$trimmedQuestion"';
    try {
      final content = await _textRequest(
        systemPrompt: '${_localizedInstruction()}\n\n'
            '${_prompts.tarotSpreadSystemPrompt(gender)}',
        userText: userContent,
        tag: 'tarot',
        temperature: 0.7,
        maxTokens: 1100,
        receiveTimeout: const Duration(seconds: 40),
      );
      return content.trim();
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw Exception(_prompts.errorRateLimit);
      }
      throw Exception(_prompts.errorConnection(e.message));
    } catch (e) {
      throw Exception(_prompts.errorProcessing(e));
    }
  }

  /// Explicar (nunca calcular) um perfil numerológico já computado no app.
  Future<String> explainNumerology({
    required String summary,
    Gender? gender,
  }) async {
    gender ??= _gender;
    try {
      final content = await _textRequest(
        systemPrompt: '${_localizedInstruction()}\n\n'
            '${_prompts.numerologySystemPrompt(gender)}',
        userText: summary,
        tag: 'numerologia',
        temperature: 0.7,
        maxTokens: 900,
        receiveTimeout: const Duration(seconds: 30),
      );
      return content.trim();
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw Exception(_prompts.errorRateLimit);
      }
      throw Exception(_prompts.errorConnection(e.message));
    } catch (e) {
      throw Exception(_prompts.errorProcessing(e));
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
      final userContent = _prompts.dreamUserPrompt(dreamDescription, feelings);

      final content = await _textRequest(
        systemPrompt: _buildDreamInterpreterSystemPrompt(gender),
        userText: userContent,
        tag: 'sonho',
        temperature: 0.6,
        maxTokens: 1100,
        receiveTimeout: const Duration(seconds: 45),
      );
      return content.trim();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception(_prompts.errorAuthentication);
      } else if (e.response?.statusCode == 429) {
        throw Exception(_prompts.errorRateLimit);
      } else if (e.response?.statusCode == 503) {
        throw Exception(_prompts.errorServiceUnavailable);
      }
      throw Exception(_prompts.errorConnection(e.message));
    } catch (e) {
      throw Exception(_prompts.errorProcessing(e));
    }
  }

  String _buildDreamInterpreterSystemPrompt(Gender gender) {
    return '${_localizedInstruction()}\n\n'
        '${_prompts.dreamInterpreterSystemPrompt(gender)}';
  }

  String _buildMysticAdvisorSystemPrompt(
    Gender gender,
  ) {
    return '${_localizedInstruction()}\n\n'
        '${_prompts.mysticAdvisorSystemPrompt(gender)}';
  }
}
