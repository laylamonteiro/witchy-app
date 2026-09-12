import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/user_model.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/tarot/domain/daily_tarot_session.dart';
import 'package:grimorio_de_bolso/features/tarot/presentation/pages/daily_tarot_selection_page.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

class _AuthFixture extends AuthProvider {
  UserModel user = UserModel.defaultUser();
  @override
  UserModel get currentUser => user;

  void switchAccount() {
    user = user.copyWith(id: 'another-account');
    notifyListeners();
  }
}

void main() {
  DailyTarotSession session(String userId, {String? selected}) =>
      DailyTarotSession(
        id: 'test-session',
        userId: userId,
        question: 'A private question',
        dayKey: '2026-9-9',
        dayStart: DateTime(2026, 9, 9),
        dayEnd: DateTime(2026, 9, 10),
        deck: List.generate(78,
            (i) => HiddenTarotCard(id: 'card-$i', reversed: false)),
        selectedId: selected,
        resultId: selected == null ? null : 'test-result',
        resultSignature: selected == null ? null : 'daily-session:test-session',
      );

  Future<void> open(WidgetTester tester, _AuthFixture auth,
      Future<DailyTarotCommit> Function(String) commit,
      List<DailyTarotCommit?> returned) async {
    await tester.pumpWidget(ChangeNotifierProvider<AuthProvider>.value(
      value: auth,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) => Scaffold(
          body: TextButton(
            child: const Text('Open fixture'),
            onPressed: () async {
              final result = await Navigator.of(context).push<DailyTarotCommit>(
                MaterialPageRoute(builder: (_) => DailyTarotSelectionPage(
                  session: session(auth.currentUser.id), onCommit: commit,
                )),
              );
              returned.add(result);
            },
          ),
        )),
      ),
    ));
    await tester.tap(find.text('Open fixture'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('fan-select')));
    await tester.pumpAndSettle();
  }

  testWidgets('double confirm calls once; busy back waits and success returns', (tester) async {
    final auth = _AuthFixture();
    addTearDown(auth.dispose);
    final pending = Completer<DailyTarotCommit>();
    final returned = <DailyTarotCommit?>[];
    final calls = <String>[];
    await open(tester, auth, (id) { calls.add(id); return pending.future; }, returned);
    final choose = tester.widget<FilledButton>(
        find.byKey(const ValueKey('fan-select'))).onPressed!;
    choose();
    choose();
    await tester.pump();
    expect(calls, ['card-39']);
    final context = tester.element(find.byType(DailyTarotSelectionPage));
    await Navigator.of(context).maybePop();
    await tester.pump();
    expect(find.byType(DailyTarotSelectionPage), findsOneWidget);
    pending.complete(DailyTarotCommit(
        session(auth.currentUser.id, selected: calls.single), created: true));
    await tester.pumpAndSettle();
    expect(find.byType(DailyTarotSelectionPage), findsNothing);
    expect(returned.single?.session.selectedId, 'card-39');
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed commit retries the same choice and restores controls', (tester) async {
    final auth = _AuthFixture();
    addTearDown(auth.dispose);
    final returned = <DailyTarotCommit?>[];
    final calls = <String>[];
    await open(tester, auth, (id) async {
      calls.add(id);
      if (calls.length == 1) throw StateError('write failed');
      return DailyTarotCommit(session(auth.currentUser.id, selected: id), created: true);
    }, returned);
    await tester.tap(find.byKey(const ValueKey('fan-select')));
    await tester.pumpAndSettle();
    expect(returned, isEmpty);
    expect(tester.widget<IconButton>(
        find.byKey(const ValueKey('fan-next'))).onPressed, isNull);
    await tester.ensureVisible(find.byKey(const ValueKey('fan-select')));
    await tester.tap(find.byKey(const ValueKey('fan-select')));
    await tester.pumpAndSettle();
    expect(calls, ['card-39', 'card-39']);
    expect(returned.single?.session.isCommitted, isTrue);
  });

  testWidgets('account switch hides the question and closes the old selection', (tester) async {
    final auth = _AuthFixture();
    addTearDown(auth.dispose);
    final returned = <DailyTarotCommit?>[];
    var calls = 0;
    await open(tester, auth, (id) async {
      calls++;
      return DailyTarotCommit(session(auth.currentUser.id, selected: id), created: true);
    }, returned);
    auth.switchAccount();
    await tester.pumpAndSettle();
    expect(find.byType(DailyTarotSelectionPage), findsNothing);
    expect(find.textContaining('A private question'), findsNothing);
    expect(calls, 0);
    expect(returned, [null]);
  });
}
