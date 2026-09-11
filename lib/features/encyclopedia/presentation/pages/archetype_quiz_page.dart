import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/data_sources/arcane_categories.dart';
import '../../data/data_sources/archetype_quiz_data.dart';
import '../../data/data_sources/archetypes_data.dart';
import '../../data/models/arcane_entry_model.dart';
import '../widgets/archetype_constellation.dart';
import 'arcane_detail_page.dart';

/// Teste de Arquétipo: 8 perguntas, resultado abre o verbete da Enciclopédia.
///
/// As perguntas vêm de `archetype_quiz_data.dart` (ContentLocale, pt/en/es).
/// A pontuação e a persistência usam o EMOJI do arquétipo como chave — o
/// emoji é invariante entre idiomas, então o resultado sobrevive a trocas de
/// idioma (os nomes são traduzidos e não servem de chave).
class ArchetypeQuizPage extends StatefulWidget {
  const ArchetypeQuizPage({super.key});

  @override
  State<ArchetypeQuizPage> createState() => _ArchetypeQuizPageState();
}

class _ArchetypeQuizPageState extends State<ArchetypeQuizPage> {
  static const _resultKey = 'archetype_result';
  static const _topThreeKey = 'archetype_top3';
  static const _dateKey = 'archetype_date';

  int _index = 0;
  final Map<String, int> _scores = {};
  List<MapEntry<String, int>> _topThree = [];
  ArcaneEntry? _result;
  String? _savedDate;

