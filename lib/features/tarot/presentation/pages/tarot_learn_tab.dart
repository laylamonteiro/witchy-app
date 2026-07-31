import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/data_sources/tarot_cards_data.dart';
import '../../data/data_sources/tarot_concept_questions.dart';
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
                    _stat(context, '🔥', AppLocalizations.of(context).tarotBestCombo, '$_bestCombo'),
                    _stat(context, '📅', AppLocalizations.of(context).tarotDayStreak, '$_dayStreak'),
                    _stat(context, '🎯', AppLocalizations.of(context).tarotAccuracy, '$accuracy%'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).tarotAnsweredOf('$_answered', '${tarotCards.length}'),
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
                  AppLocalizations.of(context).tarotQuizTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.gc.lilac,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).tarotQuizDesc,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _startSession,
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: Text(AppLocalizations.of(context).tarotQuizStart),
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

/// Pergunta da sessão: de carta (imagem + significados) ou conceitual
/// (sobre tiragens e a estrutura do baralho).
class _QuizQuestion {
  final TarotCard? card;
  final String? prompt;
  final List<String> optionTexts;
  final int correctIndex;

  const _QuizQuestion.card({
    required TarotCard this.card,
    required this.optionTexts,
    required this.correctIndex,
  }) : prompt = null;

  const _QuizQuestion.concept({
    required String this.prompt,
    required this.optionTexts,
    required this.correctIndex,
  }) : card = null;
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
  int? _selectedIndex;

  static const int _conceptPerSession = 3;

  @override
  void initState() {
    super.initState();
    final random = Random();
    final deck = List<TarotCard>.from(tarotCards)..shuffle(random);
    final concepts =
        List<(String, List<String>)>.from(tarotConceptQuestions)..shuffle(random);
    _questions = [
      for (var i = 0; i < _sessionLength - _conceptPerSession; i++)
        _buildCardQuestion(deck[i], random),
      for (var i = 0; i < _conceptPerSession; i++)
        _buildConceptQuestion(concepts[i], random),
    ]..shuffle(random);
  }

  _QuizQuestion _buildCardQuestion(TarotCard card, Random random) {
    final distractors = List<TarotCard>.from(tarotCards)
      ..remove(card)
      ..shuffle(random);
    final options = [card, ...distractors.take(3)]..shuffle(random);
    return _QuizQuestion.card(
      card: card,
      optionTexts: [
        for (final o in options) '${o.keywords.join(', ')} — ${o.upright}',
      ],
      correctIndex: options.indexOf(card),
    );
  }

  _QuizQuestion _buildConceptQuestion(
      (String, List<String>) data, Random random) {
    final correct = data.$2.first;
    final options = List<String>.from(data.$2)..shuffle(random);
    return _QuizQuestion.concept(
      prompt: data.$1,
      optionTexts: options,
      correctIndex: options.indexOf(correct),
    );
  }

  Future<void> _answer(int optionIndex) async {
    if (_selectedIndex != null) return;
    final question = _questions[_index];
    final isCorrect = optionIndex == question.correctIndex;

    setState(() {
      _selectedIndex = optionIndex;
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
        _selectedIndex = null;
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
          _sessionCorrect >= 7 ? AppLocalizations.of(context).tarotQuizBrilliant : AppLocalizations.of(context).tarotQuizDone,
          style: TextStyle(color: dialogContext.gc.textPrimary),
        ),
        content: Text(
          AppLocalizations.of(context).tarotQuizScore('$_sessionCorrect', '${_questions.length}') +
              (_sessionCorrect >= 7 ? AppLocalizations.of(context).tarotQuizPraise : AppLocalizations.of(context).tarotQuizEncourage),
          style: TextStyle(color: dialogContext.gc.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context).tarotQuizFinish),
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
            if (question.card != null) ...[
              Center(child: TarotCardView(card: question.card!, width: 130)),
              const SizedBox(height: 16),
            ] else ...[
              const Center(
                child: Text('🃏', style: TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              question.card != null
                  ? AppLocalizations.of(context)
                      .tarotQuizQuestion(question.card!.name)
                  : question.prompt!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.gc.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < question.optionTexts.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _optionTile(context, question, i),
              ),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(
      BuildContext context, _QuizQuestion question, int optionIndex) {
    final answered = _selectedIndex != null;
    final isCorrect = optionIndex == question.correctIndex;
    final isChosen = optionIndex == _selectedIndex;

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
      onTap: answered ? null : () => _answer(optionIndex),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tint ?? context.gc.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Text(
          question.optionTexts[optionIndex],
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
