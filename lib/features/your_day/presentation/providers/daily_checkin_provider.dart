import 'package:flutter/foundation.dart';

import '../../data/daily_checkin_repository.dart';

/// Os ritos do dia — micro-práticas de baixo atrito que fecham o dia da Bruxa.
/// Os ids são estáveis (persistidos no banco): não renomear.
class DailyRites {
  const DailyRites._();

  static const String gratitude = 'gratitude';

  /// Retomar o Grimório Vivo (a lição em que a Bruxa parou).
  static const String trail = 'trail';

  /// Uma tiragem de tarot.
  static const String divination = 'divination';

  static const List<String> all = [gratitude, trail, divination];
}

/// Estado do check-in diário: sequência de dias e ritos concluídos hoje.
class DailyCheckinProvider with ChangeNotifier {
  final DailyCheckinRepository _repository = DailyCheckinRepository();

  String _userId = 'local_user';
  int _streak = 0;
  int _bestStreak = 0;
  Set<String> _ritesToday = {};
  bool _loaded = false;

  /// Dias seguidos de prática (inclui hoje).
  int get streak => _streak;

  /// Maior sequência já alcançada.
  int get bestStreak => _bestStreak;

  /// Ritos concluídos hoje.
  Set<String> get ritesToday => _ritesToday;

  bool get isLoaded => _loaded;

  bool isRiteDone(String riteId) => _ritesToday.contains(riteId);

  /// Todos os ritos do dia concluídos?
  bool get isDayComplete =>
      DailyRites.all.every((rite) => _ritesToday.contains(rite));

  int get ritesDoneCount =>
      DailyRites.all.where((rite) => _ritesToday.contains(rite)).length;

  Future<void> setUserId(String userId) async {
    if (_userId == userId && _loaded) return;
    _userId = userId;
    await load();
  }

  /// Registra a visita de hoje e recarrega sequência + ritos.
  Future<void> load() async {
    await _repository.registerVisit(_userId);
    _streak = await _repository.currentStreak(_userId);
    _bestStreak = await _repository.bestStreak(_userId);
    _ritesToday = await _repository.ritesToday(_userId);
    _loaded = true;
    notifyListeners();
  }

  /// Marca um rito como feito hoje. Devolve true quando ESTE toque fechou o
  /// dia (os três ritos) — a UI usa para comemorar uma única vez.
  Future<bool> completeRite(String riteId) async {
    if (_ritesToday.contains(riteId)) return false;
    final wasComplete = isDayComplete;
    _ritesToday = await _repository.completeRite(_userId, riteId);
    // O primeiro rito do dia pode ser também o primeiro check-in: a
    // sequência precisa refletir isso na hora.
    _streak = await _repository.currentStreak(_userId);
    if (_streak > _bestStreak) _bestStreak = _streak;
    notifyListeners();
    return !wasComplete && isDayComplete;
  }
}
