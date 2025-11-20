import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/ai/ai_service.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/spell_provider.dart';
import '../../data/models/spell_model.dart';
import 'spell_detail_page.dart';
import 'ai_config_page.dart';

class AISpellCreationPage extends StatefulWidget {
  const AISpellCreationPage({super.key});

  @override
  State<AISpellCreationPage> createState() => _AISpellCreationPageState();
}

class _AISpellCreationPageState extends State<AISpellCreationPage> {
  final _intentionController = TextEditingController();
  SpellModel? _generatedSpell;
  bool _isGenerating = false;
  bool _hasApiKey = false;

  @override
  void initState() {
    super.initState();
    _checkApiKey();
  }

  @override
  void dispose() {
    _intentionController.dispose();
    super.dispose();
  }

  Future<void> _checkApiKey() async {
    final hasKey = await AIService.instance.hasApiKey();
    setState(() {
      _hasApiKey = hasKey;
    });
  }

  Future<void> _generateSpell() async {
    if (_intentionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Descreva sua intenção primeiro'),
          backgroundColor: AppColors.alert,
        ),
      );
      return;
    }

    if (!_hasApiKey) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const AIConfigPage()),
      );

      if (result == true) {
        setState(() {
          _hasApiKey = true;
        });
      } else {
        return;
      }
    }

    setState(() {
      _isGenerating = true;
      _generatedSpell = null;
    });

    try {
      final aiService = AIService.instance;
      final spell = await aiService.generateSpell(
        _intentionController.text.trim(),
      );

      setState(() {
        _generatedSpell = spell;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar: $e'),
          backgroundColor: AppColors.alert,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _saveSpell() async {
    if (_generatedSpell == null) return;

    final provider = context.read<SpellProvider>();
    await provider.addSpell(_generatedSpell!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feitiço salvo no seu grimório! ✨'),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Feitiço com IA'),
        backgroundColor: AppColors.darkBackground,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const AIConfigPage()),
              );
              if (result == true) {
                _checkApiKey();
              }
            },
            tooltip: 'Configurar IA',
          ),
        ],
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
                  const Text('✨', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    'Descreva sua Intenção',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.lilac,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Conte ao assistente de IA o que você deseja manifestar. '
                    'Quanto mais detalhes, melhor!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.softWhite.withOpacity(0.8),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            MagicalCard(
              child: TextField(
                controller: _intentionController,
                style: const TextStyle(color: AppColors.softWhite),
                decoration: InputDecoration(
                  hintText: 'Ex: Quero atrair prosperidade financeira para '
                      'pagar minhas contas e ter mais tranquilidade',
                  hintStyle: TextStyle(
                    color: AppColors.softWhite.withOpacity(0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.lilac),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.lilac.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.lilac),
                  ),
                ),
                maxLines: 5,
              ),
            ),

            const SizedBox(height: 24),

            if (_generatedSpell == null)
              ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateSpell,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.darkBackground,
                          ),
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_isGenerating ? 'Gerando...' : 'Gerar Feitiço ✨'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lilac,
                  foregroundColor: AppColors.darkBackground,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  disabledBackgroundColor: AppColors.lilac.withOpacity(0.3),
                ),
              ),

            if (_generatedSpell != null) ...[
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _generatedSpell!.name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: AppColors.lilac,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _generatedSpell!.type == SpellType.attraction
                                ? AppColors.success.withOpacity(0.2)
                                : AppColors.alert.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _generatedSpell!.type.displayName,
                            style: TextStyle(
                              color: _generatedSpell!.type == SpellType.attraction
                                  ? AppColors.success
                                  : AppColors.alert,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _generatedSpell!.purpose,
                      style: const TextStyle(
                        color: AppColors.softWhite,
                        fontSize: 14,
                      ),
                    ),
                    const Divider(color: AppColors.lilac),
                    Text(
                      'Categoria: ${_generatedSpell!.category.displayName}',
                      style: TextStyle(
                        color: AppColors.softWhite.withOpacity(0.7),
                      ),
                    ),
                    if (_generatedSpell!.moonPhase != null)
                      Text(
                        'Lua: ${_generatedSpell!.moonPhase}',
                        style: TextStyle(
                          color: AppColors.softWhite.withOpacity(0.7),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'Ingredientes:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.lilac,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ..._generatedSpell!.ingredients.map((ingredient) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '• $ingredient',
                          style: const TextStyle(color: AppColors.softWhite),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    Text(
                      'Passos:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.lilac,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _generatedSpell!.steps,
                      style: const TextStyle(
                        color: AppColors.softWhite,
                        height: 1.5,
                      ),
                    ),
                    if (_generatedSpell!.observations != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Observações:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.lilac,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _generatedSpell!.observations!,
                        style: TextStyle(
                          color: AppColors.softWhite.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _generatedSpell = null;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Gerar Outro'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.lilac,
                        side: const BorderSide(color: AppColors.lilac),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveSpell,
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.darkBackground,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
