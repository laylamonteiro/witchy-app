import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
=======
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
>>>>>>> origin/codex/add-localization-configuration-and-files
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/diagnostic/diagnostic_page.dart';
import '../../../../core/services/payment_service.dart';
import '../../../lunar/presentation/providers/lunar_provider.dart';
import '../../../wheel_of_year/presentation/providers/wheel_of_year_provider.dart';
import '../../../auth/auth.dart';
import '../../../analytics/analytics.dart';
import '../../../journeys/journeys.dart';
import '../../../auth/presentation/widgets/profile_avatar_picker.dart';
import '../../../auth/presentation/pages/change_password_page.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../../subscription/presentation/pages/subscription_page.dart';
import 'privacy_settings_page.dart';
import 'beta_codes_management_page.dart';
import 'theme_picker_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.gc.background,
      appBar: AppBar(
<<<<<<< HEAD
        title:
            ResponsiveAppBarTitle(AppLocalizations.of(context)!.settingsTitle),
=======
        title: ResponsiveAppBarTitle(AppLocalizations.of(context)!.settingsTitle),
>>>>>>> origin/codex/add-localization-configuration-and-files
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

                _buildLanguageCard(context),
                const SizedBox(height: 20),

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

<<<<<<< HEAD
  Widget _buildLanguageOptionTile(BuildContext context) {
=======

  Widget _buildLanguageCard(BuildContext context) {
>>>>>>> origin/codex/add-localization-configuration-and-files
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = context.watch<LanguageProvider>();

    String labelFor(Locale locale) {
      switch (locale.languageCode) {
        case 'en':
<<<<<<< HEAD
          return '🇺🇸 EN';
        case 'es':
          return '🇪🇸 ES';
        case 'pt':
        default:
          return '🇧🇷 PT-BR';
      }
    }

    return ListTile(
      leading: const Icon(Icons.language, color: Colors.white70),
      title: Text(
        l10n.settingsLanguageTitle,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: DropdownButton<Locale>(
        value: languageProvider.locale,
        dropdownColor: const Color(0xFF1A1A2E),
        underline: const SizedBox.shrink(),
        style: const TextStyle(color: Colors.white),
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

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.settingsLanguageChanged(labelFor(locale)),
              ),
            ),
          );
        },
=======
          return l10n.settingsLanguageEnglish;
        case 'es':
          return l10n.settingsLanguageSpanish;
        case 'pt':
        default:
          return l10n.settingsLanguagePortuguese;
      }
    }

    return MagicalCard(
      child: ListTile(
        leading: const Icon(Icons.language, color: Color(0xFF9C27B0)),
        title: Text(
          l10n.settingsLanguageTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          l10n.settingsLanguageSubtitle,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: DropdownButton<Locale>(
          value: languageProvider.locale,
          dropdownColor: const Color(0xFF1A1A2E),
          underline: const SizedBox.shrink(),
          style: const TextStyle(color: Colors.white),
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
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.settingsLanguageChanged(labelFor(locale)))),
              );
            }
          },
        ),
