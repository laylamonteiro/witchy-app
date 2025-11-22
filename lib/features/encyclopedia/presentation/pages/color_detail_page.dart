import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/color_model.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/auth.dart';

class ColorDetailPage extends StatelessWidget {
  final ColorModel colorModel;

  const ColorDetailPage({super.key, required this.colorModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(colorModel.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MagicalCard(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: colorModel.color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.surfaceBorder,
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    colorModel.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    colorModel.meaning,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Premium content - blur para usuários free
            PremiumBlurWidget(
              feature: AppFeature.encyclopediaColorsDetails,
              customMessage: 'Desbloqueie informações detalhadas sobre cores na magia',
              child: Column(
                children: [
                  MagicalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Intenções',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: colorModel.intentions
                              .map((intention) => Chip(
                                    label: Text(intention),
                                    backgroundColor: colorModel.color.withOpacity(0.3),
                                    side: BorderSide(color: colorModel.color),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  MagicalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Como Usar na Magia',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        ...colorModel.usageTips.map(
                          (tip) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 16,
                                  color: colorModel.color,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
}
