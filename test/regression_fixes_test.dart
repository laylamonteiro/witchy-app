import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grimorio_de_bolso/core/services/data_sync_service.dart';
import 'package:grimorio_de_bolso/core/services/notification_service.dart';
import 'package:grimorio_de_bolso/core/widgets/mascot/cat_chat_bubble.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/enums.dart';
import 'package:grimorio_de_bolso/features/astrology/data/models/transit_model.dart';
import 'package:grimorio_de_bolso/features/astrology/data/services/transit_interpreter.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DataSyncService converters', () {
    final service = DataSyncService();

    test('converte timestamps e booleanos nos dois sentidos', () {
      final local = {
        'id': '00000000-0000-4000-8000-000000000001',
        'user_id': 'local_user',
        'name': 'Teste',
        'purpose': 'Teste',
        'type': 'attraction',
        'category': 'other',
        'steps': 'Passo',
        'ingredients': '',
        'is_preloaded': 0,
        'created_at': 1700000000000,
        'updated_at': 1700000001000,
        'synced': 0,
      };
      final remote = service.toRemoteForTest(
        'spells',
        local,
        '00000000-0000-4000-8000-000000000099',
      );

      expect(remote['user_id'], '00000000-0000-4000-8000-000000000099');
      expect(remote['is_preloaded'], isFalse);
      expect(remote['created_at'], isA<String>());
      expect(remote, isNot(contains('synced')));

      final roundTrip = service.toLocalForTest('spells', remote);
      expect(roundTrip['is_preloaded'], 0);
      expect(roundTrip['created_at'], 1700000000000);
      expect(roundTrip['updated_at'], 1700000001000);
      expect(roundTrip['synced'], 1);
    });

    test('converte JSON textual para JSONB e de volta', () {
      final remote = service.toRemoteForTest(
        'birth_charts',
        {
          'id': '00000000-0000-4000-8000-000000000001',
          'chart_data': '{"userId":"local_user"}',
          'unknown_birth_time': 1,
          'birth_date': 1700000000000,
          'calculated_at': 1700000000000,
          'updated_at': 1700000000000,
          'synced': 0,
        },
        '00000000-0000-4000-8000-000000000099',
      );
      expect(remote['chart_data'], isA<Map<String, dynamic>>());
      expect(remote['unknown_birth_time'], isTrue);

      final local = service.toLocalForTest('birth_charts', remote);
      expect(local['chart_data'], '{"userId":"local_user"}');
      expect(local['unknown_birth_time'], 1);
    });
  });

  group('Notification scheduling helpers', () {
    test('gera IDs estáveis e diferentes por evento', () {
      final date = DateTime(2026, 8, 28);
      final full = NotificationService.notificationId('full_moon', date);
      final newMoon = NotificationService.notificationId('new_moon', date);
      expect(full, NotificationService.notificationId('full_moon', date));
      expect(full, isNot(newMoon));
    });

    test('cria lembretes em horário local fixo', () {
      final event = DateTime(2026, 3, 1, 14, 30);
      final moon = NotificationService.reminderDate(
        event,
        daysBefore: 1,
        hour: 20,
      );
      final sabbat = NotificationService.reminderDate(
        event,
        daysBefore: 3,
        hour: 9,
      );
      expect(moon, DateTime(2026, 2, 28, 20));
      expect(sabbat, DateTime(2026, 2, 26, 9));
    });
  });

  group('Energia do Dia', () {
    final interpreter = TransitInterpreter();

    TransitAspect aspect(AspectType type) => TransitAspect(
          transitPlanet: Planet.sun,
          natalPlanet: Planet.moon,
          aspectType: type,
          orb: 1,
          interpretation: 'Teste',
          energyLevel: EnergyLevel.moderate,
        );

    test('classifica corretamente aspectos tensos e harmoniosos', () {
      expect(
        interpreter.determineOverallEnergyForTest(
          List.generate(3, (_) => aspect(AspectType.conjunction)),
        ),
        EnergyLevel.intense,
      );
      expect(
        interpreter.determineOverallEnergyForTest([
          aspect(AspectType.square),
          aspect(AspectType.opposition),
        ]),
        EnergyLevel.challenging,
      );
      expect(
        interpreter.determineOverallEnergyForTest([
          aspect(AspectType.square),
          aspect(AspectType.sextile),
        ]),
        EnergyLevel.moderate,
      );
      expect(
        interpreter.determineOverallEnergyForTest([
          aspect(AspectType.trine),
          aspect(AspectType.sextile),
        ]),
        EnergyLevel.harmonious,
      );
    });

    test('o cálculo real varia conforme a data', () async {
      final results = <EnergyLevel>{};
      for (final date in [
        DateTime(2026, 7, 1),
        DateTime(2026, 7, 2),
        DateTime(2026, 7, 11),
        DateTime(2026, 1, 12),
      ]) {
        results.add(
            (await interpreter.getDailyMagicalWeather(date)).overallEnergy);
      }
      expect(results.length, greaterThanOrEqualTo(3));
    });
  });

  group('Cat bubble layout', () {
    Future<Size> pumpBubble(
      WidgetTester tester,
      String message, {
      double textScale = 1,
      double width = 320,
    }) async {
      SharedPreferences.setMockInitialValues({});
      await tester.binding.setSurfaceSize(Size(width, 500));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final auth = AuthProvider();
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: auth,
          child: MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(width, 500),
                textScaler: TextScaler.linear(textScale),
              ),
              child: Scaffold(
                body: Stack(
                  children: [
                    CatChatBubble(
                      key: UniqueKey(),
                      mascotPosition: ValueNotifier(const Offset(60, 220)),
                      message: message,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 801));
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
      return tester.getSize(find.byKey(const Key('cat-bubble-size')));
    }

    testWidgets('encolhe para texto curto e limita texto longo',
        (tester) async {
      final short = await pumpBubble(tester, 'Olá!');
      final long = await pumpBubble(
        tester,
        'Uma mensagem longa precisa quebrar linhas automaticamente sem deixar espaços vazios excessivos.',
      );
      expect(short.width, lessThan(long.width));
      expect(long.width, lessThanOrEqualTo(210));
    });

    testWidgets('não estoura em tela estreita com fonte ampliada',
        (tester) async {
      final size = await pumpBubble(
        tester,
        'Descubra a energia mágica preparada para o seu dia.',
        textScale: 1.5,
        width: 240,
      );
      expect(size.width, lessThanOrEqualTo(210));
      expect(tester.takeException(), isNull);
    });

    testWidgets('respeita telas menores que o limite padrão', (tester) async {
      final size = await pumpBubble(
        tester,
        'Uma mensagem longa também deve caber em uma tela muito estreita.',
        width: 180,
      );
      expect(size.width, lessThanOrEqualTo(164));
      expect(tester.takeException(), isNull);
    });
  });
}
