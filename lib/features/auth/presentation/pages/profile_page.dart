import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../settings/presentation/pages/faq_page.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import '../../../../core/theme/grimoire_colors.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/payment_service.dart';
import '../../../subscription/subscription.dart';
import '../../../journeys/journeys.dart';
import '../../data/models/user_model.dart';
import '../providers/auth_provider.dart';
import '../../../../core/legal/legal_document_page.dart';
import '../widgets/profile_avatar_picker.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).profileTitle),
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
                _buildProfileHeader(context, user),
                const SizedBox(height: 24),

                // Card de plano atual (para free OU admin simulando free)
                if (user.plan == SubscriptionPlan.free) ...[
                  _buildPlanCard(context, user, authProvider),
                  const SizedBox(height: 20),
                ],

                // Estatísticas de uso (para free OU admin simulando free)
                if (user.plan == SubscriptionPlan.free) ...[
                  _buildUsageStats(context, user),
                  const SizedBox(height: 20),
                ],

                // Opções de conta
                _buildAccountOptions(context, authProvider),

                // Admin options (apenas para admin)
                if (user.isAdmin) ...[
                  const SizedBox(height: 20),
                  _buildAdminOptions(context, authProvider),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    return Column(
      children: [
        // Avatar com foto de perfil
        ProfileAvatarPicker(
          currentPhotoUrl: user.photoUrl,
          size: 100,
          gradientColors: _getRoleColors(user.role),
          onPhotoChanged: (photoPath) {
            // Atualizar foto do perfil
            context.read<AuthProvider>().updateProfile(
                  displayName: user.displayName,
                );
          },
        ),
        const SizedBox(height: 16),
        // Nome com botão de editar
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user.displayName ?? AppLocalizations.of(context).profileAnonymous,
              style: TextStyle(
                color: context.gc.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF9C27B0), size: 20),
              onPressed: () => _showEditNameDialog(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
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

  void _showEditNameDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final controller = TextEditingController(
      text: authProvider.currentUser.displayName ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
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
                  BorderSide(color: const Color(0xFF9C27B0).withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF9C27B0)),
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
              backgroundColor: const Color(0xFF9C27B0),
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFree
              ? [const Color(0xFF2D2D44), const Color(0xFF1A1A2E)]
              : [const Color(0xFF9C27B0), const Color(0xFFE91E63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFree
              ? const Color(0xFF9C27B0).withValues(alpha: 0.3)
              : context.gc.textPrimary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
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
          if (isFree) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showUpgradeSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
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

  Widget _buildUsageStats(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
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
      progressColor = const Color(0xFF4CAF50);
    } else if (percentage < 0.8) {
      progressColor = const Color(0xFFFFC107);
    } else {
      progressColor = const Color(0xFFF44336);
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
    final paymentService = PaymentService();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.gc.textPrimary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          _buildOptionTile(
            context,
            icon: Icons.person_outline,
            title: AppLocalizations.of(context).profileEditProfile,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilePage()),
            ),
          ),
          _buildDivider(context),
          // Opção de gerenciar assinatura
          _buildOptionTile(
            context,
            icon: Icons.card_membership,
            title: AppLocalizations.of(context).profileManageSubscription,
            onTap: () => _handleManageSubscription(context, paymentService),
          ),
          _buildDivider(context),
          // Evolução Mágica: Jornadas + Estatísticas numa página só,
          // uma aba para cada.
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
            icon: Icons.notifications_outlined,
            title: AppLocalizations.of(context).profileNotifications,
            onTap: () => _showNotificationsDialog(context),
          ),
          _buildDivider(context),
          _buildOptionTile(
            context,
            icon: Icons.help_outline,
            title: AppLocalizations.of(context).profileHelpSupport,
            onTap: () => _showHelpDialog(context),
          ),
          _buildDivider(context),
          _buildOptionTile(
            context,
            icon: Icons.info_outline,
            title: AppLocalizations.of(context).profileAboutApp,
            onTap: () => _showAboutDialog(context),
          ),
          _buildDivider(context),
          _buildOptionTile(
            context,
            icon: Icons.logout,
            title: AppLocalizations.of(context).profileLogout,
            textColor: const Color(0xFFF44336),
            onTap: () => _showLogoutConfirmation(context, authProvider),
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
        backgroundColor: const Color(0xFF1A1A2E),
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
              backgroundColor: const Color(0xFFF44336),
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

  Widget _buildAdminOptions(BuildContext context, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D1B3D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF9C27B0).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.admin_panel_settings, color: Color(0xFF9C27B0)),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).profileAdminOptions,
                style: TextStyle(
                  color: Color(0xFF9C27B0),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Simular Plano:',
            style: TextStyle(color: context.gc.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildRoleButton(
                context,
                'Free',
                UserRole.free,
                authProvider,
              ),
              const SizedBox(width: 8),
              _buildRoleButton(
                context,
                'Premium',
                UserRole.premium,
                authProvider,
              ),
              const SizedBox(width: 8),
              _buildRoleButton(
                context,
                'Admin',
                UserRole.admin,
                authProvider,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context,
    String label,
    UserRole role,
    AuthProvider authProvider,
  ) {
    final isSelected = authProvider.currentUser.role == role;

    return Expanded(
      child: ElevatedButton(
        onPressed: () => authProvider.setUserRole(role),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? const Color(0xFF9C27B0)
              : context.gc.textPrimary.withValues(alpha: 0.1),
          foregroundColor: context.gc.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
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

  List<Color> _getRoleColors(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return [const Color(0xFFFFD700), const Color(0xFFFF8C00)];
      case UserRole.premium:
        return [const Color(0xFF9C27B0), const Color(0xFFE91E63)];
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

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Row(
          children: [
            Icon(Icons.notifications_outlined, color: Color(0xFF9C27B0)),
            SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).profileNotifications,
              style: TextStyle(color: context.gc.textPrimary),
            ),
          ],
        ),
        content: Text(
          AppLocalizations.of(context).profileNotificationsSoon,
          style: TextStyle(color: context.gc.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF9C27B0)),
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
        backgroundColor: const Color(0xFF1A1A2E),
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Color(0xFF9C27B0)),
            SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).profileHelpSupport,
              style: TextStyle(color: context.gc.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              context,
              icon: Icons.email_outlined,
              title: AppLocalizations.of(context).profileSupportEmail,
              subtitle: 'suporte.grimoriodebolso@gmail.com',
              onTap: () => _launchEmail(context),
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              context,
              icon: Icons.question_answer_outlined,
              title: 'FAQ',
              subtitle: AppLocalizations.of(context).profileFaq,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FaqPage()),
              ),
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              context,
              icon: Icons.policy_outlined,
              title: AppLocalizations.of(context).authPrivacyPolicy,
              subtitle: AppLocalizations.of(context).profilePrivacySafe,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => LegalDocumentPage.privacy),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context).commonClose,
              style: TextStyle(color: Color(0xFF9C27B0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(
    BuildContext context, {
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
            Icon(icon, color: const Color(0xFF9C27B0), size: 24),
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

  /// Abre o app de e-mail; sem app compatível, copia o endereço e avisa.
  Future<void> _launchEmail(BuildContext context) async {
    const supportEmail = 'suporte.grimoriodebolso@gmail.com';
    final uri = Uri(scheme: 'mailto', path: supportEmail);
    var opened = false;
    try {
      opened = await launchUrl(uri);
    } catch (_) {
      opened = false;
    }
    if (!opened && context.mounted) {
      await Clipboard.setData(const ClipboardData(text: supportEmail));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).supportEmailCopied(supportEmail),
          ),
        ),
      );
    }
  }

  void _handleManageSubscription(
      BuildContext context, PaymentService paymentService) {
    // Sempre navegar para página de assinatura (contém Código Premium e outras opções)
    openSubscriptionPage(context);
  }

  void _showAboutDialog(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
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
              AppLocalizations.of(context).aboutVersion(packageInfo.version, packageInfo.buildNumber),
              style: TextStyle(color: context.gc.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).aboutDescription,
              style: TextStyle(color: context.gc.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).aboutMadeWith,
              style: TextStyle(color: Color(0xFF9C27B0)),
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
              AppLocalizations.of(context).commonClose,
              style: TextStyle(color: Color(0xFF9C27B0)),
            ),
          ),
        ],
      ),
    );
  }
}
