import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/database/database_helper.dart';
import '../../../auth/data/repositories/beta_code_repository.dart';

/// Página de debug para códigos beta
/// Mostra informações detalhadas sobre Supabase e SQLite
class BetaCodesDebugPage extends StatefulWidget {
  const BetaCodesDebugPage({super.key});

  @override
  State<BetaCodesDebugPage> createState() => _BetaCodesDebugPageState();
}

class _BetaCodesDebugPageState extends State<BetaCodesDebugPage> {
  final BetaCodeRepository _repository = BetaCodeRepository();
  final List<String> _logs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _runDiagnostic();
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('[${DateTime.now().toIso8601String().substring(11, 19)}] $message');
    });
  }

  Future<void> _runDiagnostic() async {
    setState(() {
      _logs.clear();
      _isLoading = true;
    });

    try {
      _addLog('=== DIAGNÓSTICO INICIADO ===');

      // 1. Verificar configuração do Supabase
      _addLog('');
      _addLog('1️⃣ CONFIGURAÇÃO SUPABASE:');
      _addLog('   Configurado: ${SupabaseConfig.isConfigured}');
      _addLog('   URL: ${SupabaseConfig.url.isEmpty ? "❌ VAZIO" : "✅ ${SupabaseConfig.url}"}');
      _addLog('   AnonKey: ${SupabaseConfig.anonKey.isEmpty ? "❌ VAZIO" : "✅ Configurada (${SupabaseConfig.anonKey.length} chars)"}');

      // 2. Testar conexão com Supabase
      if (SupabaseConfig.isConfigured) {
        _addLog('');
        _addLog('2️⃣ TESTE DE CONEXÃO:');
        try {
          final supabase = Supabase.instance.client;
          _addLog('   Cliente Supabase: ✅ Inicializado');

          // Tentar fazer um select simples
          _addLog('   Testando SELECT na tabela beta_codes...');
          final response = await supabase
              .from(SupabaseTables.betaCodes)
              .select()
              .limit(1);
          _addLog('   SELECT: ✅ Sucesso (retornou ${response.length} registros)');
        } catch (e) {
          _addLog('   SELECT: ❌ ERRO: $e');

          if (e.toString().contains('permission') ||
              e.toString().contains('policy') ||
              e.toString().contains('RLS')) {
            _addLog('   ⚠️  PROBLEMA DE PERMISSÃO/RLS DETECTADO!');
          }
        }
      } else {
        _addLog('');
        _addLog('2️⃣ TESTE DE CONEXÃO: ⏭️  Pulado (Supabase não configurado)');
      }

      // 3. Verificar códigos no Supabase
      _addLog('');
      _addLog('3️⃣ CÓDIGOS NO SUPABASE:');
      if (SupabaseConfig.isConfigured) {
        try {
          final supabase = Supabase.instance.client;
          final codes = await supabase
              .from(SupabaseTables.betaCodes)
              .select()
              .order('created_at', ascending: false);
          _addLog('   Total: ${codes.length} códigos');
          if (codes.isNotEmpty) {
            _addLog('   Últimos 3 códigos (todas as colunas):');
            for (var i = 0; i < codes.length && i < 3; i++) {
              final code = codes[i];
              _addLog('     ═══════════════════════════════');
              _addLog('     Código: ${code['code']}');
              _addLog('     ID: ${code['id']}');
              _addLog('     Is Used: ${code['is_used']}');
              _addLog('     Max Uses: ${code['max_uses'] ?? 1}');
              _addLog('     Current Uses: ${code['current_uses'] ?? 0}');
              _addLog('     Used By: ${code['used_by'] ?? 'N/A'}');
              _addLog('     Used At: ${code['used_at'] ?? 'N/A'}');
              _addLog('     Created At: ${code['created_at']}');
            }
            _addLog('     ═══════════════════════════════');
          }
        } catch (e) {
          _addLog('   ❌ ERRO ao buscar: $e');
        }
      } else {
        _addLog('   ⏭️  Pulado (Supabase não configurado)');
      }

      // 4. Verificar tabela beta_codes no SQLite
      _addLog('');
      _addLog('4️⃣ TABELA SQLITE (beta_codes):');
      try {
        final db = await DatabaseHelper.instance.database;

        // Verificar se tabela existe
        final tableExists = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='beta_codes'"
        );

        if (tableExists.isEmpty) {
          _addLog('   ❌ TABELA NÃO EXISTE!');
        } else {
          _addLog('   ✅ Tabela existe');

          // Verificar schema
          final schema = await db.rawQuery("PRAGMA table_info(beta_codes)");
          _addLog('   Colunas: ${schema.map((col) => col['name']).join(', ')}');

          // Contar códigos
          final count = await db.rawQuery("SELECT COUNT(*) as count FROM beta_codes");
          final total = count.first['count'] as int;
          _addLog('   Total de códigos: $total');

          if (total > 0) {
            final codes = await db.query('beta_codes', limit: 3);
            _addLog('   Primeiros 3 códigos (todas as colunas):');
            for (final code in codes) {
              _addLog('     ═══════════════════════════════');
              _addLog('     Código: ${code['code']}');
              _addLog('     ID: ${code['id']}');
              _addLog('     Is Used: ${code['is_used']}');
              _addLog('     Max Uses: ${code['max_uses'] ?? 1}');
              _addLog('     Current Uses: ${code['current_uses'] ?? 0}');
              _addLog('     Used By: ${code['used_by'] ?? 'N/A'}');
              _addLog('     Used At: ${code['used_at'] ?? 'N/A'}');
              _addLog('     Created At: ${code['created_at']}');
            }
            _addLog('     ═══════════════════════════════');
          }
        }
      } catch (e) {
        _addLog('   ❌ ERRO: $e');
      }

      _addLog('');
      _addLog('=== DIAGNÓSTICO COMPLETO ===');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testCreateCode() async {
    final testCode = 'TEST${DateTime.now().millisecondsSinceEpoch % 10000}';

    setState(() {
      _logs.clear();
      _isLoading = true;
    });

    try {
      _addLog('=== TESTE DE CRIAÇÃO DE CÓDIGO ===');
      _addLog('Código de teste: $testCode');
      _addLog('');

      _addLog('Criando código...');
      final success = await _repository.createCode(testCode);

      if (success) {
        _addLog('✅ Código criado com sucesso!');

        // Verificar onde foi salvo
        _addLog('');
        _addLog('Verificando onde foi salvo...');

        if (SupabaseConfig.isConfigured) {
          try {
            final supabase = Supabase.instance.client;
            final supabaseCode = await supabase
                .from(SupabaseTables.betaCodes)
                .select()
                .eq('code', testCode)
                .maybeSingle();

            if (supabaseCode != null) {
              _addLog('✅ Encontrado no SUPABASE');
            } else {
              _addLog('❌ NÃO encontrado no SUPABASE');
            }
          } catch (e) {
            _addLog('❌ Erro ao verificar Supabase: $e');
          }
        }

        // Verificar SQLite
        final localCode = await _repository.getCode(testCode);
        if (localCode != null) {
          _addLog('✅ Encontrado no SQLITE LOCAL');
        } else {
          _addLog('❌ NÃO encontrado no SQLITE LOCAL');
        }
      } else {
        _addLog('❌ Falha ao criar código');
      }

      _addLog('');
      _addLog('=== TESTE COMPLETO ===');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('🔧 Debug - Códigos Beta'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copiar logs',
            onPressed: _logs.isEmpty ? null : _copyLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          // Botões de ação
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _runDiagnostic,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Diagnóstico Completo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lilac,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testCreateCode,
                    icon: const Icon(Icons.add),
                    label: const Text('Testar Criação'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Área de logs
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lilac.withOpacity(0.3)),
              ),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.lilac,
                      ),
                    )
                  : _logs.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum log ainda.\nClique em "Diagnóstico Completo" para começar.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            final log = _logs[index];
                            Color textColor = Colors.white70;

                            if (log.contains('✅')) {
                              textColor = Colors.greenAccent;
                            } else if (log.contains('❌')) {
                              textColor = Colors.redAccent;
                            } else if (log.contains('⚠️')) {
                              textColor = Colors.orangeAccent;
                            } else if (log.contains('===')) {
                              textColor = AppColors.lilac;
                            } else if (log.contains('1️⃣') ||
                                       log.contains('2️⃣') ||
                                       log.contains('3️⃣') ||
                                       log.contains('4️⃣')) {
                              textColor = Colors.cyanAccent;
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                log,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  height: 1.4,
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),

          const SizedBox(height: 16),

          // Informações rápidas
          Padding(
            padding: const EdgeInsets.all(16),
            child: MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 Dicas:',
                    style: TextStyle(
                      color: AppColors.lilac,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTip('Se "Supabase configurado: false", as credenciais não foram injetadas no build'),
                  _buildTip('Se aparecer erro de RLS/permission, é problema nas políticas da tabela'),
                  _buildTip('Se códigos aparecem apenas no SQLite, o Supabase não está funcionando'),
                  _buildTip('Toque no ícone de copiar (topo direito) para copiar todos os logs'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.white70)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyLogs() {
    final logsText = _logs.join('\n');
    Clipboard.setData(ClipboardData(text: logsText));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs copiados para a área de transferência!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
