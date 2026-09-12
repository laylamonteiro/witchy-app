import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/divination/data/data_sources/oracle_cards_data_pt.dart';
import 'package:grimorio_de_bolso/features/divination/presentation/oracle_art_registry.dart';
import 'package:grimorio_de_bolso/features/divination/presentation/widgets/oracle_card_face.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

void main() {
  test('every catalog ID resolves and the six scenes point at the right cards', () {
    expect(oracleCardsPt, hasLength(OracleArtRegistry.cardCount));
    for (final card in oracleCardsPt) {
      expect(OracleArtRegistry.covers(card.id), isTrue);
      expect(OracleArtRegistry.of(card.id).id, card.id);
    }
    String name(int id) => oracleCardsPt.firstWhere((c) => c.id == id).name;
    expect({for (final e in OracleArtRegistry.scenes.entries) e.value: name(e.key)}, {
      OracleScene.candle: 'A Vela',
      OracleScene.cauldron: 'O Caldeirão',
      OracleScene.cat: 'O Gato Preto',
      OracleScene.seed: 'A Semente',
      OracleScene.key: 'A Chave',
      OracleScene.door: 'A Porta',
    });
    expect(OracleArtRegistry.of(999).hasScene, isFalse);
    expect(OracleArtRegistry.of(0).scene, OracleScene.none);
  });

  testWidgets('all 44 fronts render at every scene progress without art assets', (tester) async {
    for (final progress in [0.0, .5, 1.0]) {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SingleChildScrollView(child: Wrap(children: [
          for (final card in oracleCardsPt)
            OracleCardFace(card: card, width: 60, sceneProgress: progress),
        ]))),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'progress $progress');
      expect(find.byType(OracleCardFace), findsNWidgets(44));
    }
    expect(find.text('A Vela'), findsOneWidget);
  });

  testWidgets('the focused scene plays once and reduced motion shows the final frame',
      (tester) async {
    final candle = oracleCardsPt.firstWhere((c) => c.id == 6);
    Future<void> show({required bool reduced, Object token = 1}) => tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Scaffold(body: Center(child: OracleSceneCard(card: candle, playToken: token))),
      ),
    ));
    await show(reduced: false);
    await tester.pump();
    final start = tester.widget<OracleCardFace>(find.byType(OracleCardFace)).sceneProgress;
    expect(start, lessThan(1));
    await tester.pumpAndSettle();
    expect(tester.widget<OracleCardFace>(find.byType(OracleCardFace)).sceneProgress, 1);
    await show(reduced: false, token: 2);
    await tester.pump();
    expect(tester.widget<OracleCardFace>(find.byType(OracleCardFace)).sceneProgress, lessThan(1));
    await tester.pumpAndSettle();
    await show(reduced: true, token: 3);
    await tester.pump();
    expect(tester.widget<OracleCardFace>(find.byType(OracleCardFace)).sceneProgress, 1);
  });
}
