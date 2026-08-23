import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Segura o voltar do navegador nas telas que ficam ENTRE o Google e a Home.
///
/// Na web o voltar caminha pelo histórico do navegador, e depois de um login
/// social a entrada anterior é `accounts.google.com`. O Flutter guarda uma
/// entrada extra de histórico justamente para poder consultar o app antes de
/// deixá-lo — mas ele só consulta se houver um [PopScope] montado dizendo
/// não. Sem nenhum, o primeiro voltar leva a pessoa para fora.
///
/// A HomePage já tem o seu (`canPop: false`). O que faltava eram as telas do
/// meio: a espera de até 15 segundos pela sessão que volta do OAuth, e a
/// porta de entrada quando essa espera termina sem sessão. É exatamente a
/// janela em que o Google é a página anterior — e a única em que o defeito
/// que originou este trabalho ainda aparecia.
///
/// A entrada com o Google DENTRO da página (`GoogleSignInConfig`) evita o
/// histórico na origem, mas ela tem várias condições para funcionar e cai no
/// redirecionamento quando qualquer uma falha. Enquanto o redirecionamento
/// existir, este guarda precisa existir.
///
/// **Fora da web não faz nada**, de propósito: no celular o voltar na
/// primeira tela é como se fecha o app, e engoli-lo prenderia a pessoa
/// dentro da porta de entrada sem saída nenhuma.
class GuardaDeVoltarWeb extends StatelessWidget {
  const GuardaDeVoltarWeb({
    super.key,
    required this.child,
    this.naWeb = kIsWeb,
  });

  final Widget child;

  /// Só o teste passa este valor. Ele existe para que os DOIS lados da regra
  /// possam ser exercitados: a suíte roda na VM, onde `kIsWeb` é sempre
  /// falso, e sem isto a metade que importa nunca seria verificada.
  final bool naWeb;

  @override
  Widget build(BuildContext context) {
    if (!naWeb) return child;

    // Sem `onPopInvokedWithResult`: não há nada a fazer além de não sair.
    // Estas telas não têm pilha interna para desempilhar — a de espera é um
    // spinner, e a de boas-vindas é a raiz do fluxo de entrada.
    return PopScope(canPop: false, child: child);
  }
}
