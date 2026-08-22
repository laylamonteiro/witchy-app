import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/widgets/date_input_field.dart';

/// O campo de data de nascimento que se DIGITA.
///
/// O caso que trouxe este campo: no seletor do Material, quem digitava
/// "07041993" no teclado numérico do Android não achava a barra e ficava
/// preso em "Formato inválido". Aqui a barra é colocada pelo campo.
void main() {
  Widget campo({
    DateTime? valor,
    required ValueChanged<DateTime?> aoMudar,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: DateInputField(
          value: valor,
          onChanged: aoMudar,
          label: 'Data de nascimento',
          hint: 'dd/mm/aaaa',
          invalidMessage: 'Data inválida',
          firstDate: DateTime(1900),
          lastDate: DateTime(2026, 8, 22),
        ),
      ),
    );
  }

  testWidgets('só os números bastam: a barra entra sozinha', (tester) async {
    DateTime? escolhida;
    await tester.pumpWidget(campo(aoMudar: (data) => escolhida = data));

    await tester.enterText(find.byType(TextField), '07041993');
    await tester.pump();

    expect(find.text('07/04/1993'), findsOneWidget);
    expect(escolhida, DateTime(1993, 4, 7));
    expect(find.text('Data inválida'), findsNothing);
  });

  testWidgets('data impossível avisa e não vira valor', (tester) async {
    DateTime? escolhida = DateTime(1990);
    await tester.pumpWidget(campo(aoMudar: (data) => escolhida = data));

    await tester.enterText(find.byType(TextField), '32041993');
    await tester.pump();

    expect(find.text('Data inválida'), findsOneWidget);
    expect(escolhida, isNull);
  });

  testWidgets('data fora do intervalo permitido também avisa', (tester) async {
    DateTime? escolhida = DateTime(1990);
    await tester.pumpWidget(campo(aoMudar: (data) => escolhida = data));

    // Depois de `lastDate`: ninguém nasceu no futuro.
    await tester.enterText(find.byType(TextField), '01012030');
    await tester.pump();

    expect(find.text('Data inválida'), findsOneWidget);
    expect(escolhida, isNull);
  });

  testWidgets('no meio da digitação não acusa erro', (tester) async {
    DateTime? escolhida = DateTime(1990);
    await tester.pumpWidget(campo(aoMudar: (data) => escolhida = data));

    await tester.enterText(find.byType(TextField), '0704');
    await tester.pump();

    expect(find.text('07/04'), findsOneWidget);
    expect(find.text('Data inválida'), findsNothing);
    expect(escolhida, isNull);
  });

  testWidgets('data que já existe aparece escrita no campo', (tester) async {
    await tester.pumpWidget(
      campo(valor: DateTime(1993, 4, 7), aoMudar: (_) {}),
    );

    expect(find.text('07/04/1993'), findsOneWidget);
  });

  testWidgets('data que chega depois (perfil salvo) preenche o campo',
      (tester) async {
    // O perfil da numerologia carrega do disco DEPOIS do primeiro quadro.
    late StateSetter mudar;
    DateTime? valor;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              mudar = setState;
              return DateInputField(
                value: valor,
                onChanged: (_) {},
                label: 'Data de nascimento',
                hint: 'dd/mm/aaaa',
                invalidMessage: 'Data inválida',
                firstDate: DateTime(1900),
                lastDate: DateTime(2026, 8, 22),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('07/04/1993'), findsNothing);
    mudar(() => valor = DateTime(1993, 4, 7));
    await tester.pump();

    expect(find.text('07/04/1993'), findsOneWidget);
  });
}
