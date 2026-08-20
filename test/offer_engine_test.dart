import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/offers/offer_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guardrails do Motor de Ofertas (B3 — obrigatórios):
/// frequency cap global de 1 oferta/dia, cooldown por oferta após dispensa,
/// silêncio de 30 dias após 2 dispensas, "quem já tem não vê", oferta por
/// ciclo e registro de eventos.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DateTime now;
  late OfferEngine engine;

  Future<void> freshEngine() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    engine = OfferEngine(prefs, clock: () => now);
  }

  setUp(() async {
    now = DateTime(2026, 8, 10, 9);
    await freshEngine();
  });

  test('por padrão a oferta pode aparecer', () {
    expect(engine.shouldShow(OfferSlot.dreamTeaser), isTrue);
  });

  test('quem já tem a feature nunca vê a oferta dela', () {
    expect(
      engine.shouldShow(OfferSlot.dreamTeaser, alreadyOwned: true),
      isFalse,
    );
  });

  group('frequency cap global (1 oferta/dia)', () {
    test('segunda oferta diferente no mesmo dia não entra', () async {
      await engine.recordExposure(OfferSlot.dreamTeaser);
      expect(engine.shouldShow(OfferSlot.cycleReading), isFalse);
    });

    test('a MESMA oferta pode continuar aparecendo no dia', () async {
      await engine.recordExposure(OfferSlot.dreamTeaser);
      expect(engine.shouldShow(OfferSlot.dreamTeaser), isTrue);
    });

    test('no dia seguinte a vaga abre de novo', () async {
      await engine.recordExposure(OfferSlot.dreamTeaser);
      now = now.add(const Duration(days: 1));
      expect(engine.shouldShow(OfferSlot.cycleReading), isTrue);
    });
  });

  group('dispensa e cooldown', () {
    test('oferta dispensada entra em cooldown', () async {
      await engine.recordDismissal(OfferSlot.dreamTeaser);
      now = now.add(const Duration(days: 6));
      expect(engine.shouldShow(OfferSlot.dreamTeaser), isFalse);
      now = now.add(const Duration(days: 2));
      expect(engine.shouldShow(OfferSlot.dreamTeaser), isTrue);
    });

    test('cooldown é por oferta: as demais seguem elegíveis', () async {
      await engine.recordDismissal(OfferSlot.dreamTeaser);
      expect(engine.shouldShow(OfferSlot.cycleReading), isTrue);
    });

    test('2 dispensas silenciam por 30 dias', () async {
      await engine.recordDismissal(OfferSlot.dreamTeaser);
      now = now.add(const Duration(days: 8));
      await engine.recordDismissal(OfferSlot.dreamTeaser);

      // Passado o cooldown de 7 dias, o silêncio de 30 ainda segura.
      now = now.add(const Duration(days: 15));
      expect(engine.shouldShow(OfferSlot.dreamTeaser), isFalse);

      now = now.add(const Duration(days: 16));
      expect(engine.shouldShow(OfferSlot.dreamTeaser), isTrue);
    });
  });

  group('oferta por ciclo (periodKey)', () {
    test('dispensada no ciclo não volta nele; volta no seguinte', () async {
      await engine.recordDismissal(OfferSlot.cycleReading,
          periodKey: '2026-08-08');

      // Mesmo depois do cooldown, o MESMO ciclo continua bloqueado.
      now = now.add(const Duration(days: 10));
      expect(
        engine.shouldShow(OfferSlot.cycleReading, periodKey: '2026-08-08'),
        isFalse,
      );
      // O ciclo seguinte volta a ser elegível.
      now = now.add(const Duration(days: 20));
      expect(
        engine.shouldShow(OfferSlot.cycleReading, periodKey: '2026-09-06'),
        isTrue,
      );
    });
  });

  group('conversão', () {
    test('conversão zera o histórico de dispensas', () async {
      await engine.recordDismissal(OfferSlot.cycleReading);
      await engine.recordDismissal(OfferSlot.cycleReading);
      expect(engine.shouldShow(OfferSlot.cycleReading), isFalse);

      await engine.recordConversion(OfferSlot.cycleReading);
      expect(engine.shouldShow(OfferSlot.cycleReading), isTrue);
    });
  });

  group('eventos (base para ajustar as regras)', () {
    test('exposição, clique, dispensa e conversão são contados', () async {
      await engine.recordExposure(OfferSlot.dreamTeaser);
      await engine.recordClick(OfferSlot.dreamTeaser);
      await engine.recordDismissal(OfferSlot.dreamTeaser);
      await engine.recordConversion(OfferSlot.dreamTeaser);

      expect(engine.eventCount(OfferSlot.dreamTeaser, OfferEvent.exposure), 1);
      expect(engine.eventCount(OfferSlot.dreamTeaser, OfferEvent.click), 1);
      expect(
          engine.eventCount(OfferSlot.dreamTeaser, OfferEvent.dismissal), 1);
      expect(
          engine.eventCount(OfferSlot.dreamTeaser, OfferEvent.conversion), 1);
    });

    test('exposição contínua no mesmo dia conta uma vez', () async {
      await engine.recordExposure(OfferSlot.dreamTeaser);
      await engine.recordExposure(OfferSlot.dreamTeaser);
      expect(engine.eventCount(OfferSlot.dreamTeaser, OfferEvent.exposure), 1);

      now = now.add(const Duration(days: 1));
      await engine.recordExposure(OfferSlot.dreamTeaser);
      expect(engine.eventCount(OfferSlot.dreamTeaser, OfferEvent.exposure), 2);
    });
  });

  group('muro (degustação no lugar do paywall de uma tela pedida)', () {
    test('conta como exposição', () async {
      await engine.recordWallExposure(OfferSlot.dailyWeatherTeaser);
      expect(
        engine.eventCount(OfferSlot.dailyWeatherTeaser, OfferEvent.exposure),
        1,
      );
    });

    test('não ocupa a vaga do dia de outra oferta', () async {
      // Abrir a previsão do dia (um muro) não pode calar o convite da
      // Leitura do Ciclo — o cap existe para oferta que aparece sozinha.
      await engine.recordWallExposure(OfferSlot.dailyWeatherTeaser);
      expect(engine.shouldShow(OfferSlot.cycleReading), isTrue);
    });

    test('o muro não é silenciado pelo cap de outra oferta', () async {
      // O caminho inverso: o muro não passa por shouldShow, então uma oferta
      // já exibida hoje não pode apagar a degustação da tela que a pessoa
      // abriu de propósito.
      await engine.recordExposure(OfferSlot.dreamTeaser);
      await engine.recordWallExposure(OfferSlot.lessonTeaser);
      expect(
        engine.eventCount(OfferSlot.lessonTeaser, OfferEvent.exposure),
        1,
      );
    });
  });
}
