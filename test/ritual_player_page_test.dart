import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/guided_rituals/data/models/guided_rituals_data.dart';
import 'package:grimorio_de_bolso/features/guided_rituals/data/repositories/guided_ritual_log_repository.dart';
import 'package:grimorio_de_bolso/features/guided_rituals/presentation/pages/ritual_player_page.dart';
import 'package:grimorio_de_bolso/features/guided_rituals/presentation/widgets/ritual_circle.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'support/short_test_timeout.dart';

class _PremiumFixture extends AuthProvider {
  @override
  bool get isPremiumEffective => true;
}

class _LogFake extends GuidedRitualLogRepository {
  int calls = 0;
  bool failNext = false;

  @override
  Future<void> logCompletion({
    required String userId,
    required String ritualId,
    required int xp,
    DateTime? eventDate,
    String? notes,
  }) async {
    calls++;
    if (failNext) {
      failNext = false;
      throw Exception('disk full');
    }
  }
}

void main() {
  useShortTestTimeout();
  final ritual = AllGuidedRituals.all.first;

  Future<void> show(WidgetTester tester, _LogFake log) async {
    await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>(
      create: (_) => _PremiumFixture(),
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: RitualPlayerPage(ritual: ritual, repository: log),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> tick(WidgetTester tester, int index) async {
    final box = find.byType(CheckboxListTile).at(index);
    await tester.ensureVisible(box);
    await tester.tap(box);
    await tester.pumpAndSettle();
  }

  testWidgets('the circle lights per step; completion waits for the log and is logged once',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final log = _LogFake()..failNext = true;
    await show(tester, log);
    final steps = ritual.steps.length;
    expect(tester.widget<RitualCircle>(find.byKey(const ValueKey('ritual-circle'))).lit, 0);
    for (var i = 0; i < steps - 1; i++) {
      await tick(tester, i);
      expect(tester.widget<RitualCircle>(find.byKey(const ValueKey('ritual-circle'))).lit, i + 1);
      expect(find.byKey(const ValueKey('ritual-log-retry')), findsNothing);
    }
    final l10n = AppLocalizations.of(tester.element(find.byType(RitualPlayerPage)));
    expect(find.text(l10n.guidedRitualCompletedTitle), findsNothing);

    await tick(tester, steps - 1);
    expect(log.calls, 1);
    expect(find.byKey(const ValueKey('ritual-log-retry')), findsOneWidget,
        reason: 'A failed write offers to resume the recording');
    expect(find.text(l10n.guidedRitualCompletedTitle), findsNothing,
        reason: 'No success is announced before the log succeeded');

    await tester.ensureVisible(find.byKey(const ValueKey('ritual-log-retry')));
    await tester.tap(find.byKey(const ValueKey('ritual-log-retry')));
    await tester.pumpAndSettle();
    expect(log.calls, 2);
    expect(find.text(l10n.guidedRitualCompletedTitle), findsOneWidget);
    expect(tester.widget<RitualCircle>(find.byKey(const ValueKey('ritual-circle'))).isClosed,
        isTrue);

    // Unchecking and checking again never records a second occurrence.
    await tick(tester, 0);
    expect(find.text(l10n.guidedRitualCompletedTitle), findsNothing);
    await tick(tester, 0);
    expect(log.calls, 2);
    expect(find.text(l10n.guidedRitualCompletedTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the circle draws any step count and exposes its progress', (tester) async {
    // A árvore de semântica só existe enquanto alguém a pede.
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Row(children: [
      RitualCircle(steps: 1, lit: 0),
      RitualCircle(steps: 5, lit: 3, emblem: '🔥'),
      RitualCircle(steps: 0, lit: 0),
    ]))));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('3/5'), findsOneWidget);
    expect(find.bySemanticsLabel('0/1'), findsOneWidget,
        reason: 'Each circle keeps its own count');
    expect(find.text('🔥'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
