import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Observador das rotas da raiz — o [WebBackKeeper] precisa dele para saber
/// quando voltou a ser a tela visível.
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();

/// Mantém sempre uma entrada de histórico do app acima da entrada de boot.
///
/// Na web o voltar caminha pelo histórico do NAVEGADOR, não pela pilha do
/// app. Quando as entradas do app acabam, a próxima é a página anterior da
/// aba — e depois de um login social ela é a do Google. O efeito para quem
/// usa é o app "voltar para o login do Google", indistinguível de um
/// defeito. E nada no Flutter intercepta esse salto: é uma navegação para
/// outra origem, então quando o navegador decide ir, o app já saiu.
///
/// A única defesa é não deixar as entradas do app acabarem. Este widget fica
/// na entrada de baixo e empurra a Home por cima dela; quando o voltar
/// consome essa entrada e esta volta a aparecer, ele empurra outra. O voltar
/// sempre encontra app pela frente, quantas vezes for — e quem quiser sair
/// fecha a aba, que na web é o gesto de sair.
///
/// Embaixo fica uma tela vazia de propósito: quem desenha a Home é a rota
/// empurrada, e duas Homes vivas ao mesmo tempo custariam dois relógios,
/// dois ouvintes e duas sincronizações.
class WebBackKeeper extends StatefulWidget {
  const WebBackKeeper({
    super.key,
    required this.pagina,
    this.rota = '/home',
    this.ativo,
  });

  /// O que a entrada reposta mostra.
  final WidgetBuilder pagina;

  /// O nome da rota reposta: é ele que vira endereço no navegador e, por
  /// consequência, entrada no histórico.
  final String rota;

  /// Sobrepõe o padrão (só na web). Existe para o teste, que roda fora dela.
  final bool? ativo;

  @override
  State<WebBackKeeper> createState() => _WebBackKeeperState();
}

class _WebBackKeeperState extends State<WebBackKeeper> with RouteAware {
  bool get _ativo => widget.ativo ?? kIsWeb;

  @override
  void initState() {
    super.initState();
    if (_ativo) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _repor());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final rota = ModalRoute.of(context);
    if (_ativo && rota is PageRoute) appRouteObserver.subscribe(this, rota);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  /// A rota que estava por cima saiu — o voltar acabou de gastar a entrada
  /// do app. Repõe outra antes que o próximo voltar chegue ao fim da pilha.
  @override
  void didPopNext() => _repor();

  void _repor() {
    if (!mounted) return;
    final navigator = Navigator.of(context);
    // Já existe app por cima: nada a repor (e nada de empilhar duas Homes).
    if (navigator.canPop()) return;
    navigator.push(
      PageRouteBuilder<void>(
        settings: RouteSettings(name: widget.rota),
        // Sem transição: a reposição é mecânica de histórico, não uma
        // viagem entre telas. Meio segundo de escurecimento a cada voltar
        // seria o app piscando sem motivo visível.
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, _, __) => widget.pagina(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
