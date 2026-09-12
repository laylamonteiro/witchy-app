import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/models/spell_model.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_day.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/presentation/widgets/lua_e_voce_card.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'support/short_test_timeout.dart';

/// "A Lua e você" na tela: vazio acolhedor sem começo nenhum; cada começo
/// com a sua data e a sua Lua; o resumo só com quatro começos; e a frase das
/// emoções assim que houver uma escrita num dia de sangue.
///
/// O card recebe o histórico e o hoje por parâmetro — nada de provider nem
/// banco — e é montado sozinho aqui, com a localização do app.
void main() {
  useShortTestTimeout();

  final today = DateTime(2025, 3, 1);
  final l10n = lookupAppLocalizations(const Locale('en'));

  MenstrualDay start(DateTime day, {String? mood}) => MenstrualDay(
      userId: 'she', day: day, mark: MenstrualMark.start, mood: mood);

  MenstrualDay flow(DateTime day, {String? mood}) => MenstrualDay(
      userId: 'she', day: day, mark: MenstrualMark.flow, mood: mood);

  // Quatro começos de Cheia em Cheia, os mesmos do teste do domínio.
  final fullMoonStarts = [
    start(DateTime(2024, 11, 16)),
    start(DateTime(2024, 12, 15)),
    start(DateTime(2025, 1, 14)),
    start(DateTime(2025, 2, 12)),
  ];

  Future<void> show(WidgetTester tester, List<MenstrualDay> days) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          child: LuaEVoceCard(days: days, today: today),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  Finder startRow(DateTime day) =>
      find.byKey(ValueKey('lua-e-voce-start-${MenstrualDay.keyOf(day)}'));

  testWidgets('sem começo nenhum, o card convida a marcar o primeiro',
      (tester) async {
    await show(tester, const []);
    expect(find.text(l10n.menstrualLunarTitle), findsOneWidget);
    expect(find.byKey(const ValueKey('lua-e-voce-empty')), findsOneWidget);
    expect(find.text(l10n.menstrualLunarEmpty), findsOneWidget);
    expect(find.byKey(const ValueKey('lua-e-voce-pending')), findsNothing,
        reason: 'Sem começo não há o que contar até quatro');
    expect(find.text(l10n.menstrualLunarBlessing), findsNothing);
  });

  testWidgets('dois começos mostram duas datas, cada uma com a sua Lua',
      (tester) async {
    await show(tester, fullMoonStarts.sublist(0, 2));
    expect(startRow(DateTime(2024, 11, 16)), findsOneWidget);
    expect(startRow(DateTime(2024, 12, 15)), findsOneWidget);
    // A data, como o aparelho a escreve nesta língua.
    expect(find.textContaining('2024'), findsNWidgets(2));
    // O glifo é enfeite; o nome da fase é o que fala.
    expect(find.text(MoonPhase.fullMoon.displayName), findsNWidgets(2));
    expect(find.text(l10n.menstrualLunarTagFull), findsNWidgets(2));
    expect(find.text(l10n.menstrualLunarPending(2)), findsOneWidget);
    expect(find.byKey(const ValueKey('lua-e-voce-near-full')), findsNothing,
        reason: 'O resumo espera quatro começos');
    expect(find.text(l10n.menstrualLunarBlessing), findsOneWidget);
  });

  testWidgets('com quatro começos entra o resumo dos três ciclos completos',
      (tester) async {
    await show(tester, fullMoonStarts);
    expect(find.byKey(const ValueKey('lua-e-voce-pending')), findsNothing);
    expect(find.text(l10n.menstrualLunarNearFull(3, 3)), findsOneWidget);
    expect(find.byKey(const ValueKey('lua-e-voce-near-new')), findsNothing);
    expect(find.byKey(const ValueKey('lua-e-voce-neither')), findsNothing);
    expect(startRow(DateTime(2025, 2, 12)), findsOneWidget,
        reason: 'O quarto começo fecha o terceiro intervalo e continua '
            'visível');
  });

  testWidgets('uma emoção escrita num dia de sangue vira a frase das emoções',
      (tester) async {
    await show(tester, [
      start(DateTime(2025, 2, 12), mood: 'Cansada'),
      flow(DateTime(2025, 2, 13), mood: 'cansada'),
      flow(DateTime(2025, 2, 14), mood: 'sensível'),
    ]);
    expect(find.text(l10n.menstrualLunarMoodsTitle), findsOneWidget);
    expect(find.text(l10n.menstrualLunarMoods('cansada, sensível')),
        findsOneWidget);
  });

  testWidgets('uma emoção escolhida no chip aparece pelo rótulo, não pelo id',
      (tester) async {
    // O chip grava `sensitive`; a frase diz "Sensitive". E a palavra livre
    // de um registro antigo continua sendo a palavra dela, lado a lado.
    await show(tester, [
      start(DateTime(2025, 2, 12), mood: 'sensitive'),
      flow(DateTime(2025, 2, 13), mood: 'sensitive'),
      flow(DateTime(2025, 2, 14), mood: 'cansada'),
    ]);
    expect(
        find.text(l10n.menstrualLunarMoods(
            '${l10n.menstrualMoodSensitive}, cansada')),
        findsOneWidget);
    expect(find.textContaining('sensitive'), findsNothing);
  });

  testWidgets('sem emoção escrita, a frase das emoções não aparece',
      (tester) async {
    await show(tester, fullMoonStarts);
    expect(find.byKey(const ValueKey('lua-e-voce-moods')), findsNothing);
    expect(find.text(l10n.menstrualLunarMoodsTitle), findsNothing);
  });

  testWidgets(
      'um histórico longo mostra os começos mais recentes e conta o resto',
      (tester) async {
    await show(tester, [
      for (var month = 1; month <= 8; month++)
        start(DateTime(2024, month, 10)),
    ]);
    expect(
      find.byWidgetPredicate((widget) =>
          widget.key is ValueKey<String> &&
          (widget.key as ValueKey<String>)
              .value
              .startsWith('lua-e-voce-start-')),
      findsNWidgets(LuaEVoceCard.shownStarts),
    );
    expect(startRow(DateTime(2024, 1, 10)), findsNothing,
        reason: 'O mais antigo saiu da lista, mas continua contado');
    expect(find.text(l10n.menstrualLunarEarlier(2)), findsOneWidget);
  });
}
