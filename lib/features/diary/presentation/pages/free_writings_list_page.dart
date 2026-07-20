import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/free_writing_provider.dart';
import '../../data/models/free_writing_model.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';

/// Histórico de reflexões da escrita livre.
///
/// Tocar num item devolve a reflexão selecionada (`Navigator.pop`) para o
/// canvas continuar a edição.
class FreeWritingsListPage extends StatefulWidget {
  const FreeWritingsListPage({super.key});

  @override
  State<FreeWritingsListPage> createState() => _FreeWritingsListPageState();
}

class _FreeWritingsListPageState extends State<FreeWritingsListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FreeWritingProvider>().loadFreeWritings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).diaryReflections),
      ),
      body: Consumer<FreeWritingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return LoadingWidget(message: AppLocalizations.of(context).diaryLoadingReflections);
          }

          if (provider.freeWritings.isEmpty) {
            return EmptyStateWidget(
              message:
                  AppLocalizations.of(context).diaryEmptyReflections,
              icon: Icons.auto_stories,
            );
          }

          return ListView.builder(
            itemCount: provider.freeWritings.length,
            itemBuilder: (context, index) {
              final writing = provider.freeWritings[index];
              return MagicalCard(
                onTap: () => Navigator.pop(context, writing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dateFormat.format(writing.updatedAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: context.gc.textSecondary,
                                ),
                          ),
                        ),
                        InkWell(
                          onTap: () => _confirmDelete(context, writing),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: context.gc.alert,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      writing.content,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, FreeWritingModel writing) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context).diaryDeleteReflectionTitle),
        content: Text(AppLocalizations.of(context).diaryDeleteReflectionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context).commonCancel),
          ),
          TextButton(
            onPressed: () {
              context.read<FreeWritingProvider>().delete(writing.id);
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: context.gc.alert),
            child: Text(AppLocalizations.of(context).commonDelete),
          ),
        ],
      ),
    );
  }
}
