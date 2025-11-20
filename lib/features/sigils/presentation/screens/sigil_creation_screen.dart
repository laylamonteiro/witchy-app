import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:grimorio_de_bolso/features/sigils/data/models/sigil_wheel_model.dart';
import 'package:grimorio_de_bolso/features/sigils/presentation/widgets/sigil_wheel_widget.dart';
import 'package:grimorio_de_bolso/core/theme/app_theme.dart';
import 'package:grimorio_de_bolso/core/widgets/magical_card.dart';

class SigilCreationScreen extends ConsumerStatefulWidget {
  const SigilCreationScreen({super.key});

  @override
  ConsumerState<SigilCreationScreen> createState() => _SigilCreationScreenState();
}

class _SigilCreationScreenState extends ConsumerState<SigilCreationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _intentionController = TextEditingController();
  final TextEditingController _phraseController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String _originalText = '';
  String _processedText = '';
  List<String> _sequence = [];
  List<Offset> _sigilPoints = [];
  bool _showGrid = true;
  bool _showLetters = true;
  bool _isCreating = false;
  
  // Exemplos de intenções
  final List<String> _exampleIntentions = [
    'Proteção',
    'Prosperidade',
    'Amor próprio',
    'Clareza mental',
    'Criatividade',
    'Cura',
    'Coragem',
    'Paz interior',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _intentionController.dispose();
    _phraseController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _createSigil() {
    if (_phraseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite uma frase ou palavra para criar o sigilo'),
          backgroundColor: Color(0xFFFF6B81),
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
      _originalText = _phraseController.text;
      _sequence = SigilWheel.textToSigilSequence(_originalText);
      _processedText = _sequence.join('');
      _sigilPoints = SigilWheel.generateSigilPoints(
        _originalText,
        const Size(300, 300),
      );
    });

    _animationController.forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isCreating = false;
      });
    });
  }

  void _clearSigil() {
    setState(() {
      _originalText = '';
      _processedText = '';
      _sequence = [];
      _sigilPoints = [];
      _phraseController.clear();
    });
    _animationController.reverse();
  }

  void _saveSigil() async {
    if (_sigilPoints.isEmpty) return;

    // Aqui você implementaria a lógica de salvamento
    // Por exemplo, converter o canvas em imagem e salvar

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sigilo salvo com sucesso!'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'Ver',
          textColor: AppColors.textPrimary,
          onPressed: () {
            // Navegar para a galeria de sigilos
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Criar Sigilo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navegar para histórico de sigilos
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Introdução - O que é um Sigilo
              _buildIntroductionCard(),

              const SizedBox(height: 24),

              // Título da seção
              Text(
                'Defina sua Intenção',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Card de Intenção
              _buildIntentionCard(),
              
              const SizedBox(height: 16),
              
              // Card da Roda
              _buildWheelCard(),
              
              const SizedBox(height: 16),
              
              // Card de Informações
              if (_processedText.isNotEmpty)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildInfoCard(),
                ),
              
              const SizedBox(height: 16),
              
              // Controles
              _buildControlsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntentionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de intenção
            TextFormField(
              controller: _intentionController,
              decoration: InputDecoration(
                labelText: 'Qual é sua intenção?',
                hintText: 'Ex: Proteção, Prosperidade, Amor...',
                prefixIcon: const Icon(Icons.favorite, color: AppColors.pinkWitch),
                suffixIcon: _intentionController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _intentionController.clear();
                        });
                      },
                    )
                  : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
            
            const SizedBox(height: 12),
            
            // Sugestões de intenções
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _exampleIntentions.map((intention) {
                return ActionChip(
                  label: Text(intention),
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.lilac),
                  labelStyle: const TextStyle(color: AppColors.textPrimary),
                  onPressed: () {
                    setState(() {
                      _intentionController.text = intention;
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Campo de frase
            TextFormField(
              controller: _phraseController,
              decoration: InputDecoration(
                labelText: 'Frase ou Palavra',
                hintText: 'Digite a frase para criar o sigilo',
                helperText: 'Vogais repetidas e letras duplicadas serão removidas',
                helperStyle: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
                prefixIcon: const Icon(Icons.edit, color: AppColors.mint),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_phraseController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _phraseController.clear();
                            _clearSigil();
                          });
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.auto_fix_high, color: AppColors.starYellow),
                      onPressed: _createSigil,
                      tooltip: 'Criar Sigilo',
                    ),
                  ],
                ),
              ),
              maxLines: 2,
              onChanged: (_) => setState(() {}),
              onFieldSubmitted: (_) => _createSigil(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWheelCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Roda de Sigilo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.lilac,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _showGrid ? Icons.grid_on : Icons.grid_off,
                        color: _showGrid ? AppColors.lilac : AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _showGrid = !_showGrid;
                        });
                      },
                      tooltip: 'Grade',
                    ),
                    IconButton(
                      icon: Icon(
                        _showLetters ? Icons.abc : Icons.abc_outlined,
                        color: _showLetters ? AppColors.lilac : AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _showLetters = !_showLetters;
                        });
                      },
                      tooltip: 'Letras',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Roda com sigilo
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: SigilWheelWidget(
                  size: 300,
                  highlightedLetters: _sequence,
                  sigilPoints: _sigilPoints,
                  showGrid: _showGrid,
                  showLetters: _showLetters,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Legenda
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(AppColors.mint, 'Início'),
                const SizedBox(width: 24),
                _buildLegendItem(AppColors.starYellow, 'Caminho'),
                const SizedBox(width: 24),
                _buildLegendItem(AppColors.warning, 'Fim'),
              ],
            ),
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
            color: color.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações do Sigilo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.lilac,
              ),
            ),
            const SizedBox(height: 12),
            
            // Texto original
            _buildInfoRow(
              'Original:',
              _originalText,
              AppColors.textSecondary,
            ),
            
            // Texto processado
            _buildInfoRow(
              'Processado:',
              _processedText,
              AppColors.starYellow,
            ),
            
            // Sequência
            _buildInfoRow(
              'Sequência:',
              _sequence.join(' → '),
              AppColors.lilac,
            ),
            
            // Número de pontos
            _buildInfoRow(
              'Pontos:',
              '${_sigilPoints.length}',
              AppColors.mint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sigilPoints.isNotEmpty ? _saveSigil : null,
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar Sigilo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lilac,
                      foregroundColor: const Color(0xFF2B2143),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _sigilPoints.isNotEmpty ? _shareSignil : null,
                    icon: const Icon(Icons.share),
                    label: const Text('Compartilhar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.pinkWitch,
                      side: const BorderSide(color: AppColors.pinkWitch),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _sigilPoints.isNotEmpty ? _clearSigil : null,
              icon: const Icon(Icons.refresh),
              label: const Text('Limpar e Recomeçar'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareSignil() {
    // Implementar compartilhamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preparando sigilo para compartilhar...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Como criar um Sigilo',
          style: TextStyle(color: AppColors.lilac),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpStep(
                '1',
                'Defina sua intenção',
                'Escolha o que deseja manifestar ou proteger.',
              ),
              _buildHelpStep(
                '2',
                'Escreva uma frase',
                'Transforme sua intenção em palavras simples.',
              ),
              _buildHelpStep(
                '3',
                'Processo automático',
                'O app remove vogais repetidas e letras duplicadas.',
              ),
              _buildHelpStep(
                '4',
                'Visualize o sigilo',
                'As letras são conectadas na roda formando seu símbolo único.',
              ),
              _buildHelpStep(
                '5',
                'Ative o sigilo',
                'Salve, medite sobre ele ou use em seus rituais.',
              ),
              const SizedBox(height: 16),
              const Text(
                '💡 Dica: Sigilos funcionam melhor quando você esquece o significado original e foca apenas no símbolo.',
                style: TextStyle(
                  color: AppColors.starYellow,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpStep(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.lilac.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.lilac),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.lilac,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroductionCard() {
    // DEBUG: Confirmação de build
    debugPrint('🃏 Building Introduction Card with MagicalCard');

    return MagicalCard(
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
            'Defina sua intenção, escolha uma palavra ou frase que a represente, '
            'e o app criará automaticamente seu sigilo único na Roda Mágica.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }
}
