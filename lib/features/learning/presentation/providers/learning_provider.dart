import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/data_sources/trails_data.dart';
import '../../data/models/trail_model.dart';

/// Progresso do Grimório Vivo (local, por aparelho).
class LearningProvider with ChangeNotifier {
  static const _completedKey = 'learning_completed_lessons';

  Set<String> _completed = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _completed = (prefs.getStringList(_completedKey) ?? []).toSet();
    _loaded = true;
    notifyListeners();
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

  Future<void> markCompleted(String lessonId) async {
    if (_completed.contains(lessonId)) return;
    _completed.add(lessonId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_completedKey, _completed.toList());
    notifyListeners();
  }

  /// Total de lições em todas as trilhas.
  static int get totalLessons =>
      learningTrails.fold(0, (sum, t) => sum + t.lessons.length);
}
