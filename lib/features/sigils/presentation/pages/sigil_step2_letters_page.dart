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
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.lilac,
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
                                  color: AppColors.starYellow,
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
                    'Sua palavra foi transformada para revelar sua essência:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildStep('1. Espaços foram removidos'),
                  _buildStep('2. Acentos foram simplificados'),
                  _buildStep('3. Letras repetidas foram eliminadas'),
                  const SizedBox(height: 12),
                  Text(
                    'Estas letras únicas são a base mágica do seu sigilo. '
                    'Elas representam a essência concentrada da sua intenção.',
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
