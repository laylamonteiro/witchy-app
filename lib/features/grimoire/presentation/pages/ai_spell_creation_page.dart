import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/ai/ai_service.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../providers/spell_provider.dart';
import '../../data/models/spell_model.dart';
import 'spell_detail_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../../auth/data/models/user_model.dart';

class AISpellCreationPage extends StatefulWidget {
  const AISpellCreationPage({super.key});

  @override
  State<AISpellCreationPage> createState() => _AISpellCreationPageState();
}

class _AISpellCreationPageState extends State<AISpellCreationPage> {
  final _intentionController = TextEditingController();
  SpellModel? _generatedSpell;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    // Listener para habilitar/desabilitar botão conforme usuário digita
    _intentionController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _intentionController.dispose();
    super.dispose();
  }

  Future<void> _generateSpell() async {
    // Esconder teclado
    FocusScope.of(context).unfocus();

    if (_intentionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Descreva sua intenção primeiro'),
          backgroundColor: context.gc.alert,
        ),
      );
      return;
    }

    // Verificar limite diário para usuários free
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.currentUser.canUseAi) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Você atingiu o limite diário de consultas. Volte amanhã ou seja Premium!'),
          backgroundColor: context.gc.alert,
          duration: Duration(seconds: 4),
        ),
      );
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const PremiumUpgradeSheet(),
      );
      return;
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

      // Incrementar uso de IA
      await authProvider.incrementAiConsultations();

      if (!mounted) return;

      setState(() {
        _generatedSpell = spell;
      });
    } catch (e, stackTrace) {
      if (!mounted) return;

      String errorMessage =
          'O conselheiro não pôde manifestar o feitiço. Tente novamente mais tarde.';

      if (e.toString().contains('limit') ||
          e.toString().contains('quota') ||
          e.toString().contains('usage') ||
          e.toString().contains('429')) {
        errorMessage =
            'O conselheiro precisa de descanso. Muitos pedidos foram feitos. Por favor, aguarde alguns minutos.';
      } else if (e.toString().contains('autenticação') ||
          e.toString().contains('authentication') ||
          e.toString().contains('401')) {
        errorMessage =
            'Erro temporário no serviço místico. Tente novamente em instantes.';
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection') ||
          e.toString().contains('timeout')) {
        errorMessage =
            'Erro de conexão. Verifique sua internet e tente novamente.';
      } else if (e.toString().contains('503')) {
        errorMessage =
            'O portal místico está temporariamente fechado. Tente novamente em alguns minutos.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: context.gc.alert,
          duration: const Duration(seconds: 5),
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
      SnackBar(
        content: Text('Feitiço salvo no seu grimório! ✨'),
        backgroundColor: context.gc.success,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ResponsiveAppBarTitle('Novo Feitiço'),
        backgroundColor: context.gc.darkBackground,
      ),
      backgroundColor: context.gc.darkBackground,
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
                          color: context.gc.lilac,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Compartilhe o que você deseja manifestar. '
                    'Quanto mais detalhes, mais poderoso será o feitiço!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.gc.softWhite.withOpacity(0.8),
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
                style: TextStyle(color: context.gc.softWhite),
                decoration: InputDecoration(
                  hintText: 'Ex: Quero atrair prosperidade financeira para '
                      'pagar minhas contas e ter mais tranquilidade',
                  hintStyle: TextStyle(
                    color: context.gc.softWhite.withOpacity(0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.gc.lilac),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: context.gc.lilac.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.gc.lilac),
                  ),
                ),
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed:
                  _isGenerating || _intentionController.text.trim().isEmpty
                      ? null
                      : _generateSpell,
              icon: _isGenerating
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.gc.darkBackground,
                        ),
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                  _isGenerating ? 'Manifestando...' : 'Manifestar Feitiço ✨'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.gc.lilac,
                foregroundColor: context.gc.darkBackground,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                disabledBackgroundColor: context.gc.lilac.withOpacity(0.3),
              ),
            ),

            // Exibir usos restantes para usuários free
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                if (authProvider.isPremium) return const SizedBox.shrink();
                final remaining =
                    authProvider.currentUser.remainingAiConsultations;
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Consultas restantes hoje: $remaining/${UserModel.freeAiConsultationsLimit}',
                    style: TextStyle(
                      color: remaining > 0
                          ? context.gc.softWhite.withOpacity(0.6)
                          : context.gc.alert,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),

            if (_generatedSpell != null) ...[
              const SizedBox(height: 24),
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🌟', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _generatedSpell!.name,
                            style: TextStyle(
                              color: context.gc.lilac,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: context.gc.lilac.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _generatedSpell!.category.displayName,
                            style: TextStyle(
                              color: context.gc.lilac,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _generatedSpell!.type == SpellType.attraction
                                ? context.gc.success.withOpacity(0.2)
                                : context.gc.alert.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _generatedSpell!.type.displayName,
                            style: TextStyle(
                              color:
                                  _generatedSpell!.type == SpellType.attraction
                                      ? context.gc.success
                                      : context.gc.alert,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _generatedSpell!.purpose,
                      style: TextStyle(
                        color: context.gc.softWhite.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SpellDetailPage(
                                spell: _generatedSpell!,
                                showSaveButton: true,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('Ver Detalhes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.gc.lilac,
                          foregroundColor: context.gc.darkBackground,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
