import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/i18n/gender.dart';
import '../../../../core/providers/mascot_provider.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/diagnostic/diagnostic_page.dart';
import '../../../../core/services/payment_service.dart';
import '../../../lunar/presentation/providers/lunar_provider.dart';
import '../../../wheel_of_year/presentation/providers/wheel_of_year_provider.dart';
import '../../../auth/auth.dart';
import '../../../journeys/journeys.dart';
import '../../../auth/presentation/pages/change_password_page.dart';
import '../../../subscription/presentation/pages/subscription_page.dart';
import 'about_help_page.dart';
import 'privacy_settings_page.dart';
import 'beta_codes_management_page.dart';
import 'sync_settings_page.dart';
import 'theme_picker_page.dart';

class SettingsPage extends StatelessWidget {
  /// Seletor de idioma (pt-BR / EN / ES). Reativado após a conclusão da
  /// internacionalização: scanner de PT hardcoded limpo e paridade das
  /// 1195 chaves ARB + conteúdo por locale garantida por testes no CI.
  static const bool _showLanguageOption = true;

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.gc.background,
      appBar: AppBar(
        title:
            ResponsiveAppBarTitle(AppLocalizations.of(context).settingsTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar e info básica
                _buildProfileHeader(context, user, authProvider),
                const SizedBox(height: 24),

                // Card de plano atual
                _buildPlanCard(context, user, authProvider),
                const SizedBox(height: 20),

                // Estatísticas de uso (para free OU admin simulando free)
                if (user.plan == SubscriptionPlan.free) ...[
                  _buildUsageStats(context, user),
                  const SizedBox(height: 20),
                ],

                // Opções de conta
                _buildAccountOptions(context, authProvider),

                // Admin options (apenas para admin)
                if (authProvider.isOriginalAdmin) ...[
                  const SizedBox(height: 20),
                  _buildAdminCard(context, authProvider),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageOptionTile(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageProvider = context.watch<LanguageProvider>();

    String labelFor(Locale locale) {
      switch (locale.languageCode) {
        case 'en':
          return '🇺🇸 EN';
        case 'es':
          return '🇪🇸 ES';
        case 'pt':
        default:
          return '🇧🇷 PT-BR';
      }
    }

    return ListTile(
      leading: Icon(Icons.language, color: context.gc.textSecondary),
      title: Text(
        l10n.settingsLanguageTitle,
        style: TextStyle(color: context.gc.textPrimary),
      ),
      trailing: DropdownButton<Locale>(
        value: languageProvider.locale,
        dropdownColor: context.gc.surface,
        underline: const SizedBox.shrink(),
        style: TextStyle(color: context.gc.textPrimary),
        items: LanguageProvider.supportedLocales
            .map(
              (locale) => DropdownMenuItem<Locale>(
                value: locale,
                child: Text(labelFor(locale)),
              ),
            )
            .toList(),
        onChanged: (locale) async {
          if (locale == null) return;

          await context.read<LanguageProvider>().setLocale(locale);

          if (!context.mounted) return;

          // Reagenda as notificações pendentes para re-assar os textos no
          // idioma recém-selecionado (agendamento é idempotente).
          unawaited(_scheduleNotifications(context));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.settingsLanguageChanged(labelFor(locale)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, UserModel user, AuthProvider authProvider) {
    return Column(
      children: [
        // Avatar com foto de perfil (temporariamente desabilitado)
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: _getRoleColors(context, user.role),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              _getInitials(user.displayName ?? user.email ?? 'User'),
              style: TextStyle(
                color: context.gc.textPrimary,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Nome com botão de editar
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Compensa à esquerda o espaço ocupado pelo botão à direita para
            // manter o texto exatamente no eixo central do avatar.
            const SizedBox(width: 28),
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                user.displayName ?? AppLocalizations.of(context).profileAnonymous,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.gc.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 20,
              child: IconButton(
                icon: Icon(
                  Icons.edit,
                  color: context.gc.lilac,
                  size: 20,
                ),
                onPressed: () => _showEditNameDialog(context, authProvider),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Badge de role
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _getRoleColors(context, user.role),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _getRoleLabel(user.role),
            style: TextStyle(
              color: context.gc.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _showEditNameDialog(BuildContext context, AuthProvider authProvider) {
    final controller = TextEditingController(
      text: authProvider.currentUser.displayName ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.gc.surface,
        title: Text(
          AppLocalizations.of(context).profileEditName,
          style: TextStyle(color: context.gc.textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: context.gc.textPrimary),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).authNameHint,
            hintStyle: TextStyle(color: context.gc.textPrimary.withValues(alpha: 0.5)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: context.gc.lilac.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.gc.lilac),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context).commonCancel,
              style: TextStyle(color: context.gc.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await authProvider.updateDisplayName(name);
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.gc.lilac,
            ),
            child: Text(AppLocalizations.of(context).commonSave),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
      BuildContext context, UserModel user, AuthProvider authProvider) {
    // Usar plan ao invés de role para admin poder simular
    final isFree = user.plan == SubscriptionPlan.free;
    final paymentService = PaymentService();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFree
              ? [context.gc.surfaceBorder, context.gc.surface]
              : [context.gc.lilac, context.gc.pink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFree
              ? context.gc.lilac.withValues(alpha: 0.3)
              : context.gc.textPrimary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isFree ? Icons.workspace_premium_outlined : Icons.star,
                color: context.gc.textPrimary,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFree ? AppLocalizations.of(context).profileFreePlan : AppLocalizations.of(context).profilePremiumPlan,
                      style: TextStyle(
                        color: context.gc.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isFree
                          ? AppLocalizations.of(context).profileFreePlanDesc
                          : AppLocalizations.of(context).profilePremiumPlanDesc,
                      style: TextStyle(
                        color: context.gc.textPrimary.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Informações extras para Premium
          if (!isFree) ...[
            const SizedBox(height: 12),
            if (paymentService.isLifetime)
              Text(
                AppLocalizations.of(context).settingsLifetime,
                style: TextStyle(
                  color: context.gc.textPrimary.withValues(alpha: 0.9),
                  fontSize: 13,
                ),
              )
            else if (paymentService.subscriptionExpirationDate != null)
              Text(
                AppLocalizations.of(context).settingsRenewsOn(_formatDate(context, paymentService.subscriptionExpirationDate!)),
                style: TextStyle(
                  color: context.gc.textPrimary.withValues(alpha: 0.9),
                  fontSize: 13,
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _manageSubscription(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.gc.textPrimary,
                  side: BorderSide(color: context.gc.textPrimary, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                icon: const Icon(Icons.settings, size: 18),
                label: Text(
                  AppLocalizations.of(context).profileManageSubscription,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          // Botão de upgrade para Free
          if (isFree) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const ValueKey('settings_upgrade_button'),
                onPressed: () => _showUpgradeSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.gc.lilac,
                  foregroundColor: context.gc.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, size: 18),
                    SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).profileUpgrade,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context);
    final months = [
      l10n.monthJanShort,
      l10n.monthFebShort,
      l10n.monthMarShort,
      l10n.monthAprShort,
      l10n.monthMayShort,
      l10n.monthJunShort,
      l10n.monthJulShort,
      l10n.monthAugShort,
      l10n.monthSepShort,
      l10n.monthOctShort,
      l10n.monthNovShort,
      l10n.monthDecShort,
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _manageSubscription(BuildContext context) async {
    await openSubscriptionPage(context);
  }

  Widget _buildUsageStats(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.gc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.gc.textPrimary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).profileFreeUsage,
            style: TextStyle(
              color: context.gc.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildUsageRow(
            context,
            AppLocalizations.of(context).profileSpells,
            user.spellsCount,
            UserModel.freeSpellsLimit,
            Icons.auto_fix_high,
          ),
          const SizedBox(height: 12),
          _buildUsageRow(
            context,
            AppLocalizations.of(context).profileDiaryEntries,
            user.diaryEntriesThisMonth,
            UserModel.freeDiaryEntriesLimit,
            Icons.book,
            subtitle: AppLocalizations.of(context).profileThisMonth,
          ),
          const SizedBox(height: 12),
          _buildUsageRow(
            context,
            AppLocalizations.of(context).profileMysticAdvisor,
            user.aiConsultationsToday,
            UserModel.freeAiConsultationsLimit,
            Icons.psychology,
            subtitle: AppLocalizations.of(context).profileToday,
          ),
        ],
      ),
    );
  }

  Widget _buildUsageRow(
    BuildContext context,
    String label,
    int used,
    int limit,
    IconData icon, {
    String? subtitle,
  }) {
    final percentage = used / limit;
    Color progressColor;
    if (percentage < 0.5) {
      progressColor = context.gc.success;
    } else if (percentage < 0.8) {
      progressColor = context.gc.gold;
    } else {
      progressColor = context.gc.alert;
    }

    return Row(
      children: [
        Icon(icon, color: context.gc.textSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: context.gc.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '$used/$limit',
                    style: TextStyle(
                      color: progressColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.gc.textSecondary,
                    fontSize: 11,
                  ),
                ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage.clamp(0, 1),
                backgroundColor: context.gc.textPrimary.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(progressColor),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountOptions(BuildContext context, AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        color: context.gc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.gc.textPrimary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          if (_showLanguageOption) ...[
            _buildLanguageOptionTile(context),
            _buildDivider(context),
          ],
          _buildOptionTile(
            context,
            icon: Icons.person_outline,
            title: AppLocalizations.of(context).profileEditProfile,
            onTap: () => _showEditProfileDialog(context, authProvider),
          ),
          // Só mostra "Alterar Senha" para usuários que usam email/senha
          // Usuários OAuth (Google) não podem alterar senha no app
          if (authProvider.currentUser.usesEmailPassword) ...[
            _buildDivider(context),
            _buildOptionTile(
              context,
              icon: Icons.lock_outline,
              title: AppLocalizations.of(context).changePasswordTitle,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
              ),
            ),
          ],
          _buildDivider(context),
          // Jornadas + Estatísticas moram juntas na Evolução Mágica:
          // uma entrada só, com uma aba para cada.
          _buildOptionTile(
            context,
            icon: Icons.auto_graph,
            title: AppLocalizations.of(context).progressPageTitle,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MagicalProgressPage()),
            ),
          ),
          _buildDivider(context),
          _buildOptionTile(
            context,
            icon: Icons.palette_outlined,
            title: AppLocalizations.of(context).settingsAppearance,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ThemePickerPage()),
            ),
          ),
          // Notificações são agendadas localmente pelo sistema operacional
          // (flutter_local_notifications), que não existe na web. Esconder a
          // opção evita prometer lembretes que nunca chegariam no navegador.
          if (!kIsWeb) ...[
            _buildDivider(context),
            _buildOptionTile(
              context,
              icon: Icons.notifications_outlined,
              title: AppLocalizations.of(context).profileNotifications,
              onTap: () => _showNotificationsBottomSheet(context),
            ),
          ],
          _buildDivider(context),
          _buildOptionTile(
            context,
            icon: Icons.pets_outlined,
            title: AppLocalizations.of(context).settingsSalem,
            onTap: () => _showSalemBottomSheet(context),
          ),
          _buildDivider(context),
          // Sincronização com entrada própria: recurso Premium com status e
          // ações, escondido dentro de Privacidade ninguém achava.
          _buildOptionTile(
            context,
            icon: Icons.cloud_sync_outlined,
            title: AppLocalizations.of(context).editSyncBackup,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SyncSettingsPage()),
            ),
          ),
          _buildDivider(context),
          _buildOptionTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: AppLocalizations.of(context).settingsPrivacy,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacySettingsPage()),
            ),
          ),
          _buildDivider(context),
          _buildOptionTile(
            context,
            icon: Icons.favorite_outline,
            title: AppLocalizations.of(context).settingsFollowUs,
            onTap: () => _showFollowSheet(context),
          ),
          _buildDivider(context),
          // "Sobre o App" + "Ajuda & Suporte" agora moram juntos.
          _buildOptionTile(
            context,
            icon: Icons.info_outline,
            title: AppLocalizations.of(context).settingsAboutHelp,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutHelpPage()),
            ),
          ),
          _buildDivider(context),
          _buildOptionTile(
            context,
            icon: Icons.logout,
            title: AppLocalizations.of(context).profileLogout,
            textColor: context.gc.alert,
            onTap: () => _showLogoutConfirmation(context, authProvider),
          ),
        ],
      ),
    );
  }

  /// Configurações do Salem: rever o tour guiado. (Esconder o Salem é um
  /// segredo do próprio gatinho: 5 toques nele — e ele sempre volta na
  /// próxima sessão ou com 5 toques na tela.)
  void _showSalemBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.gc.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Consumer<MascotProvider>(
          builder: (context, mascot, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🐈‍⬛', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context).settingsSalem,
                    style: TextStyle(
                      color: context.gc.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).settingsSalemDesc,
                style: TextStyle(
                  color: context.gc.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.replay, color: context.gc.lilac),
                title: Text(AppLocalizations.of(context).settingsReplayTour),
                onTap: () {
                  mascot.requestTour();
                  // Fecha o sheet e as Configurações para revelar a HomePage.
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.gc.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: context.gc.gold,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context).profileNotifications,
                    style: TextStyle(
                      color: context.gc.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: context.gc.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).settingsNotifDesc,
                style: TextStyle(
                  color: context.gc.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Consumer<NotificationProvider>(
                builder: (context, notificationProvider, _) {
                  return Column(
                    children: [
                      _NotificationTile(
                        icon: '🌕',
                        title: AppLocalizations.of(context).settingsFullMoon,
                        subtitle: AppLocalizations.of(context).settingsFullMoonDesc,
                        value: notificationProvider.fullMoonNotifications,
                        onChanged: (value) async {
                          await notificationProvider
                              .setFullMoonNotifications(value);
                          if (context.mounted) {
                            _scheduleNotifications(context);
                          }
                        },
                      ),
                      Divider(color: context.gc.textPrimary10),
                      _NotificationTile(
                        icon: '🌑',
                        title: AppLocalizations.of(context).settingsNewMoon,
                        subtitle: AppLocalizations.of(context).settingsNewMoonDesc,
                        value: notificationProvider.newMoonNotifications,
                        onChanged: (value) async {
                          await notificationProvider
                              .setNewMoonNotifications(value);
                          if (context.mounted) {
                            _scheduleNotifications(context);
                          }
                        },
                      ),
                      Divider(color: context.gc.textPrimary10),
                      _NotificationTile(
                        icon: '🎃',
                        title: AppLocalizations.of(context).settingsSabbats,
                        subtitle: AppLocalizations.of(context).settingsSabbatsDesc,
                        value: notificationProvider.sabbatNotifications,
                        onChanged: (value) async {
                          await notificationProvider
                              .setSabbatNotifications(value);
                          if (context.mounted) {
                            _scheduleNotifications(context);
                          }
                        },
                      ),
                      Divider(color: context.gc.textPrimary10),
                      _NotificationTile(
                        icon: '🌞',
                        title: AppLocalizations.of(context).settingsSunWater,
                        subtitle:
                            AppLocalizations.of(context).settingsSunWaterDesc,
                        value: notificationProvider.sunWaterNotifications,
                        onChanged: (value) async {
                          await notificationProvider
                              .setSunWaterNotifications(value);
                          if (context.mounted) {
                            _scheduleNotifications(context);
                          }
                        },
                      ),
                      Divider(color: context.gc.textPrimary10),
                      _NotificationTile(
                        icon: '🐈‍⬛',
                        title: AppLocalizations.of(context)
                            .settingsDailyReminder,
                        subtitle: AppLocalizations.of(context)
                            .settingsDailyReminderDesc,
                        value: notificationProvider.dailyReminder,
                        onChanged: (value) async {
                          await notificationProvider.setDailyReminder(value);
                          if (context.mounted) {
                            _scheduleNotifications(context);
                          }
                        },
                      ),
                      // Horário só aparece com o lembrete ligado.
                      if (notificationProvider.dailyReminder)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.schedule,
                              color: context.gc.lilac, size: 20),
                          title: Text(
                            AppLocalizations.of(context)
                                .settingsDailyReminderTime,
                            style: TextStyle(color: context.gc.textPrimary),
                          ),
                          trailing: Text(
                            '${notificationProvider.dailyReminderHour.toString().padLeft(2, '0')}:00',
                            style: TextStyle(
                              color: context.gc.lilac,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                hour: notificationProvider.dailyReminderHour,
                                minute: 0,
                              ),
                            );
                            if (picked == null) return;
                            await notificationProvider
                                .setDailyReminderHour(picked.hour);
                            if (context.mounted) {
                              _scheduleNotifications(context);
                            }
                          },
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF2196F3),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).settingsNotifMobileOnly,
                        style: TextStyle(
                          color: Color(0xFF2196F3),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _scheduleNotifications(BuildContext context) async {
    final notificationProvider = context.read<NotificationProvider>();
    final lunarProvider = context.read<LunarProvider>();
    final wheelProvider = context.read<WheelOfYearProvider>();

    final result = await notificationProvider.scheduleNotifications(
      lunarProvider: lunarProvider,
      wheelProvider: wheelProvider,
    );

    // Não exibimos aviso de SUCESSO ao (re)agendar notificações — o usuário
    // não precisa de feedback toda vez que elas são reagendadas. Apenas
    // falhas são sinalizadas.
    if (context.mounted && !result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.error ?? AppLocalizations.of(context).settingsNotifUpdateError,
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: context.gc.alert,
        ),
      );
    }
  }

  Widget _buildAdminCard(BuildContext context, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B3D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.gc.lilac.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Color(0xFFFFD700)),
              SizedBox(width: 8),
              Text(
                'Admin',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.bug_report,
              color: context.gc.lilac,
            ),
            title: Text(
              AppLocalizations.of(context).settingsDiagnostics,
              style: TextStyle(color: context.gc.textPrimary),
            ),
            subtitle: Text(
              AppLocalizations.of(context).settingsDiagnosticsSub,
              style: TextStyle(
                color: context.gc.textSecondary,
                fontSize: 12,
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: context.gc.textSecondary),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DiagnosticPage(),
                ),
              );
            },
          ),
          Divider(color: context.gc.textSecondary),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.card_giftcard,
              color: context.gc.lilac,
            ),
            title: Text(
              AppLocalizations.of(context).adminCodesTitle,
              style: TextStyle(color: context.gc.textPrimary),
            ),
            subtitle: Text(
              AppLocalizations.of(context).settingsManageCodesSub,
              style: TextStyle(
                color: context.gc.textSecondary,
                fontSize: 12,
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: context.gc.textSecondary),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BetaCodesManagementPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    final color = textColor ?? context.gc.textPrimary;
    return ListTile(
      leading: Icon(icon, color: textColor ?? context.gc.textSecondary),
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: textColor?.withValues(alpha: 0.5) ?? context.gc.textSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      color: context.gc.textPrimary.withValues(alpha: 0.1),
    );
  }

  void _showUpgradeSheet(BuildContext context) {
    openSubscriptionPage(context);
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  String _genderLabel(BuildContext context, Gender pref) {
    final l10n = AppLocalizations.of(context);
    switch (pref) {
      case Gender.feminine:
        return l10n.genderFeminine;
      case Gender.masculine:
        return l10n.genderMasculine;
      case Gender.neutral:
        return l10n.genderNeutral;
    }
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final nameController =
        TextEditingController(text: authProvider.currentUser.displayName);
    Gender selectedGender = authProvider.currentUser.gender;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: context.gc.surface,
          title: Text(
            AppLocalizations.of(context).profileEditProfile,
            style: TextStyle(color: context.gc.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(color: context.gc.textPrimary),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).authNameLabel,
                  labelStyle: TextStyle(color: context.gc.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: context.gc.textPrimary.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: context.gc.lilac),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Mesma largura e estilo do campo Nome.
              DropdownButtonFormField<Gender>(
                initialValue: selectedGender,
                isExpanded: true,
                dropdownColor: context.gc.surface,
                style: TextStyle(color: context.gc.textPrimary),
                iconEnabledColor: context.gc.lilac,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).editGenderSection,
                  labelStyle: TextStyle(color: context.gc.textSecondary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: context.gc.textPrimary.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: context.gc.lilac),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: Gender.values
                    .map((pref) => DropdownMenuItem<Gender>(
                          value: pref,
                          child: Text(_genderLabel(context, pref)),
                        ))
                    .toList(),
                onChanged: (pref) {
                  if (pref != null) {
                    setDialogState(() => selectedGender = pref);
                  }
                },
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).editGenderHelp,
                style: TextStyle(
                  color: context.gc.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).commonCancel,
                  style: TextStyle(color: context.gc.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                authProvider.updateProfile(displayName: nameController.text);
                authProvider.setGender(selectedGender);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.gc.lilac,
              ),
              child: Text(
                AppLocalizations.of(context).commonSave,
                style: TextStyle(color: context.gc.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(
      BuildContext pageContext, AuthProvider authProvider) {
    showDialog(
      context: pageContext,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.gc.surface,
        title: Text(
          AppLocalizations.of(dialogContext).profileLogout,
          style: TextStyle(color: dialogContext.gc.textPrimary),
        ),
        content: Text(
          AppLocalizations.of(dialogContext).profileLogoutConfirm,
          style: TextStyle(color: dialogContext.gc.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              AppLocalizations.of(dialogContext).commonCancel,
              style: TextStyle(color: dialogContext.gc.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await authProvider.signOut();
              if (pageContext.mounted) {
                Navigator.of(pageContext, rootNavigator: true)
                    .pushNamedAndRemoveUntil('/welcome', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: dialogContext.gc.alert,
            ),
            child: Text(
              AppLocalizations.of(dialogContext).profileLogoutAction,
              style: TextStyle(color: dialogContext.gc.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  /// Redes do Grimório: @grimoriodebolso no Instagram e no TikTok.
  void _showFollowSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.gc.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.favorite, color: sheetContext.gc.pink),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context).settingsFollowUs,
                    style: TextStyle(
                      color: sheetContext.gc.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.of(context).settingsFollowUsSub,
                style: TextStyle(
                  color: sheetContext.gc.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              _buildSocialTile(
                sheetContext,
                iconAsset: 'assets/icons/instagram.svg',
                network: 'Instagram',
                url: 'https://instagram.com/grimoriodebolso',
              ),
              _buildSocialTile(
                sheetContext,
                iconAsset: 'assets/icons/tiktok.svg',
                network: 'TikTok',
                url: 'https://www.tiktok.com/@grimoriodebolso',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialTile(
    BuildContext context, {
    required String iconAsset,
    required String network,
    required String url,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.gc.lilac.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        // Glifos oficiais das marcas (Simple Icons), tingidos no lilás do
        // tema — monocromáticos, como pedem os guias de marca.
        child: SvgPicture.asset(
          iconAsset,
          width: 22,
          height: 22,
          colorFilter: ColorFilter.mode(context.gc.lilac, BlendMode.srcIn),
        ),
      ),
      title: Text(
        network,
        style: TextStyle(color: context.gc.textPrimary),
      ),
      subtitle: Text(
        '@grimoriodebolso',
        style: TextStyle(color: context.gc.textSecondary, fontSize: 12),
      ),
      trailing:
          Icon(Icons.open_in_new, size: 16, color: context.gc.textSecondary),
      onTap: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
    );
  }

  List<Color> _getRoleColors(BuildContext context, UserRole role) {
    switch (role) {
      case UserRole.admin:
        return [const Color(0xFFFFD700), const Color(0xFFFF8C00)];
      case UserRole.premium:
        return [context.gc.lilac, context.gc.pink];
      case UserRole.free:
        return [const Color(0xFF3F51B5), const Color(0xFF2196F3)];
    }
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'ADMINISTRADOR';
      case UserRole.premium:
        return 'PREMIUM';
      case UserRole.free:
        return 'GRATUITO';
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(
        icon,
        style: const TextStyle(fontSize: 32),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: context.gc.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
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
        activeThumbColor: context.gc.success,
      ),
    );
  }
}
