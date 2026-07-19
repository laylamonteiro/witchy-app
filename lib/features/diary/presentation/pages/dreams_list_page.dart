import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/dream_provider.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/magical_fab.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import 'dream_form_page.dart';
import 'dream_interpretation_page.dart';
import 'dream_themes_page.dart';

class DreamsListPage extends StatefulWidget {
  const DreamsListPage({super.key});

  @override
  State<DreamsListPage> createState() => _DreamsListPageState();
}

class _DreamsListPageState extends State<DreamsListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DreamProvider>().loadDreams();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      body: Consumer<DreamProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Carregando sonhos...');
          }

          if (provider.dreams.isEmpty) {
            return Column(
              children: [
                _buildDreamToolsHeader(context),
                Expanded(
                  child: EmptyStateWidget(
                    message:
                        'Você ainda não registrou nenhum sonho.\nComece seu diário onírico!',
                    icon: Icons.nightlight,
                    actionText: 'Registrar Sonho',
                    onAction: () => _navigateToForm(context),
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            itemCount: provider.dreams.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _buildDreamToolsHeader(context);
              final dream = provider.dreams[index - 1];
              return MagicalCard(
                onTap: () => _navigateToForm(context, dream: dream),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dream.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Text(
                          dateFormat.format(dream.date),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: context.gc.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dream.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (dream.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: dream.tags
                            .map((tag) => Chip(
                                  label: Text(tag, style: const TextStyle(fontSize: 12)),
                                  backgroundColor:
                                      context.gc.lilac.withOpacity(0.2),
                                  side: BorderSide(color: context.gc.lilac),
                                ))
                            .toList(),
                      ),
                    ],
                    if (dream.feeling != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.favorite,
                              size: 16, color: context.gc.pink),
                          const SizedBox(width: 4),
                          Text(
                            dream.feeling!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: MagicalFAB(
        onPressed: () => _navigateToForm(context),
        icon: Icons.nightlight,
      ),
    );
  }

  void _navigateToForm(BuildContext context, {dream}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DreamFormPage(dream: dream),
      ),
    );
  }

  /// Atalhos da seção de Interpretação de Sonhos: IA (Premium) e temas (Free).
  Widget _buildDreamToolsHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _buildToolChip(
              context,
              emoji: '🔮',
              label: 'Interpretar Sonho',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DreamInterpretationPage(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildToolChip(
              context,
              emoji: '🌙',
              label: 'Temas Oníricos',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DreamThemesPage(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolChip(
    BuildContext context, {
    required String emoji,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: context.gc.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.gc.surfaceBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.gc.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
