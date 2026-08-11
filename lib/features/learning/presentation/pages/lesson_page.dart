import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../diary/data/models/affirmation_model.dart';
import '../../../diary/data/models/desire_model.dart';
import '../../../diary/data/models/dream_model.dart';
import '../../../diary/data/models/gratitude_model.dart';
import '../../../diary/presentation/pages/affirmation_form_page.dart';
import '../../../diary/presentation/pages/desire_form_page.dart';
import '../../../diary/presentation/pages/dream_form_page.dart';
import '../../../diary/presentation/pages/gratitude_form_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../../diary/presentation/providers/affirmation_provider.dart';
import '../../../diary/presentation/providers/desire_provider.dart';
import '../../../diary/presentation/providers/dream_provider.dart';
import '../../../diary/presentation/providers/gratitude_provider.dart';
import '../../../divination/presentation/pages/oracle_cards_page.dart';
import '../../../divination/presentation/pages/pendulum_page.dart';
import '../../../encyclopedia/data/models/user_entry_model.dart';
import '../../../encyclopedia/presentation/pages/add_entry_page.dart';
import '../../../encyclopedia/presentation/pages/colors_list_page.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../../grimoire/presentation/pages/spell_detail_page.dart';
import '../../../grimoire/presentation/pages/record_detail_page.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/presentation/providers/free_writing_provider.dart';
import '../../../grimoire/presentation/providers/spell_provider.dart';
import '../../../palmistry/presentation/pages/palmistry_page.dart';
import '../../../runes/presentation/pages/rune_reading_page.dart';
import '../../../sigils/presentation/pages/sigil_step1_intention_page.dart';
import '../../../tarot/presentation/pages/tarot_learn_tab.dart';
import '../../../tarot/presentation/pages/tarot_library_page.dart';
import '../../../tarot/presentation/pages/tarot_page.dart';
import '../../data/models/trail_model.dart';
import '../providers/learning_provider.dart';

/// Uma lição do Grimório Vivo em três atos:
/// 1) Ensino  2) Prática  3) A Página (preenchimento guiado, campo a campo).
///
/// Cada lição registra a página no lugar certo do app (feitiço, registro,
/// diários ou junto de uma ferramenta), levando a pessoa a usar todas as
/// funcionalidades naturalmente.
class LessonPage extends StatefulWidget {
  final LearningTrail trail;
  final TrailLesson lesson;

