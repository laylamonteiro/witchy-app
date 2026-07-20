import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/affirmation_provider.dart';
import '../../data/models/affirmation_model.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/magical_fab.dart';
import '../../../../core/theme/grimoire_colors.dart';
import 'affirmation_form_page.dart';

class AffirmationsListPage extends StatefulWidget {
  const AffirmationsListPage({super.key});

  @override
  State<AffirmationsListPage> createState() => _AffirmationsListPageState();
}

class _AffirmationsListPageState extends State<AffirmationsListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AffirmationProvider>().loadAffirmations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AffirmationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return LoadingWidget(message: AppLocalizations.of(context).diaryLoadingAffirmations);
          }

          return Column(
            children: [
              // Filtro de categoria
              Container(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip(
                        context,
                        AppLocalizations.of(context).diaryAllCategories,
                        null,
                        provider.selectedCategory == null,
                      ),
                      const SizedBox(width: 8),
                      ...AffirmationCategory.values.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildCategoryChip(
                            context,
                            '${category.icon} ${category.displayName}',
                            category,
                            provider.selectedCategory == category,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Lista de afirmações
              Expanded(
                child: provider.affirmations.isEmpty
                    ? EmptyStateWidget(
                        message:
                            AppLocalizations.of(context).diaryEmptyAffirmationsCategory,
                        icon: Icons.auto_awesome,
                        actionText: AppLocalizations.of(context).diaryAddAffirmation,
                        onAction: () => _navigateToForm(context),
                      )
                    : ListView.builder(
                        itemCount: provider.affirmations.length,
                        itemBuilder: (context, index) {
                          final affirmation = provider.affirmations[index];
                          return MagicalCard(
                            onTap: affirmation.isPreloaded
                                ? null
                                : () => _navigateToForm(context,
                                    affirmation: affirmation),
                            child: Row(
                              children: [
                                // Emoji da categoria
                                Text(
                                  affirmation.category.icon,
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(width: 12),
                                // Texto da afirmação
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        affirmation.text,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontStyle: FontStyle.italic,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        affirmation.category.displayName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: context.gc.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Botão de favorito
                                IconButton(
                                  icon: Icon(
                                    affirmation.isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: affirmation.isFavorite
                                        ? context.gc.pinkWitch
                                        : context.gc.textSecondary,
                                  ),
                                  onPressed: () => provider
                                      .toggleFavorite(affirmation),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: MagicalFAB(
        onPressed: () => _navigateToForm(context),
        icon: Icons.auto_awesome,
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String label,
    AffirmationCategory? category,
    bool isSelected,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        context.read<AffirmationProvider>().setCategory(category);
      },
      backgroundColor: context.gc.surface,
      selectedColor: context.gc.lilac.withOpacity(0.3),
      checkmarkColor: context.gc.lilac,
      side: BorderSide(
        color: isSelected ? context.gc.lilac : context.gc.surfaceBorder,
      ),
    );
  }

  void _navigateToForm(BuildContext context, {affirmation}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AffirmationFormPage(affirmation: affirmation),
      ),
    );
  }
}
