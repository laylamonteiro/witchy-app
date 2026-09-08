import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/pages/auth_wrapper.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/pages/janela_de_login_app.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

// A janela de login (a segunda aba que volta do Google) rodava o boot inteiro
// do app — inclusive abrir o banco, que na web mora no IndexedDB da origem e
// já tem dono na aba de verdade. Daí o ConstraintError logo depois do login.
//
// Agora ela sobe SÓ esta tela. O teste guarda o que isso significa: nenhum
// provider, nenhum serviço — se alguém voltar a pendurar o app inteiro aqui,
// isto quebra.
void main() {
  testWidgets('a janela sobe sozinha, sem providers, e diz que pode fechar',
      (tester) async {
    await tester.pumpWidget(const JanelaDeLoginApp());
    await tester.pumpAndSettle();

    expect(find.byType(JanelaDeLoginConcluida), findsOneWidget);

    final contexto = tester.element(find.byType(JanelaDeLoginConcluida));
    final l10n = AppLocalizations.of(contexto);
    expect(find.text(l10n.authPopupDoneTitle), findsOneWidget);
    expect(find.text(l10n.authPopupDoneBody), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
