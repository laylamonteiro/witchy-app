import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/feature_access.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/palmistry/presentation/pages/palmistry_page.dart';
import 'package:grimorio_de_bolso/features/palmistry/presentation/widgets/palm_scan_view.dart';
import 'package:grimorio_de_bolso/features/your_day/presentation/providers/daily_checkin_provider.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'support/short_test_timeout.dart';

class _PremiumFixture extends AuthProvider {
  int readings = 0;

  @override
  bool get isPremiumEffective => true;
  @override
  bool get canUsePalmistry => true;
  @override
  int get remainingPalmistryReadings => 3;
  @override
  AccessResult checkFeatureAccess(AppFeature feature) => AccessResult.full();
  @override
  Future<void> incrementPalmistryReadings() async => readings++;
}

class _CheckinFixture extends DailyCheckinProvider {
  final rites = <String>[];
  @override
  Future<void> completeRite(String riteId) async => rites.add(riteId);
}

void main() {
  useShortTestTimeout();

  /// Uma foto plausível: acima do mínimo que a tela exige.
  final photo = Uint8List.fromList(List<int>.filled(40 * 1024, 7));
  final tiny = Uint8List.fromList(List<int>.filled(1024, 7));

  late _PremiumFixture auth;
  late _CheckinFixture checkin;

  setUp(() {
    auth = _PremiumFixture();
    checkin = _CheckinFixture();
  });

  Future<void> show(
    WidgetTester tester, {
    required Future<Uint8List?> Function(ImageSource) choose,
    required Future<String> Function(Uint8List) analyze,
  }) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ChangeNotifierProvider<DailyCheckinProvider>.value(value: checkin),
      ],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: PalmistryPage(choosePhoto: choose, analyzePalm: analyze),
      ),
    ));
    await tester.pump();
  }

  Future<void> tapCamera(WidgetTester tester) async {
    final l10n = AppLocalizations.of(tester.element(find.byType(PalmistryPage)));
    await tester.ensureVisible(find.text(l10n.palmCamera));
    await tester.tap(find.text(l10n.palmCamera));
    await tester.pump();
  }

  Future<void> settle(WidgetTester tester, bool Function() ready, String stage) async {
    for (var i = 0; i < 80; i++) {
      await tester.pump(const Duration(milliseconds: 20));
      if (ready()) return;
    }
    fail('Palmistry did not reach: $stage');
  }

  testWidgets('giving up on the photo leaves the screen exactly as it was',
      (tester) async {
    var analyzed = 0;
    await show(tester,
        choose: (_) async => null,
        analyze: (_) async {
          analyzed++;
          return 'never';
        });
    final l10n = AppLocalizations.of(tester.element(find.byType(PalmistryPage)));
    await tapCamera(tester);
    await tester.pump(const Duration(milliseconds: 100));
    expect(analyzed, 0, reason: 'No photo, no vision call');
    expect(find.byType(PalmScanView), findsNothing);
    expect(find.byKey(const ValueKey('palm-retry')), findsNothing);
    expect(find.text(l10n.palmYourReading), findsNothing);
    expect(auth.readings, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failure is visible, keeps the photo and only an explicit retry asks again',
      (tester) async {
    var calls = 0;
    await show(tester,
        choose: (_) async => photo,
        analyze: (_) async {
          calls++;
          if (calls == 1) throw Exception('network down');
          return '◈ Life line\n\nA long, steady line.';
        });
    final l10n = AppLocalizations.of(tester.element(find.byType(PalmistryPage)));
    await tapCamera(tester);
    await settle(tester, () => find.byKey(const ValueKey('palm-retry')).evaluate().isNotEmpty,
        'the failure');
    expect(find.text('network down'), findsOneWidget);
    expect(find.text(l10n.palmYourReading), findsNothing,
        reason: 'No success is announced');
    expect(auth.readings, 0, reason: 'A failed reading never spends the quota');
    expect(checkin.rites, isEmpty);
    expect(calls, 1);

    await tester.ensureVisible(find.byKey(const ValueKey('palm-retry')));
    await tester.tap(find.byKey(const ValueKey('palm-retry')));
    await settle(tester, () => find.text(l10n.palmYourReading).evaluate().isNotEmpty,
        'the reading after the retry');
    expect(calls, 2, reason: 'The same photo, asked again only because it was asked');
    expect(find.byKey(const ValueKey('palm-retry')), findsNothing);
    expect(auth.readings, 1, reason: 'The quota is spent once, when the reading arrives');
    expect(checkin.rites, [DailyRites.palmistry]);
    expect(find.byType(PalmScanView), findsNothing,
        reason: 'The scan stops when the request does');
    expect(tester.takeException(), isNull);
  });

  testWidgets('a photo that is too small is refused before any vision call',
      (tester) async {
    var analyzed = 0;
    await show(tester,
        choose: (_) async => tiny,
        analyze: (_) async {
          analyzed++;
          return 'never';
        });
    final l10n = AppLocalizations.of(tester.element(find.byType(PalmistryPage)));
    await tapCamera(tester);
    await settle(tester, () => find.text(l10n.palmImageTooSmall).evaluate().isNotEmpty,
        'the size warning');
    expect(analyzed, 0);
    expect(find.byKey(const ValueKey('palm-retry')), findsNothing,
        reason: 'Asking again for the same small photo would fail the same way');
    expect(auth.readings, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the scan runs only while the real request lasts', (tester) async {
    final pending = Completer<String>();
    await show(tester,
        choose: (_) async => photo,
        analyze: (_) => pending.future);
    await tapCamera(tester);
    await settle(tester, () => find.byType(PalmScanView).evaluate().isNotEmpty,
        'the scan');
    expect(tester.widget<PalmScanView>(find.byType(PalmScanView)).active, isTrue);
    pending.complete('◈ Heart line\n\nWide open.');
    final l10n = AppLocalizations.of(tester.element(find.byType(PalmistryPage)));
    await settle(tester, () => find.text(l10n.palmYourReading).evaluate().isNotEmpty,
        'the reading');
    expect(find.byType(PalmScanView), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
