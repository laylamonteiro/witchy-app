// O contador "X registros desde a sua última leitura" lia o banco UMA vez, no
// initState, e a aba do Grimório vive num IndexedStack: o cartão nunca era
// recriado, então apagar registros noutra tela não mexia no número até alguém
// re-tocar o ícone da barra de baixo.
//
// A correção não instala observador de rota nenhum — ela se apoia em duas
// InheritedWidgets que o app JÁ tem: o `TickerMode` que o shell desliga por
// aba e o `isCurrent` do `ModalRoute`. Consultar as duas registra dependência,
// e o `didChangeDependencies` acorda sozinho.
//
// É exatamente essa suposição que este arquivo protege. Ela é de framework, e
// se um dia deixar de valer o cartão volta a mentir EM SILÊNCIO — nenhum teste
// do cartão quebraria, porque o defeito é "não acordou".
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Espelha a lógica do `_CartaoDaLeituraDoCicloState`: conta releituras e só
/// dispara na volta à cena (falso → verdadeiro), nunca a cada rebuild.
class _Sonda extends StatefulWidget {
  const _Sonda(this.aoVoltarACena);

  final VoidCallback aoVoltarACena;

  @override
  State<_Sonda> createState() => _SondaState();
}

class _SondaState extends State<_Sonda> {
  bool _estavaEmCena = true;

  static bool _lerEmCena(BuildContext context) =>
      TickerMode.of(context) && (ModalRoute.of(context)?.isCurrent ?? true);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final emCena = _lerEmCena(context);
    final voltou = emCena && !_estavaEmCena;
    _estavaEmCena = emCena;
    if (!voltou) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.aoVoltarACena();
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  testWidgets('fechar a tela empilhada por cima acorda o cartão',
      (tester) async {
    var releituras = 0;
    final chaveDoNavegador = GlobalKey<NavigatorState>();

    await tester.pumpWidget(MaterialApp(
      navigatorKey: chaveDoNavegador,
      home: Scaffold(body: _Sonda(() => releituras++)),
    ));
    await tester.pumpAndSettle();
    expect(releituras, 0, reason: 'quem carrega a primeira vez é o initState');

    // É o caminho da pessoa: do Ciclos para "Meus Registros", apaga, volta.
    chaveDoNavegador.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => const Scaffold()),
    );
    await tester.pumpAndSettle();
    expect(releituras, 0, reason: 'ir para a outra tela não relê nada');

    chaveDoNavegador.currentState!.pop();
    await tester.pumpAndSettle();
    expect(releituras, 1);
  });

  testWidgets('voltar para a aba acorda o cartão', (tester) async {
    var releituras = 0;

    Widget app({required bool abaEmCena}) => MaterialApp(
          home: Scaffold(
            // O mesmo que o shell do go_router faz com as abas escondidas.
            body: TickerMode(
              enabled: abaEmCena,
              child: _Sonda(() => releituras++),
            ),
          ),
        );

    await tester.pumpWidget(app(abaEmCena: true));
    await tester.pumpAndSettle();
    expect(releituras, 0);

    await tester.pumpWidget(app(abaEmCena: false));
    await tester.pumpAndSettle();
    expect(releituras, 0, reason: 'sair da aba não relê nada');

    await tester.pumpWidget(app(abaEmCena: true));
    await tester.pumpAndSettle();
    expect(releituras, 1);
  });

  testWidgets('rebuild com o cartão em cena não relê', (tester) async {
    // A releitura vai ao banco: presa à TRANSIÇÃO, não ao rebuild. Sem esta
    // guarda, qualquer notificação de provider viraria uma consulta nova.
    var releituras = 0;

    Widget app() => MaterialApp(home: Scaffold(body: _Sonda(() => releituras++)));

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(releituras, 0);
  });
}
