import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Letras Mágicas'),
        backgroundColor: AppColors.surface,
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
                    color: AppColors.textSecondary,
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
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sigil.intention,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.lilac,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Seta para baixo
            const Center(
              child: Text(
                '↓',
                style: TextStyle(
                  fontSize: 32,
                  color: AppColors.starYellow,
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
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Letras em destaque com tamanho dinâmico
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final letterCount = sigil.processedLetters.length;
                      // Ajustar tamanho da caixa baseado no número de letras
                      // Se muitas letras, caixas menores para caber em uma linha
                      final boxSize = letterCount > 10
                          ? (constraints.maxWidth - 16) / letterCount - 4
                          : letterCount > 7
                              ? 36.0
                              : 48.0;
                      final fontSize = boxSize < 36 ? 16.0 : 22.0;

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: sigil.processedLetters.split('').map((letter) {
                            return Container(
                              width: boxSize.clamp(24.0, 48.0),
                              height: boxSize.clamp(24.0, 48.0),
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.lilac,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  letter,
                                  style: TextStyle(
                                    color: AppColors.starYellow,
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
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
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildStep('1. Acentos foram normalizados'),
                  _buildStep('2. Espaços e símbolos foram removidos'),
                  _buildStep('3. Letras duplicadas foram eliminadas (mantém apenas a primeira ocorrência)'),
                  const SizedBox(height: 12),
                  Text(
                    'Esta sequência simplificada será conectada na Roda das Bruxas '
                    'para formar o símbolo mágico do seu sigilo.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SigilStep3DrawingPage(sigil: sigil),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Text('•', style: TextStyle(color: AppColors.lilac)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
