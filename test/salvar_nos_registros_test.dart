/// O botão "Salvar nos Registros" salva UMA vez: depois vira confirmação
/// (marcador preenchido, mint) e não aceita novo toque. O contrato inclui o
/// feedback: um haptic no sucesso — e nenhum segundo salvamento por mais que
/// se toque de novo. Com "reduzir movimento", a troca é instantânea.
///
/// O botão grava pelo repositório de verdade (sqflite ffi), e isso decide a
/// forma do teste: abrir o banco é I/O de disco, que o relógio FALSO do
/// testWidgets não avança — o await ficaria pendurado para sempre e a
/// confirmação nunca chegaria à tela. Por isso o banco é aberto uma vez em
/// setUpAll (relógio real) e a espera pelo insert alterna tempo real
/// (runAsync) com desenho (pump), sempre com teto.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/features/diary/data/models/free_writing_model.dart';
import 'package:grimorio_de_bolso/features/diary/presentation/widgets/save_to_records_button.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  // Sem isolate: o SQLite responde no mesmo isolate, em vez de mensagens que
  // o relógio falso do teste de widget não entregaria.
  databaseFactory = databaseFactoryFfiNoIsolate;

  late List<String> hapticos;

  setUpAll(() async {
    // Abre (e cria) o banco aqui fora, onde o relógio é real: dentro do
    // testWidgets essa abertura nunca completaria.
    await DatabaseHelper.instance.database;
  });

  setUp(() {
    hapticos = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        hapticos.add(call.arguments as String);
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Widget app(Widget child, {bool semAnimacoes = false}) => MaterialApp(
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
        home: Scaffold(body: Center(child: child)),
      );

  /// Toca em salvar e espera a confirmação chegar à tela: cada volta dá um
  /// tempo REAL ao insert (runAsync) e desenha um quadro (pump). O teto de
  /// 50 voltas (~1s) faz o teste falhar por asserção em vez de pendurar a
  /// suíte se o salvamento nunca completar.
  Future<void> tocarEmSalvar(WidgetTester tester) async {
    await tester.tap(find.byType(OutlinedButton));
    for (var i = 0; i < 50; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
      if (find.byIcon(Icons.bookmark_added).evaluate().isNotEmpty) return;
    }
  }

  /// O SnackBar de confirmação fica alguns segundos em cena; sem deixar o
  /// timer dele terminar, o binding acusa timer pendente no fim do teste.
  Future<void> deixarOAvisoPassar(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  testWidgets('salva uma vez, vira confirmação e ignora o segundo toque',
      (tester) async {
    var entradasMontadas = 0;
    await tester.pumpWidget(app(SaveToRecordsButton(
      buildEntry: () {
        entradasMontadas++;
        return FreeWritingModel(
          userId: 'u-teste',
          title: 'leitura',
          content: 'conteúdo',
          source: FreeWritingSource.pendulum,
        );
      },
    )));

    expect(find.byIcon(Icons.bookmark_add_outlined), findsOneWidget);

    await tocarEmSalvar(tester);
    await tester.pumpAndSettle();

    expect(entradasMontadas, 1);
    expect(find.byIcon(Icons.bookmark_added), findsOneWidget);
    expect(hapticos, ['HapticFeedbackType.selectionClick']);
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).enabled,
      isFalse,
    );

    // Segundo toque: botão desabilitado, nada salva de novo.
    await tester.tap(find.byType(OutlinedButton), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(entradasMontadas, 1);
    expect(hapticos.length, 1);

    await deixarOAvisoPassar(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduzir movimento: confirmação instantânea, mesmo contrato',
      (tester) async {
    var entradasMontadas = 0;
    await tester.pumpWidget(app(
      SaveToRecordsButton(
        buildEntry: () {
          entradasMontadas++;
          return FreeWritingModel(
            userId: 'u-teste',
            title: 'leitura',
            content: 'conteúdo',
            source: FreeWritingSource.tarot,
          );
        },
      ),
      semAnimacoes: true,
    ));

    await tocarEmSalvar(tester);
    // Um quadro a mais, sem avançar o relógio: com duração zero o ícone
    // antigo já saiu: com os 260 ms de sempre ele ainda estaria em cena.
    await tester.pump();

    expect(entradasMontadas, 1);
    expect(find.byIcon(Icons.bookmark_added), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_add_outlined), findsNothing);
    expect(hapticos, ['HapticFeedbackType.selectionClick']);

    await deixarOAvisoPassar(tester);
    expect(tester.takeException(), isNull);
  });
}
