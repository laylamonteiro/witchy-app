import 'package:flutter/material.dart';
import '../../data/models/metal_model.dart';
import '../../data/models/crystal_model.dart'; // Para ElementExtension
import '../../data/models/herb_model.dart'; // Para PlanetExtension
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../auth/auth.dart';

class MetalDetailPage extends StatelessWidget {
  final MetalModel metal;

  const MetalDetailPage({super.key, required this.metal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(metal.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MagicalCard(
              child: Column(
                children: [
                  if (metal.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        metal.imageUrl!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage(context);
                        },
                      ),
                    )
                  else
                    _buildPlaceholderImage(context),
                  const SizedBox(height: 16),
                  Text(
                    metal.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(metal.planet.emoji,
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        metal.planet.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 16),
                      Text(metal.element.emoji,
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        metal.element.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: metal.conductsPower
                          ? context.gc.success.withOpacity(0.2)
                          : context.gc.info.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: metal.conductsPower
                            ? context.gc.success
                            : context.gc.info,
                      ),
                    ),
                    child: Text(
                      metal.conductsPower
                          ? '⚡ Conduz energia mágica'
                          : '🛡️ Protetor',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: metal.conductsPower
                                ? context.gc.success
                                : context.gc.info,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    metal.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Safety Warnings Section (only if there are warnings)
            if (metal.safetyWarnings.isNotEmpty)
              MagicalCard(
                child: Container(
                  decoration: BoxDecoration(
                    color: context.gc.alert.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.gc.alert, width: 2),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: context.gc.alert,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Avisos de Segurança',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: context.gc.alert,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...metal.safetyWarnings.map(
                        (warning) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '⚠️',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  warning,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Propriedades Mágicas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: metal.magicalProperties
                        .map((property) => Chip(
                              label: Text(property),
                              backgroundColor: context.gc.lilac.withOpacity(0.2),
                              side: BorderSide(color: context.gc.lilac),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            MagicalCard(
              child: PremiumContentSection(
                feature: AppFeature.encyclopediaMetalsDetails,
                title: Text(
                  'Usos Mágicos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                subtitle:
                    'Aplicações deste metal em rituais, proteção e condução de energia.',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    ...metal.ritualUses.map(
                      (use) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: context.gc.starYellow,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                use,
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
            ),
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Correspondências',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ...metal.correspondences.map(
                    (correspondence) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: context.gc.mint,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              correspondence,
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
            if (metal.traditionalUses != null)
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.history_edu,
                          color: context.gc.pinkWitch,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Contexto Histórico',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      metal.traditionalUses!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
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

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: context.gc.starYellow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.gc.starYellow,
          width: 3,
        ),
      ),
      child: Icon(
        _getMetalIcon(metal.name),
        color: context.gc.starYellow,
        size: 80,
      ),
    );
  }

  IconData _getMetalIcon(String metalName) {
    switch (metalName.toLowerCase()) {
      case 'ouro':
        return Icons.auto_awesome;
      case 'prata':
        return Icons.nightlight;
      case 'cobre':
        return Icons.favorite;
      case 'ferro':
        return Icons.shield;
      case 'estanho':
        return Icons.calendar_view_week;
      case 'chumbo':
        return Icons.lock;
      case 'bronze':
        return Icons.history_edu;
      case 'latão':
        return Icons.light_mode;
      case 'alumínio':
        return Icons.speed;
      default:
        return Icons.blur_circular;
    }
  }
}
