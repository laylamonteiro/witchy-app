import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/magical_button.dart';
import '../../data/models/sigil_model.dart';
import '../../data/models/sigil_wheel_model.dart';
import '../widgets/witch_wheel_painter.dart';
import '../widgets/sigil_drawing_painter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

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
  bool _isShuffled = false;
  Map<String, WheelPosition>? _shuffledPositions;
  bool _isSaving = false;

  Future<void> _saveAndFinish() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final data = <String, dynamic>{
        'id': const Uuid().v4(),
        'user_id': context.read<AuthProvider>().currentUser.id,
        'intention': widget.sigil.intention,
        'image_path': jsonEncode({
          'letters': widget.sigil.processedLetters,
          'points': widget.sigil.points
              .map((point) => {'x': point.dx, 'y': point.dy})
              .toList(),
        }),
        'created_at': now,
        'updated_at': now,
        'synced': 0,
      };
      final db = await DatabaseHelper.instance.database;
      await db.insert('sigils', data);
      await DataSyncService().syncItem(SyncEntity.sigils, data);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível salvar o sigilo: $e')),
      );
    }
  }

  /// Embaralha as posições das letras na roda (como no "Sigilo Nada" do livro)
  void _shuffleLetters() {
    setState(() {
      _isShuffled = true;
      _shuffledPositions = SigilWheel.generateShuffledPositions();
    });
  }

  /// Restaura as posições originais das letras
  void _resetLetters() {
    setState(() {
      _isShuffled = false;
      _shuffledPositions = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.gc.background,
      appBar: AppBar(
        title: const ResponsiveAppBarTitle('Seu Sigilo'),
        backgroundColor: context.gc.surface,
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
                    color: context.gc.lilac,
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
                    width: 360,
                    height: 360,
                    decoration: BoxDecoration(
                      color: context.gc.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomPaint(
                      size: const Size(360, 360),
                      painter: _showWheel
                          ? WitchWheelPainter(
                              borderColor: context.gc.surfaceBorder,
                              starColor: context.gc.starYellow,
                              accentColor: context.gc.lilac,
                              showLetters: true,
                              highlightedLetters: widget.sigil.processedLetters
                                  .split('')
                                  .toSet(),
                              customPositions: _shuffledPositions,
                            )
                          : null,
                      foregroundPainter: SigilDrawingPainter(
                        lineColor: context.gc.starYellow,
                        pointColor: context.gc.lilac,
                        intention: widget.sigil.intention,
                        showStartEnd: _showStartEnd,
                        customPositions: _shuffledPositions,
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
                        _buildLegendItem(context.gc.lilac, 'Letras'),
                        const SizedBox(width: 16),
                        _buildLegendItem(Colors.red.shade300, 'Fim'),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Controles de visualização (todos lado a lado)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showWheel
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 16,
                              color: _showWheel
                                  ? context.gc.lilac
                                  : context.gc.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            const Text('Roda'),
                          ],
                        ),
                        selected: _showWheel,
                        onSelected: (value) {
                          setState(() {
                            _showWheel = value;
                          });
                        },
                        selectedColor: context.gc.lilac.withOpacity(0.2),
                        backgroundColor: context.gc.surface,
                        labelStyle: TextStyle(
                          color: _showWheel
                              ? context.gc.lilac
                              : context.gc.textSecondary,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color:
                              _showWheel ? context.gc.lilac : Colors.transparent,
                        ),
                        showCheckmark: false,
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showStartEnd
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 16,
                              color: _showStartEnd
                                  ? context.gc.starYellow
                                  : context.gc.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            const Text('Pontos'),
                          ],
                        ),
                        selected: _showStartEnd,
                        onSelected: (value) {
                          setState(() {
                            _showStartEnd = value;
                          });
                        },
                        selectedColor: context.gc.starYellow.withOpacity(0.2),
                        backgroundColor: context.gc.surface,
                        labelStyle: TextStyle(
                          color: _showStartEnd
                              ? context.gc.starYellow
                              : context.gc.textSecondary,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color: _showStartEnd
                              ? context.gc.starYellow
                              : Colors.transparent,
                        ),
                        showCheckmark: false,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _shuffleLetters,
                        icon: const Icon(Icons.shuffle, size: 20),
                        tooltip: 'Embaralhar letras',
                        style: IconButton.styleFrom(
                          backgroundColor: _isShuffled
                              ? context.gc.mint.withOpacity(0.3)
                              : context.gc.surface,
                          foregroundColor: _isShuffled
                              ? context.gc.mint
                              : context.gc.textSecondary,
                        ),
                      ),
                      if (_isShuffled) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: _resetLetters,
                          icon: const Icon(Icons.restart_alt, size: 20),
                          tooltip: 'Restaurar posições',
                          style: IconButton.styleFrom(
                            backgroundColor: context.gc.surface,
                            foregroundColor: context.gc.textSecondary,
                          ),
                        ),
                      ],
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
                      color: context.gc.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: context.gc.starYellow.withOpacity(0.3),
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
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: context.gc.textSecondary,
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
              text: _isSaving ? 'Salvando...' : 'Finalizar',
              onPressed: _saveAndFinish,
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
          style: TextStyle(
            color: context.gc.textSecondary,
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
            style: TextStyle(
              color: context.gc.lilac,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: context.gc.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
