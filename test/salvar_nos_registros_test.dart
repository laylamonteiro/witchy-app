/// O botão "Salvar nos Registros" salva UMA vez: depois vira confirmação
/// (marcador preenchido, mint) e não aceita novo toque. O contrato inclui o
/// feedback: um haptic no sucesso — e nenhum segundo salvamento por mais que
/// se toque de novo. Com "reduzir movimento", a troca é instantânea.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/diary/data/models/free_writing_model.dart';
import 'package:grimorio_de_bolso/features/diary/presentation/widgets/save_to_records_button.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late List<String> hapticos;

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

    await tester.tap(find.byType(OutlinedButton));
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

    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();

    expect(entradasMontadas, 1);
    expect(find.byIcon(Icons.bookmark_added), findsOneWidget);
    expect(hapticos, ['HapticFeedbackType.selectionClick']);
    expect(tester.takeException(), isNull);
  });
}
