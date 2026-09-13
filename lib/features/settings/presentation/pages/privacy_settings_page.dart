import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/legal/legal_document_page.dart';
import '../../../../core/services/data_export_service.dart';
import '../../../../core/services/data_sync_service.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/database/database_helper.dart';
import '../../../diary/data/repositories/free_writing_repository.dart';
import '../../../menstrual_cycle/data/menstrual_consent_store.dart';
import '../../../menstrual_cycle/data/menstrual_report_marks.dart';
import '../../../menstrual_cycle/data/repositories/menstrual_cycle_repository.dart';
import '../../../menstrual_cycle/domain/menstrual_access.dart';
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

  /// Quantos dias do ciclo existem nesta conta. É contagem de operação:
  /// serve para dizer o alcance de apagar, não para analisar nada.
  int _menstrualDays = 0;

  /// O bloco do Ciclo só aparece para quem a funcionalidade é oferecida e já
  /// disse sim ao registro. Antes disso não há nada sobre o que decidir.
  bool _menstrualOffered = false;
  bool _menstrualConsented = false;

  /// O SEGUNDO sim: guardar o registro do ciclo também na conta.
  ///
  /// Ele morava dentro da própria página do Ciclo, num card com texto longo.
  /// Mudou para cá por pedido da dona: é decisão sobre DADO, e todas as
  /// outras — exportar, limpar o aparelho, apagar o ciclo, apagar a conta —
  /// já se tomam nesta tela. O que não mudou foi a regra: nasce desligado,
  /// ligar pergunta de novo, desligar é um toque só, e apagar a cópia da
  /// nuvem continua sendo um gesto à parte de desligar o envio.
  bool _menstrualCloudOn = false;

  /// Existe conta de verdade? Sem ela não há para onde enviar: o sim ficaria
  /// guardado sob o `local_user`, não faria nada e não acompanharia ela ao
  /// entrar na conta. Um sim que não tem efeito é um sim que engana.
  bool _menstrualHasAccount = false;

  /// A sincronização geral do app. O envio do ciclo precisa dela ligada para
  /// acontecer: sem isso, o sim daqui fica esperando sem sintoma nenhum.
  bool _appSyncOn = true;

  bool _menstrualCloudBusy = false;

  Future<void> _loadMenstrual() async {
    try {
      final auth = context.read<AuthProvider>();
      final userId = auth.currentUser.id;
      final temConta = auth.currentUser.isAuthenticated;
      final oferecido = MenstrualAccess(
        gender: auth.currentUser.gender,
        consented: true,
        premium: false,
      ).isOffered;
      final days = await MenstrualCycleRepository().count(userId);
      final consentiu = await const MenstrualConsentStore().recordingAllowed(userId);
      final cloudOn = consentiu &&
          temConta &&
          await const MenstrualConsentStore().syncAllowed(userId);
      final appSyncOn = await DataSyncService().cloudSyncEnabled;
      if (!mounted) return;
      setState(() {
        _menstrualDays = days;
        _menstrualOffered = oferecido;
        _menstrualConsented = consentiu;
        _menstrualCloudOn = cloudOn;
        _menstrualHasAccount = temConta;
        _appSyncOn = appSyncOn;
      });
    } catch (_) {
      // Sem registro, o bloco simplesmente não aparece.
    }
  }

  /// Liga o envio em dois tempos: o interruptor abre uma confirmação que
  /// repete o que sobe e o que nunca sobe. É aqui que dado de saúde passa a
  /// sair do aparelho, e um toque distraído não pode bastar para isso.
  /// Desligar é um toque só — a saída nunca é a parte que se dificulta.
  Future<void> _onMenstrualCloudChanged(bool ligar) async {
    if (!ligar) {
      await _setMenstrualCloud(false);
      return;
    }
    final l10n = AppLocalizations.of(context);
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const ValueKey('menstrual-cloud-confirm'),
        backgroundColor: dialogContext.gc.surface,
        title: Text(l10n.menstrualCloudConfirmTitle,
            style: TextStyle(color: dialogContext.gc.textPrimary)),
        content: Text(l10n.menstrualCloudConfirmBody,
            style: TextStyle(color: dialogContext.gc.textSecondary)),
        actions: [
          TextButton(
            key: const ValueKey('menstrual-cloud-confirm-cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.menstrualCloudCancel),
          ),
          ElevatedButton(
            key: const ValueKey('menstrual-cloud-confirm-accept'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.menstrualCloudConfirmAction),
          ),
        ],
      ),
    );
    if (confirmado == true && mounted) await _setMenstrualCloud(true);
  }

  Future<void> _setMenstrualCloud(bool on) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final userId = context.read<AuthProvider>().currentUser.id;
    await const MenstrualConsentStore().setSyncAllowed(userId, on);
    // Nos dois sentidos, e antes de qualquer outra coisa: a lápide de um dia
    // menstrual É a data em que ela sangrou e depois apagou. Desligando, ela
    // ficaria guardada esperando um religar; ligando, sairia daqui na
    // primeira varredura — e ela não pediu nem uma coisa nem outra ao mexer
    // neste interruptor.
    await MenstrualCycleRepository().descartarLapidesPendentes(userId);
    // Ligar vale para o registro INTEIRO, não só para o que vier depois: é
    // sobre ele que ela acabou de dizer sim.
    if (on) await MenstrualCycleRepository().markForUpload(userId);
    if (!mounted) return;
    setState(() => _menstrualCloudOn = on);
    messenger.showSnackBar(SnackBar(
      content: Text(
          on ? l10n.menstrualCloudEnabled : l10n.menstrualCloudDisabled),
      duration: const Duration(seconds: 2),
    ));
  }

  /// Apagar a cópia da nuvem. Gesto à parte de desligar o envio, e de
  /// propósito: desligar para de mandar, isto tira o que já foi. Juntar os
  /// dois faria um deles acontecer sem ela ter pedido.
  Future<void> _eraseMenstrualCloud() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const ValueKey('menstrual-cloud-erase-confirm'),
        backgroundColor: dialogContext.gc.surface,
        title: Text(l10n.menstrualCloudEraseTitle,
            style: TextStyle(color: dialogContext.gc.textPrimary)),
        // Apagar a cópia NÃO desliga o envio, e a leitura natural de "apagar
        // da nuvem" é que aquilo acabou: sem esta frase, o próximo dia
        // registrado sobe e o registro volta a existir no servidor sem que
        // ela tenha entendido que ainda estava enviando.
        content: Text(
            _menstrualCloudOn
                ? '${l10n.menstrualCloudEraseBody}\n\n'
                    '${l10n.menstrualCloudEraseStillOn}'
                : l10n.menstrualCloudEraseBody,
            style: TextStyle(color: dialogContext.gc.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.menstrualCloudCancel),
          ),
          ElevatedButton(
            key: const ValueKey('menstrual-cloud-erase-accept'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.menstrualCloudEraseAction),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;
    setState(() => _menstrualCloudBusy = true);
    final userId = context.read<AuthProvider>().currentUser.id;
    final apagou = await DataSyncService().apagarCicloNaNuvem(userId);
    if (!mounted) return;
    setState(() => _menstrualCloudBusy = false);
    // Dizer "apagado" sem ter apagado é a pior resposta possível aqui.
    messenger.showSnackBar(SnackBar(
      content: Text(apagou
          ? l10n.menstrualCloudErased
          : l10n.menstrualCloudEraseFailed),
      duration: const Duration(seconds: 2),
    ));
  }

  /// Apaga só o registro do ciclo, e esquece as respostas de consentimento.
  ///
  /// Se alguma leitura levou esses registros junto, a confirmação diz quantas
  /// são e o relatório derivado vai junto — apagar o original não basta se as
  /// observações dela continuam dentro de um texto no acervo. Os créditos de
  /// leitura ficam: ela pode gerar de novo, sem a fonte íntima.
  Future<void> _eraseMenstrualRecord() async {
    final l10n = AppLocalizations.of(context);
    final userId = context.read<AuthProvider>().currentUser.id;
    final messenger = ScaffoldMessenger.of(context);
    final success = context.gc.success;
    final marks = await const MenstrualReportMarks().all(userId);
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.gc.surface,
        title: Text(l10n.menstrualPrivacyErase,
            style: TextStyle(color: dialogContext.gc.textPrimary)),
        content: Text(
            marks.isEmpty
                ? l10n.menstrualPrivacyEraseConfirm(_menstrualDays)
                : '${l10n.menstrualPrivacyEraseConfirm(_menstrualDays)}\n\n'
                    '${l10n.menstrualPrivacyEraseReadings(marks.length)}',
            style: TextStyle(color: dialogContext.gc.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: dialogContext.gc.alert),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    // O que ela pediu sai DESTE aparelho de qualquer jeito; o pedido à conta
    // pode não ter ido, e a frase precisa dizer qual dos dois aconteceu.
    // Prometer "apagado" enquanto a cópia ainda está lá é a única mentira que
    // esta tela não pode contar.
    final resultado = await MenstrualCycleRepository().purge(userId);
    await const MenstrualConsentStore().forget(userId);
    // As cópias derivadas vão junto: o relatório é onde as observações dela
    // continuariam existindo depois de o registro sumir. O crédito da
    // leitura permanece, e a entrada pode ser gerada de novo sem a fonte.
    for (final mark in marks) {
      await FreeWritingRepository().delete(mark.writingId);
    }
    await const MenstrualReportMarks().forget(userId);
    if (!mounted) return;
    // O `forget` acima apaga também o sim do registro: sem ele o bloco do
    // Ciclo desta tela não tem mais sobre o que decidir, e some junto.
    setState(() {
      _menstrualDays = 0;
      _menstrualConsented = false;
      _menstrualCloudOn = false;
    });
    messenger.showSnackBar(SnackBar(
      content: Text(resultado.nuvemLimpa
          ? l10n.menstrualPrivacyErased
          : l10n.menstrualPrivacyErasedHere),
      backgroundColor: success,
    ));
  }

  Future<void> _loadSettings() async {
    unawaited(_loadMenstrual());
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
                    // O registro do ciclo tem porta própria: quem quiser
                    // apagar só ele não precisa limpar o aparelho inteiro,
                    // e quem retirou o consentimento continua podendo
                    // apagar o que já escreveu.
                    if (_menstrualDays > 0) ...[
                      _buildDivider(),
                      _buildActionTile(
                        icon: Icons.nights_stay_outlined,
                        title: l10n.menstrualPrivacyErase,
                        subtitle: l10n.menstrualPrivacyEraseCount(_menstrualDays),
                        onTap: _eraseMenstrualRecord,
                        isDestructive: true,
                      ),
                    ],
                    _buildDivider(),
                    _buildActionTile(
                      icon: Icons.delete_forever_outlined,
                      title: l10n.editDeleteAccount,
                      subtitle: l10n.editDeleteAccountSubtitle,
                      onTap: _deleteAccount,
                      isDestructive: true,
                    ),
                  ]),

                  // Seção: Ciclo Menstrual
                  //
                  // Só existe para quem a área é oferecida e já disse sim ao
                  // registro: antes disso não há decisão nenhuma a tomar, e
                  // um bloco sobre o corpo numa tela que ela nunca pediu
                  // seria ruído.
                  if (_menstrualOffered && _menstrualConsented) ...[
                    const SizedBox(height: 24),
                    _buildSectionHeader(l10n.menstrualCardTitle),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        l10n.menstrualCloudBody,
                        key: const ValueKey('menstrual-cloud-body'),
                        style: TextStyle(
                          color: context.gc.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                    _buildSettingsCard([
                      _buildSwitchTile(
                        tileKey: const ValueKey('menstrual-cloud'),
                        icon: Icons.cloud_outlined,
                        title: l10n.menstrualCloudTitle,
                        subtitle: _menstrualCloudSubtitle(l10n),
                        value: _menstrualCloudOn,
                        // Sem conta não há para onde enviar, e um sim que não
                        // tem efeito é um sim que engana: o interruptor fica
                        // desligado e a linha abaixo dele explica por quê.
                        onChanged: _menstrualHasAccount && !_menstrualCloudBusy
                            ? _onMenstrualCloudChanged
                            : null,
                      ),
                      if (_menstrualHasAccount) ...[
                        _buildDivider(),
                        _buildActionTile(
                          tileKey: const ValueKey('menstrual-cloud-erase'),
                          icon: Icons.cloud_off_outlined,
                          title: l10n.menstrualCloudErase,
                          subtitle: l10n.menstrualCloudEraseBody,
                          onTap: _menstrualCloudBusy
                              ? () {}
                              : _eraseMenstrualCloud,
                          isDestructive: true,
                        ),
                      ],
                    ]),
                  ],

                  const SizedBox(height: 24),

                  // Informações sobre privacidade
                  _buildInfoCard(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  /// O estado do envio em uma linha: sem conta, ligado ou desligado — e, se
  /// o sim estiver de pé mas a sincronização do app desligada, o aviso de que
  /// nada sai daqui assim mesmo.
  String _menstrualCloudSubtitle(AppLocalizations l10n) {
    if (!_menstrualHasAccount) return l10n.menstrualCloudStateNoAccount;
    if (!_menstrualCloudOn) return l10n.menstrualCloudStateOff;
    return _appSyncOn
        ? l10n.menstrualCloudStateOn
        : '${l10n.menstrualCloudStateOn}\n${l10n.menstrualCloudNeedsSync}';
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

  /// [onChanged] nulo desliga o interruptor: é o que o bloco do Ciclo usa
  /// quando não há conta para onde enviar.
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    Key? tileKey,
  }) {
    return ListTile(
      key: tileKey,
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
    Key? tileKey,
  }) {
    final color = isDestructive ? Colors.red : context.gc.textPrimary;
    final iconBgColor = isDestructive
        ? Colors.red.withValues(alpha: 0.2)
        : context.gc.lilac.withValues(alpha: 0.2);
    final iconColor = isDestructive ? Colors.red : context.gc.lilac;

    return ListTile(
      key: tileKey,
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
    // A conta ativa decide o que entra no arquivo: o banco deste aparelho
    // pode guardar linhas de uma conta anterior, e elas não são dela.
    final userId = context.read<AuthProvider>().currentUser.id;
    try {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.editExporting),
          backgroundColor: gc.lilac,
        ),
      );

      await DataExportService.instance.exportAndDeliver(
        userId: userId,
        subject: l10n.privacyBackupSubject,
      );

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
        // A lista de tabelas não mora mais aqui, e é essa a correção: esta
        // tela e o Editar Perfil mantinham cada uma a sua, com o mesmo rótulo
        // e o mesmo texto de confirmação, e as duas divergiram — aqui o
        // registro menstrual sumia e as páginas-espelho dele no Grimório
        // ficavam legíveis depois de a pessoa mandar limpar tudo.
        //
        // A cópia na nuvem fica, como o texto da confirmação promete. Quem
        // quer o registro do ciclo apagado da CONTA tem o gesto logo acima
        // ("apagar meus registros do ciclo"), que fala com o servidor e sabe
        // dizer se conseguiu — este aqui não saberia.
        await DatabaseHelper.instance.limparConteudoDesteAparelho();

        if (mounted) {
          // O contador do bloco do ciclo acompanha: a limpeza levou o registro
          // deste aparelho, e deixar o número de ontem na tela seria dizer que
          // ele continua aqui.
          setState(() => _menstrualDays = 0);
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