  /// A constelação e a revelação só acontecem na sessão que acabou de
  /// terminar; um resultado guardado abre direto no estado final.
  bool _justFinished = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  /// Resolve a chave persistida (emoji ou, em registros antigos, o nome em
  /// português) para o verbete no idioma atual.
  ArcaneEntry _entryForKey(String key) {
    return archetypesData.firstWhere(
      (e) => e.emoji == key || e.name == key,
      orElse: () => archetypesData.first,
    );
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_resultKey);
    if (saved == null || !mounted) return;
    setState(() {
      _result = _entryForKey(saved);
      _topThree = (prefs.getStringList(_topThreeKey) ?? [])
          .map((raw) {
            final parts = raw.split('|');
            return MapEntry(parts.first, int.tryParse(parts.last) ?? 0);
          })
          .toList();
      _savedDate = prefs.getString(_dateKey);
    });
  }

  /// Grava o resultado e devolve a data gravada, ou null se a gravação
  /// falhou — a tela só mostra a data que existe de verdade no aparelho.
  Future<String?> _persist(String winnerEmoji) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final date = '${now.day.toString().padLeft(2, '0')}/'
          '${now.month.toString().padLeft(2, '0')}/${now.year}';
      await prefs.setString(_resultKey, winnerEmoji);
      await prefs.setStringList(
        _topThreeKey,
        [for (final e in _topThree) '${e.key}|${e.value}'],
      );
      await prefs.setString(_dateKey, date);
      return date;
    } catch (_) {
      return null;
    }
  }

  Future<void> _answer(ArchetypeQuizOption option) async {
    _scores[option.archetypeEmoji] =
        (_scores[option.archetypeEmoji] ?? 0) + 1;

    if (_index < archetypeQuizQuestions.length - 1) {
      setState(() => _index++);
      return;
    }

    // Cada resposta soma 1 ponto ao arquétipo correspondente; vence o de
    // maior pontuação (empate: o que atingiu a pontuação primeiro). A
    // contagem é a de sempre: a constelação apenas desenha o que ela deu.
    final winner = _scores.entries
        .reduce((a, b) => b.value > a.value ? b : a)
        .key;
    _topThree = (_scores.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(3)
        .toList();
    // Guardar primeiro, revelar depois: o resultado que aparece é o que
    // ficou no aparelho. O teste tem progresso próprio e não entra no XP.
    final date = await _persist(winner);
    if (!mounted) return;
    setState(() {
      _savedDate = date;
      _justFinished = true;
      _result = _entryForKey(winner);
    });
  }

  void _restart() {
    setState(() {
      _index = 0;
      _scores.clear();
      _topThree = [];
      _result = null;
      _savedDate = null;
      _justFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).quizTitle),
      ),
      body: _result != null ? _buildResult(_result!) : _buildQuestion(),
    );
  }

  Widget _buildQuestion() {
    final questions = archetypeQuizQuestions;
    final question = questions[_index];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(
            value: (_index + 1) / questions.length,
            backgroundColor: context.gc.surfaceBorder,
            valueColor: AlwaysStoppedAnimation(context.gc.lilac),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)
                .quizProgress('${_index + 1}', '${questions.length}'),
            textAlign: TextAlign.center,
            style: TextStyle(color: context.gc.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 20),
          Text(
            question.text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: context.gc.textPrimary,
                ),
          ),
          const SizedBox(height: 20),
          for (final option in question.options)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => _answer(option),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.gc.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.gc.surfaceBorder),
                  ),
                  child: Text(
                    option.text,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.4),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResult(ArcaneEntry result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MagicalCard(
            child: Column(
              children: [
                // A constelação da sessão: uma estrela por arquétipo tocado
                // pelas respostas, ligadas na ordem do céu. Sem sorteio: as
                // mesmas respostas dão sempre a mesma figura.
                if (_scores.isNotEmpty)
                  Semantics(
                    label: AppLocalizations.of(context).quizConstellationLabel,
                    child: ArchetypeConstellation(
                      scores: Map<String, int>.from(_scores),
                      order: [for (final entry in archetypesData) entry.emoji],
                      winner: result.emoji,
                      animate: _justFinished,
                    ),
                  ),
                _Reveal(
                  play: _justFinished,
                  child: Text(result.emoji, style: const TextStyle(fontSize: 56)),
                ),
                const SizedBox(height: 12),
                if (_savedDate != null) ...[
                  Text(
                    AppLocalizations.of(context).quizSavedOn(_savedDate!),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.gc.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  AppLocalizations.of(context).quizYourArchetypeIs,
                  style: TextStyle(color: context.gc.textSecondary),
                ),
                const SizedBox(height: 4),
                _Reveal(
                  play: _justFinished,
                  delay: GrimoireMotion.state,
                  child: Text(
                    result.name,
                    key: const ValueKey('quiz-result-name'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: context.gc.lilac,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  result.summary,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.gc.textPrimary,
                      ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ArcaneDetailPage(
                        entry: result,
                        category: ArcaneCategory.archetypes,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.menu_book, size: 18),
                  label: Text(AppLocalizations.of(context).quizSeeInEncyclopedia),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _restart,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(AppLocalizations.of(context).quizRetake),
                ),
              ],
            ),
          ),
          if (_topThree.length > 1)
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).quizStrongestEnergies,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: context.gc.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  for (final entry in _topThree)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              _entryForKey(entry.key).name,
                              style: TextStyle(
                                color: context.gc.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: LinearProgressIndicator(
                              value: entry.value /
                                  archetypeQuizQuestions.length,
                              backgroundColor: context.gc.surfaceBorder,
                              valueColor: AlwaysStoppedAnimation(
                                  context.gc.lilac),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${entry.value}',
                            style: TextStyle(
                              color: context.gc.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          MagicalCard(
            child: Text(
              AppLocalizations.of(context).quizMirrorNote,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.gc.textSecondary,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A revelação do arquétipo: sobe e assenta uma vez, quando o teste acaba
/// de terminar. Um resultado guardado — e o movimento reduzido — abre
/// direto no estado final, que é o mesmo.
class _Reveal extends StatelessWidget {
  const _Reveal({required this.play, required this.child, this.delay = Duration.zero});

  final bool play;
  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    if (!play || GrimoireMotion.reduced(context)) return child;
    final total = GrimoireMotion.celebration + delay;
    final start = delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: total,
      curve: Curves.linear,
      builder: (context, raw, inner) {
        final t = Interval(start, 1, curve: GrimoireMotion.enter).transform(raw);
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: inner),
        );
      },
      child: child,
    );
  }
}
