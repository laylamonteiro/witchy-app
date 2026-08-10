import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../../core/services/data_sync_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../subscription/presentation/pages/subscription_page.dart';

/// Sincronização e Backup com item PRÓPRIO nas Configurações — morava
/// dentro de Privacidade, onde ninguém achava (e semanticamente privacidade
/// é consentimento de dados, não backup).
class SyncSettingsPage extends StatefulWidget {
  const SyncSettingsPage({super.key});

  @override
  State<SyncSettingsPage> createState() => _SyncSettingsPageState();
}

class _SyncSettingsPageState extends State<SyncSettingsPage> {
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
    final cloudSyncEnabled = await DataSyncService.ensureCloudSyncPreference(
      prefs,
      isPremium: authProvider.isPremiumEffective,
    );
    await syncProvider.refreshState();
    if (!mounted) return;
    setState(() {
      _cloudSyncEnabled = cloudSyncEnabled;
      _isLoading = false;
    });
  }

  Future<void> _saveCloudSync(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(DataSyncService.cloudSyncPreferenceKey, value);
    await prefs.setBool(DataSyncService.cloudSyncUserConfiguredKey, true);
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
          l10n.editSyncBackup,
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
          ? Center(child: CircularProgressIndicator(color: context.gc.lilac))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(l10n.editSyncBackup),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      final isPremium = authProvider.isPremiumEffective;
                      return _buildSettingsCard([
                        _buildSwitchTile(
                          icon: Icons.sync,
                          title: l10n.editSyncBackupCloud,
                          subtitle: isPremium
                              ? l10n.editSyncBackupOn
                              : l10n.editSyncPremiumOnly,
                          value: isPremium && _cloudSyncEnabled,
                          onChanged: (value) {
                            // Free não altera o toggle: qualquer toque abre
                            // o convite Premium.
                            if (!isPremium) {
                              _showUpgradeDialog();
                              return;
                            }
                            setState(() => _cloudSyncEnabled = value);
                            _saveCloudSync(value);
                          },
                        ),
                      ]);
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader(l10n.privacySyncStatusSection),
                  _buildSyncStatusCard(),
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
    return Container(
      decoration: BoxDecoration(
        color: context.gc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.gc.textPrimary10),
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

  Widget _buildSyncStatusCard() {
    return Consumer<SyncProvider>(
      builder: (context, syncProvider, _) {
        final l10n = AppLocalizations.of(context);
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
                  context.gc.lilac.withValues(alpha: 0.2),
                  context.gc.gold.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.gc.gold.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: context.gc.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.workspace_premium,
                          color: context.gc.gold, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.privacyCloudSyncUpsellTitle,
                            style: TextStyle(
                              color: context.gc.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.editSyncPremiumOnly,
                            style: TextStyle(
                              color: context.gc.gold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.privacyCloudSyncUpsellBody,
                  style:
                      TextStyle(color: context.gc.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => openSubscriptionPage(context),
                    icon: const Icon(Icons.star, size: 18),
                    label: Text(l10n.premiumBePremium),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.gc.lilac,
                      foregroundColor: context.gc.onPrimary,
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
            color: context.gc.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.gc.textPrimary10),
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
                                    ? l10n.privacySyncOff
                                    : isReady
                                        ? syncProvider.statusText
                                        : l10n.privacySyncNotConnected,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.gc.textPrimary,
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
                                color: context.gc.gold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                l10n.privacyPremiumBadge,
                                style: TextStyle(
                                  color: context.gc.gold,
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
                              ? l10n.privacySyncEnablePrompt
                              : isReady
                                  ? syncProvider.lastSyncText
                                  : l10n.privacySyncLoginPrompt,
                          style: TextStyle(
                            color: context.gc.textSecondary,
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
                        if (mounted && this.context.mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result.success
                                    ? l10n.privacySyncSuccess
                                    : result.error ?? l10n.syncError,
                              ),
                              backgroundColor: result.success
                                  ? context.gc.success
                                  : context.gc.alert,
                            ),
                          );
                        }
                      },
                      icon: Icon(Icons.refresh, color: context.gc.lilac),
                      tooltip: l10n.privacySyncNow,
                    ),
                  if (isSyncing)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(context.gc.lilac),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getSyncStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.idle:
        return context.gc.lilac;
      case SyncStatus.syncing:
        return context.gc.lilac;
      case SyncStatus.success:
        return context.gc.success;
      case SyncStatus.error:
        return context.gc.alert;
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

  void _showUpgradeDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.gc.surface,
        title: Row(
          children: [
            const Icon(Icons.workspace_premium, color: Color(0xFFFFD700)),
            const SizedBox(width: 8),
            Text(
              l10n.editPremiumFeature,
              style: TextStyle(color: context.gc.textPrimary),
            ),
          ],
        ),
        content: Text(
          l10n.editSyncPremiumPitch,
          style: TextStyle(color: context.gc.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.editNotNow,
              style: TextStyle(color: context.gc.textSecondary),
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
              l10n.profileUpgrade,
              style: TextStyle(color: context.gc.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
