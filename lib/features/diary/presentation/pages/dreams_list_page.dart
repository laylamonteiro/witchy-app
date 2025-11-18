import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/dream_provider.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_assets.dart';
import 'dream_form_page.dart';

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
            return EmptyStateWidget(
              message:
                  'Você ainda não registrou nenhum sonho.\nComece seu diário onírico!',
              icon: Icons.nightlight,
              actionText: 'Registrar Sonho',
              onAction: () => _navigateToForm(context),
            );
          }

          return ListView.builder(
            itemCount: provider.dreams.length,
            itemBuilder: (context, index) {
              final dream = provider.dreams[index];
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
                                    color: AppColors.textSecondary,
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
                                      AppColors.lilac.withOpacity(0.2),
                                  side: const BorderSide(color: AppColors.lilac),
                                ))
                            .toList(),
                      ),
                    ],
                    if (dream.feeling != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.favorite,
                              size: 16, color: AppColors.pink),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        backgroundColor: AppColors.lilac,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            AppAssets.addDark,
            colorFilter: const ColorFilter.mode(
              Color(0xFF2B2143),
              BlendMode.srcIn,
            ),
          ),
        ),
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
}
