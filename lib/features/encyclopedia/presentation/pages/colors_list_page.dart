import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../data/models/color_model.dart';
import '../providers/encyclopedia_provider.dart';
import '../widgets/entry_pager.dart';
import 'color_detail_page.dart';

/// Roda de Cores: a porta de entrada da seção — os 20 tons oficiais em
/// ordem cromática. Tocar numa fatia destaca-a como uma pétala e abre o
/// card de correspondências; "Abrir página completa" leva ao verbete, com
/// pager na ordem da roda. Sem entradas pessoais nem busca: em Cores, o
/// conteúdo é a roda e as páginas completas.
class ColorsListPage extends StatefulWidget {
  const ColorsListPage({super.key});

  @override
  State<ColorsListPage> createState() => _ColorsListPageState();
}

class _ColorsListPageState extends State<ColorsListPage>
    with TickerProviderStateMixin {
  /// Ordem cromática sobre os índices de `colorsData` (mesma ordem pt/en/es):
  /// neutros (branco → prateado → cinza → preto), terrosos e quentes
  /// (marrom → vinho → vermelho → laranja → dourado → amarelo), verdes,
  /// azuis e violetas, fechando o círculo no rosa — vizinho do vinho do
  /// outro lado dos neutros.
  static const List<int> _wheelOrder = [
    0, 19, 2, 1, 12, 4, 3, 6, 8, 7, 11, 9, 10, 16, 13, 14, 15, 17, 18, 5,
  ];

  /// Ajustes de exibição para o fundo escuro: preto puro some no fundo,
  /// branco e amarelos puros estouram. O valor CANÔNICO segue sendo o do
  /// modelo — estes tons são só da roda.
  static const Map<int, Color> _displayOverrides = {
    0: Color(0xFFF3EFF6), // Branco
    1: Color(0xFF17121E), // Preto
    2: Color(0xFF8E8B99), // Cinza
    3: Color(0xFFE14B41), // Vermelho
    5: Color(0xFFDE4B7F), // Rosa
    6: Color(0xFFF09A38), // Laranja
    7: Color(0xFFF2E36B), // Amarelo
    8: Color(0xFFE8C34A), // Dourado
    10: Color(0xFF1E5E2B), // Verde-escuro
    13: Color(0xFF8FC6E8), // Azul-claro
    14: Color(0xFF3E8EE0), // Azul
    15: Color(0xFF232E7E), // Azul-marinho
    16: Color(0xFF45CFC4), // Turquesa
    17: Color(0xFF9231A8), // Roxo
    19: Color(0xFFC4C3CE), // Prateado
  };

  /// Geometria lógica da roda (espaço 400×400, como o protótipo aprovado).
  static const double _logicalSide = 400;
  static const double _outerR = 150;
  static const double _innerR = 64;

  late final AnimationController _orbitCtrl; // ornamentos: 1 volta / 90s
  late final AnimationController _sparksCtrl; // pó de estrelas: 70s, reverso
  late final AnimationController _popCtrl; // pétala da seleção

  /// Posição selecionada NA RODA (0..19), não no colorsData.
  int? _selected;
  bool? _reducedMotion;

  @override
  void initState() {
    super.initState();
    _orbitCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 90));
    _sparksCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 70));
    _popCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280), value: 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Céu parado para quem pediu menos movimento (acessibilidade).
    final reduced = MediaQuery.of(context).disableAnimations;
    if (reduced != _reducedMotion) {
      _reducedMotion = reduced;
      if (reduced) {
        _orbitCtrl.stop();
        _sparksCtrl.stop();
      } else {
        _orbitCtrl.repeat();
        _sparksCtrl.repeat();
      }
    }
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _sparksCtrl.dispose();
    _popCtrl.dispose();
    super.dispose();
  }

  ColorModel _modelAt(List<ColorModel> colors, int wheelPos) =>
      colors[_wheelOrder[wheelPos] % colors.length];

  Color _displayAt(List<ColorModel> colors, int wheelPos) {
    final dataIndex = _wheelOrder[wheelPos] % colors.length;
    return _displayOverrides[dataIndex] ?? colors[dataIndex].color;
  }

  void _select(int wheelPos) {
    setState(() => _selected = wheelPos);
    _popCtrl.forward(from: 0);
  }

  void _handleTap(Offset local, double side, int count) {
    final scale = side / _logicalSide;
    final v = local - Offset(side / 2, side / 2);
    final r = v.distance / scale;
    // Aceita um respiro além da borda: a pétala selecionada cresce ~6,5%.
    if (r < _innerR || r > _outerR * 1.08) return;
    final fromTop =
        (math.atan2(v.dy, v.dx) + math.pi / 2 + 2 * math.pi) % (2 * math.pi);
    _select((fromTop / (2 * math.pi / count)).floor() % count);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<EncyclopediaProvider>(
      builder: (context, provider, _) {
        final colors = provider.colors;
        if (colors.isEmpty) return const SizedBox.shrink();
        final count = math.min(_wheelOrder.length, colors.length);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: [
            Text(
              l10n.encyColorsWheelHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.gc.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            _buildWheel(colors, count),
            const SizedBox(height: 4),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: _selected == null
                  ? const SizedBox.shrink()
                  : _buildDetailCard(context, colors, count),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWheel(List<ColorModel> colors, int count) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final side = constraints.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (d) => _handleTap(d.localPosition, side, count),
                child: AnimatedBuilder(
                  animation:
                      Listenable.merge([_orbitCtrl, _sparksCtrl, _popCtrl]),
                  builder: (context, _) => CustomPaint(
                    painter: _WheelPainter(
                      sectors: [
                        for (var i = 0; i < count; i++)
                          _displayAt(colors, i),
                      ],
                      selected: _selected,
                      selScale: 1 +
                          0.065 *
                              Curves.easeOutBack.transform(_popCtrl.value),
                      gapColor: context.gc.background,
                      gold: context.gc.gold,
                      star: context.gc.starYellow,
                      orbitT: _orbitCtrl.value,
                      sparksT: _sparksCtrl.value,
                    ),
                    child: Center(child: _buildHub(colors, side)),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Centro da roda: o espelho da escolha. Em repouso convida; ao escolher,
  /// mostra o tom e o nome.
  Widget _buildHub(List<ColorModel> colors, double side) {
    final l10n = AppLocalizations.of(context);
    final hubSide = side * ((_innerR - 8) * 2 / _logicalSide);
    final selected = _selected;
    return Container(
      width: hubSide,
      height: hubSide,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.gc.surface,
        border: Border.all(
          color: context.gc.gold.withValues(alpha: 0.55),
          width: 1.5,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: selected == null
            ? Center(
                key: const ValueKey('hint'),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    '${l10n.encyColorsWheelCenterHint} ✦',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.gc.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              )
            : Column(
                key: ValueKey('sel$selected'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: hubSide * 0.32,
                    height: hubSide * 0.32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _displayAt(colors, selected),
                      border: Border.all(
                        color: context.gc.textPrimary.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _modelAt(colors, selected).name,
                        maxLines: 1,
                        style: GoogleFonts.cinzelDecorative(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: context.gc.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDetailCard(
      BuildContext context, List<ColorModel> colors, int count) {
    final l10n = AppLocalizations.of(context);
    final selected = _selected!;
    final model = _modelAt(colors, selected);
    final display = _displayAt(colors, selected);

    return Container(
      key: ValueKey('card$selected'),
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: context.gc.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: display.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: display,
                  border: Border.all(
                    color: context.gc.textPrimary.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: display.withValues(alpha: 0.4),
                      blurRadius: 18,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        model.name,
                        maxLines: 1,
                        style: GoogleFonts.cinzelDecorative(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: context.gc.lilac,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      model.meaning,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Cada fatia tem 18°: as setas deixam corrigir o toque e
              // passear pelas cores na ordem da roda, sem re-mirar.
              _pagerButton(Icons.chevron_left,
                  () => _select((selected - 1 + count) % count)),
              const SizedBox(width: 6),
              _pagerButton(
                  Icons.chevron_right, () => _select((selected + 1) % count)),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: model.intentions
                .take(4)
                .map(
                  (intention) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13, vertical: 6),
                    decoration: BoxDecoration(
                      color: display.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: display),
                    ),
                    child: Text(
                      intention,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: context.gc.starYellow,
                side: BorderSide(color: context.gc.gold),
                shape: const StadiumBorder(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EntryPager(
                      itemCount: count,
                      initialIndex: selected,
                      itemBuilder: (_, i) => ColorDetailPage(
                        colorModel: _modelAt(colors, i),
                      ),
                    ),
                  ),
                );
              },
              child: Text('${l10n.encyColorsOpenFull} ✦'),
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: context.gc.textPrimary10, height: 1),
          const SizedBox(height: 10),
          Text(
            l10n.encyColorsDisclaimer,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.gc.textSecondary,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }

  Widget _pagerButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.gc.background,
          border: Border.all(color: context.gc.surfaceBorder),
        ),
        child: Icon(icon, size: 20, color: context.gc.textSecondary),
      ),
    );
  }
}

/// Pinta a roda no espaço lógico 400×400: aro pontilhado dourado com
/// ornamentos de lua e estrela em órbita lenta, pó de estrelas girando ao
/// contrário, e as fatias com frestas na cor do fundo. A fatia selecionada
/// cresce como uma pétala, com brilho da própria cor, e as demais recuam.
class _WheelPainter extends CustomPainter {
  final List<Color> sectors; // já em ordem de roda, tons de exibição
  final int? selected;
  final double selScale;
  final Color gapColor;
  final Color gold;
  final Color star;
  final double orbitT; // 0..1, volta dos ornamentos
  final double sparksT; // 0..1, volta (reversa) do pó de estrelas

  static const double _logicalSide = 400;
  static const double _outerR = 150;
  static const double _innerR = 64;
  static const double _orbitR = 172;
  static const double _ornR = 185;
  static const double _sparkR = 163;
  static const List<String> _glyphs = ['✦', '☾', '✧', '☽', '✦', '✧'];
  static const List<double> _glyphDeg = [-62, 38, 152, 218, 262, 118];
  static const List<double> _sparkDeg = [8, 52, 96, 141, 187, 232, 276, 321];

  _WheelPainter({
    required this.sectors,
    required this.selected,
    required this.selScale,
    required this.gapColor,
    required this.gold,
    required this.star,
    required this.orbitT,
    required this.sparksT,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _logicalSide;
    canvas.save();
    canvas.scale(scale);
    const center = Offset(_logicalSide / 2, _logicalSide / 2);

    _paintOrbit(canvas, center);
    _paintWedges(canvas, center);
    _paintSparks(canvas, center);

    canvas.restore();
  }

  void _paintOrbit(Canvas canvas, Offset center) {
    final dashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = gold.withValues(alpha: 0.45);
    const dashCount = 68;
    final rect = Rect.fromCircle(center: center, radius: _orbitR);
    final spin = orbitT * 2 * math.pi;
    for (var i = 0; i < dashCount; i++) {
      final a = spin + i * 2 * math.pi / dashCount;
      canvas.drawArc(rect, a, 2 / _orbitR, false, dashPaint);
    }

    for (var i = 0; i < _glyphs.length; i++) {
      final a = -math.pi / 2 + _glyphDeg[i] * math.pi / 180 + spin;
      final pos = center +
          Offset(math.cos(a), math.sin(a)) * _ornR;
      final tp = TextPainter(
        text: TextSpan(
          text: _glyphs[i],
          style: TextStyle(
            fontSize: 13,
            color: star.withValues(alpha: 0.9),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  void _paintWedges(Canvas canvas, Offset center) {
    final n = sectors.length;
    final step = 2 * math.pi / n;
    const top = -math.pi / 2;
    final gapPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = gapColor;

    Path? selectedPath;
    Color? selectedColor;
    for (var k = 0; k < n; k++) {
      final path = _sector(center, top + k * step, top + (k + 1) * step);
      if (k == selected) {
        // Pétala: cresce a partir do centro da roda.
        final m = Matrix4.identity()
          ..translate(center.dx, center.dy)
          ..scale(selScale)
          ..translate(-center.dx, -center.dy);
        selectedPath = path.transform(m.storage);
        selectedColor = sectors[k];
        continue; // pinta por último, sobre as vizinhas
      }
      final dimmed = selected != null;
      final fill = Paint()
        ..color = dimmed
            ? sectors[k].withValues(alpha: 0.4)
            : sectors[k];
      canvas.drawPath(path, fill);
      canvas.drawPath(path, gapPaint);
    }

    if (selectedPath != null && selectedColor != null) {
      final glow = Paint()
        ..color = selectedColor.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
      canvas.drawPath(selectedPath, glow);
      canvas.drawPath(selectedPath, Paint()..color = selectedColor);
      canvas.drawPath(selectedPath, gapPaint);
    }
  }

  void _paintSparks(Canvas canvas, Offset center) {
    final spin = sparksT * 2 * math.pi;
    for (var i = 0; i < _sparkDeg.length; i++) {
      final a = -math.pi / 2 + _sparkDeg[i] * math.pi / 180 - spin;
      final pos = center + Offset(math.cos(a), math.sin(a)) * _sparkR;
      final twinkle = 0.25 +
          0.55 *
              (0.5 +
                  0.5 * math.sin(2 * math.pi * (sparksT * 3 + i * 0.37)));
      canvas.drawCircle(
        pos,
        i % 3 == 0 ? 2 : 1.2,
        Paint()..color = star.withValues(alpha: twinkle),
      );
    }
  }

  Path _sector(Offset c, double a0, double a1) {
    return Path()
      ..moveTo(c.dx + _outerR * math.cos(a0), c.dy + _outerR * math.sin(a0))
      ..arcTo(Rect.fromCircle(center: c, radius: _outerR), a0, a1 - a0, false)
      ..lineTo(c.dx + _innerR * math.cos(a1), c.dy + _innerR * math.sin(a1))
      ..arcTo(
          Rect.fromCircle(center: c, radius: _innerR), a1, -(a1 - a0), false)
      ..close();
  }

  @override
  bool shouldRepaint(_WheelPainter old) =>
      old.selected != selected ||
      old.selScale != selScale ||
      old.orbitT != orbitT ||
      old.sparksT != sparksT ||
      old.sectors != sectors ||
      old.gapColor != gapColor;
}
