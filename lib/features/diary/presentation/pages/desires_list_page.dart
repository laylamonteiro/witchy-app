import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/desire_provider.dart';
import '../../data/models/desire_model.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/magical_fab.dart';
import '../../../../core/theme/app_theme.dart';
import 'desire_form_page.dart';

class DesiresListPage extends StatefulWidget {
  const DesiresListPage({super.key});

  @override
  State<DesiresListPage> createState() => _DesiresListPageState();
}

class _DesiresListPageState extends State<DesiresListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DesireProvider>().loadDesires();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      body: Consumer<DesireProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Carregando desejos...');
          }

          if (provider.desires.isEmpty) {
            return EmptyStateWidget(
              message:
                  'Você ainda não registrou nenhum desejo.\nComece a manifestar seus sonhos!',
              icon: Icons.auto_awesome,
              actionText: 'Adicionar Desejo',
              onAction: () => _navigateToForm(context),
            );
          }

          return ListView.builder(
            itemCount: provider.desires.length,
            itemBuilder: (context, index) {
              final desire = provider.desires[index];
              return MagicalCard(
                onTap: () => _navigateToForm(context, desire: desire),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            desire.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Text(
                          dateFormat.format(desire.createdAt),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      desire.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          avatar: Text(desire.status.emoji),
                          label: Text(
                            desire.status.displayName,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor:
                              _getStatusColor(desire.status).withOpacity(0.2),
                          side: BorderSide(color: _getStatusColor(desire.status)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: MagicalFAB(
        onPressed: () => _navigateToForm(context),
        icon: Icons.auto_awesome,
      ),
    );
  }

  Color _getStatusColor(DesireStatus status) {
    switch (status) {
      case DesireStatus.open:
        return AppColors.info;
      case DesireStatus.manifesting:
        return AppColors.lilac;
      case DesireStatus.manifested:
        return AppColors.success;
      case DesireStatus.released:
        return AppColors.textSecondary;
    }
  }

  void _navigateToForm(BuildContext context, {desire}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DesireFormPage(desire: desire),
      ),
    );
  }
}
