import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/data_sources/tarot_cards_data.dart';
import '../../data/models/tarot_card_model.dart';
import '../widgets/tarot_card_view.dart';

/// Tutor de Tarot: quiz de significados com combo e sequência de dias.
class TarotLearnTab extends StatefulWidget {
  const TarotLearnTab({super.key});

  @override
  State<TarotLearnTab> createState() => _TarotLearnTabState();
}

class _TarotLearnTabState extends State<TarotLearnTab> {
  static const _bestComboKey = 'tarot_best_combo';
  static const _answeredKey = 'tarot_answered_total';
  static const _correctKey = 'tarot_correct_total';
  static const _streakKey = 'tarot_day_streak';
  static const _lastDayKey = 'tarot_last_day';

  int _bestCombo = 0;
  int _answered = 0;
  int _correct = 0;
  int _dayStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _bestCombo = prefs.getInt(_bestComboKey) ?? 0;
      _answered = prefs.getInt(_answeredKey) ?? 0;
      _correct = prefs.getInt(_correctKey) ?? 0;
      _dayStreak = prefs.getInt(_streakKey) ?? 0;
    });
  }

  Future<void> _startSession() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TarotQuizPage()),
    );
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final accuracy =
        _answered == 0 ? 0 : ((_correct / _answered) * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MagicalCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _stat(context, '🔥', 'Melhor combo', '$_bestCombo'),
                    _stat(context, '📅', 'Dias seguidos', '$_dayStreak'),
                    _stat(context, '🎯', 'Precisão', '$accuracy%'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$_answered respondidas · ${tarotCards.length} cartas no baralho',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          MagicalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Teste o que você sabe',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.gc.lilac,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Uma sessão com perguntas embaralhadas sobre os '
                  'significados das cartas. Acertos consecutivos formam '
                  'combo — volte todos os dias para manter a sequência.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _startSession,
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Sessão de 10 perguntas'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(
      BuildContext context, String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: context.gc.lilac,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: context.gc.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}

class _QuizQuestion {
  final TarotCard card;
  final List<TarotCard> options;

  const _QuizQuestion({required this.card, required this.options});
}

/// Sessão de quiz: "o que representa esta carta?" com 4 alternativas.
class TarotQuizPage extends StatefulWidget {
  const TarotQuizPage({super.key});

  @override
  State<TarotQuizPage> createState() => _TarotQuizPageState();
}

class _TarotQuizPageState extends State<TarotQuizPage> {
  static const int _sessionLength = 10;

  late final List<_QuizQuestion> _questions;
  int _index = 0;
  int _combo = 0;
  int _sessionCorrect = 0;
  TarotCard? _selected;

  @override
  void initState() {
    super.initState();
    final random = Random();
    final deck = List<TarotCard>.from(tarotCards)..shuffle(random);
    _questions = [
      for (var i = 0; i < _sessionLength; i++)
        _buildQuestion(deck[i], random),
    ];
  }

  _QuizQuestion _buildQuestion(TarotCard card, Random random) {
    final distractors = List<TarotCard>.from(tarotCards)
      ..remove(card)
      ..shuffle(random);
    final options = [card, ...distractors.take(3)]..shuffle(random);
    return _QuizQuestion(card: card, options: options);
  }

  Future<void> _answer(TarotCard option) async {
    if (_selected != null) return;
    final question = _questions[_index];
    final isCorrect = option == question.card;

    setState(() {
      _selected = option;
      if (isCorrect) {
        _combo++;
        _sessionCorrect++;
      } else {
        _combo = 0;
      }
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _TarotLearnTabState._answeredKey,
      (prefs.getInt(_TarotLearnTabState._answeredKey) ?? 0) + 1,
    );
    if (isCorrect) {
      await prefs.setInt(
        _TarotLearnTabState._correctKey,
        (prefs.getInt(_TarotLearnTabState._correctKey) ?? 0) + 1,
      );
      final best = prefs.getInt(_TarotLearnTabState._bestComboKey) ?? 0;
      if (_combo > best) {
        await prefs.setInt(_TarotLearnTabState._bestComboKey, _combo);
      }
    }
    await _updateDayStreak(prefs);

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    if (_index < _questions.length - 1) {
      setState(() {
        _index++;
        _selected = null;
      });
    } else {
      _showResult();
    }
  }

  Future<void> _updateDayStreak(SharedPreferences prefs) async {
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final lastDay = prefs.getString(_TarotLearnTabState._lastDayKey);
    if (lastDay == todayKey) return;

    final yesterday = today.subtract(const Duration(days: 1));
    final yesterdayKey =
        '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
    final streak = prefs.getInt(_TarotLearnTabState._streakKey) ?? 0;
    await prefs.setInt(
      _TarotLearnTabState._streakKey,
      lastDay == yesterdayKey ? streak + 1 : 1,
    );
    await prefs.setString(_TarotLearnTabState._lastDayKey, todayKey);
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: dialogContext.gc.surface,
        title: Text(
          _sessionCorrect >= 7 ? 'Brilhante! ✨' : 'Sessão concluída 🌙',
          style: TextStyle(color: dialogContext.gc.textPrimary),
        ),
        content: Text(
          'Você acertou $_sessionCorrect de ${_questions.length}.'
          '${_sessionCorrect >= 7 ? ' As cartas reconhecem sua dedicação.' : ' Continue praticando — cada sessão aprofunda a leitura.'}',
          style: TextStyle(color: dialogContext.gc.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Concluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_index];

    return Scaffold(
      appBar: AppBar(
        title: Text('${_index + 1} / ${_questions.length}'),
        actions: [
          if (_combo > 1)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '🔥 $_combo',
                  style: TextStyle(
                    color: context.gc.starYellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_index + 1) / _questions.length,
              backgroundColor: context.gc.surfaceBorder,
              valueColor: AlwaysStoppedAnimation(context.gc.lilac),
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 20),
            Center(child: TarotCardView(card: question.card, width: 130)),
            const SizedBox(height: 16),
            Text(
              'O que representa ${question.card.name}?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.gc.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            for (final option in question.options)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _optionTile(context, question, option),
              ),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(
      BuildContext context, _QuizQuestion question, TarotCard option) {
    final answered = _selected != null;
    final isCorrect = option == question.card;
    final isChosen = option == _selected;

    Color border = context.gc.surfaceBorder;
    Color? tint;
    if (answered && isCorrect) {
      border = context.gc.success;
      tint = context.gc.success.withValues(alpha: 0.12);
    } else if (answered && isChosen) {
      border = context.gc.alert;
      tint = context.gc.alert.withValues(alpha: 0.12);
    }

    return InkWell(
      onTap: answered ? null : () => _answer(option),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tint ?? context.gc.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Text(
          '${option.keywords.join(', ')} — ${option.upright}',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(height: 1.4),
        ),
      ),
    );
  }
}
