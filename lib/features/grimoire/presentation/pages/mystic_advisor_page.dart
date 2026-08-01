import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/ai/ai_service.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../../core/services/ad_service.dart';

/// Conselheiro Místico: responde perguntas sobre bruxaria, magia e misticismo.
///
/// Formato pergunta -> resposta única. A resposta é revelada com efeito
/// "typewriter" para reforçar o ar de sabedoria de um oráculo que fala aos poucos.
class MysticAdvisorPage extends StatefulWidget {
  const MysticAdvisorPage({super.key});

  @override
  State<MysticAdvisorPage> createState() => _MysticAdvisorPageState();
}

class _MysticAdvisorPageState extends State<MysticAdvisorPage>
    with SingleTickerProviderStateMixin {
  final _questionController = TextEditingController();
  String? _answer;
  bool _isAsking = false;

  late final AnimationController _typeController;
  Animation<int>? _typedChars;

  @override
  void initState() {
    super.initState();
    // Listener para habilitar/desabilitar botão conforme usuário digita
    _questionController.addListener(() {
      setState(() {});
    });
    _typeController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _askAdvisor() async {
    // Esconder teclado
    FocusScope.of(context).unfocus();

    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).advisorAskFirst),
          backgroundColor: context.gc.alert,
        ),
      );
      return;
    }

    // Verificar limite diário para usuários free
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.currentUser.canUseAdvisor) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).advisorDailyLimit),
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
      _isAsking = true;
      _answer = null;
    });

    try {
      final aiService = AIService.instance;
      final answer = await aiService.answerMysticQuestion(
        _questionController.text.trim(),
      );

      // Incrementar uso do Conselheiro
      await authProvider.incrementAdvisorConsultations();

      if (!mounted) return;

      setState(() {
        _answer = answer;
      });
      _startTypewriter(answer);

      // Anúncio intersticial para usuários free (cooldown interno).
      AdService.instance.maybeShowInterstitial();
    } catch (e) {
      if (!mounted) return;

      String errorMessage =
          AppLocalizations.of(context).advisorGenericError;

      if (e.toString().contains('limit') ||
          e.toString().contains('quota') ||
          e.toString().contains('usage') ||
          e.toString().contains('429')) {
        errorMessage =
            AppLocalizations.of(context).advisorRateLimited;
      } else if (e.toString().contains('autenticação') ||
          e.toString().contains('authentication') ||
          e.toString().contains('401')) {
        errorMessage =
            AppLocalizations.of(context).advisorTempError;
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection') ||
          e.toString().contains('timeout')) {
        errorMessage =
            AppLocalizations.of(context).advisorConnectionError;
      } else if (e.toString().contains('503')) {
        errorMessage =
            AppLocalizations.of(context).advisorPortalClosed;
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
          _isAsking = false;
        });
      }
    }
  }

  /// Revela a resposta letra a letra, como um oráculo que fala aos poucos.
  void _startTypewriter(String text) {
    _typeController.stop();
    _typeController.duration =
        Duration(milliseconds: (text.length * 18).clamp(800, 6000));
    _typedChars = StepTween(begin: 0, end: text.length).animate(
      CurvedAnimation(parent: _typeController, curve: Curves.linear),
    );
    _typeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).profileMysticAdvisor),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 8),
                      const Text('🔮', style: TextStyle(fontSize: 80)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).advisorWisdomTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: context.gc.lilac,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).advisorIntro,
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
                controller: _questionController,
                style: TextStyle(color: context.gc.softWhite),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).advisorQuestionHint,
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
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed:
                  _isAsking || _questionController.text.trim().isEmpty
                      ? null
                      : _askAdvisor,
              icon: _isAsking
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
                  : const Icon(Icons.auto_stories),
              label: Text(
                  _isAsking ? AppLocalizations.of(context).advisorConsultingStars : AppLocalizations.of(context).advisorConsult),
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

            // Exibir consultas restantes para usuários free
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                if (authProvider.isPremium) return const SizedBox.shrink();
                final remaining =
                    authProvider.currentUser.remainingAdvisorConsultations;
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    AppLocalizations.of(context).advisorRemainingToday('$remaining/${UserModel.freeAdvisorConsultationsLimit}'),
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

            if (_answer != null) ...[
              const SizedBox(height: 24),
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🌙', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Text(
                          AppLocalizations.of(context).advisorAnswers,
                          style: TextStyle(
                            color: context.gc.lilac,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTypewriterAnswer(_answer!),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Resposta com efeito typewriter. A parte ainda não revelada permanece
  /// transparente no mesmo texto, preservando quebras e altura do layout.
  Widget _buildTypewriterAnswer(String text) {
    final style = TextStyle(
      color: context.gc.softWhite.withOpacity(0.9),
      fontSize: 15,
      height: 1.5,
    );

    final animation = _typedChars;
    if (animation == null) {
      return Text(text, style: style);
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final count = animation.value.clamp(0, text.length);
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(text: text.substring(0, count)),
              TextSpan(
                text: text.substring(count),
                style: const TextStyle(color: Colors.transparent),
              ),
            ],
          ),
          style: style,
        );
      },
    );
  }
}
