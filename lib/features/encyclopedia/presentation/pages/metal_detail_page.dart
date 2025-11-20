import 'package:flutter/material.dart';
import '../../data/models/metal_model.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';

class MetalDetailPage extends StatelessWidget {
  final MetalModel metal;

  const MetalDetailPage({super.key, required this.metal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(metal.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MagicalCard(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.starYellow.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.starYellow,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      _getMetalIcon(metal.name),
                      color: AppColors.starYellow,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    metal.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(metal.planet.emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        metal.planet.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 16),
                      Text(metal.element.emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        metal.element.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: metal.conductsPower
                          ? AppColors.success.withOpacity(0.2)
                          : AppColors.info.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: metal.conductsPower ? AppColors.success : AppColors.info,
                      ),
                    ),
                    child: Text(
                      metal.conductsPower ? '⚡ Conduz energia mágica' : '🛡️ Protetor',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: metal.conductsPower ? AppColors.success : AppColors.info,
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
                    color: AppColors.alert.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.alert, width: 2),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.alert,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Avisos de Segurança',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.alert,
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
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                              backgroundColor: AppColors.lilac.withOpacity(0.2),
                              side: const BorderSide(color: AppColors.lilac),
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
                    'Usos Rituais',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ...metal.ritualUses.map(
                    (use) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: AppColors.starYellow,
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
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: AppColors.mint,
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
                        const Icon(
                          Icons.history_edu,
                          color: AppColors.pinkWitch,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tradição e História',
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
