import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/desire_provider.dart';
import '../../data/models/desire_model.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_assets.dart';
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
                        Text(
                          desire.status.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            desire.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(desire.status.displayName),
                      backgroundColor: _getStatusColor(desire.status).withOpacity(0.2),
                      side: BorderSide(color: _getStatusColor(desire.status)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      desire.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (desire.evolution != null &&
                        desire.evolution!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.trending_up,
                                size: 16, color: AppColors.info),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                desire.evolution!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
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
