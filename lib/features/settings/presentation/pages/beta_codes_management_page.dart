import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/repositories/beta_code_repository.dart';
import 'beta_codes_debug_page.dart';

class BetaCodesManagementPage extends StatefulWidget {
  const BetaCodesManagementPage({super.key});

  @override
  State<BetaCodesManagementPage> createState() =>
      _BetaCodesManagementPageState();
}

class _BetaCodesManagementPageState extends State<BetaCodesManagementPage> {
  List<Map<String, dynamic>> _codes = [];
  bool _isLoading = true;
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _maxUsesController =
      TextEditingController(text: '1');
  final BetaCodeRepository _repository = BetaCodeRepository();

  @override
  void initState() {
    super.initState();
    _loadCodes();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _maxUsesController.dispose();
    super.dispose();
  }

  AppLocalizations get _l10n => AppLocalizations.of(context);

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
            content: Text('${_l10n.adminCodesLoadError}: $e'),
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
        SnackBar(
          content: Text(_l10n.adminCodesEnterValid),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validar formato do código (letras e números apenas)
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.adminCodesLettersNumbersOnly),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validar max_uses
    final maxUses = int.tryParse(_maxUsesController.text) ?? 1;
    if (maxUses < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.adminCodesUsesAtLeastOne),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await authProvider.createBetaCode(code, maxUses: maxUses);

    if (mounted) {
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_l10n.adminCodesCreated(result, maxUses)),
            backgroundColor: Colors.green,
          ),
        );
        _codeController.clear();
        _maxUsesController.text = '1'; // Resetar para 1
        _loadCodes();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_l10n.adminCodesCreateFailed),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _invalidateCode(String codeId, String code) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_l10n.adminCodesInvalidateTitle),
        content: Text(_l10n.adminCodesInvalidateConfirm(code)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(_l10n.adminCodesInvalidateAction),
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
              content: Text(_l10n.adminCodesInvalidated(code)),
              backgroundColor: Colors.green,
            ),
          );
          _loadCodes();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_l10n.adminCodesInvalidateError),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_l10n.adminCodesInvalidateError}: $e'),
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
        title: Text(_l10n.adminCodesDeleteTitle),
        content: Text(_l10n.adminCodesDeleteConfirm(code)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(_l10n.commonDelete),
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
              content: Text(_l10n.adminCodesDeleted(code)),
              backgroundColor: Colors.green,
            ),
          );
          _loadCodes();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_l10n.adminCodesDeleteError),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_l10n.adminCodesDeleteError}: $e'),
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
        title: ResponsiveAppBarTitle(_l10n.adminCodesTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.bug_report, color: context.gc.lilac),
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
          ? const LoadingWidget()
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
                        Row(
                          children: [
                            const Text('➕', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Text(
                              _l10n.adminCodesCreateNew,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: context.gc.lilac,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Campo de código
                        TextField(
                          controller: _codeController,
                          decoration: InputDecoration(
                            labelText: _l10n.adminCodesCodeLabel,
                            hintText: _l10n.adminCodesCodeHint,
                            hintStyle: TextStyle(
                              color: context.gc.softWhite.withValues(alpha: 0.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: context.gc.lilac),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: context.gc.lilac.withValues(alpha: 0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: context.gc.lilac),
                            ),
                          ),
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[A-Z0-9]')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Campo de número de usos
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _maxUsesController,
                                decoration: InputDecoration(
                                  labelText: _l10n.adminCodesUsesLabel,
                                  hintText: '1',
                                  suffixText: _l10n.adminCodesUsesSuffix,
                                  hintStyle: TextStyle(
                                    color: context.gc.softWhite.withValues(alpha: 0.5),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: context.gc.lilac),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: context.gc.lilac.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: context.gc.lilac),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _createCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.gc.lilac,
                                // textPrimary é quase branco nos temas
                                // escuros e sumia sobre o lilás claro;
                                // onPrimary é o token para texto sobre o
                                // acento.
                                foregroundColor: context.gc.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(_l10n.adminCodesCreateAction),
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
                          _l10n.adminCodesStatTotal,
                          _codes.length.toString(),
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          _l10n.adminCodesStatAvailable,
                          _codes
                              .where((c) =>
                                  c['is_used'] == false || c['is_used'] == 0)
                              .length
                              .toString(),
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          _l10n.adminCodesStatUsed,
                          _codes
                              .where((c) =>
                                  c['is_used'] == true || c['is_used'] == 1)
                              .length
                              .toString(),
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Lista de códigos
                  Text(
                    _l10n.adminCodesListTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.gc.lilac,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_codes.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          _l10n.adminCodesEmpty,
                          style: TextStyle(
                            color: context.gc.softWhite.withValues(alpha: 0.5),
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
              color: context.gc.softWhite.withValues(alpha: 0.7),
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
    final usedAt =
        code['used_at'] != null ? _parseDateTime(code['used_at']) : null;

    final usedBy = code['used_by'] as String?;

    // Informações de múltiplos usos
    final currentUses = (code['current_uses'] ?? 0) as int;
    final maxUses = (code['max_uses'] ?? 1) as int;
    final usesRemaining = maxUses - currentUses;

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
                      ? Colors.orange.withValues(alpha: 0.2)
                      : Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isUsed ? Colors.orange : Colors.green,
                  ),
                ),
                child: Text(
                  isUsed
                      ? _l10n.adminCodesBadgeUsed
                      : _l10n.adminCodesBadgeAvailable,
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.gc.lilac,
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
                    SnackBar(
                      content: Text(_l10n.adminCodesCopied),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                tooltip: _l10n.adminCodesCopyTooltip,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Informações
          Text(
            _l10n.adminCodesCreatedAt(_formatDate(createdAt)),
            style: TextStyle(
              fontSize: 12,
              color: context.gc.softWhite.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          // Informação de usos
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 14,
                color: context.gc.softWhite.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                _l10n.adminCodesUses('$currentUses', '$maxUses'),
                style: TextStyle(
                  fontSize: 12,
                  color: usesRemaining > 0
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (usesRemaining > 0) ...[
                const SizedBox(width: 8),
                Text(
                  _l10n.adminCodesRemaining(usesRemaining),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.gc.softWhite.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
          if (usedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              _l10n.adminCodesLastUsedAt(_formatDate(usedAt)),
              style: TextStyle(
                fontSize: 12,
                color: context.gc.softWhite.withValues(alpha: 0.6),
              ),
            ),
          ],
          if (usedBy != null) ...[
            const SizedBox(height: 4),
            Text(
              _l10n.adminCodesLastUser(usedBy),
              style: TextStyle(
                fontSize: 12,
                color: context.gc.softWhite.withValues(alpha: 0.6),
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
                  label: Text(_l10n.adminCodesInvalidateAction),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange,
                  ),
                ),
              TextButton.icon(
                onPressed: () => _deleteCode(code['id'], codeText),
                icon: const Icon(Icons.delete, size: 16),
                label: Text(_l10n.commonDelete),
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
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMd(locale).add_Hm().format(date);
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
