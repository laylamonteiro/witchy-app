import 'package:flutter/foundation.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/data_sources/trails_data.dart';
import '../../data/models/trail_model.dart';
import '../../data/repositories/learning_progress_repository.dart';
import '../../../../core/content/content_locale.dart';
import '../../../../core/database/database_helper.dart';

/// Strings do idioma atual sem BuildContext; o locale vem do ContentLocale.
AppLocalizations get _l10n =>
    lookupAppLocalizations(ContentLocale.instance.locale);


/// Nível do Grimório Vivo — gamificação no espírito das Jornadas Mágicas
/// (XP e títulos), aplicada ao aprendizado.
class LearningLevel {
  final String title;
  final String emoji;
  final int minXp;

  const LearningLevel(this.title, this.emoji, this.minXp);
}

/// Progresso do Grimório Vivo — persistido no banco e sincronizado na
/// nuvem como os demais registros (antes vivia só em SharedPreferences).
class LearningProvider with ChangeNotifier {
  static const _legacyCompletedKey = 'learning_completed_lessons';

  final LearningProgressRepository _repository = LearningProgressRepository();

  /// XP por página escrita e bônus por trilha encadernada.
  static const int xpPerPage = 25;
  static const int xpPerTrailBound = 100;

  /// XP UNIFICADO: as práticas também alimentam o nível, com pesos menores
  /// que o estudo — criar algo (registro, sigilo, página da enciclopédia)
  /// vale mais que consultar (tiragens), e o ritual guiado fica no meio.
  /// Assim "XP" significa a mesma coisa no app inteiro.
  static const int xpPerGuidedRitual = 10;
  static const int xpPerCreation = 5;
  static const int xpPerDivination = 2;

  /// Níveis com nomes no idioma atual (limiares de XP invariantes).
  static List<LearningLevel> get levels => [
        LearningLevel(_l10n.learnLevelApprentice, '🕯️', 0),
        LearningLevel(_l10n.learnLevelInitiate, '🌙', 100),
        LearningLevel(_l10n.learnLevelPractitioner, '⭐', 300),
        LearningLevel(_l10n.learnLevelAdept, '🔮', 600),
        LearningLevel(_l10n.learnLevelMaster, '👑', 1000),
        LearningLevel(_l10n.learnLevelGuardian, '📜', 1500),
      ];

  Set<String> _completed = {};
  bool _loaded = false;
  String _currentUserId = 'local_user';
  int _practiceXp = 0;

  bool get isLoaded => _loaded;

  Future<void> setUserId(String userId) async {
    if (_currentUserId == userId && _loaded) return;
    _currentUserId = userId;
    await load();
  }

  Future<void> load() async {
    await _migrateLegacyPrefs();
    _completed = await _repository.completedLessonIds(_currentUserId);
    _practiceXp = await _computePracticeXp();
    _loaded = true;
    notifyListeners();
  }

  /// Recalcula só a parcela de práticas (chamado pelas telas de resumo,
  /// já que as práticas acontecem espalhadas pelo app).
  Future<void> refreshPracticeXp() async {
    _practiceXp = await _computePracticeXp();
    notifyListeners();
  }

  /// XP das práticas direto do banco: criações (registros do grimório,
  /// diários, sigilos, páginas da enciclopédia pessoal), tiragens (runas,
  /// oráculo, pêndulo) e rituais guiados concluídos.
  Future<int> _computePracticeXp() async {
    const creationTables = [
      'spells',
      'dreams',
      'gratitudes',
      'affirmations',
      'desires',
      'sigils',
      'user_encyclopedia_entries',
    ];
    const divinationTables = [
      'rune_readings',
      'oracle_readings',
      'pendulum_consultations',
    ];

    Future<int> count(dynamic db, String table) async {
      try {
        final preloadedFilter = (table == 'spells' || table == 'affirmations')
            ? ' AND is_preloaded = 0'
            : '';
        final result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM $table '
          'WHERE user_id = ?$preloadedFilter',
          [_currentUserId],
        );
        return result.first['count'] as int? ?? 0;
      } catch (_) {
        return 0;
      }
    }

    try {
      final db = await DatabaseHelper.instance.database;
      var xp = 0;
      for (final t in creationTables) {
        xp += await count(db, t) * xpPerCreation;
      }
      for (final t in divinationTables) {
        xp += await count(db, t) * xpPerDivination;
      }
      xp += await count(db, 'guided_ritual_logs') * xpPerGuidedRitual;
      return xp;
    } catch (_) {
      return 0;
    }
  }

  /// Progresso antigo (SharedPreferences) vira linhas no banco uma única vez.
  Future<void> _migrateLegacyPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getStringList(_legacyCompletedKey);
    if (legacy == null || legacy.isEmpty) return;
    await _repository.importLegacy(_currentUserId, legacy.toSet());
    await prefs.remove(_legacyCompletedKey);
  }

  bool isLessonCompleted(String lessonId) => _completed.contains(lessonId);

  int completedInTrail(LearningTrail trail) =>
      trail.lessons.where((l) => _completed.contains(l.id)).length;

  bool isTrailComplete(LearningTrail trail) =>
      completedInTrail(trail) == trail.lessons.length;

  // Não há cadeado entre lições: todas ficam abertas, e a Bruxa escolhe por
  // onde começar. A ordem é sugestão (a trilha é linear no conteúdo), nunca
  // uma trava — explorar livremente vale mais que forçar a sequência.

  int get totalPagesWritten => _completed.length;

  int get boundTrails =>
      learningTrails.where(isTrailComplete).length;

  /// Parcela do estudo (lições e trilhas).
  int get lessonXp =>
      totalPagesWritten * xpPerPage + boundTrails * xpPerTrailBound;

  /// Parcela das práticas (criações, tiragens e rituais guiados).
  int get practiceXp => _practiceXp;

  /// XP total unificado — é este que define o nível exibido no app.
  int get xp => lessonXp + _practiceXp;

  LearningLevel get level {
    var current = levels.first;
    for (final l in levels) {
      if (xp >= l.minXp) current = l;
    }
    return current;
  }

  LearningLevel? get nextLevel {
    for (final l in levels) {
      if (xp < l.minXp) return l;
    }
    return null;
  }

  /// Progresso 0..1 dentro do nível atual.
  double get levelProgress {
    final next = nextLevel;
    if (next == null) return 1;
    final base = level.minXp;
    return (xp - base) / (next.minXp - base);
  }

  /// Marca a lição e informa o que aconteceu (XP ganho, trilha encadernada,
  /// nível subiu) para a UI celebrar.
  Future<LessonReward> markCompleted(
      LearningTrail trail, String lessonId) async {
    if (_completed.contains(lessonId)) {
      return const LessonReward(xpGained: 0);
    }

    final levelBefore = level;
    final wasComplete = isTrailComplete(trail);

    _completed.add(lessonId);
    await _repository.markCompleted(_currentUserId, lessonId);

    final nowComplete = isTrailComplete(trail);
    final reward = LessonReward(
      xpGained: xpPerPage + (nowComplete && !wasComplete ? xpPerTrailBound : 0),
      trailBound: nowComplete && !wasComplete,
      leveledUpTo: level.title != levelBefore.title ? level : null,
    );
    notifyListeners();
    return reward;
  }

  /// Total de lições em todas as trilhas.
  static int get totalLessons =>
      learningTrails.fold(0, (sum, t) => sum + t.lessons.length);
}

class LessonReward {
  final int xpGained;
  final bool trailBound;
  final LearningLevel? leveledUpTo;

  const LessonReward({
    required this.xpGained,
    this.trailBound = false,
    this.leveledUpTo,
  });
}
