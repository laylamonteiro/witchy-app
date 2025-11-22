import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/data_sync_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

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
  bool _syncEnabled = true;
  bool _backupEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _analyticsEnabled = prefs.getBool('privacy_analytics') ?? true;
      _crashReportingEnabled = prefs.getBool('privacy_crash_reporting') ?? true;
      _personalizedContent = prefs.getBool('privacy_personalized') ?? true;
      _syncEnabled = prefs.getBool('privacy_sync') ?? true;
      _backupEnabled = prefs.getBool('privacy_backup') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
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
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
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
                      subtitle: 'Ajude a melhorar o app compartilhando dados de uso anonimos',
                      value: _analyticsEnabled,
                      onChanged: (value) {
                        setState(() => _analyticsEnabled = value);
                        _saveSetting('privacy_analytics', value);
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.bug_report_outlined,
                      title: 'Relatorios de Erro',
                      subtitle: 'Enviar relatorios automaticos quando o app tiver problemas',
                      value: _crashReportingEnabled,
                      onChanged: (value) {
                        setState(() => _crashReportingEnabled = value);
                        _saveSetting('privacy_crash_reporting', value);
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.auto_awesome,
                      title: 'Conteudo Personalizado',
                      subtitle: 'Receber sugestoes baseadas no seu uso do app',
                      value: _personalizedContent,
                      onChanged: (value) {
                        setState(() => _personalizedContent = value);
                        _saveSetting('privacy_personalized', value);
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Seção: Sincronização e Backup
                  _buildSectionHeader('Sincronizacao e Backup'),
                  _buildSettingsCard([
                    _buildSwitchTile(
                      icon: Icons.sync,
                      title: 'Sincronizacao Automatica',
                      subtitle: 'Manter seus dados sincronizados entre dispositivos',
                      value: _syncEnabled,
                      onChanged: (value) {
                        setState(() => _syncEnabled = value);
                        _saveSetting('privacy_sync', value);
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.cloud_upload_outlined,
                      title: 'Backup na Nuvem',
                      subtitle: 'Salvar uma copia dos seus dados na nuvem',
                      value: _backupEnabled,
                      onChanged: (value) {
                        setState(() => _backupEnabled = value);
                        _saveSetting('privacy_backup', value);
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Seção: Gerenciar Dados
                  _buildSectionHeader('Gerenciar Seus Dados'),
                  _buildSettingsCard([
                    _buildActionTile(
                      icon: Icons.download_outlined,
                      title: 'Exportar Meus Dados',
                      subtitle: 'Baixar uma copia de todos os seus dados',
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
          color: AppTheme.primary,
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
        color: AppTheme.cardBackground,
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
          color: AppTheme.primary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
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
        activeColor: AppTheme.primary,
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
        : AppTheme.primary.withValues(alpha: 0.2);
    final iconColor = isDestructive ? Colors.red : AppTheme.primary;

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
          color: isDestructive ? Colors.red.withValues(alpha: 0.7) : Colors.white54,
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

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: AppTheme.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Sua Privacidade Importa',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Seus dados magicos sao sagrados. Nunca vendemos suas informacoes pessoais '
            'e voce tem controle total sobre o que e coletado e armazenado.',
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
              'Ler Politica de Privacidade completa',
              style: TextStyle(
                color: AppTheme.primary,
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
        backgroundColor: AppTheme.cardBackground,
        title: const Text(
          'Exportar Dados',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Seus dados serao exportados em formato JSON. '
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
              // TODO: Implementar exportação de dados
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exportacao iniciada...'),
                  backgroundColor: AppTheme.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
            ),
            child: const Text('Exportar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _clearLocalData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text(
          'Limpar Dados Locais?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Isso removera todos os dados salvos neste dispositivo. '
          'Se voce tem sincronizacao ativada, seus dados na nuvem serao mantidos.',
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
      // TODO: Implementar limpeza de dados locais
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados locais removidos'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
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
          'ATENCAO: Esta acao e IRREVERSIVEL!\n\n'
          'Todos os seus dados serao permanentemente excluidos, incluindo:\n'
          '- Feiticos e rituais\n'
          '- Entradas de diario\n'
          '- Mapa astral\n'
          '- Configuracoes\n\n'
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
      // TODO: Implementar exclusão de conta
      final authProvider = context.read<AuthProvider>();
      await authProvider.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
      }
    }
  }

  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBackground,
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
                'Politica de Privacidade',
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
                  '''POLITICA DE PRIVACIDADE - GRIMORIO DE BOLSO

Ultima atualizacao: Novembro 2025

1. COLETA DE DADOS

Coletamos apenas os dados necessarios para o funcionamento do app:
- Email e senha (para autenticacao)
- Dados de perfil (nome, foto - opcionais)
- Dados de nascimento (para calculo do mapa astral)
- Conteudo criado por voce (feiticos, diarios, etc.)

2. USO DOS DADOS

Seus dados sao utilizados exclusivamente para:
- Prover os servicos do app
- Sincronizar entre dispositivos
- Melhorar a experiencia do usuario

3. COMPARTILHAMENTO

NAO vendemos, alugamos ou compartilhamos seus dados pessoais com terceiros, exceto:
- Quando exigido por lei
- Para proteger nossos direitos legais

4. SEGURANCA

Utilizamos criptografia e melhores praticas de seguranca para proteger seus dados.

5. SEUS DIREITOS

Voce pode a qualquer momento:
- Acessar seus dados
- Corrigir informacoes
- Exportar seus dados
- Excluir sua conta

6. CONTATO

Para duvidas sobre privacidade, entre em contato:
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