  const LessonPage({super.key, required this.trail, required this.lesson});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  int _step = 0; // 0 ensino · 1 prática · 2 página
  bool _practiceDone = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Gate central: só a 1ª lição de cada trilha é gratuita. Qualquer
    // caminho que chegue aqui (trilha, card do Seu Dia, futuros atalhos)
    // passa pela mesma porta — free vê o paywall e a página se fecha.
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureAccess());
  }

  Future<void> _ensureAccess() async {
    if (!mounted) return;
    final index =
        widget.trail.lessons.indexWhere((l) => l.id == widget.lesson.id);
    final isPremium = context.read<AuthProvider>().isPremiumEffective;
    if (index > 0 && !isPremium) {
      await showPaywallThenPop(context);
    }
  }

  late final _titleController =
      TextEditingController(text: widget.lesson.pageTitle);
  late final List<TextEditingController> _promptControllers = [
    for (final _ in widget.lesson.pagePrompts) TextEditingController(),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    for (final c in _promptControllers) {
      c.dispose();
    }
    super.dispose();
  }

  /// Monta o conteúdo final da página: pergunta + resposta, na voz da pessoa.
  String _assemblePage() {
    final buffer = StringBuffer();
    for (var i = 0; i < widget.lesson.pagePrompts.length; i++) {
      final answer = _promptControllers[i].text.trim();
      buffer.writeln('✦ ${widget.lesson.pagePrompts[i]}');
      buffer.writeln(
          answer.isEmpty ? AppLocalizations.of(context).learnToFill : answer);
      if (i != widget.lesson.pagePrompts.length - 1) buffer.writeln();
    }
    return buffer.toString();
  }

  /// Só as respostas, sem as perguntas (para afirmações).
  String _answersOnly() => [
        for (final c in _promptControllers)
          if (c.text.trim().isNotEmpty) c.text.trim(),
      ].join('\n');

  bool get _hasAnyAnswer =>
      _promptControllers.any((c) => c.text.trim().isNotEmpty);

  String get _pageTitle => _titleController.text.trim().isEmpty
      ? widget.lesson.pageTitle
      : _titleController.text.trim();

  /// Nome do destino da página, para a pessoa saber onde vai encontrá-la.
  String _placeName(AppLocalizations l10n) => switch (widget.lesson.recordKind) {
        LessonRecordKind.spell => l10n.grimoireMySpells,
        LessonRecordKind.dream => l10n.learnPlaceDreams,
        LessonRecordKind.gratitude => l10n.learnPlaceGratitude,
        LessonRecordKind.affirmation => l10n.learnPlaceAffirmations,
        LessonRecordKind.desire => l10n.learnPlaceDesires,
        _ => l10n.grimoireMyRecords,
      };

  /// Nome e página da ferramenta usada na lição (quando houver).
  ///
  /// O destino vem de [TrailLesson.toolTarget]: a lição pode apontar para
  /// a funcionalidade exata de que a prática precisa (ex.: Biblioteca de
  /// Cartas, Tutor de Tarot) em vez da página genérica da ferramenta.
  (String, WidgetBuilder)? _toolFor(AppLocalizations l10n) =>
      switch (widget.lesson.toolTarget) {
        LessonTool.sigils => (
            l10n.toolSigilsTitle,
            (_) => const SigilStep1IntentionPage()
          ),
        LessonTool.runes => (
            l10n.toolRunesTitle,
            (_) => const RuneReadingPage()
          ),
        LessonTool.oracle => (
            l10n.toolOracleTitle,
            (_) => const OracleCardsPage()
          ),
        LessonTool.pendulum => (
            l10n.toolPendulumTitle,
            (_) => const PendulumPage()
          ),
        LessonTool.tarot => (
            l10n.toolTarotTitle,
            (_) => const TarotPage()
          ),
        LessonTool.tarotLibrary => (
            l10n.tarotLibraryTitle,
            (_) => const TarotLibraryPage()
          ),
        LessonTool.tarotTutor => (
            l10n.tarotTutorTitle,
            (_) => const TarotQuizPage()
          ),
        LessonTool.palmistry => (
            l10n.toolPalmistryTitle,
            (_) => const PalmistryPage()
          ),
        // Enciclopédia pessoal: a prática identifica uma planta/pedra
        // por foto e cria o verbete próprio (a página gera o paywall para
        // quem é free — o atalho pode abrir direto).
        LessonTool.addHerb => (
            l10n.encyAddTitle(l10n.encyTabHerbs),
            (_) => const AddEntryPage(category: UserEntryCategory.herb)
          ),
        LessonTool.addCrystal => (
            l10n.encyAddTitle(l10n.encyTabCrystals),
            (_) => const AddEntryPage(category: UserEntryCategory.crystal)
          ),
        // Cores não têm mais identificação por foto: o atalho leva ao
        // catálogo oficial (roda + páginas completas).
        LessonTool.addColor => (
            l10n.encyTabColors,
            (_) => Scaffold(
                  appBar: AppBar(
                    title: ResponsiveAppBarTitle(l10n.encyTabColors),
                  ),
                  body: const ColorsListPage(),
                )
          ),
        null => null,
      };

  /// Salva a página no destino certo e devolve o builder da tela do registro.
  Future<WidgetBuilder> _saveRecord() async {
    final lesson = widget.lesson;
    final content = _assemblePage();

    switch (lesson.recordKind) {
      case LessonRecordKind.dream:
        final dream = DreamModel(
          title: _pageTitle,
          content: content,
          tags: const ['grimório-vivo'],
          date: DateTime.now(),
        );
        await context.read<DreamProvider>().addDream(dream);
        return (_) => DreamFormPage(dream: dream);

      case LessonRecordKind.gratitude:
        final gratitude = GratitudeModel(
          title: _pageTitle,
          content: content,
          tags: const ['grimório-vivo'],
          date: DateTime.now(),
        );
        await context.read<GratitudeProvider>().addGratitude(gratitude);
        return (_) => GratitudeFormPage(gratitude: gratitude);

      case LessonRecordKind.affirmation:
        final affirmation = AffirmationModel(
          text: _answersOnly(),
          category: AffirmationCategory.healing,
        );
        await context.read<AffirmationProvider>().addAffirmation(affirmation);
        return (_) => AffirmationFormPage(affirmation: affirmation);

      case LessonRecordKind.desire:
        final desire = DesireModel(
          title: _pageTitle,
          description: content,
        );
        await context.read<DesireProvider>().addDesire(desire);
        return (_) => DesireFormPage(desire: desire);

      case LessonRecordKind.spell:
        final spell = SpellModel(
          name: _pageTitle,
          purpose: lesson.pagePurpose,
          type: lesson.pageType,
          category: lesson.pageCategory,
          ingredients: lesson.pageIngredients,
          steps: content,
          observations: AppLocalizations.of(context)
              .learnPageNote(widget.trail.title, lesson.title),
        );
        await context.read<SpellProvider>().addSpell(spell);
        return (_) => SpellDetailPage(spell: spell);

      default:
        // Página de estudo/reflexão: entra no acervo "Meus Registros"
        // (free_writings), com a nota da trilha abrindo o conteúdo.
        final note = AppLocalizations.of(context)
            .learnPageNote(widget.trail.title, lesson.title);
        final entry = FreeWritingModel(
          userId: context.read<AuthProvider>().currentUser.id,
          title: _pageTitle,
          content: '$note\n\n$content',
          source: FreeWritingSource.grimorioVivo,
        );
        await context.read<FreeWritingProvider>().save(entry);
        return (_) => RecordDetailPage(entry: entry);
    }
  }

  Future<void> _writePage() async {
    if (_isSaving) return;
    if (!_hasAnyAnswer) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).learnFillAtLeastOne),
          backgroundColor: context.gc.warning,
        ),
      );
      return;
    }
    setState(() => _isSaving = true);

    try {
      final recordBuilder = await _saveRecord();
      if (!mounted) return;
      final reward = await context
          .read<LearningProvider>()
          .markCompleted(widget.trail, widget.lesson.id);

      if (!mounted) return;
      final navigator = Navigator.of(context);
      await _celebrate(reward);
      if (!mounted) return;
      // "Que assim seja" leva direto ao registro criado.
      navigator.pop();
      navigator.push(MaterialPageRoute(builder: recordBuilder));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'.replaceAll('Exception: ', '')),
          backgroundColor: context.gc.alert,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Selo de conclusão: XP ganho, subida de nível e encadernação da trilha.
  Future<void> _celebrate(LessonReward reward) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: dialogContext.gc.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: reward.trailBound
                  ? dialogContext.gc.starYellow
                  : dialogContext.gc.lilac,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (reward.trailBound
                        ? dialogContext.gc.starYellow
                        : dialogContext.gc.lilac)
                    .withValues(alpha: 0.35),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.4, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Text(
                  reward.trailBound ? '📕' : '📜',
                  style: const TextStyle(fontSize: 64),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                reward.trailBound
                    ? AppLocalizations.of(context).learnTrailBound
                    : AppLocalizations.of(context).learnPageDone,
                style: Theme.of(dialogContext)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: dialogContext.gc.lilac),
              ),
              const SizedBox(height: 8),
              if (reward.xpGained > 0)
                Text(
                  '+${reward.xpGained} XP',
                  style: TextStyle(
                    color: dialogContext.gc.starYellow,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (reward.trailBound) ...[
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)
                      .learnChapterBound(widget.trail.title),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: dialogContext.gc.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
              if (reward.leveledUpTo != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: dialogContext.gc.lilac.withValues(alpha: 0.15),
                  ),
                  child: Text(
                    '${reward.leveledUpTo!.emoji} ${AppLocalizations.of(context).learnNewTitle}: '
                    '${reward.leveledUpTo!.title}',
                    style: TextStyle(
                      color: dialogContext.gc.lilac,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(AppLocalizations.of(context).learnSoBeIt),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // O gesto de voltar percorre os passos antes de sair da lição.
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _step--);
      },
      child: Scaffold(
        appBar: AppBar(
          title: ResponsiveAppBarTitle(widget.lesson.title),
        ),
        body: Column(
          children: [
            _buildLessonHeader(context),
            _buildStepper(context),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: switch (_step) {
                  0 => _buildTeaching(context),
                  1 => _buildPractice(context),
                  _ => _buildPage(context),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Cabeçalho persistente da lição: título completo (o do AppBar pode
  /// truncar), posição na trilha e o XP que a conclusão vale — visível em
  /// TODOS os passos, não só no Ensino.
  Widget _buildLessonHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final index =
        widget.trail.lessons.indexWhere((l) => l.id == widget.lesson.id);
    final total = widget.trail.lessons.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(context.gc.surface, context.gc.lilac, 0.22)!,
            Color.lerp(context.gc.surface, context.gc.pink, 0.18)!,
          ],
        ),
        border: Border.all(color: context.gc.lilac.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(widget.trail.emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.lesson.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: context.gc.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.learnLessonOfTrail(index + 1, total)} · '
                      '${widget.trail.title}',
                      style: TextStyle(
                        color: context.gc.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: context.gc.starYellow.withValues(alpha: 0.15),
                ),
                child: Text(
                  '+${LearningProvider.xpPerPage} XP',
                  style: TextStyle(
                    color: context.gc.starYellow,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progresso na trilha: a lição atual pintada sobre o total.
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : (index + 1) / total,
              minHeight: 3,
              backgroundColor: context.gc.surfaceBorder,
              valueColor: AlwaysStoppedAnimation(context.gc.lilac),
            ),
          ),
        ],
      ),
    );
  }

  /// Toque nos passos: voltar é livre, a Prática é sempre acessível e A
  /// Página exige a prática marcada — com aviso em vez de toque morto.
  void _onStepTap(int i) {
    if (i == _step) return;
    if (i <= 1 || _practiceDone) {
      setState(() => _step = i);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).learnCompletePracticeFirst),
        backgroundColor: context.gc.warning,
      ),
    );
  }

  Widget _buildStepper(BuildContext context) {
    final labels = [
      AppLocalizations.of(context).learnStepTeaching,
      AppLocalizations.of(context).learnStepPractice,
      AppLocalizations.of(context).learnStepPage,
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            Expanded(
              child: InkWell(
                onTap: () => _onStepTap(i),
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Bolinha numerada: check nos passos concluídos,
                        // preenchida no atual — "onde estou" deixa de
                        // parecer barra de progresso.
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < _step
                                ? context.gc.mint.withValues(alpha: 0.18)
                                : i == _step
                                    ? context.gc.lilac
                                    : Colors.transparent,
                            border: Border.all(
                              color: i < _step
                                  ? context.gc.mint
                                  : i == _step
                                      ? context.gc.lilac
                                      : context.gc.surfaceBorder,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: i < _step
                                ? Icon(Icons.check,
                                    size: 12, color: context.gc.mint)
                                : Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: i == _step
                                          ? context.gc.onPrimary
                                          : context.gc.textSecondary,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            labels[i],
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: i == _step
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: i <= _step
                                  ? context.gc.lilac
                                  : context.gc.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: i <= _step
                            ? context.gc.lilac
                            : context.gc.surfaceBorder,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (i != labels.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }

  Widget _buildTeaching(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final paragraphs = widget.lesson.teaching
        .split('\n\n')
        .where((p) => p.trim().isNotEmpty)
        .toList();
    final sectionTitles = [
      l10n.learnSection1,
      l10n.learnSection2,
      l10n.learnSection3,
      l10n.learnSection4,
    ];
    final accents = [
      context.gc.lilac,
      context.gc.mint,
      context.gc.pink,
      context.gc.starYellow,
    ];
    const sectionEmojis = ['🕯️', '🌙', '✨', '🔮'];

    return SingleChildScrollView(
      key: const ValueKey('teaching'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Parágrafos do ensino em seções coloridas com título (o
          // cabeçalho da lição vive acima do stepper, em todos os passos)
          for (var i = 0; i < paragraphs.length; i++)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color.lerp(
                        context.gc.surface, accents[i % accents.length], 0.07),
                    border: Border(
                      left: BorderSide(
                        color: accents[i % accents.length],
                        width: 3,
                      ),
                      top: BorderSide(color: context.gc.surfaceBorder),
                      right: BorderSide(color: context.gc.surfaceBorder),
                      bottom: BorderSide(color: context.gc.surfaceBorder),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${sectionEmojis[i % sectionEmojis.length]} '
                        '${sectionTitles[i % sectionTitles.length]}',
                        style: TextStyle(
                          color: accents[i % accents.length],
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        paragraphs[i],
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(height: 1.6, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _step = 1),
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: Text(AppLocalizations.of(context).learnGoToPractice),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Seção destacada do passo Prática, no mesmo padrão visual das seções
  /// do Ensino (borda lateral colorida + título com emoji).
  Widget _practiceSection(
    BuildContext context, {
    required Color accent,
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color.lerp(context.gc.surface, accent, 0.07),
            border: Border(
              left: BorderSide(color: accent, width: 3),
              top: BorderSide(color: context.gc.surfaceBorder),
              right: BorderSide(color: context.gc.surfaceBorder),
              bottom: BorderSide(color: context.gc.surfaceBorder),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }

  /// Quebra o "Como fazer" em passos numerados escaneáveis. As práticas
  /// são redigidas como frases sequenciais ("Primeiro... Depois... Por
  /// fim..."); com 3+ frases, a lista numerada é mais fácil de seguir do
  /// que o parágrafo corrido. Textos curtos ou já estruturados pelo autor
  /// (com quebras de linha) permanecem como estão.
  static List<String>? _practiceStepsOf(String text) {
    if (text.contains('\n')) return null;
    final sentences = text
        .split(RegExp(r'(?<=[.!?…])\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (sentences.length < 3) return null;
    return [
      // Sem ponto final no fim de cada passo (padrão de texto do app).
      for (final s in sentences) s.replaceFirst(RegExp(r'\.$'), ''),
    ];
  }

  Widget _practiceStepRow(BuildContext context, int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.gc.mint.withValues(alpha: 0.15),
              border: Border.all(
                color: context.gc.mint.withValues(alpha: 0.6),
              ),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: context.gc.mint,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.5, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPractice(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tool = _toolFor(l10n);
    final steps = _practiceStepsOf(widget.lesson.practice);

    return SingleChildScrollView(
      key: const ValueKey('practice'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🎯 Objetivo: o que esta prática quer alcançar.
          _practiceSection(
            context,
            accent: context.gc.lilac,
            title: '🎯 ${l10n.learnPracticeGoal}',
            child: Text(
              widget.lesson.pagePurpose,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.5, fontSize: 15),
            ),
          ),
          // 🕯️ Como fazer: a prática em si (+ atalho da ferramenta).
          _practiceSection(
            context,
            accent: context.gc.mint,
            title: '🕯️ ${l10n.learnPracticeHow}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (steps != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < steps.length; i++)
                        _practiceStepRow(context, i + 1, steps[i]),
                    ],
                  )
                else
                  Text(
                    widget.lesson.practice,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.6, fontSize: 15),
                  ),
                if (tool != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: context.gc.lilac.withValues(alpha: 0.10),
                      border: Border.all(
                        color: context.gc.lilac.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.learnToolHint,
                          style: TextStyle(
                            color: context.gc.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: tool.$2),
                          ),
                          icon: const Icon(Icons.auto_fix_high, size: 16),
                          label: Text(l10n.learnOpenTool(tool.$1)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // ✍️ Depois: a página que a lição cria e onde ela fica guardada.
          _practiceSection(
            context,
            accent: context.gc.pink,
            title: '✍️ ${l10n.learnPracticeThen}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.learnCreatesPage(widget.lesson.pageTitle),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.bookmark_border,
                        size: 15, color: context.gc.mint),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.learnSavesTo(_placeName(l10n)),
                        style: TextStyle(
                          color: context.gc.mint,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            // O check é o portão do próximo passo: ganha moldura própria
            // (menta quando marcado) e resposta tátil, para a ligação com
            // o botão abaixo ficar visível.
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _practiceDone
                    ? context.gc.mint.withValues(alpha: 0.08)
                    : context.gc.lilac.withValues(alpha: 0.06),
                border: Border.all(
                  color: _practiceDone
                      ? context.gc.mint.withValues(alpha: 0.55)
                      : context.gc.lilac.withValues(alpha: 0.35),
                ),
              ),
              child: CheckboxListTile(
                value: _practiceDone,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  setState(() => _practiceDone = v ?? false);
                },
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8),
                activeColor: context.gc.mint,
                title: Text(
                  l10n.learnDidPractice,
                  style: TextStyle(
                    color: context.gc.textPrimary,
                    fontSize: 14,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed:
                  _practiceDone ? () => setState(() => _step = 2) : null,
              icon: const Icon(Icons.edit, size: 18),
              label: Text(l10n.learnWriteMyPage),
            ),
          ),
          if (!_practiceDone) ...[
            const SizedBox(height: 6),
            // Explica o botão desabilitado em vez de deixá-lo mudo.
            Text(
              l10n.learnMarkPracticeHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.gc.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      key: const ValueKey('page'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.learnAnswerHelp,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.bookmark_border,
                        size: 15, color: context.gc.mint),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.learnSavesTo(_placeName(l10n)),
                        style: TextStyle(
                          color: context.gc.mint,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                      labelText: l10n.learnPageTitleLabel),
                ),
                for (var i = 0; i < widget.lesson.pagePrompts.length; i++) ...[
                  const SizedBox(height: 14),
                  Text(
                    '✦ ${widget.lesson.pagePrompts[i]}',
                    style: TextStyle(
                      color: context.gc.lilac,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _promptControllers[i],
                    maxLines: null,
                    minLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: l10n.learnWriteHere,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _writePage,
                    icon: _isSaving
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.gc.onPrimary,
                            ),
                          )
                        : const Icon(Icons.menu_book, size: 18),
                    // A recompensa aparece na hora da decisão, não só no
                    // selo de conclusão. FittedBox: o rótulo encolhe o
                    // necessário para ficar SEMPRE em uma linha.
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${l10n.learnSealPage} · +${LearningProvider.xpPerPage} XP',
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
