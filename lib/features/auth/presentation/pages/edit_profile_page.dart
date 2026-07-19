import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/i18n/gender.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/services/data_sync_service.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/config/supabase_config.dart';
import '../providers/auth_provider.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../../../subscription/presentation/pages/subscription_page.dart';

/// Página de edição de perfil com todas as configurações de privacidade
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();

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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final authProvider = context.read<AuthProvider>();
    final prefs = await SharedPreferences.getInstance();
    final isPremium = authProvider.isPremiumEffective;
    final cloudSyncEnabled = await DataSyncService.ensureCloudSyncPreference(
      prefs,
      isPremium: isPremium,
    );

    if (!mounted) return;
    setState(() {
      _nameController.text = authProvider.currentUser.displayName ?? '';
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
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: context.gc.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ResponsiveAppBarTitle(
          'Editar Perfil',
          style: GoogleFonts.cinzelDecorative(
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
          ? Center(
              child: CircularProgressIndicator(color: context.gc.lilac))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seção: Informações Básicas
                  _buildSectionHeader('Informações Básicas'),
                  _buildSettingsCard([
                    _buildTextFieldTile(
                      icon: Icons.person_outline,
                      title: 'Nome',
                      controller: _nameController,
                      onSave: () async {
                        await authProvider.updateProfile(
                          displayName: _nameController.text.trim(),
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Nome atualizado!'),
                              backgroundColor: context.gc.success,
                            ),
                          );
                        }
                      },
                    ),
                    _buildDivider(),
                    _buildInfoTile(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      value: user.email,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Seção: Gênero
                  _buildSectionHeader('Gênero'),
                  _buildSettingsCard([
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Como o app deve se dirigir a você? Usamos essa '
                            'escolha nos textos personalizados e nas respostas '
                            'do Conselheiro Místico.',
                            style: TextStyle(
                              color: context.gc.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: Gender.values.map((pref) {
                              final selected =
                                  user.gender == pref;
                              return ChoiceChip(
                                label: Text(_genderLabel(pref)),
                                selected: selected,
                                selectedColor:
                                    context.gc.lilac.withOpacity(0.25),
                                labelStyle: TextStyle(
                                  color: selected
                                      ? context.gc.lilac
                                      : context.gc.textSecondary,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                side: BorderSide(
                                  color: selected
                                      ? context.gc.lilac
                                      : context.gc.surfaceBorder,
                                ),
                                backgroundColor: context.gc.surface,
                                onSelected: (_) => authProvider
                                    .setGender(pref),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Seção: Segurança (apenas para não-OAuth)
                  if (!_isOAuthUser(user.email)) ...[
                    _buildSectionHeader('Segurança'),
                    _buildSettingsCard([
                      _buildActionTile(
                        icon: Icons.lock_outline,
                        title: 'Alterar Senha',
                        subtitle: 'Modificar sua senha de acesso',
                        onTap: _showChangePasswordDialog,
                      ),
                    ]),
                    const SizedBox(height: 24),
                  ],

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

  bool _isOAuthUser(String? email) {
    // Se o usuário logou com OAuth (Google), não mostrar opção de senha
    // Por enquanto, assumimos que emails que não foram criados localmente são OAuth
    // Você pode adicionar um campo no UserModel para rastrear isso melhor
    if (email == null) return false;
    return false; // Por padrão, assume que todos podem trocar senha
  }

  String _genderLabel(Gender pref) {
    switch (pref) {
      case Gender.feminine:
        return 'Feminino';
      case Gender.masculine:
        return 'Masculino';
      case Gender.neutral:
        return 'Neutro';
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.nunito(
          color: context.gc.lilac,
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
        color: context.gc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.gc.textPrimary10),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextFieldTile({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required VoidCallback onSave,
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
      title: TextField(
        controller: controller,
        style: GoogleFonts.nunito(color: context.gc.textPrimary),
        decoration: InputDecoration(
          labelText: title,
          labelStyle: GoogleFonts.nunito(color: context.gc.textSecondary),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.check, color: context.gc.lilac),
        onPressed: onSave,
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String? value,
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
        style: GoogleFonts.nunito(
          color: context.gc.textSecondary,
          fontSize: 12,
        ),
      ),
      subtitle: Text(
        value ?? 'Não informado',
        style: GoogleFonts.nunito(
          color: context.gc.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
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
        style: GoogleFonts.nunito(
          color: context.gc.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.nunito(
          color: context.gc.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: context.gc.lilac,
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
        style: GoogleFonts.nunito(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.nunito(
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
              Icon(Icons.shield_outlined,
                  color: context.gc.lilac, size: 20),
              const SizedBox(width: 8),
              Text(
                'Sua Privacidade Importa',
                style: GoogleFonts.nunito(
                  color: context.gc.lilac,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Seus dados mágicos são sagrados. Nunca vendemos suas informações pessoais '
            'e você tem controle total sobre o que é coletado e armazenado.',
            style: GoogleFonts.nunito(
              color: context.gc.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.gc.surface,
        title: Text(
          'Alterar Senha',
          style: GoogleFonts.nunito(color: context.gc.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              style: GoogleFonts.nunito(color: context.gc.textPrimary),
              decoration: InputDecoration(
                labelText: 'Senha Atual',
                labelStyle: GoogleFonts.nunito(color: context.gc.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: context.gc.textPrimary.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: context.gc.lilac),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              style: GoogleFonts.nunito(color: context.gc.textPrimary),
              decoration: InputDecoration(
                labelText: 'Nova Senha',
                labelStyle: GoogleFonts.nunito(color: context.gc.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: context.gc.textPrimary.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: context.gc.lilac),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              style: GoogleFonts.nunito(color: context.gc.textPrimary),
              decoration: InputDecoration(
                labelText: 'Confirmar Nova Senha',
                labelStyle: GoogleFonts.nunito(color: context.gc.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: context.gc.textPrimary.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: context.gc.lilac),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.nunito()),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('As senhas não coincidem'),
                    backgroundColor: context.gc.alert,
                  ),
                );
                return;
              }

              if (newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('A nova senha deve ter pelo menos 6 caracteres'),
                    backgroundColor: context.gc.alert,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              // Atualizar senha via Supabase ou local
              if (SupabaseConfig.isConfigured) {
                try {
                  final authRepo = SupabaseAuthRepository();
                  final result = await authRepo.updatePassword(
                    currentPasswordController.text,
                    newPasswordController.text,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result.success
                            ? 'Senha alterada com sucesso!'
                            : result.errorMessage ?? 'Erro ao alterar senha'),
                        backgroundColor: result.success
                            ? context.gc.success
                            : context.gc.alert,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro: $e'),
                        backgroundColor: context.gc.alert,
                      ),
                    );
                  }
                }
              } else {
                // Modo local - sempre sucesso (senhas não são armazenadas localmente)
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Senha alterada com sucesso!'),
                      backgroundColor: context.gc.success,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.gc.lilac,
            ),
            child: Text(
              'Alterar',
              style: GoogleFonts.nunito(color: context.gc.textPrimary),
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
        backgroundColor: context.gc.surface,
        title: Text(
          'Exportar Dados',
          style: GoogleFonts.nunito(color: context.gc.textPrimary),
        ),
        content: Text(
          'Seus dados serão exportados em formato JSON. '
          'Isso pode levar alguns segundos.',
          style: GoogleFonts.nunito(color: context.gc.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: GoogleFonts.nunito()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performExport();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.gc.lilac,
            ),
            child: Text('Exportar',
                style: GoogleFonts.nunito(color: context.gc.textPrimary)),
          ),
        ],
      ),
    );
  }

  Future<void> _performExport() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exportando dados...'),
          backgroundColor: context.gc.lilac,
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
          SnackBar(
            content: Text('Dados exportados com sucesso!'),
            backgroundColor: context.gc.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao exportar: $e'),
            backgroundColor: context.gc.alert,
          ),
        );
      }
    }
  }

  Future<void> _clearLocalData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.gc.surface,
        title: Text(
          'Limpar Dados Locais?',
          style: GoogleFonts.nunito(color: context.gc.textPrimary),
        ),
        content: Text(
          'Isso removerá todos os dados salvos neste dispositivo. '
          'Se você tem sincronização ativada, seus dados na nuvem serão mantidos.',
          style: GoogleFonts.nunito(color: context.gc.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: GoogleFonts.nunito()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child:
                Text('Limpar', style: GoogleFonts.nunito(color: context.gc.textPrimary)),
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
            SnackBar(
              content: Text('Dados locais removidos com sucesso'),
              backgroundColor: context.gc.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao limpar dados: $e'),
              backgroundColor: context.gc.alert,
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
        backgroundColor: context.gc.surface,
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'Excluir Conta',
              style: GoogleFonts.nunito(color: Colors.red),
            ),
          ],
        ),
        content: Text(
          'ATENÇÃO: Esta ação é IRREVERSÍVEL!\n\n'
          'Todos os seus dados serão permanentemente excluídos, incluindo:\n'
          '- Feitiços e rituais\n'
          '- Entradas de diário\n'
          '- Mapa astral\n'
          '- Configurações\n\n'
          'Tem certeza absoluta?',
          style: GoogleFonts.nunito(color: context.gc.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: GoogleFonts.nunito()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Excluir Permanentemente',
              style: GoogleFonts.nunito(color: context.gc.textPrimary),
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
        builder: (context) => AlertDialog(
          backgroundColor: context.gc.surface,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: context.gc.lilac),
              const SizedBox(height: 16),
              Text(
                'Excluindo conta...',
                style: GoogleFonts.nunito(color: context.gc.textSecondary),
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
          SnackBar(
            content: Text('Conta excluída com sucesso'),
            backgroundColor: context.gc.success,
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
            backgroundColor: context.gc.alert,
          ),
        );
      }
    }
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.gc.surface,
        title: Row(
          children: [
            const Icon(Icons.workspace_premium, color: Color(0xFFFFD700)),
            const SizedBox(width: 8),
            Text(
              'Recurso Premium',
              style: GoogleFonts.nunito(color: context.gc.textPrimary),
            ),
          ],
        ),
        content: Text(
          'A sincronização de dados na nuvem é um recurso exclusivo para usuários Premium.\n\n'
          'Com o Premium, seus dados ficam sempre seguros e sincronizados entre todos os seus dispositivos.',
          style: GoogleFonts.nunito(color: context.gc.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Agora Não',
              style: GoogleFonts.nunito(color: context.gc.textSecondary),
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
            child: Text(
              'Fazer Upgrade',
              style: GoogleFonts.nunito(color: context.gc.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
