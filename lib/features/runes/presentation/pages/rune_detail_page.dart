import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/models/rune_model.dart';

/// Tela de detalhe de uma runa
class RuneDetailPage extends StatelessWidget {
  final Rune rune;

  const RuneDetailPage({
    super.key,
    required this.rune,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(rune.name),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card com símbolo
            MagicalCard(
              child: Column(
                children: [
                  // Símbolo grande
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      rune.symbol,
                      style: const TextStyle(
                        fontSize: 120,
                        color: AppColors.starYellow,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nome da runa
                  Text(
                    rune.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.lilac,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Palavras-chave
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Text(
                        'Palavras-chave',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: rune.keywords.map((keyword) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lilac.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.lilac.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          keyword,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.lilac,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Descrição
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('📖', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Text(
                        'Significado',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    rune.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Nota informativa
            MagicalCard(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.starYellow.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Lembre-se: as runas são ferramentas de reflexão e '
                        'autoconhecimento. Use-as como um ponto de partida para '
                        'explorar suas próprias percepções e intuições.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
