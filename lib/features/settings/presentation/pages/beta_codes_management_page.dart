import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/repositories/beta_code_repository.dart';
import 'beta_codes_debug_page.dart';

class BetaCodesManagementPage extends StatefulWidget {
  const BetaCodesManagementPage({super.key});

  @override
  State<BetaCodesManagementPage> createState() => _BetaCodesManagementPageState();
}

class _BetaCodesManagementPageState extends State<BetaCodesManagementPage> {
  List<Map<String, dynamic>> _codes = [];
  bool _isLoading = true;
  final TextEditingController _codeController = TextEditingController();
  final BetaCodeRepository _repository = BetaCodeRepository();

  @override
  void initState() {
    super.initState();
    _loadCodes();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadCodes() async {
    setState(() => _isLoading = true);
    try {
      final codes = await _repository.getAllCodes();
      setState(() {
        _codes = codes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar códigos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createCode() async {
    final authProvider = context.read<AuthProvider>();
    final code = _codeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um código válido'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validar formato do código (letras e números apenas)
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Use apenas letras e números'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await authProvider.createBetaCode(code);

    if (mounted) {
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Código "$result" criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _codeController.clear();
        _loadCodes();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao criar código (código já existe?)'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _invalidateCode(String codeId, String code) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalidar Código'),
        content: Text('Tem certeza que deseja invalidar o código "$code"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Invalidar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await _repository.invalidateCode(code);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Código "$code" invalidado'),
              backgroundColor: Colors.green,
            ),
          );
          _loadCodes();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao invalidar código'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao invalidar código: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteCode(String codeId, String code) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Código'),
        content: Text('Tem certeza que deseja excluir permanentemente o código "$code"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await _repository.deleteCode(code);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Código "$code" excluído'),
              backgroundColor: Colors.green,
            ),
          );
          _loadCodes();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao excluir código'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir código: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        title: const Text('Gerenciar Códigos Beta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report, color: AppColors.lilac),
            tooltip: 'Debug',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BetaCodesDebugPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card para criar novo código
                  MagicalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text('➕', style: TextStyle(fontSize: 24)),
                            SizedBox(width: 12),
                            Text(
                              'Criar Novo Código',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.lilac,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _codeController,
                                decoration: InputDecoration(
                                  hintText: 'Digite o código (ex: BETA2025)',
                                  hintStyle: TextStyle(
                                    color: AppColors.softWhite.withOpacity(0.5),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppColors.lilac),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: AppColors.lilac.withOpacity(0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: AppColors.lilac),
                                  ),
                                ),
                                textCapitalization: TextCapitalization.characters,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _createCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lilac,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Criar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Estatísticas
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total',
                          _codes.length.toString(),
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Disponíveis',
                          _codes.where((c) => c['is_used'] == false || c['is_used'] == 0).length.toString(),
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Usados',
                          _codes.where((c) => c['is_used'] == true || c['is_used'] == 1).length.toString(),
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Lista de códigos
                  const Text(
                    'Códigos Criados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lilac,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_codes.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'Nenhum código criado ainda',
                          style: TextStyle(
                            color: AppColors.softWhite.withOpacity(0.5),
                          ),
                        ),
                      ),
                    )
                  else
                    ..._codes.map((code) => _buildCodeCard(code)),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.softWhite.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeCard(Map<String, dynamic> code) {
    // Normalizar is_used (pode vir como bool do Supabase ou int do SQLite)
    final isUsed = code['is_used'] == true || code['is_used'] == 1;
    final codeText = code['code'] as String;

    // Normalizar created_at (pode vir como String ISO8601 do Supabase ou int do SQLite)
    final createdAt = _parseDateTime(code['created_at']);

    // Normalizar used_at
    final usedAt = code['used_at'] != null ? _parseDateTime(code['used_at']) : null;

    final usedBy = code['used_by'] as String?;

    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUsed
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isUsed ? Colors.orange : Colors.green,
                  ),
                ),
                child: Text(
                  isUsed ? 'USADO' : 'DISPONÍVEL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isUsed ? Colors.orange : Colors.green,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Código
              Expanded(
                child: SelectableText(
                  codeText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lilac,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              // Botão copiar
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: codeText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Código copiado!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                tooltip: 'Copiar código',
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Informações
          Text(
            'Criado em: ${_formatDate(createdAt)}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.softWhite.withOpacity(0.6),
            ),
          ),
          if (isUsed && usedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Usado em: ${_formatDate(usedAt)}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.softWhite.withOpacity(0.6),
              ),
            ),
          ],
          if (isUsed && usedBy != null) ...[
            const SizedBox(height: 4),
            Text(
              'Usado por: $usedBy',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.softWhite.withOpacity(0.6),
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Ações
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isUsed)
                TextButton.icon(
                  onPressed: () => _invalidateCode(code['id'], codeText),
                  icon: const Icon(Icons.block, size: 16),
                  label: const Text('Invalidar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange,
                  ),
                ),
              TextButton.icon(
                onPressed: () => _deleteCode(code['id'], codeText),
                icon: const Icon(Icons.delete, size: 16),
                label: const Text('Excluir'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Parse DateTime de diferentes formatos (Supabase String ISO8601 ou SQLite int milliseconds)
  DateTime _parseDateTime(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }

    if (value is int) {
      // SQLite: milliseconds since epoch
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      // Supabase: ISO8601 string
      return DateTime.parse(value);
    } else {
      // Fallback
      print('Formato de data desconhecido: $value (${value.runtimeType})');
      return DateTime.now();
    }
  }
}
