import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/magical_button.dart';
import '../../../auth/auth.dart';
import '../../data/models/sigil_model.dart';
import 'sigil_step2_letters_page.dart';

/// Etapa 1: Definir intenção para o sigilo
class SigilStep1IntentionPage extends StatefulWidget {
  const SigilStep1IntentionPage({super.key});

  @override
  State<SigilStep1IntentionPage> createState() =>
      _SigilStep1IntentionPageState();
}

class _SigilStep1IntentionPageState extends State<SigilStep1IntentionPage> {
  final TextEditingController _intentionController = TextEditingController();
  bool _canContinue = false;

  @override
  void initState() {
    super.initState();
    _intentionController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _intentionController.dispose();
    super.dispose();
  }

  void _validateInput() {
    setState(() {
      // Validar se é uma única palavra (sem espaços) e tem pelo menos 3 letras
      final text = _intentionController.text.trim();
      _canContinue = text.isNotEmpty &&
                     !text.contains(' ') &&
                     text.length >= 3;
    });
  }

  void _continue() {
    if (!_canContinue) return;

    final sigil = Sigil.fromIntention(_intentionController.text.trim());

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SigilStep2LettersPage(sigil: sigil),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final access = authProvider.checkFeatureAccess(AppFeature.sigilsCreate);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Criar Sigilo'),
            backgroundColor: AppColors.surface,
          ),
          body: access.hasFullAccess
              ? _buildContent(context)
              : _buildPremiumLocked(context),
        );
      },
    );
  }

  Widget _buildPremiumLocked(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🃏', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            Text(
              'Criação de Sigilos',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.lilac,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'A criação de sigilos personalizados é uma funcionalidade exclusiva para assinantes Premium.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const PremiumUpgradeSheet(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Desbloquear com Premium',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card de explicação - PRIMEIRO
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🃏', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 12),
                      Text(
                        'O que é um Sigilo?',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sigilos são símbolos mágicos criados para manifestar intenções. '
                    'Ao transformar palavras em símbolos abstratos, você cria uma marca energética '
                    'que carrega o poder da sua vontade, sem revelar sua intenção para outras pessoas.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Defina sua intenção, escolha uma palavra que a represente, '
                    'e o app criará automaticamente seu sigilo único.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Título da etapa - DEPOIS
            Text(
              'Defina sua Intenção',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Campo de entrada
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sua palavra de intenção',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _intentionController,
                    decoration: InputDecoration(
                      hintText: 'Digite uma palavra...',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.surfaceBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.surfaceBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.lilac,
                          width: 2,
                        ),
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                    textCapitalization: TextCapitalization.none,
                    maxLength: 30,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '⚠️ Use apenas UMA palavra, sem espaços',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _intentionController.text.contains(' ')
                              ? Colors.red.shade300
                              : AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Exemplos
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Exemplos de palavras',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  _buildExample('Prosperidade'),
                  _buildExample('Proteção'),
                  _buildExample('Cura'),
                  _buildExample('Confiança'),
                  _buildExample('Intuição'),
                  const SizedBox(height: 8),
                  Text(
                    'Dica: Escolha palavras positivas e específicas que ressoem com você.',
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
            if (_canContinue)
              MagicalButton(
                text: 'Continuar',
                onPressed: _continue,
              )
            else
              ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Continuar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildExample(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Text('•', style: TextStyle(color: AppColors.lilac)),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
