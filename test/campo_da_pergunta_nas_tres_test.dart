// A mesma caixa, no mesmo lugar, nas três adivinhações de carta e pedra.
//
// Era esta a queixa que abriu a mudança: no tarô a pergunta ficava ACIMA das
// tiragens, nas runas ENTRE elas e o botão, e no oráculo não existia. Aqui o
// invariante fica trancado — a caixa é o PRIMEIRO campo da tela de escolha e
// está ACIMA do leque, nas três.
@Timeout(Duration(minutes: 2))
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/divination/contexto_da_tiragem.dart';
import 'package:grimorio_de_bolso/core/divination/regra_da_tiragem.dart';
import 'package:grimorio_de_bolso/core/widgets/campo_da_pergunta.dart';
import 'package:grimorio_de_bolso/core/widgets/magical_card.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/divination/data/data_sources/oracle_cards_data.dart';
import 'package:grimorio_de_bolso/features/divination/data/models/oracle_card_model.dart';
import 'package:grimorio_de_bolso/features/divination/data/repositories/oracle_selection_repository.dart';
import 'package:grimorio_de_bolso/features/divination/domain/oracle_selection_session.dart';
import 'package:grimorio_de_bolso/features/divination/presentation/pages/oracle_selection_page.dart';
import 'package:grimorio_de_bolso/features/divination/presentation/widgets/card_selection_surface.dart';
import 'package:grimorio_de_bolso/features/runes/data/data_sources/runes_data.dart';
import 'package:grimorio_de_bolso/features/runes/data/models/rune_spread_model.dart';
import 'package:grimorio_de_bolso/features/runes/domain/rune_selection_session.dart';
import 'package:grimorio_de_bolso/features/runes/data/repositories/rune_selection_repository.dart';
import 'package:grimorio_de_bolso/features/runes/presentation/pages/rune_selection_page.dart';
import 'package:grimorio_de_bolso/features/runes/presentation/widgets/rune_selection_surface.dart';
import 'package:grimorio_de_bolso/features/tarot/data/data_sources/tarot_cards_data.dart';
import 'package:grimorio_de_bolso/features/tarot/data/repositories/tarot_spread_repository.dart';
import 'package:grimorio_de_bolso/features/tarot/domain/tarot_spread_session.dart';
import 'package:grimorio_de_bolso/features/tarot/presentation/pages/tarot_spread_selection_page.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'support/short_test_timeout.dart';

const _user = 'local_user';
final _dia = DateTime(2026, 9, 15);

class _Auth extends AuthProvider {
  _Auth({this.premium = false});
  final bool premium;
  @override
  bool get isPremiumEffective => premium;
}

Widget _app(Widget tela, {bool premium = false}) => MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
            create: (_) => _Auth(premium: premium)),
      ],
      child: MaterialApp(
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: tela,
      ),
    );

