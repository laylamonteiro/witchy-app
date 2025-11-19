import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../lunar/presentation/providers/lunar_provider.dart';
import '../../../wheel_of_year/presentation/providers/wheel_of_year_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
          ],
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
          backgroundColor: AppColors.mint,
        ),
      );
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
