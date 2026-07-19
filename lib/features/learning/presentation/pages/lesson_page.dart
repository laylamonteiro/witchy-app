import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../../grimoire/presentation/providers/spell_provider.dart';
import '../../data/models/trail_model.dart';
import '../providers/learning_provider.dart';

/// Uma lição do Grimório Vivo: ensino -> prática -> escrever a página.
class LessonPage extends StatefulWidget {
  final LearningTrail trail;
  final TrailLesson lesson;

  const LessonPage({super.key, required this.trail, required this.lesson});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  late final _titleController =
      TextEditingController(text: widget.lesson.pageTitle);
  late final _stepsController =
      TextEditingController(text: widget.lesson.pageStepsTemplate);
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _stepsController.dispose();
    super.dispose();
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
        steps: _stepsController.text,
        observations:
            'Página do Grimório Vivo — ${widget.trail.title} · ${lesson.title}',
      );
      await context.read<SpellProvider>().addSpell(spell);
      await context.read<LearningProvider>().markCompleted(lesson.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Página escrita no seu grimório! 📖✨'),
          backgroundColor: context.gc.success,
        ),
      );
      Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final completed =
        context.watch<LearningProvider>().isLessonCompleted(lesson.id);

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(lesson.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📜 Ensino',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.gc.lilac,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    lesson.teaching,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.55),
                  ),
                ],
              ),
            ),
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🕯️ Prática',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.gc.starYellow,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    lesson.practice,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.5, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✍️ Escreva a sua página',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.gc.lilac,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Esta página será salva no Meu Grimório — ela é sua, '
                    'edite à vontade. Os "___" são os espaços para você '
                    'preencher agora ou depois.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration:
                        const InputDecoration(labelText: 'Título da página'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _stepsController,
                    maxLines: null,
                    minLines: 6,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Conteúdo da página',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                          : Icon(
                              completed
                                  ? Icons.library_add
                                  : Icons.menu_book,
                              size: 18,
                            ),
                      label: Text(
                        completed
                            ? 'Escrever outra versão'
                            : 'Escrever no meu grimório',
                      ),
                    ),
                  ),
                  if (completed) ...[
                    const SizedBox(height: 8),
                    Text(
                      '✓ Lição concluída — a página está no Meu Grimório.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.gc.success,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
