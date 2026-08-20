import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../services/debug_log_service.dart';

/// Pontos de oferta do app. Cada slot é UMA oferta reconhecível pela pessoa
/// (a degustação de uma feature ou o convite da Leitura do Ciclo) — os
/// guardrails de frequência e silêncio são contados por slot.
enum OfferSlot {
  /// Degustação da interpretação de sonhos por IA (sonho salvo sem análise).
  dreamTeaser,

  /// Degustação do Clima Mágico completo no Seu Dia.
  dailyWeatherTeaser,

  /// Degustação do Perfil Mágico após criar o mapa astral.
  magicalProfileTeaser,

  /// Convite pós-tiragem grátis do dia (runas/oráculo/pêndulo).
  ///
  /// RESERVADO, sem tela por decisão de produto: aqui o que a assinatura
  /// vende é QUANTIDADE, não conteúdo — a pessoa já leu as tiragens do dia.
  /// Sortear uma carta extra só para escondê-la seria provocação, não
  /// degustação. O gostinho desta tela é o do Conselheiro
  /// ([counselorTeaser]), sobre a tiragem que ela acabou de fazer.
  drawLimitTeaser,

  /// Degustação da lição seguinte de uma trilha.
  lessonTeaser,

  /// Degustação do Conselheiro Místico.
  counselorTeaser,

  /// Convite para comprar a Leitura do Ciclo (gatilho de engajamento).
  cycleReading,
}

/// Eventos registrados por oferta — a matéria-prima para ajustar as regras.
enum OfferEvent { exposure, click, dismissal, conversion }