>>>>>>> origin/codex/add-localization-configuration-and-files
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
              colors: _getRoleColors(user.role),
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
                user.displayName ?? 'Bruxa Anônima',
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
              colors: _getRoleColors(user.role),
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
          'Editar Nome',
          style: TextStyle(color: context.gc.textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: context.gc.textPrimary),
          decoration: InputDecoration(
            hintText: 'Seu nome mágico',
            hintStyle: TextStyle(color: context.gc.textPrimary.withOpacity(0.5)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: context.gc.lilac.withOpacity(0.5)),
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
              'Cancelar',
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
            child: const Text('Salvar'),
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
                      isFree ? 'Plano Gratuito' : 'Plano Premium',
                      style: TextStyle(
                        color: context.gc.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isFree
                          ? 'Algumas funcionalidades são limitadas'
                          : 'Acesso completo a todas as funcionalidades',
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
                'Assinatura Vitalícia',
                style: TextStyle(
                  color: context.gc.textPrimary.withValues(alpha: 0.9),
                  fontSize: 13,
                ),
              )
            else if (paymentService.subscriptionExpirationDate != null)
              Text(
                'Renova em: ${_formatDate(paymentService.subscriptionExpirationDate!)}',
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
                label: const Text(
                  'Gerenciar Assinatura',
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Fazer Upgrade',
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
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
            'Uso do Plano Gratuito',
            style: TextStyle(
              color: context.gc.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildUsageRow(
            'Feitiços',
            user.spellsCount,
            UserModel.freeSpellsLimit,
            Icons.auto_fix_high,
          ),
          const SizedBox(height: 12),
          _buildUsageRow(
            'Entradas de Diário',
            user.diaryEntriesThisMonth,
            UserModel.freeDiaryEntriesLimit,
            Icons.book,
            subtitle: 'este mês',
          ),
          const SizedBox(height: 12),
          _buildUsageRow(
            'Consultas IA',
            user.aiConsultationsToday,
            UserModel.freeAiConsultationsLimit,
            Icons.psychology,
            subtitle: 'hoje',
          ),
        ],
      ),
    );
  }

  Widget _buildUsageRow(
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
          _buildLanguageOptionTile(context),
          _buildDivider(),
          _buildOptionTile(
            icon: Icons.person_outline,
            title: 'Editar Perfil',
            onTap: () => _showEditProfileDialog(context, authProvider),
          ),
          // Só mostra "Alterar Senha" para usuários que usam email/senha
          // Usuários OAuth (Google) não podem alterar senha no app
          if (authProvider.currentUser.usesEmailPassword) ...[
            _buildDivider(),
            _buildOptionTile(
              icon: Icons.lock_outline,
              title: 'Alterar Senha',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
              ),
            ),
          ],
          _buildDivider(),
          _buildOptionTile(
            icon: Icons.analytics_outlined,
            title: 'Estatísticas Mágicas',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MagicalAnalyticsPage()),
            ),
          ),
          _buildDivider(),
          _buildOptionTile(
            icon: Icons.explore_outlined,
            title: 'Jornadas Mágicas',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JourneysPage()),
            ),
          ),
          _buildDivider(),
          _buildOptionTile(
            icon: Icons.palette_outlined,
            title: 'Aparência',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ThemePickerPage()),
            ),
          ),
          _buildDivider(),
          _buildOptionTile(
            icon: Icons.notifications_outlined,
            title: 'Notificações',
            onTap: () => _showNotificationsBottomSheet(context),
          ),
          _buildDivider(),
          _buildOptionTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacidade',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacySettingsPage()),
            ),
          ),
          _buildDivider(),
          _buildOptionTile(
            icon: Icons.help_outline,
            title: 'Ajuda & Suporte',
            onTap: () => _showHelpDialog(context),
          ),
          _buildDivider(),
          _buildOptionTile(
            icon: Icons.info_outline,
            title: 'Sobre o App',
            onTap: () => _showAboutDialog(context),
          ),
          _buildDivider(),
          _buildOptionTile(
            icon: Icons.logout,
            title: 'Sair da Conta',
            textColor: context.gc.alert,
            onTap: () => _showLogoutConfirmation(context, authProvider),
          ),
        ],
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
                    'Notificações',
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
                'Configure lembretes para eventos mágicos importantes',
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
                        title: 'Lua Cheia',
                        subtitle: 'Lembrete 1 dia antes da Lua Cheia',
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
                        title: 'Lua Nova',
                        subtitle: 'Lembrete 1 dia antes da Lua Nova',
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
                        title: 'Sabbats',
                        subtitle: 'Lembrete 3 dias antes de cada Sabbat',
                        value: notificationProvider.sabbatNotifications,
                        onChanged: (value) async {
                          await notificationProvider
                              .setSabbatNotifications(value);
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
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFF2196F3).withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF2196F3),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'As notificações serão enviadas apenas em dispositivos móveis',
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
            result.error ?? 'Não foi possível atualizar as notificações',
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
              'Diagnóstico & Debug',
              style: TextStyle(color: context.gc.textPrimary),
            ),
            subtitle: Text(
              'Testes, alternância de roles e mais',
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
              'Gerenciar Códigos Premium',
              style: TextStyle(color: context.gc.textPrimary),
            ),
            subtitle: Text(
              'Criar e invalidar códigos promocionais',
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

  Widget _buildOptionTile({
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

  Widget _buildDivider() {
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

  void _showRevenueCatNotConfiguredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.gc.surface,
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: context.gc.gold),
            SizedBox(width: 8),
            Text(
              'Pagamentos Não Configurados',
              style: TextStyle(color: context.gc.textPrimary, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'O sistema de pagamentos ainda não foi configurado nesta versão do app.\n\n'
          'Se você é desenvolvedor, verifique os logs do console para mais detalhes.',
          style: TextStyle(color: context.gc.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Entendi',
              style: TextStyle(color: context.gc.lilac),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final nameController =
        TextEditingController(text: authProvider.currentUser.displayName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.gc.surface,
        title: Text(
          'Editar Perfil',
          style: TextStyle(color: context.gc.textPrimary),
        ),
        content: TextField(
          controller: nameController,
          style: TextStyle(color: context.gc.textPrimary),
          decoration: InputDecoration(
            labelText: 'Nome',
            labelStyle: TextStyle(color: context.gc.textSecondary),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Cancelar', style: TextStyle(color: context.gc.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              authProvider.updateProfile(displayName: nameController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.gc.lilac,
            ),
            child: Text(
              'Salvar',
              style: TextStyle(color: context.gc.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(
      BuildContext pageContext, AuthProvider authProvider) {
    showDialog(
      context: pageContext,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.gc.surface,
        title: Text(
          'Sair da Conta',
          style: TextStyle(color: context.gc.textPrimary),
        ),
        content: Text(
          'Tem certeza que deseja sair?\nSeus dados locais serão mantidos.',
          style: TextStyle(color: context.gc.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancelar',
              style: TextStyle(color: context.gc.textSecondary),
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
              backgroundColor: context.gc.alert,
            ),
            child: Text(
              'Sair',
              style: TextStyle(color: context.gc.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.gc.surface,
        title: Row(
          children: [
            Icon(Icons.help_outline, color: context.gc.lilac),
            SizedBox(width: 8),
            Text(
              'Ajuda & Suporte',
              style: TextStyle(color: context.gc.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              icon: Icons.email_outlined,
              title: 'Email de Suporte',
              subtitle: 'suporte@grimoriodebolso.com',
              onTap: () => _launchEmail(),
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              icon: Icons.question_answer_outlined,
              title: 'FAQ',
              subtitle: 'Perguntas frequentes',
              onTap: () => _launchFaq(),
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              icon: Icons.policy_outlined,
              title: 'Política de Privacidade',
              subtitle: 'Seus dados estão seguros',
              onTap: () => _launchPrivacyPolicy(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fechar',
              style: TextStyle(color: context.gc.lilac),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(icon, color: context.gc.lilac, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: context.gc.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: context.gc.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.gc.textSecondary),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail() async {
    final uri = Uri.parse('mailto:suporte@grimoriodebolso.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchFaq() async {
    final uri = Uri.parse('https://grimoriodebolso.com/faq');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    final uri = Uri.parse('https://grimoriodebolso.com/privacidade');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showAboutDialog(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.gc.surface,
        title: Row(
          children: [
            Text('✨', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text(
              'Grimório de Bolso',
              style: TextStyle(color: context.gc.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versão ${packageInfo.version} (${packageInfo.buildNumber})',
              style: TextStyle(color: context.gc.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              'Seu companheiro para práticas mágicas, rituais e autoconhecimento através da astrologia e bruxaria moderna.',
              style: TextStyle(color: context.gc.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Desenvolvido com 🔮 e ✨',
              style: TextStyle(color: context.gc.lilac),
            ),
            const SizedBox(height: 8),
            Text(
              '© 2024 Grimório de Bolso',
              style: TextStyle(color: context.gc.textSecondary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fechar',
              style: TextStyle(color: context.gc.lilac),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getRoleColors(UserRole role) {
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
        activeColor: context.gc.success,
      ),
    );
  }
}
