import 'package:flutter/material.dart';

import '../theme/grimoire_colors.dart';
import '../theme/grimoire_motion.dart';
import 'estrela_de_quatro_pontas.dart';

/// Cenas ilustradas do estado vazio — cada canto do Grimório tem a sua.
///
/// Tudo desenhado com CustomPainter em tons apagados do tema; nada de
/// assets novos. O único ponto de cor é o elemento "mágico" da cena,
/// sempre com alfa baixo — vazio não compete com conteúdo.
enum MagicalEmptyStateType {
  /// Pote de gratidões com uma estrela quase apagada dentro.
  gratitude,

  /// Lua minguando sobre um travesseiro.
  dreams,

  /// Estrela cadente esperando ser acesa.
  desires,

  /// Pena pousada sobre uma página em branco.
  writing,

  /// Lente de busca com pontinhos apagados.
  search,

  /// Livro fechado com uma estrela discreta na capa.
  generic,
}

/// Estado vazio padrão do app: ilustração (ou ícone legado) + mensagem +
/// ação opcional.
///
/// Compatibilidade: chamadores antigos que só passam [icon] continuam com
/// o visual de antes. Com [type], entra a cena ilustrada; sem nenhum dos
/// dois, vale a cena genérica.
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final MagicalEmptyStateType? type;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon,
    this.type,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    // A ilustração vence quando declarada; o ícone segura o formato antigo.
    final variante =
        type ?? (icon == null ? MagicalEmptyStateType.generic : null);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (variante != null)
              _EmptyIllustration(type: variante)
            else
              Icon(
                icon,
                size: 80,
                color: context.gc.surfaceBorder,
              ),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.gc.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A cena de 112 pt com movimento ambiente mínimo: OU a ilustração flutua
/// ~2 px, OU o elemento mágico pisca devagar — um só por variante, para o
/// vazio respirar sem virar espetáculo.
class _EmptyIllustration extends StatefulWidget {
  final MagicalEmptyStateType type;

  const _EmptyIllustration({required this.type});

  @override
  State<_EmptyIllustration> createState() => _EmptyIllustrationState();
}

class _EmptyIllustrationState extends State<_EmptyIllustration>
    with SingleTickerProviderStateMixin {
  // 3,4 s: o mesmo fôlego das outras respirações do app.
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3400),
  );

  // null = preferência de movimento ainda não lida. O loop só liga depois
  // de consultá-la — um repeat() no initState travaria pumpAndSettle nos
  // testes e ignoraria "reduzir movimento".
  bool? _reduced;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = GrimoireMotion.reduced(context);
    if (reduced == _reduced) return;
    _reduced = reduced;
    if (reduced) {
      _c.stop();
      _c.value = 0.5; // quadro médio: brilho presente, cena assentada
    } else {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  bool get _floats =>
      widget.type == MagicalEmptyStateType.dreams ||
      widget.type == MagicalEmptyStateType.writing;

  @override
  Widget build(BuildContext context) {
    final gc = context.gc;
    final flutua = _floats;
    // Decorativa: o leitor de tela fica só com a mensagem de texto.
    return ExcludeSemantics(
      child: SizedBox(
        key: const ValueKey('empty_state_illustration'),
        width: 112,
        height: 112,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = Curves.easeInOut.transform(_c.value);
            final cena = CustomPaint(
              size: const Size.square(112),
              painter: _ScenePainter(
                type: widget.type,
                gc: gc,
                // Cena que flutua não pisca: o brilho fica na fase média.
                t: flutua ? 0.5 : t,
              ),
            );
            if (!flutua) return cena;
            return Transform.translate(
              offset: Offset(0, (t - 0.5) * 4), // ±2 px, bem devagar
              child: cena,
            );
          },
        ),
      ),
    );
  }
}

/// Desenha a cena da variante num espaço fixo de 112 pt.
///
/// Base sempre em surfaceBorder/textSecondary; o toque de lilac/starYellow
/// entra com alfa baixo, oscilando com [t] quando a variante pisca.
class _ScenePainter extends CustomPainter {
  final MagicalEmptyStateType type;
  final GrimoireColors gc;

  /// Fase do brilho (0..1).
  final double t;

  const _ScenePainter({
    required this.type,
    required this.gc,
    required this.t,
  });

  Color get _base => gc.surfaceBorder;
  Color get _detalhe => gc.textSecondary.withValues(alpha: 0.55);

  Paint _traco(Color cor, [double largura = 2]) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = largura
    ..strokeCap = StrokeCap.round
    ..color = cor;

