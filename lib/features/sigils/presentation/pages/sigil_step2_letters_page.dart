import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/magical_button.dart';
import '../../data/models/sigil_model.dart';
import 'sigil_step3_drawing_page.dart';

/// Etapa 2: Mostrar letras mágicas processadas
class SigilStep2LettersPage extends StatelessWidget {
  final Sigil sigil;

  const SigilStep2LettersPage({
    super.key,
    required this.sigil,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.gc.background,
      appBar: AppBar(
        title: const ResponsiveAppBarTitle('Letras Mágicas'),
        backgroundColor: context.gc.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título da etapa
            Text(
              'Letras do seu Sigilo',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'A essência mágica da sua intenção',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.gc.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Mostrar intenção original
            MagicalCard(
              child: Column(
                children: [
                  Text(
                    'Sua intenção:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sigil.intention,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: context.gc.lilac,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Seta para baixo
            Center(
              child: Text(
                '↓',
                style: TextStyle(
                  fontSize: 32,
                  color: context.gc.starYellow,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Mostrar letras processadas
            MagicalCard(
              child: Column(
                children: [
                  Text(
                    'Transformada em:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Letras em destaque
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: sigil.processedLetters.split('').map((letter) {
                      return Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: context.gc.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: context.gc.lilac,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            letter,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: context.gc.starYellow,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Explicação
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Text(
                        'O que aconteceu?',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sua palavra foi simplificada seguindo a tradição dos sigilos:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildStep(context, '1. Acentos foram normalizados'),
                  _buildStep(context, '2. Espaços e símbolos foram removidos'),
                  _buildStep(
                      context,
                      '3. Letras duplicadas foram eliminadas (mantém apenas a primeira ocorrência)'),
                  const SizedBox(height: 12),
                  Text(
                    'Esta sequência simplificada será conectada na Roda das Bruxas '
                    'para formar o símbolo mágico do seu sigilo.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Botão continuar
            MagicalButton(
              text: 'Ver Desenho do Sigilo',
              onPressed: () async {
                final completed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SigilStep3DrawingPage(sigil: sigil),
                  ),
                );
                if (completed == true && context.mounted) {
                  Navigator.pop(context, true);
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text('•', style: TextStyle(color: context.gc.lilac)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: context.gc.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