/// Decide SE uma oferta pode aparecer e registra o que aconteceu com ela.
///
/// Princípio: mostrar valor real no momento em que ele existe, nunca paywall
/// frio — e nunca virar assédio. Guardrails (todos aplicados em
/// [shouldShow]):
/// - No máximo UMA oferta visível por dia no app inteiro (a mesma oferta
///   pode continuar aparecendo no dia; uma segunda diferente não entra).
/// - Oferta dispensada entra em cooldown de [dismissCooldown].
/// - Dispensada [silenceAfterDismissals] vezes: silêncio de [silenceDuration].
/// - Quem já tem a feature (Premium/compra) nunca vê a oferta dela.
/// - Ofertas por ciclo ([periodKey]): dispensou, só volta no ciclo seguinte.
///
/// O estado vive em SharedPreferences (local, por aparelho): oferta é
/// interface, não dado da pessoa — não sincroniza.
class OfferEngine {
  OfferEngine(this._prefs, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final SharedPreferences _prefs;
  final DateTime Function() _clock;

  static OfferEngine? _instance;

  /// Instância padrão do app (prefs reais). Testes constroem a sua própria.
  static Future<OfferEngine> load() async {
    return _instance ??= OfferEngine(await SharedPreferences.getInstance());
  }

  /// Cooldown por oferta depois de UMA dispensa.
  static const Duration dismissCooldown = Duration(days: 7);

  /// Dispensas que silenciam a oferta por [silenceDuration].
  static const int silenceAfterDismissals = 2;

  /// Silêncio após dispensas repetidas.
  static const Duration silenceDuration = Duration(days: 30);

  static const _prefix = 'offer_engine';

  String _slotKey(OfferSlot slot, String field) =>
      '${_prefix}_${slot.name}_$field';

  String _dayKey(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// A oferta [slot] pode aparecer agora?
  ///
  /// [alreadyOwned]: a pessoa já tem o que a oferta vende (ex.: Premium
  /// vendo teaser de feature Premium) — nunca mostrar.
  /// [periodKey]: identidade do ciclo para ofertas 1×/ciclo (ex.: a data da
  /// lua nova que abre a lunação). Dispensada neste ciclo, só volta no
  /// próximo.
  bool shouldShow(
    OfferSlot slot, {
    bool alreadyOwned = false,
    String? periodKey,
  }) {
    if (alreadyOwned) return false;

    final now = _clock();

    // Silêncio por dispensas repetidas.
    final silencedUntil = _prefs.getInt(_slotKey(slot, 'silenced_until'));
    if (silencedUntil != null &&
        now.isBefore(DateTime.fromMillisecondsSinceEpoch(silencedUntil))) {
      return false;
    }

    // Cooldown depois da última dispensa.
    final lastDismissed = _prefs.getInt(_slotKey(slot, 'last_dismissed_at'));
    if (lastDismissed != null &&
        now.isBefore(DateTime.fromMillisecondsSinceEpoch(lastDismissed)
            .add(dismissCooldown))) {
      return false;
    }

    // Oferta por ciclo: dispensada neste ciclo não volta nele.
    if (periodKey != null &&
        _prefs.getString(_slotKey(slot, 'dismissed_period')) == periodKey) {
      return false;
    }

    // Frequency cap global: 1 oferta por dia. A MESMA oferta pode seguir
    // visível (rebuilds/reaberturas do dia); uma segunda diferente espera.
    final lastShownDay = _prefs.getString('${_prefix}_last_shown_day');
    final lastShownSlot = _prefs.getString('${_prefix}_last_shown_slot');
    if (lastShownDay == _dayKey(now) &&
        lastShownSlot != null &&
        lastShownSlot != slot.name) {
      return false;
    }

    return true;
  }

  /// Registra que a oferta apareceu (ocupa a vaga do dia).
  Future<void> recordExposure(OfferSlot slot) async {
    final now = _clock();
    final day = _dayKey(now);
    // Exposição contínua no mesmo dia não infla o contador de eventos.
    final alreadyToday =
        _prefs.getString('${_prefix}_last_shown_day') == day &&
            _prefs.getString('${_prefix}_last_shown_slot') == slot.name;
    await _prefs.setString('${_prefix}_last_shown_day', day);
    await _prefs.setString('${_prefix}_last_shown_slot', slot.name);
    if (!alreadyToday) {
      await _bumpEvent(slot, OfferEvent.exposure);
    }
  }

  /// Registra a dispensa (X do card): cooldown e, na reincidência, silêncio.
  Future<void> recordDismissal(OfferSlot slot, {String? periodKey}) async {
    final now = _clock();
    final count = (_prefs.getInt(_slotKey(slot, 'dismiss_count')) ?? 0) + 1;
    await _prefs.setInt(_slotKey(slot, 'dismiss_count'), count);
    await _prefs.setInt(
        _slotKey(slot, 'last_dismissed_at'), now.millisecondsSinceEpoch);
    if (periodKey != null) {
      await _prefs.setString(_slotKey(slot, 'dismissed_period'), periodKey);
    }
    if (count >= silenceAfterDismissals) {
      await _prefs.setInt(
        _slotKey(slot, 'silenced_until'),
        now.add(silenceDuration).millisecondsSinceEpoch,
      );
    }
    await _bumpEvent(slot, OfferEvent.dismissal);
  }

  /// Registra a exposição de um MURO: a degustação que substitui o paywall
  /// de uma tela que a pessoa abriu de propósito (a previsão do dia, o perfil
  /// mágico, a lição da trilha).
  ///
  /// Conta como evento, mas NÃO ocupa a vaga do dia nem passa por
  /// [shouldShow]: o cap existe para conter oferta que aparece sem ser
  /// chamada, e um muro é a própria tela pedida — silenciá-lo mostraria
  /// MENOS do que o paywall que ele substituiu.
  Future<void> recordWallExposure(OfferSlot slot) =>
      _bumpEvent(slot, OfferEvent.exposure);

  /// Registra o toque no convite (a pessoa quis ver).
  Future<void> recordClick(OfferSlot slot) => _bumpEvent(slot, OfferEvent.click);

  /// Registra a conversão (assinou/comprou a partir desta oferta) e zera o
  /// histórico de dispensas — a relação com a oferta recomeçou do zero.
  Future<void> recordConversion(OfferSlot slot) async {
    await _prefs.remove(_slotKey(slot, 'dismiss_count'));
    await _prefs.remove(_slotKey(slot, 'last_dismissed_at'));
    await _prefs.remove(_slotKey(slot, 'silenced_until'));
    await _prefs.remove(_slotKey(slot, 'dismissed_period'));
    await _bumpEvent(slot, OfferEvent.conversion);
  }

  /// Contador acumulado de um evento (base local para ajustar as regras).
  int eventCount(OfferSlot slot, OfferEvent event) =>
      _prefs.getInt(_slotKey(slot, 'ev_${event.name}')) ?? 0;

  Future<void> _bumpEvent(OfferSlot slot, OfferEvent event) async {
    final key = _slotKey(slot, 'ev_${event.name}');
    final total = (_prefs.getInt(key) ?? 0) + 1;
    await _prefs.setInt(key, total);
    unawaited(debugLog('OFFER', '${slot.name}: ${event.name} ($total)'));
  }
}
