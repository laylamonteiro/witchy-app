import 'package:flutter/material.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../runes/presentation/pages/rune_reading_page.dart';
import 'pendulum_page.dart';
import 'oracle_cards_page.dart';

class DivinationHubPage extends StatelessWidget {
  const DivinationHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Divinação'),
        backgroundColor: AppColors.darkBackground,
      ),
      backgroundColor: AppColors.darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MagicalCard(
              child: Column(
                children: [
                  const Text('🔮', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    'Artes Divinatórias',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.lilac,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Consulte os oráculos e receba orientação',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.softWhite.withOpacity(0.8),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildDivinationOption(
              context,
              icon: 'ᚱᚢᚾᚨ',
              title: 'Runas',
              description: 'Leitura das antigas runas nórdicas',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RuneReadingPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildDivinationOption(
              context,
              icon: '⟟',
              title: 'Pêndulo',
              description: 'Perguntas de sim ou não',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PendulumPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildDivinationOption(
              context,
              icon: '🔮',
              title: 'Oracle Cards',
              description: 'Mensagens e orientação do universo',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const OracleCardsPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivinationOption(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: MagicalCard(
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.softWhite,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.softWhite.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.lilac,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
