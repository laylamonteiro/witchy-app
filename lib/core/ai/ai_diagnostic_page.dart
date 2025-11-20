import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/magical_card.dart';
import 'ai_service.dart';
import 'groq_credentials.dart';

/// Página de diagnóstico da API Groq
/// Testa credenciais e funcionalidade da IA
class AIDiagnosticPage extends StatefulWidget {
  const AIDiagnosticPage({super.key});

  @override
  State<AIDiagnosticPage> createState() => _AIDiagnosticPageState();
}

class _AIDiagnosticPageState extends State<AIDiagnosticPage> {
  final List<String> _logs = [];
  bool _isTesting = false;
  String? _result;

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toIso8601String().split('T')[1].substring(0, 8)} - $message');
    });
  }

  Future<void> _testGroqAPI() async {
    setState(() {
      _isTesting = true;
      _result = null;
      _logs.clear();
    });

    _addLog('🤖 Iniciando teste da API Groq...');

    try {
      // 1. Verificar se a chave está configurada
      _addLog('🔑 Verificando credenciais...');
      final apiKey = GroqCredentials.apiKey;

      if (apiKey == 'SUBSTITUA_PELA_SUA_CHAVE_GROQ_AQUI' || apiKey.isEmpty) {
        _addLog('❌ API KEY NÃO CONFIGURADA!');
        _addLog('📝 Você precisa editar lib/core/ai/groq_credentials.dart');
        _addLog('🌐 Obtenha sua chave em: https://console.groq.com/keys');
        setState(() {
          _result = 'ERRO: API Key não configurada';
          _isTesting = false;
        });
        return;
      }

      _addLog('✅ API Key encontrada: ${apiKey.substring(0, 10)}...');

      // 2. Testar geração de feitiço
      _addLog('📡 Testando geração de feitiço com Llama 3.1 70B...');
      _addLog('💭 Intenção de teste: "Atrair prosperidade"');

      final aiService = AIService.instance;
      final spell = await aiService.generateSpell('Atrair prosperidade');

      _addLog('✅ FEITIÇO GERADO COM SUCESSO!');
      _addLog('   Nome: ${spell.name}');
      _addLog('   Tipo: ${spell.type.name}');
      _addLog('   Categoria: ${spell.category.name}');
      _addLog('   Ingredientes: ${spell.ingredients.length}');
      _addLog('   Fase Lunar: ${spell.moonPhase?.name ?? "Não especificada"}');

      setState(() {
        _result = 'SUCESSO: API funcionando perfeitamente!';
        _isTesting = false;
      });
    } catch (e, stackTrace) {
      _addLog('❌ ERRO AO TESTAR API: $e');

      // Diagnóstico de erros comuns
      if (e.toString().contains('400')) {
        _addLog('');
        _addLog('🔍 DIAGNÓSTICO: Requisição Inválida (400)');
        _addLog('   Possíveis causas:');
        _addLog('   1. Modelo solicitado não existe ou mudou de nome');
        _addLog('   2. Parâmetro response_format não suportado pelo modelo');
        _addLog('   3. Formato da requisição incorreto');
        _addLog('');
        _addLog('📝 Mensagem de erro da API:');
        final errorMatch = RegExp(r'Erro 400: (.+)').firstMatch(e.toString());
        if (errorMatch != null) {
          _addLog('   ${errorMatch.group(1)}');
        }
        _addLog('');
        _addLog('✅ SOLUÇÃO:');
        _addLog('   Verifique os logs detalhados acima');
        _addLog('   O erro específico da API está descrito');
      } else if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        _addLog('');
        _addLog('🔍 DIAGNÓSTICO: Erro de Autenticação (401)');
        _addLog('   Possíveis causas:');
        _addLog('   1. API key inválida ou expirada');
        _addLog('   2. API key de outro serviço (não Groq)');
        _addLog('   3. API key revogada');
        _addLog('');
        _addLog('✅ SOLUÇÃO:');
        _addLog('   1. Acesse https://console.groq.com/keys');
        _addLog('   2. Gere uma nova API key');
        _addLog('   3. Edite lib/core/ai/groq_credentials.dart');
        _addLog('   4. Cole a nova chave no lugar do placeholder');
      } else if (e.toString().contains('429') || e.toString().contains('rate limit')) {
        _addLog('');
        _addLog('🔍 DIAGNÓSTICO: Limite de Requisições (429)');
        _addLog('   Você excedeu o limite de requisições gratuitas');
        _addLog('   Aguarde alguns minutos antes de tentar novamente');
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        _addLog('');
        _addLog('🔍 DIAGNÓSTICO: Erro de Conexão');
        _addLog('   Verifique sua conexão com a internet');
      } else if (e.toString().contains('503')) {
        _addLog('');
        _addLog('🔍 DIAGNÓSTICO: Serviço Temporariamente Indisponível');
        _addLog('   A API Groq pode estar em manutenção');
        _addLog('   Tente novamente em alguns minutos');
      }

      _addLog('');
      _addLog('📋 Detalhes técnicos:');
      _addLog(stackTrace.toString().split('\n').take(5).join('\n'));

      setState(() {
        _result = 'ERRO: ${e.toString()}';
        _isTesting = false;
      });
    }
  }

  void _copyLogs() {
    final logsText = _logs.join('\n');
    Clipboard.setData(ClipboardData(text: logsText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs copiados para a área de transferência'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico IA'),
        backgroundColor: AppColors.darkBackground,
        actions: [
          if (_logs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyLogs,
              tooltip: 'Copiar logs',
            ),
        ],
      ),
      backgroundColor: AppColors.darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MagicalCard(
              child: Column(
                children: [
                  const Icon(
                    Icons.psychology,
                    size: 64,
                    color: AppColors.lilac,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Teste da API Groq',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.lilac,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Verifica se a API key está configurada e funcional',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.softWhite.withOpacity(0.8),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botão de teste
            ElevatedButton.icon(
              onPressed: _isTesting ? null : _testGroqAPI,
              icon: _isTesting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.darkBackground,
                        ),
                      ),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_isTesting ? 'Testando...' : 'Executar Teste'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lilac,
                foregroundColor: AppColors.darkBackground,
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: AppColors.lilac.withOpacity(0.3),
              ),
            ),

            if (_result != null) ...[
              const SizedBox(height: 16),
              MagicalCard(
                child: Row(
                  children: [
                    Icon(
                      _result!.startsWith('SUCESSO')
                          ? Icons.check_circle
                          : Icons.error,
                      color: _result!.startsWith('SUCESSO')
                          ? AppColors.success
                          : AppColors.alert,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _result!,
                        style: TextStyle(
                          color: _result!.startsWith('SUCESSO')
                              ? AppColors.success
                              : AppColors.alert,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (_logs.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Logs de Diagnóstico',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.lilac,
                    ),
              ),
              const SizedBox(height: 8),
              MagicalCard(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _logs.join('\n'),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: AppColors.softWhite,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Instruções
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: AppColors.lilac),
                      const SizedBox(width: 8),
                      Text(
                        'Como Configurar',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.lilac,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStep('1', 'Acesse https://console.groq.com/keys'),
                  const SizedBox(height: 8),
                  _buildStep('2', 'Crie uma conta gratuita (se ainda não tem)'),
                  const SizedBox(height: 8),
                  _buildStep('3', 'Clique em "Create API Key"'),
                  const SizedBox(height: 8),
                  _buildStep('4', 'Copie a chave gerada'),
                  const SizedBox(height: 8),
                  _buildStep('5', 'Edite lib/core/ai/groq_credentials.dart'),
                  const SizedBox(height: 8),
                  _buildStep('6', 'Cole a chave no lugar do placeholder'),
                  const SizedBox(height: 8),
                  _buildStep('7', 'Reinicie o app e teste novamente'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.lilac.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: AppColors.lilac,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.softWhite,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
