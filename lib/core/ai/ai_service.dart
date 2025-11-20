import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../features/grimoire/data/models/spell_model.dart';

/// Serviço de IA usando Groq (gratuito, sem API key necessária)
class AIService {
  static final AIService instance = AIService._();

  AIService._();

  // TODO: Obtenha sua API key gratuita em: https://console.groq.com/keys
  // Groq é 100% gratuito e muito rápido. Basta criar conta e gerar a chave.
  static const _groqApiKey = 'SUBSTITUA_PELA_SUA_CHAVE_GROQ_AQUI';

  final Dio _dio = Dio();

  /// Verificar se o serviço está disponível (sempre true para Groq)
  Future<bool> hasApiKey() async {
    return true;
  }

  /// Gerar feitiço com IA usando Groq
  Future<SpellModel> generateSpell(String userIntention) async {
    return _generateWithGroq(userIntention);
  }

  Future<SpellModel> _generateWithGroq(String intention) async {
    try {
      final response = await _dio.post(
        'https://api.groq.com/openai/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_groqApiKey',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
        data: {
          'model': 'llama-3.1-70b-versatile',
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
          'temperature': 0.8,
          'max_tokens': 1024,
          'response_format': {'type': 'json_object'},
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      final spellData = jsonDecode(content);

      return _parseSpellData(spellData);
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
