import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../../grimoire/presentation/providers/spell_provider.dart';
import '../../data/models/trail_model.dart';
import '../providers/learning_provider.dart';

/// Uma lição do Grimório Vivo em três atos:
/// 1) Ensino  2) Prática  3) A Página (preenchimento guiado, campo a campo).
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
      buffer.writeln(answer.isEmpty ? '(a preencher)' : answer);
      if (i != widget.lesson.pagePrompts.length - 1) buffer.writeln();
    }
    return buffer.toString();
  }

  Future<void> _writePage() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final lesson = widget.lesson;
      final spell = SpellModel(
        name: _titleController.text.trim().isEmpty
            ? lesson.pageTitle
            : _titleController.text.trim(),
        purpose: lesson.pagePurpose,
        type: lesson.pageType,
        category: lesson.pageCategory,
        ingredients: lesson.pageIngredients,
        steps: _assemblePage(),
        observations:
            'Página do Grimório Vivo — ${widget.trail.title} · ${lesson.title}',
      );
      await context.read<SpellProvider>().addSpell(spell);
      final reward = await context
          .read<LearningProvider>()
          .markCompleted(widget.trail, lesson.id);

      if (!mounted) return;
      await _celebrate(reward);
      if (mounted) Navigator.of(context).pop();
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
                    ? 'Trilha Encadernada!'
                    : 'Página escrita!',
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
                  'O capítulo "${widget.trail.title}" agora é um livro '
                  'encadernado no seu grimório — escrito por você.',
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
                    '${reward.leveledUpTo!.emoji} Novo título: '
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
                child: const Text('Que assim seja ✨'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(widget.lesson.title),
      ),
      body: Column(
        children: [
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
    );
  }

  Widget _buildStepper(BuildContext context) {
    const labels = ['📜 Ensino', '🕯️ Prática', '✍️ A Página'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            Expanded(
              child: Column(
                children: [
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          i == _step ? FontWeight.bold : FontWeight.normal,
                      color: i <= _step
                          ? context.gc.lilac
                          : context.gc.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 4,
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
            if (i != labels.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }

  Widget _buildTeaching(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('teaching'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MagicalCard(
            child: Text(
              widget.lesson.teaching,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.6, fontSize: 15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _step = 1),
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Ir para a prática'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPractice(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('practice'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lesson.practice,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                      ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: _practiceDone,
                  onChanged: (v) =>
                      setState(() => _practiceDone = v ?? false),
                  contentPadding: EdgeInsets.zero,
                  activeColor: context.gc.lilac,
                  title: Text(
                    'Fiz a prática (ou vou fazer hoje)',
                    style: TextStyle(
                      color: context.gc.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed:
                  _practiceDone ? () => setState(() => _step = 2) : null,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Escrever minha página'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
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
                  'Responda com as suas palavras — o app monta a página e '
                  'guarda no Meu Grimório. Ela é sua para sempre.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration:
                      const InputDecoration(labelText: 'Título da página'),
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
                    decoration: const InputDecoration(
                      hintText: 'Escreva aqui…',
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
                    label: const Text('Selar página no grimório'),
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
