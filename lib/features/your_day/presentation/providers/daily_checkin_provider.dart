import 'package:flutter/widgets.dart';

import '../../data/daily_checkin_repository.dart';

/// Os ritos do dia — micro-práticas de baixo atrito que fecham o dia da Bruxa.
/// Os ids são estáveis (persistidos no banco): não renomear.
class DailyRites {
  const DailyRites._();

  static const String gratitude = 'gratitude';

  /// Registrar um sonho no diário onírico.
  static const String dream = 'dream';

  /// Uma tiragem de tarot.
  static const String divination = 'divination';

  /// Ritos exploratórios: cada página marca o seu quando a ação acontece.
  static const String palmistry = 'palmistry';
  static const String natureIdentify = 'nature_identify';
  static const String oracle = 'oracle';
  static const String runes = 'runes';
  static const String pendulum = 'pendulum';

  /// Marcador do dia fechado (os três ritos cumpridos). Não é um rito que
  /// se faz — é o selo que o card grava, e vale o bônus de XP do dia.
  static const String dayComplete = 'day_complete';

  static const List<String> all = [gratitude, dream, divination];

  /// Revezamento do terceiro slot do card: gratidão e sonho são fixos, e o
  /// rito exploratório muda a cada dia para apresentar outras partes do
  /// app. Determinístico pela data — estável durante o dia inteiro.
  static const List<String> rotation = [
    divination,
    oracle,
    palmistry,
    runes,
    natureIdentify,
    pendulum,
  ];

  static String featuredToday({DateTime? now}) {
    final date = now ?? DateTime.now();
    final days = DateTime(date.year, date.month, date.day)
        .difference(DateTime(2020, 1, 1))
        .inDays;
    return rotation[days % rotation.length];
  }
}

/// Estado do check-in diário: sequência de dias e ritos concluídos hoje.
class DailyCheckinProvider with ChangeNotifier, WidgetsBindingObserver {
  DailyCheckinProvider() {
    // O Android mantém o processo vivo por dias: sem observar o ciclo de
    // vida, reabrir o app num dia novo não registrava a visita e o streak
    // congelava no valor do último load.
    WidgetsBinding.instance.addObserver(this);
  }

  final DailyCheckinRepository _repository = DailyCheckinRepository();

  String _userId = 'local_user';
  int _streak = 0;
  int _bestStreak = 0;
  Set<String> _ritesToday = {};
  bool _loaded = false;

  /// Dia (YYYY-MM-DD local) do último load — para detectar a virada.
  String? _loadedDay;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Voltou do background: se o dia virou desde o último load, registra a
    // visita de hoje e recarrega sequência + ritos.
    if (state == AppLifecycleState.resumed) ensureToday();
  }

  /// Garante que a visita de HOJE está registrada. Custa nada quando o dia
  /// já foi carregado (comparação de string), então pode ser chamado de
  /// qualquer tela que mostre a sequência — é a rede de segurança para o
  /// app que fica dias vivo em background sem passar por um load novo.
  Future<void> ensureToday() async {
    if (!_loaded) return;
    if (_loadedDay == DailyCheckinRepository.dayKey(DateTime.now())) return;
    await load();
  }

  /// Dias seguidos de prática (inclui hoje).
  int get streak => _streak;

  /// Maior sequência já alcançada.
  int get bestStreak => _bestStreak;

  /// Ritos marcados aqui. Gratidão e sonho NÃO passam por este caminho: eles
  /// viram registro no diário, e o card os lê de lá — marcar no toque diria
  /// "feito" para quem só espiou a tela.
  Set<String> get ritesToday => _ritesToday;

  bool get isLoaded => _loaded;

  bool isRiteDone(String riteId) => _ritesToday.contains(riteId);

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
    _loadedDay = DailyCheckinRepository.dayKey(DateTime.now());
    _loaded = true;
    notifyListeners();
  }

  /// Marca um rito como concluído — só deve ser chamado quando a ação
  /// REALMENTE aconteceu (ex.: a tiragem de tarot foi feita).
  Future<void> completeRite(String riteId) async {
    if (_ritesToday.contains(riteId)) return;
    _ritesToday = await _repository.completeRite(_userId, riteId);
    // O primeiro rito do dia pode ser também o primeiro check-in: a
    // sequência precisa refletir isso na hora.
    _streak = await _repository.currentStreak(_userId);
    if (_streak > _bestStreak) _bestStreak = _streak;
    _loadedDay = DailyCheckinRepository.dayKey(DateTime.now());
    notifyListeners();
  }
}