void main() {
  useShortTestTimeout();

  // As sessões nascem AQUI, e não dentro de um testWidgets: lá o relógio é
  // falso, e um Future de banco de verdade nunca completa.
  late RuneSelectionSession runas;
  late TarotSpreadSession tarot;
  late OracleSelectionSession oraculo;
  late OracleSelectionSession semanal;
  late OracleSelectionSession diaria;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    final dir = await Directory.systemTemp.createTemp('campo_da_pergunta');
    await databaseFactory.setDatabasesPath(dir.path);
    await DatabaseHelper.instance.database;

    runas = await RuneSelectionRepository().prepare(userId: _user,
        spread: RuneSpreadType.threeCast, catalog: runesData,
        startNew: true, now: _dia);
    tarot = await TarotSpreadRepository().prepare(userId: _user,
        spread: 'threeCards', catalog: tarotCards, startNew: true, now: _dia);
    oraculo = await OracleSelectionRepository().prepare(userId: _user,
        spread: OracleSpreadType.threeCard, catalog: oracleCardsData,
        startNew: true, now: _dia);
    semanal = await OracleSelectionRepository().prepare(userId: _user,
        spread: OracleSpreadType.weeklyGuidance, catalog: oracleCardsData,
        startNew: true, now: _dia);
    diaria = await OracleSelectionRepository().prepare(userId: _user,
        spread: OracleSpreadType.daily, catalog: oracleCardsData,
        startNew: true, now: _dia);
  });

  /// As três telas de escolha, montadas com uma sessão de verdade.
  List<(String, Widget)> telas() => [
        (
          'runas',
          RuneSelectionPage(
            session: runas,
            positionLabels: const ['A', 'B', 'C'],
            onSelect: (_, __) async => RuneSelectionUpdate(runas),
            contexto: const ContextoDaTiragem(),
            premium: false,
            aoEscreverPergunta: (_) async {},
          )
        ),
        (
          'tarô',
          TarotSpreadSelectionPage(
            session: tarot,
            title: 'Três Cartas',
            positionLabels: const ['A', 'B', 'C'],
            onSelect: (_, __) async => TarotSpreadUpdate(tarot),
            contexto: const ContextoDaTiragem(),
            premium: false,
            aoEscreverPergunta: (_) async {},
          )
        ),
        (
          'oráculo',
          OracleSelectionPage(
            session: oraculo,
            positionLabels: const ['A', 'B', 'C'],
            onSelect: (_, __) async => OracleSelectionUpdate(oraculo),
            contexto: const ContextoDaTiragem(),
            premium: false,
            aoEscreverPergunta: (_) async {},
          )
        ),
      ];

  testWidgets('a caixa é a mesma e vem acima do leque nas três',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final (nome, tela) in telas()) {
      await tester.pumpWidget(_app(tela));
      await tester.pump();

      final campo = find.byKey(const ValueKey('campo-da-pergunta'));
      expect(campo, findsOneWidget, reason: '$nome: a caixa tem de existir');
      expect(find.byType(CampoDaPergunta), findsOneWidget,
          reason: '$nome: é a MESMA caixa, não uma cópia parecida');

      // É o único campo da tela — não há um segundo lugar para perguntar.
      expect(find.byType(TextField), findsOneWidget, reason: nome);

      // E vem ACIMA do leque, que é o que a queixa original pedia.
      final leque = find.byWidgetPredicate((w) =>
          w is CardSelectionSurface || w is RuneSelectionSurface);
      expect(leque, findsOneWidget, reason: nome);
      expect(tester.getTopLeft(campo).dy,
          lessThan(tester.getTopLeft(leque).dy),
          reason: '$nome: a pergunta vem antes da escolha, sempre');

      // O mesmo rótulo nas três: a palavra não pode mudar de tela para tela.
      final l10n = AppLocalizations.of(tester.element(campo));
      expect(find.text(l10n.tarotQuestionLabel), findsOneWidget, reason: nome);

      // A caixa dourada de acento, como no tarô de antes.
      final card = tester
          .widget<MagicalCard>(find
              .ancestor(of: campo, matching: find.byType(MagicalCard))
              .first);
      expect(card.accent, isNotNull, reason: '$nome: a caixa é de acento');
    }
  });

  testWidgets('sem cota, o leque nasce desligado e as duas saídas aparecem',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // A pergunta de hoje já foi feita e a cota acabou: escrever outra coisa
    // não tem tiragem.
    const semCota = ContextoDaTiragem(
        perguntaDoDia: 'vou viajar?', rascunho: 'Vou viajar?', temCota: false);
    await tester.pumpWidget(_app(OracleSelectionPage(
      session: semanal,
      positionLabels: const ['A', 'B', 'C', 'D', 'E'],
      onSelect: (_, __) async => OracleSelectionUpdate(semanal),
      contexto: semCota,
      premium: false,
      aoEscreverPergunta: (_) async {},
    )));
    await tester.pump();
    final campo = find.byKey(const ValueKey('campo-da-pergunta'));
    final l10n = AppLocalizations.of(tester.element(campo));

    await tester.enterText(campo, 'Mudo de casa?');
    await tester.pump();

    expect(find.text(l10n.perguntaAjudaSemCota), findsOneWidget,
        reason: 'o aviso aparece ANTES de qualquer carta ser tocada');
    expect(
        tester
            .widget<CardSelectionSurface>(find.byType(CardSelectionSurface))
            .enabled,
        isFalse,
        reason: 'o leque desliga — não se escolhe a carta para levar o não');

    // A saída livre está à mão, e devolve o estado no mesmo quadro.
    final voltar = find.byKey(const ValueKey('atalho-da-pergunta'));
    expect(voltar, findsOneWidget);
    expect(find.text(l10n.perguntaVoltarParaHoje), findsOneWidget);
    await tester.tap(voltar);
    await tester.pump();
    expect(find.text(l10n.perguntaAjudaLivre), findsOneWidget);
    expect(
        tester
            .widget<CardSelectionSurface>(find.byType(CardSelectionSurface))
            .enabled,
        isTrue);
    expect(tester.widget<TextField>(campo).controller!.text, 'Vou viajar?',
        reason: 'volta na grafia da pessoa, não normalizada');

    // E o campo NUNCA trava: a porta fechada foi abolida deste app.
    expect(tester.widget<TextField>(campo).enabled, isTrue);
  });

  testWidgets('Premium não vê aviso de cota, mas vê "já feita"',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const contexto = ContextoDaTiragem(
        perguntaDoDia: 'vou viajar?',
        temCota: false,
        mesasDeHoje: {'mudo de casa?': 'mesa-de-hoje'});

    await tester.pumpWidget(_app(
        OracleSelectionPage(
          session: diaria,
          positionLabels: const ['A'],
          onSelect: (_, __) async => OracleSelectionUpdate(diaria),
          contexto: contexto,
          premium: true,
          aoEscreverPergunta: (_) async {},
        ),
        premium: true));
    await tester.pump();
    final campo = find.byKey(const ValueKey('campo-da-pergunta'));
    final l10n = AppLocalizations.of(tester.element(campo));

    await tester.enterText(campo, 'Uma pergunta qualquer');
    await tester.pump();
    expect(find.byKey(const ValueKey('aviso-da-pergunta')), findsNothing,
        reason: 'quem não tem cota não precisa ouvir falar dela');

    // "Já feita" vale para qualquer plano: não há sorteio novo, é a mesma mesa.
    await tester.enterText(campo, 'Mudo de casa?');
    await tester.pump();
    expect(find.text(l10n.perguntaAjudaJaFeita), findsOneWidget);
    expect(
        const ContextoDaTiragem(mesasDeHoje: {'mudo de casa?': 'x'})
            .situacaoDe('  MUDO DE CASA? ', premium: true),
        SituacaoDaTiragem.jaFeita);
  });
}
