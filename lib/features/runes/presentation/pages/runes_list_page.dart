import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/models/rune_model.dart';
import 'rune_detail_page.dart';

/// Tela de lista de runas
class RunesListPage extends StatelessWidget {
  const RunesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final runes = Rune.getAllRunes();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Runas'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Introdução
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('ᚠ', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Text(
                        'Sobre as Runas',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'As runas são um alfabeto antigo usado pelos povos germânicos '
                    'e nórdicos. Além de escrita, cada runa carrega significados '
                    'simbólicos profundos e pode ser usada para reflexão, '
                    'autoconhecimento e leitura oracular.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Explore as 24 runas do Futhark Antigo abaixo. '
                    'Toque em cada uma para conhecer seu significado.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Título da lista
            Text(
              'Futhark Antigo',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Grid de runas
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0, // Aumentado de 1.2 para 1.0 para dar mais altura
              ),
              itemCount: runes.length,
              itemBuilder: (context, index) {
                final rune = runes[index];
                return _buildRuneCard(context, rune);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRuneCard(BuildContext context, Rune rune) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RuneDetailPage(rune: rune),
          ),
        );
      },
      child: MagicalCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Símbolo da runa
              Text(
                rune.symbol,
                style: const TextStyle(
                  fontSize: 42, // Reduzido de 48 para 42
                  color: AppColors.starYellow,
                ),
              ),
              const SizedBox(height: 8),

              // Nome da runa
              Text(
                rune.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.lilac,
                      fontSize: 16, // Tamanho fixo para consistência
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Primeira palavra-chave
              if (rune.keywords.isNotEmpty)
                Flexible(
                  child: Text(
                    rune.keywords.first,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12, // Tamanho fixo
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2, // Permitir até 2 linhas
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
