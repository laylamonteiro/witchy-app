import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
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
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).sigilMagicLetters),
        backgroundColor: context.gc.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título da etapa
            Text(
              AppLocalizations.of(context).sigilYourLetters,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).sigilEssence,
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
                    AppLocalizations.of(context).sigilYourIntention,
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
                    AppLocalizations.of(context).sigilTransformedInto,
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
                        AppLocalizations.of(context).sigilWhatHappened,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context).sigilSimplified,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildStep(context, AppLocalizations.of(context).sigilStepAccents),
                  _buildStep(context, AppLocalizations.of(context).sigilStepSpaces),
                  _buildStep(
                      context,
                      AppLocalizations.of(context).sigilStepDupes),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context).sigilWheelNote,
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
              text: AppLocalizations.of(context).sigilSeeDrawing,
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
