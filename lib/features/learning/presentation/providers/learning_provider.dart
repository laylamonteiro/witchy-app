import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/data_sources/trails_data.dart';
import '../../data/models/trail_model.dart';
import '../../data/repositories/learning_progress_repository.dart';

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

  static const levels = [
    LearningLevel('Aprendiz', '🕯️', 0),
    LearningLevel('Iniciada', '🌙', 100),
    LearningLevel('Praticante', '⭐', 300),
    LearningLevel('Adepta', '🔮', 600),
    LearningLevel('Mestra', '👑', 1000),
    LearningLevel('Guardiã do Grimório', '📜', 1500),
  ];

  Set<String> _completed = {};
  bool _loaded = false;
  String _currentUserId = 'local_user';

  bool get isLoaded => _loaded;

  Future<void> setUserId(String userId) async {
    if (_currentUserId == userId && _loaded) return;
    _currentUserId = userId;
    await load();
  }

  Future<void> load() async {
    await _migrateLegacyPrefs();
    _completed = await _repository.completedLessonIds(_currentUserId);
    _loaded = true;
    notifyListeners();
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

  /// Uma lição destrava quando a anterior foi concluída (a primeira é livre).
  bool isLessonUnlocked(LearningTrail trail, int index) {
    if (index == 0) return true;
    return _completed.contains(trail.lessons[index - 1].id);
  }

  int get totalPagesWritten => _completed.length;

  int get boundTrails =>
      learningTrails.where(isTrailComplete).length;

  int get xp =>
      totalPagesWritten * xpPerPage + boundTrails * xpPerTrailBound;

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
