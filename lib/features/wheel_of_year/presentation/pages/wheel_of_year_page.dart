import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/wheel_of_year_provider.dart';
import '../../data/models/sabbat_model.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';

class WheelOfYearPage extends StatelessWidget {
  const WheelOfYearPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roda do Ano'),
      ),
      body: Consumer<WheelOfYearProvider>(
        builder: (context, provider, _) {
          final sabbats = provider.getAllSabbats();
          final nextSabbat = provider.getNextSabbat();
          final dateFormat = DateFormat('dd/MM/yyyy');

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Próximo Sabbat em destaque
                if (nextSabbat != null)
                  MagicalCard(
                    child: Column(
                      children: [
                        Text(
                          'Próximo Sabbat',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          nextSabbat.emoji,
                          style: const TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          nextSabbat.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dateFormat.format(nextSabbat.date),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        _buildDaysUntilChip(
                          context,
                          nextSabbat.daysUntil(DateTime.now()),
                        ),
                      ],
                    ),
                  ),

                // Lista de todos os Sabbats
                MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calendário dos Sabbats',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      ...sabbats.map((sabbat) => _buildSabbatItem(
                            context,
                            sabbat,
                            dateFormat,
                          )),
                    ],
                  ),
                ),

                // Informação sobre a Roda do Ano
                MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.info,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sobre a Roda do Ano',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'A Roda do Ano representa o ciclo anual de celebrações da natureza. São 8 sabbats que marcam mudanças sazonais: 4 festivais solares (solstícios e equinócios) e 4 festivais de fogo (datas fixas).',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Estas datas foram adaptadas para o hemisfério sul, seguindo o ciclo natural das estações.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDaysUntilChip(BuildContext context, int days) {
    String text;
    if (days == 0) {
      text = 'Hoje!';
    } else if (days == 1) {
      text = 'Amanhã';
    } else {
      text = 'Em $days dias';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lilac.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lilac),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.lilac,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildSabbatItem(
    BuildContext context,
    Sabbat sabbat,
    DateFormat dateFormat,
  ) {
    final now = DateTime.now();
    final daysUntil = sabbat.daysUntil(now);
    final isPast = sabbat.isPast(now);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showSabbatDetails(context, sabbat, dateFormat),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isPast
                ? AppColors.surface.withOpacity(0.5)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPast
                  ? AppColors.surfaceBorder.withOpacity(0.5)
                  : AppColors.surfaceBorder,
            ),
          ),
          child: Row(
            children: [
              Text(
                sabbat.emoji,
                style: TextStyle(
                  fontSize: 40,
                  color: isPast ? Colors.white.withOpacity(0.5) : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sabbat.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isPast
                                ? AppColors.textSecondary
                                : AppColors.lilac,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(sabbat.date),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    if (!isPast) ...[
                      const SizedBox(height: 4),
                      Text(
                        daysUntil == 0
                            ? 'Hoje!'
                            : daysUntil == 1
                                ? 'Amanhã'
                                : 'Em $daysUntil dias',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.mint,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isPast
                    ? AppColors.textSecondary.withOpacity(0.5)
                    : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSabbatDetails(
    BuildContext context,
    Sabbat sabbat,
    DateFormat dateFormat,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  sabbat.emoji,
                  style: const TextStyle(fontSize: 64),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  sabbat.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Datas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.lilac,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lilac.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lilac.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🌎',
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hemisfério Sul',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.lilac,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sabbat.type.southernHemisphereDate,
                                style:
                                    Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🌍',
                          style: TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hemisfério Norte',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sabbat.type.northernHemisphereDate,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Significado',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                sabbat.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Text(
                'Cristais',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sabbat.type.crystals
                    .map((crystal) => Chip(
                          label: Text(crystal),
                          backgroundColor: AppColors.lilac.withOpacity(0.2),
                          side: const BorderSide(color: AppColors.lilac),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Ervas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sabbat.type.herbs
                    .map((herb) => Chip(
                          label: Text(herb),
                          backgroundColor: AppColors.mint.withOpacity(0.2),
                          side: const BorderSide(color: AppColors.mint),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Cores',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sabbat.type.colors
                    .map((color) => Chip(
                          label: Text(color),
                          backgroundColor: AppColors.starYellow.withOpacity(0.2),
                          side: const BorderSide(color: AppColors.starYellow),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Comidas Tradicionais',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ...sabbat.type.foods.map((food) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🍽️', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            food,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
              Text(
                'Rituais Sugeridos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...sabbat.rituals.map((ritual) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '•',
                          style: TextStyle(
                            fontSize: 20,
                            color: AppColors.lilac,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ritual,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
