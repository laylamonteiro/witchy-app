import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/desire_provider.dart';
import '../../data/models/desire_model.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/magical_fab.dart';
import '../../../../core/theme/grimoire_colors.dart';
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
            return LoadingWidget(message: AppLocalizations.of(context).diaryLoadingDesires);
          }

          if (provider.desires.isEmpty) {
            return EmptyStateWidget(
              message:
                  AppLocalizations.of(context).diaryEmptyDesires,
              icon: Icons.auto_awesome,
              actionText: AppLocalizations.of(context).diaryAddDesire,
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
                            // Sigilos nunca revelam a intenção — título fixo.
                            desire.hasSigilImage
                                ? AppLocalizations.of(context)
                                    .diaryDesireSigilTitle
                                : desire.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Text(
                          dateFormat.format(desire.createdAt),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.gc.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (desire.hasSigilImage)
                      _buildSigilThumb(context, desire)
                    else
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

  Widget _buildSigilThumb(BuildContext context, DesireModel desire) {
    final bytes = desire.sigilImageBytes;
    if (bytes == null) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          bytes,
          height: 90,
          width: 90,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Color _getStatusColor(DesireStatus status) {
    switch (status) {
      case DesireStatus.open:
        return context.gc.info;
      case DesireStatus.manifesting:
        return context.gc.lilac;
      case DesireStatus.manifested:
        return context.gc.success;
      case DesireStatus.released:
        return context.gc.textSecondary;
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
