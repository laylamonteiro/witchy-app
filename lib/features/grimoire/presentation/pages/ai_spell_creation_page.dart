import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/ai/ai_service.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
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
    print('✨ AISpellCreationPage: Iniciando geração de feitiço...');

    if (_intentionController.text.trim().isEmpty) {
      print('⚠️ AISpellCreationPage: Texto vazio, abortando');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Descreva sua intenção primeiro'),
          backgroundColor: AppColors.alert,
        ),
      );
      return;
    }

    // Verificar limite diário para usuários free
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.currentUser.canUseAi) {
      print('⚠️ AISpellCreationPage: Limite diário atingido');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você atingiu o limite diário de consultas. Volte amanhã ou seja Premium!'),
          backgroundColor: AppColors.alert,
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

    print('📝 AISpellCreationPage: Intenção: "${_intentionController.text.trim()}"');

    setState(() {
      _isGenerating = true;
      _generatedSpell = null;
    });

    try {
      print('🤖 AISpellCreationPage: Chamando AIService.generateSpell...');
      final aiService = AIService.instance;
      final spell = await aiService.generateSpell(
        _intentionController.text.trim(),
      );

      print('✅ AISpellCreationPage: Feitiço gerado com sucesso!');
      print('   Nome: ${spell.name}');
      print('   Categoria: ${spell.category}');

      // Incrementar uso de IA
      await authProvider.incrementAiConsultations();

      if (!mounted) {
        print('⚠️ AISpellCreationPage: Widget não está montado, abortando');
        return;
      }

      setState(() {
        _generatedSpell = spell;
      });
      print('✅ AISpellCreationPage: Estado atualizado com feitiço');
    } catch (e, stackTrace) {
      print('❌ AISpellCreationPage: ERRO ao gerar feitiço: $e');
      print('📋 Stack trace: ${stackTrace.toString().split('\n').take(5).join('\n')}');

      if (!mounted) return;

      String errorMessage = 'O conselheiro não pôde manifestar o feitiço. Tente novamente mais tarde.';

      if (e.toString().contains('limit') || e.toString().contains('quota') || e.toString().contains('usage') || e.toString().contains('429')) {
        errorMessage = 'O conselheiro precisa de descanso. Muitos pedidos foram feitos. Por favor, aguarde alguns minutos.';
        print('⚠️ AISpellCreationPage: Limite de requisições atingido (429)');
      } else if (e.toString().contains('autenticação') || e.toString().contains('authentication') || e.toString().contains('401')) {
        errorMessage = 'Erro temporário no serviço místico. Tente novamente em instantes.';
        print('⚠️ AISpellCreationPage: Erro de autenticação (401)');
      } else if (e.toString().contains('network') || e.toString().contains('connection') || e.toString().contains('timeout')) {
        errorMessage = 'Erro de conexão. Verifique sua internet e tente novamente.';
        print('⚠️ AISpellCreationPage: Erro de rede/timeout');
      } else if (e.toString().contains('503')) {
        errorMessage = 'O portal místico está temporariamente fechado. Tente novamente em alguns minutos.';
        print('⚠️ AISpellCreationPage: Serviço indisponível (503)');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.alert,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        print('✅ AISpellCreationPage: Finalizou (isGenerating=false)');
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
    print('🎨 AISpellCreationPage.build: _isGenerating=$_isGenerating, _generatedSpell!=null=${_generatedSpell != null}, text.length=${_intentionController.text.length}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conselheiro Místico'),
        backgroundColor: AppColors.darkBackground,
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
                    'Compartilhe com o conselheiro místico o que você deseja manifestar. '
                    'Quanto mais detalhes, mais poderoso será o feitiço!',
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
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _isGenerating || _intentionController.text.trim().isEmpty
                  ? null
                  : _generateSpell,
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
              label: Text(_isGenerating ? 'Manifestando...' : 'Manifestar Feitiço ✨'),
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
                            style: const TextStyle(
                              color: AppColors.lilac,
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
                            color: AppColors.lilac.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _generatedSpell!.category.displayName,
                            style: const TextStyle(
                              color: AppColors.lilac,
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
                                ? AppColors.success.withOpacity(0.2)
                                : AppColors.alert.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
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
                    const SizedBox(height: 16),
                    Text(
                      _generatedSpell!.purpose,
                      style: TextStyle(
                        color: AppColors.softWhite.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SpellDetailPage(
                                    spell: _generatedSpell!,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.visibility, size: 18),
                            label: const Text('Detalhes', style: TextStyle(fontSize: 14)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.lilac,
                              side: const BorderSide(color: AppColors.lilac),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saveSpell,
                            icon: const Icon(Icons.save, size: 18),
                            label: const Text('Salvar', style: TextStyle(fontSize: 14)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lilac,
                              foregroundColor: AppColors.darkBackground,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                      ],
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
