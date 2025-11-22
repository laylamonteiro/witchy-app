import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/diagnostic/diagnostic_page.dart';
import '../../../lunar/presentation/providers/lunar_provider.dart';
import '../../../wheel_of_year/presentation/providers/wheel_of_year_provider.dart';
import '../../../auth/auth.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card de Perfil
                _buildProfileCard(context, user),

                // Card de Notificações
                MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.notifications_active,
                            color: AppColors.starYellow,
                            size: 28,
                          ),
                      const SizedBox(width: 12),
                      Text(
                        'Notificações',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure lembretes para eventos mágicos importantes',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
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
                          const Divider(color: AppColors.surfaceBorder),
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
                          const Divider(color: AppColors.surfaceBorder),
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
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.info.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'As notificações serão enviadas apenas em dispositivos móveis',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.info,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.lilac,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Sobre',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        label: 'Versão',
                        value: '1.0.0',
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Desenvolvido por',
                        value: 'Claude + Layla',
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Grimório de Bolso é um app mágico para bruxas e bruxos iniciantes, com informações precisas e culturalmente adaptadas para o Brasil.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),

                // Card de Admin (para admins originais, mesmo simulando outros roles)
                if (authProvider.isOriginalAdmin) _buildAdminCard(context, authProvider),
              ],
            ),
          );
        },
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
          backgroundColor: AppColors.mint,
        ),
      );
    }
  }

  Widget _buildProfileCard(BuildContext context, UserModel user) {
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar com badge de role
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _getRoleColors(user.role),
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getRoleIcon(user.role),
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? 'Bruxa Anônima',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _getRoleColors(user.role),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getRoleLabel(user.role),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
              ),
            ],
          ),
          if (user.isFree) ...[
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const PremiumUpgradeSheet(),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF9C27B0).withOpacity(0.2),
                      const Color(0xFFE91E63).withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF9C27B0).withOpacity(0.5),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Color(0xFF9C27B0),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Desbloqueie recursos Premium',
                        style: TextStyle(
                          color: Color(0xFF9C27B0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF9C27B0),
                      size: 16,
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

  Widget _buildAdminCard(BuildContext context, AuthProvider authProvider) {
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.admin_panel_settings,
                color: Color(0xFFFFD700),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Admin',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFFFFD700),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Diagnóstico
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.bug_report,
              color: AppColors.lilac,
            ),
            title: const Text('Diagnóstico'),
            subtitle: Text(
              'Testar funcionalidades do app',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DiagnosticPage(),
                ),
              );
            },
          ),
          const Divider(color: AppColors.surfaceBorder),
          // Simular planos
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simular Plano:',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
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
              : Colors.white.withOpacity(0.1),
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
        return 'ADMIN';
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
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.mint,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
