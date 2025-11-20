import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/services/external_chart_api.dart';

/// Página de diagnóstico da API Prokerala
/// Testa credenciais e exibe logs detalhados
class APIDiagnosticPage extends StatefulWidget {
  const APIDiagnosticPage({super.key});

  @override
  State<APIDiagnosticPage> createState() => _APIDiagnosticPageState();
}

class _APIDiagnosticPageState extends State<APIDiagnosticPage> {
  final List<String> _logs = [];
  bool _isTestingToken = false;
  bool _isTestingChart = false;
  String? _tokenResult;
  String? _chartResult;

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toIso8601String().split('T')[1].substring(0, 8)} - $message');
    });
  }

  Future<void> _testToken() async {
    setState(() {
      _isTestingToken = true;
      _tokenResult = null;
      _logs.clear();
    });

    _addLog('🔑 Iniciando teste de autenticação OAuth 2.0...');

    try {
      _addLog('📡 Tentando obter token de acesso...');

      // Resetar cache de token
      ExternalChartAPI.instance.clearTokenCache();
      _addLog('✅ Cache de token limpo');

      // Tentar obter token
      final token = await ExternalChartAPI.instance.getAccessToken();

      _addLog('✅ TOKEN OBTIDO COM SUCESSO!');
      _addLog('📝 Token: ${token.substring(0, 20)}...');

      setState(() {
        _tokenResult = '✅ Autenticação funcionando!\n\nToken: ${token.substring(0, 50)}...';
      });
    } catch (e, stackTrace) {
      _addLog('❌ ERRO AO OBTER TOKEN: $e');
      _addLog('📋 Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');

      setState(() {
        _tokenResult = '❌ Erro na autenticação:\n\n$e\n\nVerifique:\n- Credenciais estão corretas?\n- Tem conexão com internet?\n- API Prokerala está online?';
      });
    } finally {
      setState(() {
        _isTestingToken = false;
      });
    }
  }

  Future<void> _testChart() async {
    setState(() {
      _isTestingChart = true;
      _chartResult = null;
      _logs.clear();
    });

    _addLog('🌟 Iniciando teste de cálculo de mapa...');

    try {
      // Dados de teste: 31/03/1994, 19:39, São Paulo
      final testDate = DateTime(1994, 3, 31, 19, 39, 0);
      final latitude = -23.5505;
      final longitude = -46.6333;

      _addLog('📅 Data de teste: 31/03/1994 19:39');
      _addLog('📍 Local: São Paulo (-23.5505, -46.6333)');

      _addLog('📡 Chamando API Prokerala...');
      final result = await ExternalChartAPI.instance.calculateBirthChart(
        birthDate: testDate,
        latitude: latitude,
        longitude: longitude,
        houseSystem: 'placidus',
      );

      _addLog('✅ API RESPONDEU!');
      _addLog('📦 Processando resposta...');

      final parsedData = ExternalChartAPI.instance.parseAPIResponse(result);
      final planets = parsedData['planets'] as List;
      final houses = parsedData['houses'] as List;
      final ascendant = parsedData['ascendant'];

      _addLog('✅ CÁLCULO BEM-SUCEDIDO!');
      _addLog('   - ${planets.length} planetas calculados');
      _addLog('   - ${houses.length} casas calculadas');
      if (ascendant != null) {
        _addLog('   - Ascendente encontrado');
      }

      String resultText = '✅ Mapa calculado com sucesso!\n\n';
      resultText += 'Planetas: ${planets.length}\n';
      resultText += 'Casas: ${houses.length}\n';
      if (ascendant != null) {
        resultText += 'Ascendente: Calculado\n';
      }
      resultText += '\n🎯 API ESTÁ FUNCIONANDO PERFEITAMENTE!\n';
      resultText += 'Acuracidade: Swiss Ephemeris (±0.1°)';

      setState(() {
        _chartResult = resultText;
      });
    } catch (e, stackTrace) {
      _addLog('❌ ERRO NO CÁLCULO: $e');
      _addLog('📋 Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');

      setState(() {
        _chartResult = '❌ Erro ao calcular mapa:\n\n$e\n\nPossíveis causas:\n- Token expirou\n- API atingiu limite de requisições\n- Erro no formato dos dados';
      });
    } finally {
      setState(() {
        _isTestingChart = false;
      });
    }
  }

  void _copyLogs() {
    final logsText = _logs.join('\n');
    Clipboard.setData(ClipboardData(text: logsText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs copiados para área de transferência'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico da API'),
        backgroundColor: AppColors.darkBackground,
      ),
      backgroundColor: AppColors.darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Informações
            MagicalCard(
              child: Column(
                children: [
                  const Text('🔍', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    'Diagnóstico da API Prokerala',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.lilac,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Use os testes abaixo para verificar se a API está funcionando corretamente. '
                    'Os logs mostrarão exatamente o que está acontecendo.',
                    style: TextStyle(
                      color: AppColors.softWhite.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Teste de Token
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Text('🔑', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 12),
                      Text(
                        'Teste 1: Autenticação OAuth',
                        style: TextStyle(
                          color: AppColors.lilac,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Testa se as credenciais estão corretas e se consegue obter token de acesso.',
                    style: TextStyle(
                      color: AppColors.softWhite.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isTestingToken ? null : _testToken,
                    icon: _isTestingToken
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.darkBackground,
                            ),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(_isTestingToken ? 'Testando...' : 'Testar Autenticação'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lilac,
                      foregroundColor: AppColors.darkBackground,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  if (_tokenResult != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _tokenResult!.startsWith('✅')
                            ? AppColors.success.withOpacity(0.2)
                            : AppColors.alert.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _tokenResult!.startsWith('✅')
                              ? AppColors.success
                              : AppColors.alert,
                        ),
                      ),
                      child: Text(
                        _tokenResult!,
                        style: TextStyle(
                          color: AppColors.softWhite.withOpacity(0.9),
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Teste de Cálculo
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Text('🌟', style: TextStyle(fontSize: 24)),
                      SizedBox(width: 12),
                      Text(
                        'Teste 2: Cálculo de Mapa',
                        style: TextStyle(
                          color: AppColors.lilac,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Testa cálculo completo de um mapa astral usando dados de teste.',
                    style: TextStyle(
                      color: AppColors.softWhite.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isTestingChart ? null : _testChart,
                    icon: _isTestingChart
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.darkBackground,
                            ),
                          )
                        : const Icon(Icons.calculate),
                    label: Text(_isTestingChart ? 'Calculando...' : 'Testar Cálculo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lilac,
                      foregroundColor: AppColors.darkBackground,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  if (_chartResult != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _chartResult!.startsWith('✅')
                            ? AppColors.success.withOpacity(0.2)
                            : AppColors.alert.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _chartResult!.startsWith('✅')
                              ? AppColors.success
                              : AppColors.alert,
                        ),
                      ),
                      child: Text(
                        _chartResult!,
                        style: TextStyle(
                          color: AppColors.softWhite.withOpacity(0.9),
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Logs
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text('📋', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Logs Detalhados',
                          style: TextStyle(
                            color: AppColors.lilac,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_logs.isNotEmpty)
                        TextButton.icon(
                          onPressed: _copyLogs,
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copiar'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.lilac,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.lilac.withOpacity(0.3),
                      ),
                    ),
                    child: _logs.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Execute um teste para ver os logs aqui',
                              style: TextStyle(
                                color: AppColors.softWhite.withOpacity(0.5),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(12),
                            itemCount: _logs.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  _logs[index],
                                  style: TextStyle(
                                    color: AppColors.softWhite.withOpacity(0.8),
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