  Paint _tinta(Color cor) => Paint()..color = cor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 112, size.height / 112);
    switch (type) {
      case MagicalEmptyStateType.gratitude:
        _paintGratitude(canvas);
        break;
      case MagicalEmptyStateType.dreams:
        _paintDreams(canvas);
        break;
      case MagicalEmptyStateType.desires:
        _paintDesires(canvas);
        break;
      case MagicalEmptyStateType.writing:
        _paintWriting(canvas);
        break;
      case MagicalEmptyStateType.search:
        _paintSearch(canvas);
        break;
      case MagicalEmptyStateType.generic:
        _paintGeneric(canvas);
        break;
    }
  }

  void _paintGratitude(Canvas canvas) {
    // Pote de gratidões fechado; a estrela guardada pisca baixinho.
    final pote = RRect.fromRectAndRadius(
      const Rect.fromLTRB(34, 40, 78, 94),
      const Radius.circular(14),
    );
    canvas.drawRRect(pote, _traco(_base));
    final tampa = RRect.fromRectAndRadius(
      const Rect.fromLTRB(38, 28, 74, 38),
      const Radius.circular(5),
    );
    canvas.drawRRect(tampa, _traco(_detalhe, 1.6));
    const centro = Offset(56, 68);
    canvas.drawCircle(
      centro,
      17,
      _tinta(gc.starYellow.withValues(alpha: 0.05 + 0.09 * t)),
    );
    canvas.drawPath(
      _estrela(centro, 10),
      _tinta(gc.starYellow.withValues(alpha: 0.14 + 0.24 * t)),
    );
  }

  void _paintDreams(Canvas canvas) {
    // Lua sobre travesseiro; aqui quem se move é a cena inteira, flutuando.
    final lua = Path.combine(
      PathOperation.difference,
      Path()
        ..addOval(Rect.fromCircle(center: const Offset(70, 36), radius: 17)),
      Path()
        ..addOval(Rect.fromCircle(center: const Offset(78, 30), radius: 15)),
    );
    canvas.drawPath(lua, _tinta(gc.lilac.withValues(alpha: 0.18 + 0.18 * t)));
    canvas.drawCircle(const Offset(38, 30), 1.8, _tinta(_detalhe));
    canvas.drawCircle(const Offset(50, 48), 1.4, _tinta(_detalhe));
    final travesseiro = RRect.fromRectAndRadius(
      const Rect.fromLTRB(24, 66, 88, 94),
      const Radius.circular(16),
    );
    canvas.drawRRect(travesseiro, _traco(_base));
    canvas.drawLine(
      const Offset(34, 80),
      const Offset(78, 80),
      _traco(gc.textSecondary.withValues(alpha: 0.3), 1.2),
    );
  }

  void _paintDesires(Canvas canvas) {
    // Estrela cadente ainda por acender: rastro apagado, miolo tímido.
    canvas.drawLine(const Offset(22, 34), const Offset(56, 56), _traco(_base));
    canvas.drawLine(
      const Offset(28, 52),
      const Offset(54, 68),
      _traco(_base, 1.6),
    );
    const centro = Offset(72, 66);
    canvas.drawCircle(
      centro,
      21,
      _tinta(gc.starYellow.withValues(alpha: 0.04 + 0.08 * t)),
    );
    final estrela = _estrela(centro, 14);
    canvas.drawPath(
      estrela,
      _tinta(gc.starYellow.withValues(alpha: 0.12 + 0.22 * t)),
    );
    canvas.drawPath(estrela, _traco(_detalhe, 1.4));
  }

  void _paintWriting(Canvas canvas) {
    // Página em branco à espera; a pena flutua junto com a cena.
    final pagina = RRect.fromRectAndRadius(
      const Rect.fromLTRB(28, 26, 84, 94),
      const Radius.circular(8),
    );
    canvas.drawRRect(pagina, _traco(_base));
    final pena = Path()
      ..moveTo(72, 34)
      ..quadraticBezierTo(88, 48, 60, 68)
      ..quadraticBezierTo(56, 50, 72, 34)
      ..close();
    canvas.drawPath(pena, _tinta(gc.textSecondary.withValues(alpha: 0.4)));
    canvas.drawLine(
      const Offset(60, 68),
      const Offset(48, 84),
      _traco(_detalhe, 1.8),
    );
    canvas.drawCircle(
      const Offset(47, 87),
      2.6,
      _tinta(gc.lilac.withValues(alpha: 0.2 + 0.2 * t)),
    );
  }

  void _paintSearch(Canvas canvas) {
    // Lente de busca vazia; um único pontinho guarda um resto de brilho.
    canvas.drawCircle(const Offset(50, 48), 22, _traco(_base, 2.4));
    canvas.drawLine(
      const Offset(66, 64),
      const Offset(84, 82),
      _traco(_base, 4),
    );
    canvas.drawCircle(
      const Offset(42, 44),
      2.4,
      _tinta(gc.textSecondary.withValues(alpha: 0.35)),
    );
    canvas.drawCircle(
      const Offset(52, 58),
      2.0,
      _tinta(gc.textSecondary.withValues(alpha: 0.35)),
    );
    canvas.drawCircle(
      const Offset(57, 40),
      2.6,
      _tinta(gc.lilac.withValues(alpha: 0.18 + 0.24 * t)),
    );
  }

  void _paintGeneric(Canvas canvas) {
    // Livro fechado; a estrela da capa mal se anuncia.
    final capa = RRect.fromRectAndRadius(
      const Rect.fromLTRB(30, 30, 82, 94),
      const Radius.circular(7),
    );
    canvas.drawRRect(capa, _traco(_base));
    canvas.drawLine(
      const Offset(40, 31),
      const Offset(40, 93),
      _traco(_detalhe, 1.4),
    );
    const centro = Offset(61, 62);
    canvas.drawCircle(
      centro,
      14,
      _tinta(gc.starYellow.withValues(alpha: 0.04 + 0.07 * t)),
    );
    canvas.drawPath(
      _estrela(centro, 8),
      _tinta(gc.starYellow.withValues(alpha: 0.1 + 0.18 * t)),
    );
  }

  /// A silhueta ✦ compartilhada, com o miolo um tiquinho mais cheio.
  Path _estrela(Offset centro, double raio) =>
      estrelaDeQuatroPontas(centro, raio, razaoInterna: 0.42);

  @override
  bool shouldRepaint(_ScenePainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.type != type || oldDelegate.gc != gc;
}
