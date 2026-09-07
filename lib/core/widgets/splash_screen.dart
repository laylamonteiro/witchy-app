import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/grimoire_colors.dart';

/// Abertura do app: apenas o logo, sem texto — POR CIMA do app, nunca no
/// lugar dele.
///
/// A versão anterior, passados 2,5 s, fazia `Navigator.pushReplacement` do
/// conteúdo inteiro da Home. Isso vinha de antes do go_router: hoje a Home é
/// uma rota DE PÁGINA do Navigator raiz, e substituí-la por uma rota
/// imperativa deixava dois estados da Home vivos — os closures da cópia
/// visível (o "Pular tour", as abas) apontavam para um State descartado, e
/// os Navigators das abas (GlobalKey) eram roubados de uma cópia para a
/// outra a cada rebuild (o teclado abrindo, por exemplo), derrubando o foco
/// de qualquer campo de texto. Sintomas reais: "Pular tour" sem efeito e o
/// teclado fechando sozinho na web.
///
/// Agora o [child] é montado desde o primeiro quadro e o logo é só uma
/// camada que esmaece e sai. Nenhuma rota é empurrada.
class SplashScreen extends StatefulWidget {
  final Widget child;

  const SplashScreen({super.key, required this.child});

  /// Quanto tempo o logo fica na tela antes de esmaecer.
  static const Duration duracao = Duration(milliseconds: 2500);

  /// Duração do fade de saída (a mesma da transição antiga).
  static const Duration saida = Duration(milliseconds: 500);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrada = AnimationController(
    duration: const Duration(milliseconds: 2000),
    vsync: this,
  );
  late final AnimationController _saida = AnimationController(
    duration: SplashScreen.saida,
    vsync: this,
  );

  late final Animation<double> _fadeDoLogo =
      Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: _entrada,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ),
  );
  late final Animation<double> _escalaDoLogo =
      Tween<double>(begin: 0.88, end: 1.0).animate(
    CurvedAnimation(
      parent: _entrada,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ),
  );
  late final Animation<double> _opacidadeDaCamada =
      Tween<double>(begin: 1.0, end: 0.0).animate(_saida);

  /// A camada do logo ainda está na árvore (some depois do fade).
  bool _visivel = true;

  @override
  void initState() {
    super.initState();
    _entrada.forward();
    // Tempo preservado: só o que acontece no fim mudou (fade da camada, em
    // vez de troca de rota).
    Future<void>.delayed(SplashScreen.duracao, _esmaecer);
  }

  Future<void> _esmaecer() async {
    if (!mounted) return;
    await _saida.forward();
    if (mounted) setState(() => _visivel = false);
  }

  @override
  void dispose() {
    _entrada.dispose();
    _saida.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_visivel)
          Positioned.fill(
            child: FadeTransition(
              opacity: _opacidadeDaCamada,
              // Enquanto o logo está na frente, nenhum toque chega ao app.
              child: AbsorbPointer(
                child: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle.light,
                  child: ColoredBox(
                    color: context.gc.background,
                    child: Center(
                      child: FadeTransition(
                        opacity: _fadeDoLogo,
                        child: ScaleTransition(
                          scale: _escalaDoLogo,
                          child: Image.asset(
                            'assets/app_icon.png',
                            width: 160,
                            height: 160,
                            // Sem texto de reserva: se o logo não carregar, a
                            // tela fica apenas no fundo do app e segue para o
                            // conteúdo.
                            errorBuilder: (_, __, ___) => const SizedBox(
                              width: 160,
                              height: 160,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
