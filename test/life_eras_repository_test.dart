import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/birth_chart_model.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/enums.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/planet_position_model.dart';
import 'package:grimorio_de_bolso/features/cycles/data/models/life_eras_state.dart';
import 'package:grimorio_de_bolso/features/cycles/data/repositories/life_eras_repository.dart';
import 'package:grimorio_de_bolso/features/cycles/domain/era_ruler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A costura entre o mapa astral salvo e o cálculo das Eras.
///
/// O caso de referência do motor já é coberto em
/// `life_eras_calculator_test.dart`. O que se prova aqui é o encanamento: que
/// a longitude vem da LUA (e não de outro planeta), que ela é tratada como
/// TROPICAL, que o instante sai do resolvedor de fuso, e que o cache invalida
/// quando o mapa muda.
BirthChartModel mapa({
  required double longitudeDaLua,
  bool horaDesconhecida = false,
  String id = 'mapa-1',
  int calcVersion = 3,
}) {
  return BirthChartModel(
    id: id,
    userId: 'bruxa-1',
    birthDate: DateTime(1994, 8, 15),
    birthTime: const TimeOfDay(hour: 12, minute: 0),
    birthPlace: 'Meridiano de Greenwich',
    // Fora do Brasil: o resolvedor cai no fuso natural da longitude, que em
    // lon 0 é UTC+0. Assim o instante fica exatamente 1994-08-15T12:00Z e o
    // resultado pode ser comparado com o caso de referência.
    latitude: 40.0,
    longitude: 0.0,
    timezone: 'UTC+0',
    unknownBirthTime: horaDesconhecida,
    planets: [
      // Um chamariz: se o código pegasse o primeiro planeta da lista em vez
      // da Lua, o regente natal sairia errado e o teste falharia.
      const PlanetPosition(
        planet: Planet.sun,
        sign: ZodiacSign.leo,
        degree: 22,
        minute: 0,
        houseNumber: 10,
        isRetrograde: false,
        longitude: 142.0,
        speed: 0.95,
      ),
      PlanetPosition(
        planet: Planet.moon,
        sign: ZodiacSign.gemini,
        degree: 23,
        minute: 27,
        houseNumber: 3,
        isRetrograde: false,
        longitude: longitudeDaLua,
        speed: 13.1,
      ),
    ],
    houses: const [],
    aspects: const [],
    calculatedAt: DateTime(2026, 1, 1),
    calcVersion: calcVersion,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('calcularParaMapa', () {
    test('usa a longitude da Lua e reproduz o caso de referência', () {
      final linha = LifeErasRepository.calcularParaMapa(
        mapa(longitudeDaLua: 83.4598),
      );

      expect(linha.nascimentoUtc, DateTime.utc(1994, 8, 15, 12, 0));
      expect(linha.regenteNatal, EraRegente.marte);
      expect(linha.nakshatra, 4);
      expect(linha.eras[2].regente, EraRegente.jupiter);
      expect(linha.eras[2].inicio.year, 2016);
      expect(linha.eras[2].fim.year, 2032);
    });

    test('trata a longitude como tropical, não como sideral', () {
      // Alimentar o cálculo com um valor JÁ sideral produz outro setor lunar.
      // Se algum dia alguém remover a subtração da ayanamsa, este teste cai.
      final tropical =
          LifeErasRepository.calcularParaMapa(mapa(longitudeDaLua: 83.4598));
      final comoSeFosseSideral =
          LifeErasRepository.calcularParaMapa(mapa(longitudeDaLua: 59.6819));

      expect(tropical.nakshatra, isNot(comoSeFosseSideral.nakshatra));
    });
  });

  group('load', () {
    test('sem mapa, o estado é incompleto', () async {
      final estado =
          await LifeErasRepository().load(userId: 'bruxa-1', chart: null);
      expect(estado, isA<LifeErasIncomplete>());
    });

    test('com mapa, entrega a linha do tempo', () async {
      final estado = await LifeErasRepository()
          .load(userId: 'bruxa-1', chart: mapa(longitudeDaLua: 83.4598));

      expect(estado, isA<LifeErasReady>());
      final pronta = estado as LifeErasReady;
      expect(pronta.linha.regenteNatal, EraRegente.marte);
      expect(pronta.horaIncerta, isFalse);
    });

    test('hora desconhecida entrega a linha do tempo COM o aviso ligado',
        () async {
      // Decisão de produto: mostrar mesmo assim, nunca sem o aviso.
      final estado = await LifeErasRepository().load(
        userId: 'bruxa-1',
        chart: mapa(longitudeDaLua: 83.4598, horaDesconhecida: true),
      );

      expect(estado, isA<LifeErasReady>());
      expect((estado as LifeErasReady).horaIncerta, isTrue);
    });
  });

  group('Cache', () {
    test('a segunda leitura devolve a mesma linha do tempo', () async {
      final repo = LifeErasRepository();
      final chart = mapa(longitudeDaLua: 83.4598);

      final primeira =
          await repo.load(userId: 'bruxa-1', chart: chart) as LifeErasReady;
      final segunda =
          await repo.load(userId: 'bruxa-1', chart: chart) as LifeErasReady;

      expect(segunda.linha.eras.first.inicio, primeira.linha.eras.first.inicio);
      expect(segunda.linha.eras.last.fim, primeira.linha.eras.last.fim);
      expect(segunda.linha.regenteNatal, primeira.linha.regenteNatal);
    });

    test('recalcular o mapa derruba o cache', () async {
      final repo = LifeErasRepository();

      final antes = await repo.load(
        userId: 'bruxa-1',
        chart: mapa(longitudeDaLua: 83.4598),
      ) as LifeErasReady;

      // Mesmo id, versão de cálculo nova: é o que acontece quando o app sobe
      // `kChartCalcVersion` e recalcula os mapas antigos em silêncio.
      final depois = await repo.load(
        userId: 'bruxa-1',
        chart: mapa(longitudeDaLua: 300.0, calcVersion: 4),
      ) as LifeErasReady;

      expect(antes.linha.regenteNatal, EraRegente.marte);
      expect(depois.linha.regenteNatal, EraRegente.sol);
    });

    test('trocar o mapa derruba o cache', () async {
      final repo = LifeErasRepository();

      await repo.load(userId: 'bruxa-1', chart: mapa(longitudeDaLua: 83.4598));
      final depois = await repo.load(
        userId: 'bruxa-1',
        chart: mapa(longitudeDaLua: 300.0, id: 'mapa-2'),
      ) as LifeErasReady;

      expect(depois.linha.regenteNatal, EraRegente.sol);
    });

    test('cada usuária tem a própria chave', () async {
      final repo = LifeErasRepository();

      final umaBruxa = await repo.load(
        userId: 'bruxa-1',
        chart: mapa(longitudeDaLua: 83.4598),
      ) as LifeErasReady;
      final outraBruxa = await repo.load(
        userId: 'bruxa-2',
        chart: mapa(longitudeDaLua: 300.0),
      ) as LifeErasReady;

      expect(umaBruxa.linha.regenteNatal, EraRegente.marte);
      expect(outraBruxa.linha.regenteNatal, EraRegente.sol);
    });

    test('clear apaga o que estava guardado', () async {
      final repo = LifeErasRepository();
      await repo.load(userId: 'bruxa-1', chart: mapa(longitudeDaLua: 83.4598));
      await repo.clear('bruxa-1');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('life_eras_bruxa-1'), isNull);
    });
  });
}
