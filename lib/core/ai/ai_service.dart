import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../features/grimoire/data/models/spell_model.dart';

enum AIProvider {
  openai,
  gemini;

  String get displayName {
    switch (this) {
      case AIProvider.openai:
        return 'OpenAI (GPT-4)';
      case AIProvider.gemini:
        return 'Google Gemini';
    }
  }
}

class AIService {
  static final AIService instance = AIService._();

  AIService._();

  static const _keyStorageKey = 'openai_api_key';
  static const _providerKey = 'ai_provider';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Dio _dio = Dio();

  /// Salvar API key
  Future<void> saveApiKey(String apiKey, AIProvider provider) async {
    await _secureStorage.write(key: _keyStorageKey, value: apiKey);
    await _secureStorage.write(key: _providerKey, value: provider.name);
  }

  /// Obter API key
  Future<String?> getApiKey() async {
    return await _secureStorage.read(key: _keyStorageKey);
  }

  /// Obter provider
  Future<AIProvider?> getProvider() async {
    final providerName = await _secureStorage.read(key: _providerKey);
    if (providerName == null) return null;
    return AIProvider.values.firstWhere((e) => e.name == providerName);
  }

  /// Verificar se tem API key
  Future<bool> hasApiKey() async {
    final key = await _secureStorage.read(key: _keyStorageKey);
    return key != null && key.isNotEmpty;
  }

  /// Remover API key
  Future<void> removeApiKey() async {
    await _secureStorage.delete(key: _keyStorageKey);
    await _secureStorage.delete(key: _providerKey);
  }

  /// Gerar feitiço com IA
  Future<SpellModel> generateSpell(String userIntention) async {
    final apiKey = await _secureStorage.read(key: _keyStorageKey);
    final providerName = await _secureStorage.read(key: _providerKey);

    if (apiKey == null) {
      throw Exception('API key não configurada');
    }

    final provider = AIProvider.values.firstWhere(
      (e) => e.name == providerName,
      orElse: () => AIProvider.openai,
    );

    if (provider == AIProvider.openai) {
      return _generateWithOpenAI(apiKey, userIntention);
    } else {
      return _generateWithGemini(apiKey, userIntention);
    }
  }

  Future<SpellModel> _generateWithOpenAI(
    String apiKey,
    String intention,
  ) async {
    try {
      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content': _buildSystemPrompt(),
            },
            {
              'role': 'user',
              'content': intention,
            },
          ],
          'response_format': {'type': 'json_object'},
          'temperature': 0.8,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      final spellData = jsonDecode(content);

      return _parseSpellData(spellData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('API key inválida');
      } else if (e.response?.statusCode == 429) {
        throw Exception('Limite de uso excedido. Tente novamente mais tarde.');
      }
      throw Exception('Erro na API: ${e.message}');
    }
  }

  Future<SpellModel> _generateWithGemini(
    String apiKey,
    String intention,
  ) async {
    try {
      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'contents': [
            {
              'parts': [
                {
                  'text': '${_buildSystemPrompt()}\n\nIntenção do usuário: $intention',
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.8,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        },
      );

      final text = response.data['candidates'][0]['content']['parts'][0]['text'];

      // Extrair JSON do texto (Gemini pode retornar com markdown)
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (jsonMatch == null) {
        throw Exception('Resposta inválida da IA');
      }

      final spellData = jsonDecode(jsonMatch.group(0)!);
      return _parseSpellData(spellData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('API key inválida ou requisição inválida');
      }
      throw Exception('Erro na API: ${e.message}');
    }
  }

  SpellModel _parseSpellData(Map<String, dynamic> data) {
    return SpellModel(
      id: const Uuid().v4(),
      name: data['name'] ?? 'Feitiço Personalizado',
      purpose: data['purpose'] ?? '',
      type: _parseSpellType(data['type']),
      category: _parseSpellCategory(data['category']),
      moonPhase: data['moonPhase'] != null
          ? _parseMoonPhase(data['moonPhase'])
          : null,
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

  String? _parseMoonPhase(String? phase) {
    if (phase == null) return null;
    // Mapear para os valores usados no app
    final phaseMap = {
      'newMoon': 'Nova',
      'waxingCrescent': 'Crescente',
      'firstQuarter': 'Quarto Crescente',
      'waxingGibbous': 'Crescente Gibosa',
      'fullMoon': 'Cheia',
      'waningGibbous': 'Minguante Gibosa',
      'lastQuarter': 'Quarto Minguante',
      'waningCrescent': 'Minguante',
    };
    return phaseMap[phase] ?? 'Qualquer';
  }

  String _buildSystemPrompt() {
    return '''Você é um assistente especializado em bruxaria moderna e práticas esotéricas.

Crie um feitiço baseado na intenção do usuário.

IMPORTANTE: Retorne APENAS um objeto JSON válido, sem markdown ou explicações adicionais.

Formato do JSON:
{
  "name": "Nome do feitiço",
  "purpose": "Propósito específico",
  "type": "attraction" ou "banishment",
  "category": "love/protection/prosperity/healing/cleansing/luck/creativity/communication/dreams/divination/energy/home/wisdom/study/courage/friendship/work/banishing",
  "moonPhase": "newMoon/waxingCrescent/firstQuarter/waxingGibbous/fullMoon/waningGibbous/lastQuarter/waningCrescent",
  "ingredients": ["item 1", "item 2", "item 3"],
  "steps": "Passo 1\\nPasso 2\\nPasso 3\\n...",
  "duration": 1,
  "observations": "Observações e dicas importantes"
}

Diretrizes:
- Use APENAS ingredientes acessíveis e seguros
- Ingredientes comuns: velas (cores variadas), ervas (alecrim, lavanda, manjericão, canela), cristais (quartzo, ametista), sal, água
- NUNCA sugira ingredientes perigosos ou difíceis de encontrar
- Inclua avisos de segurança se necessário nas observações
- Seja específico nos passos (enumere de 1 a X, separados por \\n)
- Recomende fase lunar apropriada
- Tom: acolhedor, místico mas prático
- Feitiços devem ser éticos (não manipulação, não prejudicar terceiros)
- Se for feitiço de amor, SEMPRE adicionar "com respeito ao livre arbítrio"
- Máximo 5-7 ingredientes
- Passos claros e objetivos (5-10 passos)''';
  }
}
