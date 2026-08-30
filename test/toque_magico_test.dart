import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimorio_de_bolso/core/haptics/toque_magico.dart';
import 'package:grimorio_de_bolso/core/widgets/mascot/draggable_cat_mascot.dart';
import 'package:grimorio_de_bolso/features/encyclopedia/presentation/pages/encyclopedia_index_page.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

/// O contrato do toque físico (ago/2026): o carinho no Salem vibra leve, o
/// puf de fumaça e a capa pousando vibram médio — e quem pediu "reduzir
/// movimento" fecha o livro em silêncio, junto com a poeira.
///
/// A perna web (`navigator.vibrate`) é intestável na VM por definição; ela é
/// uma ponte fininha sem decisão nenhuma, e o que se testa aqui é a perna
/// nativa, espiando o canal de plataforma — o mesmo truque de
/// `porteiro_do_voltar_test.dart`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Captura o que o app pede à plataforma; é aqui que o
  /// `HapticFeedback.vibrate` aparece — ou não.
  List<MethodCall> espionarAPlataforma() {
    final chamadas = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (chamada) async {
      chamadas.add(chamada);
      return null;
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    return chamadas;
  }

  List<Object?> vibracoes(List<MethodCall> chamadas) => chamadas
      .where((c) => c.method == 'HapticFeedback.vibrate')
      .map((c) => c.arguments)
      .toList();

  Widget app(Widget child) => MaterialApp(
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );

  group('ToqueMagico', () {
    testWidgets('leve() é o lightImpact do motor', (tester) async {
      final chamadas = espionarAPlataforma();
      ToqueMagico.leve();
      await tester.pump(); // o canal de plataforma entrega em microtask
      expect(vibracoes(chamadas), ['HapticFeedbackType.lightImpact']);
    });

    testWidgets('medio() é o mediumImpact do motor', (tester) async {
      final chamadas = espionarAPlataforma();
      ToqueMagico.medio();
      await tester.pump();
      expect(vibracoes(chamadas), ['HapticFeedbackType.mediumImpact']);
    });
  });

  group('Salem', () {
    Finder gatinho() => find.descendant(
          of: find.byType(DraggableCatMascot),
          matching: find.byType(GestureDetector),
        );

    testWidgets('o carinho vibra leve', (tester) async {
      final chamadas = espionarAPlataforma();
      await tester.pumpWidget(app(const DraggableCatMascot()));
      await tester.pump();

      await tester.tap(gatinho().first);
      await tester.pump(const Duration(milliseconds: 300));

      // O toque no mascote dá SEMPRE um clique leve (selectionClick, pedido
      // explícito da Bruxa) e, quando gera partículas (gato já sentado), também
      // o carinho leve (lightImpact). Ver DraggableCatMascot._onTap.
      expect(vibracoes(chamadas),
          ['HapticFeedbackType.selectionClick', 'HapticFeedbackType.lightImpact']);
    });

    testWidgets('o 5º toque rápido some em fumaça com o toque forte',
        (tester) async {
      final chamadas = espionarAPlataforma();
      var sumiu = false;
      await tester.pumpWidget(app(DraggableCatMascot(
        onDismissed: () => sumiu = true,
      )));
      await tester.pump();

      // Quatro carinhos leves...
      for (var i = 0; i < 4; i++) {
        await tester.tap(gatinho().first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 50));
      }
      // ...e o quinto dissolve o Salem — o puf é o toque médio.
      await tester.tap(gatinho().first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 600));

      expect(sumiu, isTrue);
      expect(vibracoes(chamadas).last, 'HapticFeedbackType.mediumImpact');
    });

    testWidgets('a volta do esconderijo materializa com o toque forte',
        (tester) async {
      final chamadas = espionarAPlataforma();
      var voltou = false;
      await tester.pumpWidget(app(DraggableCatMascot(
        appearInSmoke: true,
        onAppeared: () => voltou = true,
      )));
      // O puf da materialização sai no post-frame; o aviso ao pai, 550ms depois.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(voltou, isTrue);
      expect(vibracoes(chamadas), ['HapticFeedbackType.mediumImpact']);
    });
  });

  group('Capa do Grimório', () {
    testWidgets('com "reduzir movimento", a capa pousa em silêncio',
        (tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      final chamadas = espionarAPlataforma();
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('pt', 'BR'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // Mesmo harness de encyclopedia_sections_test.dart: as estrelas da
        // capa piscam em laço, então o teste roda com disableAnimations —
        // que é exatamente a condição sob a qual a vibração NÃO deve sair
        // (ela mora no mesmo guarda da poeira).
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: Scaffold(body: EncyclopediaIndexPage(onSectionSelected: (_) {})),
      ));
      await tester.pump();

      // Abre a capa (sem animação: instantâneo)...
      await tester.tap(find.byKey(const ValueKey('grimoire-cover')));
      await tester.pump();
      // ...e fecha pelo mesmo caminho do re-toque na bottom bar.
      expect(EncyclopediaIndexPage.toggleCover(), isTrue);
      await tester.pump();

      expect(find.byKey(const ValueKey('grimoire-cover')), findsOneWidget);
      expect(vibracoes(chamadas), isEmpty);
    });
  });
}
