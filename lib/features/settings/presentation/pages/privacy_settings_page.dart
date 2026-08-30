import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/legal/legal_document_page.dart';
import '../../../../core/services/data_export_service.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/repositories/supabase_auth_repository.dart';

/// Página de configurações de privacidade
class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  // Preferências de privacidade
  bool _analyticsEnabled = true;
  bool _crashReportingEnabled = true;
  bool _personalizedContent = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _analyticsEnabled = prefs.getBool('privacy_analytics') ?? true;
      _crashReportingEnabled = prefs.getBool('privacy_crash_reporting') ?? true;
      _personalizedContent = prefs.getBool('privacy_personalized') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.gc.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ResponsiveAppBarTitle(
          l10n.settingsPrivacy,
          style: TextStyle(
            color: context.gc.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.gc.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seção: Coleta de Dados
                  _buildSectionHeader(l10n.editDataCollection),
                  _buildSettingsCard([
                    _buildSwitchTile(
                      icon: Icons.analytics_outlined,
                      title: l10n.editAnalytics,
                      subtitle: l10n.editAnalyticsSubtitle,
                      value: _analyticsEnabled,
                      onChanged: (value) {
                        setState(() => _analyticsEnabled = value);
                        _saveSetting('privacy_analytics', value);
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.bug_report_outlined,
                      title: l10n.editCrashReports,
                      subtitle: l10n.editCrashReportsSubtitle,
                      value: _crashReportingEnabled,
                      onChanged: (value) {
                        setState(() => _crashReportingEnabled = value);
                        _saveSetting('privacy_crash_reporting', value);
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.auto_awesome,
                      title: l10n.editPersonalizedContent,
                      subtitle: l10n.editPersonalizedContentSubtitle,
                      value: _personalizedContent,
                      onChanged: (value) {
                        setState(() => _personalizedContent = value);
                        _saveSetting('privacy_personalized', value);
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Seção: Gerenciar Dados
                  _buildSectionHeader(l10n.editManageData),
                  _buildSettingsCard([
                    _buildActionTile(
                      icon: Icons.download_outlined,
                      title: l10n.editExportData,
                      subtitle: l10n.editExportDataSubtitle,
                      onTap: _exportData,
                    ),
                    _buildDivider(),
                    _buildActionTile(
                      icon: Icons.delete_sweep_outlined,
                      title: l10n.editClearLocal,
                      subtitle: l10n.editClearLocalSubtitle,
                      onTap: _clearLocalData,
                      isDestructive: false,
                    ),
                    _buildDivider(),
                    _buildActionTile(
                      icon: Icons.delete_forever_outlined,
                      title: l10n.editDeleteAccount,
                      subtitle: l10n.editDeleteAccountSubtitle,
                      onTap: _deleteAccount,
                      isDestructive: true,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Informações sobre privacidade
                  _buildInfoCard(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: context.gc.lilac,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    // A cor vive no Material, não num Container por fora: os ListTile pintam
    // o respingo do toque no Material mais próximo, e com o fundo opaco por
    // cima o respingo ficava invisível (o Flutter reclama disso em debug).
    return Material(
      color: context.gc.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.gc.textPrimary10),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.gc.lilac.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: context.gc.lilac, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: context.gc.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: context.gc.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: context.gc.lilac,
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : context.gc.textPrimary;
    final iconBgColor = isDestructive
        ? Colors.red.withValues(alpha: 0.2)
        : context.gc.lilac.withValues(alpha: 0.2);
    final iconColor = isDestructive ? Colors.red : context.gc.lilac;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDestructive
              ? Colors.red.withValues(alpha: 0.7)
              : context.gc.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: color.withValues(alpha: 0.5)),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 56,
      color: context.gc.textPrimary.withValues(alpha: 0.1),
    );
  }

  Widget _buildInfoCard() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.gc.lilac.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.gc.lilac.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: context.gc.lilac, size: 20),
              SizedBox(width: 8),
              Text(
                l10n.editPrivacyMatters,
                style: TextStyle(
                  color: context.gc.lilac,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.editPrivacyNote,
            style: TextStyle(
              color: context.gc.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _showPrivacyPolicy,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10n.privacyReadFullPolicy,
              style: TextStyle(
                color: context.gc.lilac,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.gc.surface,
        title: Text(
          l10n.editExportTitle,
          style: TextStyle(color: context.gc.textPrimary),
        ),
        content: Text(
          l10n.editExportConfirm,
          style: TextStyle(color: context.gc.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performExport();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.gc.lilac,
            ),
            child:
                // textPrimary é quase branco nos temas escuros e sumia
                // sobre o fundo lilás; onPrimary é o token para texto
                // sobre o acento.
                Text(l10n.editExportAction,
                    style: TextStyle(color: context.gc.onPrimary)),
          ),
        ],
      ),
    );
  }

  Future<void> _performExport() async {
    final l10n = AppLocalizations.of(context);
    // Capturados ANTES dos awaits: usar o context depois deles é apostar
    // que o widget continua vivo (use_build_context_synchronously).
    final messenger = ScaffoldMessenger.of(context);
    final gc = context.gc;
    try {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.editExporting),
          backgroundColor: gc.lilac,
        ),
      );

      await DataExportService.instance
          .exportAndDeliver(subject: l10n.privacyBackupSubject);

      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.editExportSuccess),
          backgroundColor: gc.success,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('${l10n.editExportError}: $e'),
          backgroundColor: gc.alert,
        ),
      );
    }
  }
  Future<void> _clearLocalData() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.gc.surface,
        title: Text(
          l10n.editClearLocalTitle,
          style: TextStyle(color: context.gc.textPrimary),
        ),
        content: Text(
          l10n.editClearLocalConfirm,
          style: TextStyle(color: context.gc.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: Text(l10n.editClearAction,
                style: TextStyle(color: context.gc.textPrimary)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final db = await DatabaseHelper.instance.database;

        // Tabelas para limpar (exceto dados pré-carregados)
        final tables = [
          'spells',
          'dreams',
          'desires',
          'gratitudes',
          'daily_rituals',
          'ritual_logs',
          'sigils',
          'birth_charts',
          'magical_profiles',
          'rune_readings',
          'pendulum_consultations',
          'oracle_readings',
          'daily_magical_weather',
          'learning_progress',
          'guided_ritual_logs',
          'user_encyclopedia_entries',
          'daily_checkins'
        ];

        for (final table in tables) {
          try {
            if (table == 'spells' || table == 'affirmations') {
              // Manter itens pré-carregados
              await db.delete(table, where: 'is_preloaded = ?', whereArgs: [0]);
            } else {
              await db.delete(table);
            }
          } catch (e) {
            // Ignorar erros de tabelas que não existem
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.editClearSuccess),
              backgroundColor: context.gc.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.editClearError}: $e'),
              backgroundColor: context.gc.alert,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.gc.surface,
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              l10n.editDeleteTitle,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
        content: Text(
          l10n.editDeleteWarning,
          style: TextStyle(color: context.gc.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              l10n.editDeletePermanently,
              style: TextStyle(color: context.gc.textPrimary),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Capturados antes dos awaits — e o loading precisa fechar mesmo que
      // a página morra no meio (use_build_context_synchronously).
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      final router = GoRouter.of(context);
      final gc = context.gc;
      final authProvider = context.read<AuthProvider>();

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: context.gc.surface,
          content: LoadingWidget(message: l10n.editDeleting),
        ),
      );

      try {
        // 1. Deletar dados do Supabase (se logado)
        if (SupabaseConfig.isConfigured) {
          final authRepository = SupabaseAuthRepository();
          final result = await authRepository.deleteAccount();
          if (!result.success) {
            throw Exception(result.errorMessage ?? l10n.editDeleteError);
          }
        }

        // 2. Limpar banco de dados local
        final db = DatabaseHelper.instance;
        await db.clearAllTables();

        // 3. Limpar SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // 4. Fazer logout do provider
        await authProvider.clearAllData();

        // Fechar loading
        navigator.pop();

        // Mostrar mensagem de sucesso
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.editDeleteSuccess),
            backgroundColor: gc.success,
          ),
        );

        // Redirecionar para tela inicial. Com o router, o logout já dispara o
        // redirect para /welcome (refreshListenable); isto é explícito por
        // garantia de tempo. `router` foi capturado ANTES dos awaits, para não
        // usar BuildContext depois deles (use_build_context_synchronously).
        router.go('/welcome');
      } catch (e) {
        // Fechar loading
        navigator.pop();

        // Mostrar erro
        messenger.showSnackBar(
          SnackBar(
            content: Text('${l10n.editDeleteErrorPrefix}: $e'),
            backgroundColor: gc.alert,
          ),
        );
      }
    }
  }

  void _showPrivacyPolicy() {
    // Mesmo documento oficial usado em Ajuda & Suporte
    // (assets/legal/politica_de_privacidade.md).
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LegalDocumentPage.privacy),
    );
  }
}
