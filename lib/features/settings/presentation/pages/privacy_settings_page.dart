import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/data_sync_service.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/repositories/supabase_auth_repository.dart';
import '../../../subscription/presentation/pages/subscription_page.dart';

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
  bool _cloudSyncEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final authProvider = context.read<AuthProvider>();
    final syncProvider = context.read<SyncProvider>();
    final prefs = await SharedPreferences.getInstance();
    final isPremium = authProvider.isPremiumEffective;
    final cloudSyncEnabled = await DataSyncService.ensureCloudSyncPreference(
      prefs,
      isPremium: isPremium,
    );
    await syncProvider.refreshState();
    if (!mounted) return;
    setState(() {
      _analyticsEnabled = prefs.getBool('privacy_analytics') ?? true;
      _crashReportingEnabled = prefs.getBool('privacy_crash_reporting') ?? true;
      _personalizedContent = prefs.getBool('privacy_personalized') ?? true;
      _cloudSyncEnabled = cloudSyncEnabled;
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    if (key == DataSyncService.cloudSyncPreferenceKey) {
      await prefs.setBool(
        DataSyncService.cloudSyncUserConfiguredKey,
        true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const ResponsiveAppBarTitle(
          'Privacidade',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.lilac))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seção: Coleta de Dados
                  _buildSectionHeader('Coleta de Dados'),
                  _buildSettingsCard([
                    _buildSwitchTile(
                      icon: Icons.analytics_outlined,
                      title: 'Analytics',
                      subtitle:
                          'Ajude a melhorar o app compartilhando dados de uso anônimos',
                      value: _analyticsEnabled,
                      onChanged: (value) {
                        setState(() => _analyticsEnabled = value);
                        _saveSetting('privacy_analytics', value);
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.bug_report_outlined,
                      title: 'Relatórios de Erro',
                      subtitle:
                          'Enviar relatórios automáticos quando o app tiver problemas',
                      value: _crashReportingEnabled,
                      onChanged: (value) {
                        setState(() => _crashReportingEnabled = value);
                        _saveSetting('privacy_crash_reporting', value);
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.auto_awesome,
                      title: 'Conteúdo Personalizado',
                      subtitle: 'Receber sugestões baseadas no seu uso do app',
                      value: _personalizedContent,
                      onChanged: (value) {
                        setState(() => _personalizedContent = value);
                        _saveSetting('privacy_personalized', value);
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Seção: Sincronização e Backup
                  _buildSectionHeader('Sincronização e Backup'),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      final isPremium = authProvider.isPremiumEffective;
                      return _buildSettingsCard([
                        _buildSwitchTile(
                          icon: Icons.sync,
                          title: 'Sincronização e Backup na Nuvem',
                          subtitle: isPremium
                              ? 'Manter seus dados protegidos e sincronizados entre dispositivos'
                              : 'Recurso exclusivo Premium',
                          value: _cloudSyncEnabled,
                          onChanged: (value) {
                            if (!isPremium && value) {
                              _showUpgradeDialog();
                            } else {
                              setState(() => _cloudSyncEnabled = value);
                              _saveSetting(
                                DataSyncService.cloudSyncPreferenceKey,
                                value,
                              );
                            }
                          },
                        ),
                      ]);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Seção: Status de Sincronização
                  _buildSectionHeader('Status de Sincronização'),
                  _buildSyncStatusCard(),

                  const SizedBox(height: 24),

                  // Seção: Gerenciar Dados
                  _buildSectionHeader('Gerenciar Seus Dados'),
                  _buildSettingsCard([
                    _buildActionTile(
                      icon: Icons.download_outlined,
                      title: 'Exportar Meus Dados',
                      subtitle: 'Baixar uma cópia de todos os seus dados',
                      onTap: _exportData,
                    ),
                    _buildDivider(),
                    _buildActionTile(
                      icon: Icons.delete_sweep_outlined,
                      title: 'Limpar Dados Locais',
                      subtitle: 'Remover dados salvos neste dispositivo',
                      onTap: _clearLocalData,
                      isDestructive: false,
                    ),
                    _buildDivider(),
                    _buildActionTile(
                      icon: Icons.delete_forever_outlined,
                      title: 'Excluir Minha Conta',
                      subtitle: 'Remover permanentemente todos os seus dados',
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
        style: const TextStyle(
          color: AppColors.lilac,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
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
          color: AppColors.lilac.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.lilac, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.lilac,
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
    final color = isDestructive ? Colors.red : Colors.white;
    final iconBgColor = isDestructive
        ? Colors.red.withValues(alpha: 0.2)
        : AppColors.lilac.withValues(alpha: 0.2);
    final iconColor = isDestructive ? Colors.red : AppColors.lilac;

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
              : Colors.white54,
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
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _buildSyncStatusCard() {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, _) {
        final isPremium = syncProvider.isPremium;
        final isReady = syncProvider.isReady && _cloudSyncEnabled;
        final status = syncProvider.status;
        final isSyncing = syncProvider.isSyncing;

        // Se não é premium, mostrar upsell
        if (!isPremium) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.lilac.withValues(alpha: 0.2),
                  AppColors.gold.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.workspace_premium,
                          color: AppColors.gold, size: 28),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sincronização na Nuvem',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Recurso exclusivo Premium',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Mantenha seus dados sincronizados entre todos os seus dispositivos e nunca perca seus feitiços e diários.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => openSubscriptionPage(context),
                    icon: const Icon(Icons.star, size: 18),
                    label: const Text('Seja Premium'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getSyncStatusColor(status).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getSyncStatusIcon(status),
                      color: _getSyncStatusColor(status),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                !_cloudSyncEnabled
                                    ? 'Sincronização desativada'
                                    : isReady
                                        ? syncProvider.statusText
                                        : 'Não conectado',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'PREMIUM',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          !_cloudSyncEnabled
                              ? 'Ative a sincronização na nuvem'
                              : isReady
                                  ? syncProvider.lastSyncText
                                  : 'Faça login para sincronizar',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isReady && !isSyncing)
                    IconButton(
                      onPressed: () async {
                        // Botão de atualizar executa uma sincronização completa
                        final result = await syncProvider.sync();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result.success
                                    ? 'Sincronizado com sucesso.'
                                    : result.error ?? 'Erro na sincronização',
                              ),
                              backgroundColor: result.success
                                  ? AppColors.success
                                  : AppColors.alert,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.refresh, color: AppColors.lilac),
                      tooltip: 'Sincronizar agora',
                    ),
                  if (isSyncing)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.lilac),
                      ),
                    ),
                ],
              ),
              // Botões "Enviar Tudo"/"Baixar Tudo" removidos — o botão de
              // atualizar (refresh) acima já executa uma sincronização
              // completa (upload + download).
            ],
          ),
        );
      },
    );
  }

  Color _getSyncStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return AppColors.lilac;
      case SyncStatus.syncing:
        return AppColors.lilac;
      case SyncStatus.success:
        return AppColors.success;
      case SyncStatus.error:
        return AppColors.alert;
      case SyncStatus.conflict:
        return Colors.orange;
    }
  }

  IconData _getSyncStatusIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return Icons.cloud_queue_outlined;
      case SyncStatus.syncing:
        return Icons.sync;
      case SyncStatus.success:
        return Icons.cloud_done_outlined;
      case SyncStatus.error:
        return Icons.cloud_off_outlined;
      case SyncStatus.conflict:
        return Icons.warning_amber_outlined;
    }
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lilac.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lilac.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: AppColors.lilac, size: 20),
              SizedBox(width: 8),
              Text(
                'Sua Privacidade Importa',
                style: TextStyle(
                  color: AppColors.lilac,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Seus dados mágicos são sagrados. Nunca vendemos suas informações pessoais '
            'e você tem controle total sobre o que é coletado e armazenado.',
            style: TextStyle(
              color: Colors.white70,
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
            child: const Text(
              'Ler Política de Privacidade completa',
              style: TextStyle(
                color: AppColors.lilac,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Exportar Dados',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Seus dados serão exportados em formato JSON. '
          'Isso pode levar alguns segundos.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performExport();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lilac,
            ),
            child:
                const Text('Exportar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _performExport() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exportando dados...'),
          backgroundColor: AppColors.lilac,
        ),
      );

      final db = await DatabaseHelper.instance.database;
      final exportData = <String, dynamic>{};

      // Tabelas para exportar
      final tables = [
        'spells',
        'dreams',
        'desires',
        'gratitudes',
        'affirmations',
        'daily_rituals',
        'ritual_logs',
        'sigils',
        'birth_charts',
        'magical_profiles',
        'rune_readings',
        'pendulum_consultations',
        'oracle_readings',
        'daily_magical_weather'
      ];

      for (final table in tables) {
        try {
          final data = await db.query(table);
          exportData[table] = data;
        } catch (e) {
          exportData[table] = [];
        }
      }

      exportData['export_date'] = DateTime.now().toIso8601String();
      exportData['app_version'] = '1.0.0';

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'grimorio_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      if (mounted) {
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Backup Grimório de Bolso',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados exportados com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar: $e'),
            backgroundColor: AppColors.alert,
          ),
        );
      }
    }
  }

  Future<void> _clearLocalData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Limpar Dados Locais?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Isso removera todos os dados salvos neste dispositivo. '
          'Se você tem sincronização ativada, seus dados na nuvem serão mantidos.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Limpar', style: TextStyle(color: Colors.white)),
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
          'daily_magical_weather'
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
            const SnackBar(
              content: Text('Dados locais removidos com sucesso'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao limpar dados: $e'),
              backgroundColor: AppColors.alert,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text(
              'Excluir Conta',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        content: const Text(
          'ATENÇÃO: Esta ação é IRREVERSÍVEL!\n\n'
          'Todos os seus dados serão permanentemente excluídos, incluindo:\n'
          '- Feitiços e rituais\n'
          '- Entradas de diário\n'
          '- Mapa astral\n'
          '- Configurações\n\n'
          'Tem certeza absoluta?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Excluir Permanentemente',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          backgroundColor: AppColors.surface,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.lilac),
              SizedBox(height: 16),
              Text(
                'Excluindo conta...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );

      try {
        // 1. Deletar dados do Supabase (se logado)
        if (SupabaseConfig.isConfigured) {
          final authRepository = SupabaseAuthRepository();
          final result = await authRepository.deleteAccount();
          if (!result.success) {
            throw Exception(result.errorMessage ?? 'Erro ao deletar conta');
          }
        }

        // 2. Limpar banco de dados local
        final db = DatabaseHelper.instance;
        await db.clearAllTables();

        // 3. Limpar SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // 4. Fazer logout do provider
        final authProvider = context.read<AuthProvider>();
        await authProvider.clearAllData();

        if (!mounted) return;

        // Fechar loading
        Navigator.of(context).pop();

        // Mostrar mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta excluída com sucesso'),
            backgroundColor: AppColors.success,
          ),
        );

        // Redirecionar para tela inicial
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/welcome', (route) => false);
      } catch (e) {
        if (!mounted) return;

        // Fechar loading
        Navigator.of(context).pop();

        // Mostrar erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir conta: $e'),
            backgroundColor: AppColors.alert,
          ),
        );
      }
    }
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Color(0xFFFFD700)),
            SizedBox(width: 8),
            Text(
              'Recurso Premium',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: const Text(
          'A sincronização de dados na nuvem é um recurso exclusivo para usuários Premium.\n\n'
          'Com o Premium, seus dados ficam sempre seguros e sincronizados entre todos os seus dispositivos.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Agora Não',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openSubscriptionPage(this.context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
            ),
            child: const Text(
              'Fazer Upgrade',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Política de Privacidade',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: const Text(
                  '''POLÍTICA DE PRIVACIDADE - GRIMÓRIO DE BOLSO

Última atualização: Novembro 2025

1. COLETA DE DADOS

Coletamos apenas os dados necessários para o funcionamento do app:
- Email e senha (para autenticação)
- Dados de perfil (nome, foto - opcionais)
- Dados de nascimento (para cálculo do mapa astral)
- Conteúdo criado por você (feitiços, diários, etc.)

2. USO DOS DADOS

Seus dados são utilizados exclusivamente para:
- Prover os serviços do app
- Sincronizar entre dispositivos
- Melhorar a experiência do usuário

3. COMPARTILHAMENTO

NÃO vendemos, alugamos ou compartilhamos seus dados pessoais com terceiros, exceto:
- Quando exigido por lei
- Para proteger nossos direitos legais

4. SEGURANCA

Utilizamos criptografia e melhores práticas de segurança para proteger seus dados.

5. SEUS DIREITOS

Você pode a qualquer momento:
- Acessar seus dados
- Corrigir informações
- Exportar seus dados
- Excluir sua conta

6. CONTATO

Para dúvidas sobre privacidade, entre em contato:
privacidade@grimoriodebolso.com.br
''',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
