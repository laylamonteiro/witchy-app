import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/gratitude_provider.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/magical_fab.dart';
import '../../../../core/theme/app_theme.dart';
import 'gratitude_form_page.dart';

class GratitudesListPage extends StatefulWidget {
  const GratitudesListPage({super.key});

  @override
  State<GratitudesListPage> createState() => _GratitudesListPageState();
}

class _GratitudesListPageState extends State<GratitudesListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GratitudeProvider>().loadGratitudes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      body: Consumer<GratitudeProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget(message: 'Carregando gratidões...');
          }

          if (provider.gratitudes.isEmpty) {
            return EmptyStateWidget(
              message:
                  'Você ainda não registrou nenhuma gratidão.\nComece a cultivar abundância em sua vida!',
              icon: Icons.favorite,
              actionText: 'Adicionar Gratidão',
              onAction: () => _navigateToForm(context),
            );
          }

          return ListView.builder(
            itemCount: provider.gratitudes.length,
            itemBuilder: (context, index) {
              final gratitude = provider.gratitudes[index];
              return MagicalCard(
                onTap: () => _navigateToForm(context, gratitude: gratitude),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            gratitude.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Text(
                          dateFormat.format(gratitude.date),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      gratitude.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (gratitude.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: gratitude.tags
                            .map((tag) => Chip(
                                  label: Text(tag, style: const TextStyle(fontSize: 12)),
                                  backgroundColor:
                                      AppColors.mint.withOpacity(0.2),
                                  side: const BorderSide(color: AppColors.mint),
                                ))
                            .toList(),
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
        icon: Icons.favorite,
      ),
    );
  }

  void _navigateToForm(BuildContext context, {gratitude}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GratitudeFormPage(gratitude: gratitude),
      ),
    );
  }
}
