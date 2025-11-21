import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/magical_button.dart';
import '../../data/models/sigil_model.dart';
import '../widgets/witch_wheel_painter.dart';
import '../widgets/sigil_drawing_painter.dart';

/// Etapa 3: Mostrar desenho do sigilo com a Roda das Bruxas
class SigilStep3DrawingPage extends StatefulWidget {
  final Sigil sigil;

  const SigilStep3DrawingPage({
    super.key,
    required this.sigil,
  });

  @override
  State<SigilStep3DrawingPage> createState() => _SigilStep3DrawingPageState();
}

class _SigilStep3DrawingPageState extends State<SigilStep3DrawingPage> {
  bool _showWheel = true;
  bool _showStartEnd = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Seu Sigilo'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título
            Text(
              'Desenho do seu Sigilo',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.sigil.intention,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.lilac,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Área do desenho
            MagicalCard(
              child: Column(
                children: [
                  // Desenho do sigilo
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomPaint(
                      size: const Size(280, 280),
                      painter: _showWheel
                          ? WitchWheelPainter(
                              showLetters: true,
                              // radius usa SigilWheel.wheelRadius por padrão
                            )
                          : null,
                      foregroundPainter: SigilDrawingPainter(
                        points: widget.sigil.points,
                        showStartEnd: _showStartEnd,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Legenda
                  if (_showStartEnd) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(Colors.green.shade300, 'Início'),
                        const SizedBox(width: 16),
                        _buildLegendItem(AppColors.lilac, 'Letras'),
                        const SizedBox(width: 16),
                        _buildLegendItem(Colors.red.shade300, 'Fim'),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Controles de visualização
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilterChip(
                        label: Text(_showWheel ? 'Ocultar Roda' : 'Mostrar Roda'),
                        selected: _showWheel,
                        onSelected: (value) {
                          setState(() {
                            _showWheel = value;
                          });
                        },
                        selectedColor: AppColors.lilac.withOpacity(0.3),
                        checkmarkColor: AppColors.lilac,
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text(_showStartEnd ? 'Ocultar Pontos' : 'Mostrar Pontos'),
                        selected: _showStartEnd,
                        onSelected: (value) {
                          setState(() {
                            _showStartEnd = value;
                          });
                        },
                        selectedColor: AppColors.starYellow.withOpacity(0.3),
                        checkmarkColor: AppColors.starYellow,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Informações
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🎨', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Text(
                        'Como usar seu sigilo',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStep(
                    '1. Copie este desenho',
                    'Reproduza o traçado em seu caderno, altar, vela, ou papel ritual.',
                  ),
                  _buildStep(
                    '2. Personalize',
                    'Simplifique, gire, ou adicione detalhes. Torná-lo seu faz parte da magia.',
                  ),
                  _buildStep(
                    '3. Ative o sigilo',
                    'Use em meditação, queime em ritual, ou carregue consigo para focar sua intenção.',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.starYellow.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('✨', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Lembre-se: a magia está na sua intenção e no ato de criar, '
                            'não apenas no desenho final.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Botão finalizar
            MagicalButton(
              text: 'Finalizar',
              onPressed: () {
                // Voltar para o início
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStep(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.lilac,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
