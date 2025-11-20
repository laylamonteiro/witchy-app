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
    return '''Você é o Conselheiro Místico, guardião da sabedoria arcana do Grimório de Bolso.

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
- Ingredientes permitidos: velas coloridas, ervas culinárias (alecrim, lavanda, manjericão, canela, tomilho, sálvia), cristais comuns (quartzo, ametista, citrino), sal, água, mel, óleos essenciais, papéis, incensos
- NUNCA sugira ingredientes perigosos, tóxicos, raros ou de difícil obtenção
- Inclua avisos de segurança nas observações quando necessário (ex: cuidado com fogo de velas)
- Seja específico e poético nos passos (enumere de 1 a X, separados por \\n)
- Escolha a fase lunar mais apropriada para o tipo de magia
- Tom: Acolhedor, místico, evocativo, mas sempre prático e aterrado
- Feitiços devem ser SEMPRE éticos: sem manipulação de livre arbítrio, sem prejudicar terceiros, sem magia de controle
- Em feitiços de amor, SEMPRE incluir "respeitando o livre arbítrio de todos os envolvidos"
- Use entre 5-7 ingredientes (nunca menos de 5, nunca mais de 7)
- Crie 5-10 passos claros, objetivos e ritualísticos
- Os nomes dos feitiços devem ser poéticos e evocativos (ex: "Ritual da Lua Crescente para Abundância", "Feitiço das Estrelas Cadentes")
- Nas observações, adicione dicas místicas sobre o melhor momento, energia necessária, ou como potencializar o feitiço''';
  }
}
