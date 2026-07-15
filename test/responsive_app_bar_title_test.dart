import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/theme/app_theme.dart';

void main() {
  testWidgets(
    'mantém título longo em uma linha sem overflow em tela estreita',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(240, 500));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(2.5),
            ),
            child: Scaffold(
              appBar: AppBar(
                title: const ResponsiveAppBarTitle(
                  'Sugestões Personalizadas para o Seu Dia',
                ),
                actions: const [
                  IconButton(onPressed: null, icon: Icon(Icons.settings)),
                ],
              ),
            ),
          ),
        ),
      );

      expect(
          find.text('Sugestões Personalizadas para o Seu Dia'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final text = tester.widget<Text>(
        find.text('Sugestões Personalizadas para o Seu Dia'),
      );
      expect(text.maxLines, 1);
      expect(text.softWrap, isFalse);

      final fittedBox = tester.widget<FittedBox>(
        find.ancestor(
          of: find.text('Sugestões Personalizadas para o Seu Dia'),
          matching: find.byType(FittedBox),
        ),
      );
      expect(fittedBox.fit, BoxFit.scaleDown);
    },
  );
}
