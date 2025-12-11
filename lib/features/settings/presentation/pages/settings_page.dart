import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/diagnostic/diagnostic_page.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/services/payment_service.dart';
import '../../../lunar/presentation/providers/lunar_provider.dart';
import '../../../wheel_of_year/presentation/providers/wheel_of_year_provider.dart';
import '../../../auth/auth.dart';
import '../../../subscription/subscription.dart';
import '../../../analytics/analytics.dart';
import '../../../journeys/journeys.dart';
import '../../../auth/data/repositories/supabase_auth_repository.dart';
import '../../../auth/presentation/widgets/profile_avatar_picker.dart';
import '../../../auth/presentation/pages/change_password_page.dart';
import 'privacy_settings_page.dart';
import 'beta_codes_management_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        title: const Text('Configurações'),
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

                // Estatísticas de uso (para free)
                if (user.isFree) ...[
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

  Widget _buildProfileHeader(BuildContext context, UserModel user, AuthProvider authProvider) {
    return Column(
      children: [
        // Avatar com foto de perfil
        ProfileAvatarPicker(
          currentPhotoUrl: user.photoUrl,
          size: 100,
          gradientColors: _getRoleColors(user.role),
          onPhotoChanged: (photoPath) {
            authProvider.updateProfile(displayName: user.displayName);
          },
        ),
        const SizedBox(height: 16),
        // Nome com botão de editar
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user.displayName ?? 'Bruxa Anônima',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF9C27B0), size: 20),
              onPressed: () => _showEditNameDialog(context, authProvider),
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
            style: const TextStyle(
              color: Colors.white,
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
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Editar Nome',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Seu nome mágico',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFF9C27B0).withOpacity(0.5)),
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
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
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
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, UserModel user, AuthProvider authProvider) {
    final isPremium = user.isPremium;
    final paymentService = PaymentService();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPremium
              ? [const Color(0xFF9C27B0), const Color(0xFFE91E63)]
              : [const Color(0xFF2D2D44), const Color(0xFF1A1A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPremium
              ? Colors.white.withValues(alpha: 0.2)
              : const Color(0xFF9C27B0).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPremium ? Icons.star : Icons.workspace_premium_outlined,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPremium ? 'Plano Premium' : 'Plano Gratuito',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isPremium
                          ? 'Acesso completo a todas as funcionalidades'
                          : 'Algumas funcionalidades são limitadas',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Informações extras para Premium
          if (isPremium) ...[
            const SizedBox(height: 12),
            if (paymentService.isLifetime)
              Text(
                'Assinatura Vitalícia',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                ),
              )
            else if (paymentService.subscriptionExpirationDate != null)
              Text(
                'Renova em: ${_formatDate(paymentService.subscriptionExpirationDate!)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _manageSubscription(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1.5),
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
          if (!isPremium) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showUpgradeSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C27B0),
                  foregroundColor: Colors.white,
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
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _manageSubscription(BuildContext context) async {
    final paymentService = PaymentService();
    await paymentService.presentCustomerCenter();
  }

  Widget _buildUsageStats(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Uso do Plano Gratuito',
            style: TextStyle(
              color: Colors.white,
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
      progressColor = const Color(0xFF4CAF50);
    } else if (percentage < 0.8) {
      progressColor = const Color(0xFFFFC107);
    } else {
      progressColor = const Color(0xFFF44336);
    }

    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
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
                    style: const TextStyle(
                      color: Colors.white,
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
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage.clamp(0, 1),
                backgroundColor: Colors.white.withValues(alpha: 0.1),
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
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
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
            icon: Icons.card_membership,
            title: 'Gerenciar Assinatura',
            onTap: () => Navigator.pushNamed(context, '/subscription'),
          ),
          _buildDivider(),
          _buildOptionTile(
            icon: Icons.analytics_outlined,
            title: 'Estatisticas Magicas',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MagicalAnalyticsPage()),
            ),
          ),
          _buildDivider(),
          _buildOptionTile(
            icon: Icons.explore_outlined,
            title: 'Jornadas Magicas',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JourneysPage()),
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
            textColor: const Color(0xFFF44336),
            onTap: () => _showLogoutConfirmation(context, authProvider),
          ),
        ],
      ),
    );
  }

  void _showNotificationsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
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
                  const Icon(
                    Icons.notifications_active,
                    color: Color(0xFFFFC107),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Notificações',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Configure lembretes para eventos mágicos importantes',
                style: TextStyle(
                  color: Colors.white54,
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
                          await notificationProvider.setFullMoonNotifications(value);
                          if (context.mounted) {
                            _scheduleNotifications(context);
                          }
                        },
                      ),
                      const Divider(color: Colors.white10),
                      _NotificationTile(
                        icon: '🌑',
                        title: 'Lua Nova',
                        subtitle: 'Lembrete 1 dia antes da Lua Nova',
                        value: notificationProvider.newMoonNotifications,
                        onChanged: (value) async {
                          await notificationProvider.setNewMoonNotifications(value);
                          if (context.mounted) {
                            _scheduleNotifications(context);
                          }
                        },
                      ),
                      const Divider(color: Colors.white10),
                      _NotificationTile(
                        icon: '🎃',
                        title: 'Sabbats',
                        subtitle: 'Lembrete 3 dias antes de cada Sabbat',
                        value: notificationProvider.sabbatNotifications,
                        onChanged: (value) async {
                          await notificationProvider.setSabbatNotifications(value);
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
                  border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.3)),
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

    await notificationProvider.scheduleNotifications(
      lunarProvider: lunarProvider,
      wheelProvider: wheelProvider,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notificações atualizadas!'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF4CAF50),
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
          color: const Color(0xFF9C27B0).withValues(alpha: 0.5),
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
            leading: const Icon(
              Icons.bug_report,
              color: Color(0xFF9C27B0),
            ),
            title: const Text(
              'Diagnóstico & Debug',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Testes, alternância de roles e mais',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DiagnosticPage(),
                ),
              );
            },
          ),
          const Divider(color: Colors.white12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.card_giftcard,
              color: Color(0xFF9C27B0),
            ),
            title: const Text(
              'Gerenciar Códigos Beta',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Criar e invalidar códigos promocionais',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38),
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
    final color = textColor ?? Colors.white;
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.white70),
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: textColor?.withValues(alpha: 0.5) ?? Colors.white38,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  void _showUpgradeSheet(BuildContext context) async {
    final paymentService = PaymentService();
    final result = await paymentService.presentPaywall();

    if (!context.mounted) return;

    // Se o resultado foi cancelled e o RevenueCat não está configurado, mostrar aviso
    if (result == PaywallResult.cancelled && !paymentService.isInitialized) {
      _showRevenueCatNotConfiguredDialog(context);
    }
  }

  void _showRevenueCatNotConfiguredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Color(0xFFFFC107)),
            SizedBox(width: 8),
            Text(
              'Pagamentos Não Configurados',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'O sistema de pagamentos ainda não foi configurado nesta versão do app.\n\n'
          'Se você é desenvolvedor, verifique os logs do console para mais detalhes.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Entendi',
              style: TextStyle(color: Color(0xFF9C27B0)),
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
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Nome',
            labelStyle: const TextStyle(color: Colors.white54),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF9C27B0)),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              authProvider.updateProfile(displayName: nameController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
            ),
            child: const Text(
              'Salvar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Sair da Conta',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja sair?\nSeus dados locais serão mantidos.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _handleLogout(context, authProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
            ),
            child: const Text(
              'Sair',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, AuthProvider authProvider) async {
    try {
      if (SupabaseConfig.isConfigured) {
        final authRepo = SupabaseAuthRepository();
        await authRepo.signOut();
      }

      await authProvider.signOut();

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao sair: $e'),
            backgroundColor: const Color(0xFFF44336),
          ),
        );
      }
    }
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Color(0xFF9C27B0)),
            SizedBox(width: 8),
            Text(
              'Ajuda & Suporte',
              style: TextStyle(color: Colors.white),
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
            child: const Text(
              'Fechar',
              style: TextStyle(color: Color(0xFF9C27B0)),
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
            Icon(icon, color: const Color(0xFF9C27B0), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
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
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Row(
          children: [
            Text('✨', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text(
              'Grimório de Bolso',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versão ${packageInfo.version} (${packageInfo.buildNumber})',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            const Text(
              'Seu companheiro para práticas mágicas, rituais e autoconhecimento através da astrologia e bruxaria moderna.',
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Desenvolvido com 🔮 e ✨',
              style: TextStyle(color: Color(0xFF9C27B0)),
            ),
            const SizedBox(height: 8),
            const Text(
              '© 2024 Grimório de Bolso',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Fechar',
              style: TextStyle(color: Color(0xFF9C27B0)),
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
}

class _NotificationTile extends StatelessWidget{
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
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
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
        activeColor: const Color(0xFF4CAF50),
      ),
    );
  }
}
