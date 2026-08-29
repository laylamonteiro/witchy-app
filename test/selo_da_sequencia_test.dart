/// O topo do "Seu Dia" comemora o que ACONTECE, não o que já estava lá.
///
/// A sequência que sobe com a tela em cena dá um pulso na chama; a que já
/// chega alta (abrir o app com 30 dias) assenta calada, e reconstruir a tela
/// não repete festa nenhuma — o erro clássico deste tipo de widget. O mesmo
/// vale para o degrau de nível: o emoji só troca com respiro quando o título
/// muda de verdade.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/learning/presentation/providers/learning_provider.dart';
import 'package:grimorio_de_bolso/features/your_day/presentation/providers/daily_checkin_provider.dart';
import 'package:grimorio_de_bolso/features/your_day/presentation/widgets/greeting_header.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Check-in sem banco: o cabeçalho só lê isLoaded e streak.
class _CheckinFake extends DailyCheckinProvider {
  _CheckinFake(this._streak);

  int _streak;

  @override
  bool get isLoaded => true;

  @override
  int get streak => _streak;

  void mudaPara(int novo) {
    _streak = novo;
    notifyListeners();
  }

  /// Rebuild sem mudança nenhuma — o cenário que não pode virar festa.
  void cutuca() => notifyListeners();
}

/// Nível sem banco: o cabeçalho só lê level, xp e levelProgress.
class _LearningFake extends LearningProvider {
  _LearningFake(this._level);

  LearningLevel _level;

  @override
  LearningLevel get level => _level;

  @override
  int get xp => _level.minXp;

  @override
  double get levelProgress => 0.5;

  void sobePara(LearningLevel novo) {
    _level = novo;
    notifyListeners();
  }
}

const _aprendiz = LearningLevel('Aprendiz', '🕯️', 0);
const _iniciada = LearningLevel('Iniciada', '🌙', 100);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget app({
    required _CheckinFake checkin,
    required _LearningFake learning,
    bool semAnimacoes = false,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<DailyCheckinProvider>.value(value: checkin),
        ChangeNotifierProvider<LearningProvider>.value(value: learning),
      ],
      child: MaterialApp(
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: semAnimacoes
            ? (context, child) => MediaQuery(
                  data:
                      MediaQuery.of(context).copyWith(disableAnimations: true),
                  child: child!,
                )
            : null,
        home: const Scaffold(body: GreetingHeader()),
      ),
    );
  }

  /// Maior escala aplicada à chama: o pulso vive num Transform.scale em volta
  /// dela, então a matriz denuncia se a comemoração rodou ou não.
  double escalaDaChama(WidgetTester tester) {
    final transforms = tester.widgetList<Transform>(
      find.ancestor(of: find.text('🔥'), matching: find.byType(Transform)),
    );
    var maior = 0.0;
    for (final t in transforms) {
      final sx = t.transform.storage[0];
      if (sx > maior) maior = sx;
    }
    return maior;
  }

  testWidgets('sequência que já chega alta assenta sem pulsar',
      (tester) async {
    final checkin = _CheckinFake(30); // marco, e ainda assim em silêncio
    await tester.pumpWidget(
      app(checkin: checkin, learning: _LearningFake(_aprendiz)),
    );
    // O céu do cabeçalho pisca em laço: nada de pumpAndSettle aqui.
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('🔥'), findsOneWidget);
    expect(escalaDaChama(tester), closeTo(1.0, 0.02),
        reason: 'montar já com 30 dias não é conquista de agora');
    expect(tester.takeException(), isNull);
  });

  testWidgets('sequência que sobe em cena pulsa uma vez e volta ao lugar',
      (tester) async {
    final checkin = _CheckinFake(5);
    await tester.pumpWidget(
      app(checkin: checkin, learning: _LearningFake(_aprendiz)),
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(escalaDaChama(tester), closeTo(1.0, 0.02));

    checkin.mudaPara(6);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(escalaDaChama(tester), greaterThan(1.05),
        reason: 'a chama cresce no instante em que a sequência sobe');

    // E assenta: o pulso é um respiro, não um estado novo.
    await tester.pump(const Duration(milliseconds: 400));
    expect(escalaDaChama(tester), closeTo(1.0, 0.02));

    // Reconstruir com o MESMO número não recomeça nada.
    checkin.cutuca();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(escalaDaChama(tester), closeTo(1.0, 0.02),
        reason: 'rebuild não é conquista');
    expect(tester.takeException(), isNull);
  });

  testWidgets('degrau novo de nível troca o emoji; montar num nível alto não',
      (tester) async {
    final learning = _LearningFake(_aprendiz);
    await tester.pumpWidget(
      app(checkin: _CheckinFake(2), learning: learning),
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('🕯️'), findsOneWidget);

    learning.sobePara(_iniciada);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('🌙'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('com "reduzir movimento" a tela assenta e nada fica animando',
      (tester) async {
    final checkin = _CheckinFake(6);
    await tester.pumpWidget(app(
      checkin: checkin,
      learning: _LearningFake(_aprendiz),
      semAnimacoes: true,
    ));
    // Só termina porque o céu e os selos param sozinhos.
    await tester.pumpAndSettle();

    checkin.mudaPara(7); // marco: nem o brilho dourado pode ligar laço
    await tester.pumpAndSettle();

    expect(escalaDaChama(tester), closeTo(1.0, 0.02));
    expect(tester.takeException(), isNull);
  });
}
