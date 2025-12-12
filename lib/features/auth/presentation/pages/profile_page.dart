import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/services/payment_service.dart';
import '../../../subscription/subscription.dart';
import '../../../settings/settings.dart';
import '../../../analytics/analytics.dart';
import '../../../journeys/journeys.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../providers/auth_provider.dart';
import '../widgets/premium_blur_widget.dart';
import '../widgets/profile_avatar_picker.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        title: const Text('Meu Perfil'),
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
                // DEBUG: Card baseado em PLAN não ROLE
                if (user.plan == SubscriptionPlan.free) ...[
                  _buildPlanCard(context, user, authProvider),
                  const SizedBox(height: 20),
                ],

                // DEBUG: Marcador visual para confirmar build novo
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    border: Border.all(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'DEBUG: Build ${DateTime.now().millisecondsSinceEpoch} - Plan: ${user.plan.toString().split('.').last}',
                    style: const TextStyle(color: Colors.red, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),

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

  void _showEditNameDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
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
              : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isFree ? Icons.workspace_premium_outlined : Icons.star,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFree ? 'Plano Gratuito' : 'Plano Premium',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isFree
                          ? 'Algumas funcionalidades são limitadas'
                          : 'Acesso completo a todas as funcionalidades',
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
          if (isFree) ...[
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
    final paymentService = PaymentService();

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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilePage()),
            ),
          ),
          _buildDivider(),
          // Opção de gerenciar assinatura
          _buildOptionTile(
            icon: Icons.card_membership,
            title: 'Gerenciar Assinatura',
            onTap: () => _handleManageSubscription(context, paymentService),
          ),
          _buildDivider(),
          // Estatísticas mágicas
          _buildOptionTile(
            icon: Icons.analytics_outlined,
            title: 'Estatísticas Mágicas',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MagicalAnalyticsPage()),
            ),
          ),
          _buildDivider(),
          // Jornadas gamificadas
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
            icon: Icons.notifications_outlined,
            title: 'Notificações',
            onTap: () => _showNotificationsDialog(context),
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
      // Logout do Supabase se configurado
      if (SupabaseConfig.isConfigured) {
        final authRepo = SupabaseAuthRepository();
        await authRepo.signOut();
      }

      // Limpar estado local
      await authProvider.signOut();

      // Navegar para tela de welcome
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
          const Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Color(0xFF9C27B0)),
              SizedBox(width: 8),
              Text(
                'Opções de Admin',
                style: TextStyle(
                  color: Color(0xFF9C27B0),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Simular Plano:',
            style: TextStyle(color: Colors.white70, fontSize: 12),
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
              : Colors.white.withValues(alpha: 0.1),
          foregroundColor: Colors.white,
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
    // Usar o paywall do RevenueCat
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

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.shield;
      case UserRole.premium:
        return Icons.star;
      case UserRole.free:
        return Icons.person;
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
        title: const Row(
          children: [
            Icon(Icons.notifications_outlined, color: Color(0xFF9C27B0)),
            SizedBox(width: 8),
            Text(
              'Notificações',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: const Text(
          'As configurações de notificações estarão disponíveis em breve!\n\nVocê poderá personalizar alertas para:\n• Lembretes de rituais\n• Fases da lua\n• Datas mágicas especiais',
          style: TextStyle(color: Colors.white70, height: 1.5),
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

  void _handleManageSubscription(BuildContext context, PaymentService paymentService) {
    // Sempre navegar para página de assinatura (contém código beta e outras opções)
    Navigator.pushNamed(context, '/subscription');
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
}
