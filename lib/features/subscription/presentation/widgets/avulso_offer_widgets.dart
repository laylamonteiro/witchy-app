import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/grimoire_colors.dart';
import 'subscription_offer_widgets.dart' show CatHeroArt;

/// As peças do paywall de produto AVULSO — CÓPIAS das peças do paywall de
/// assinatura, com componente PRÓPRIO (decisão da dona, 23/08: não ficar
/// adequando o oficial).
///
/// As MEDIDAS são as do oficial, sem encolher nada: letra, foto e botão no
/// mesmo tamanho do paywall de assinatura (decisão da dona, 23/08 — a
/// "metade" do avulso é a QUANTIDADE de conteúdo: 3 bullets e um preço, não
/// tipografia menor; e o botão de meia altura cortava o próprio texto).
///
/// Cópia de propósito, não parametrização: os modos compactos opt-in que
/// viviam nos componentes oficiais espalhavam `if` de escala por eles, e
/// toda mudança num paywall arriscava o outro. A ÚNICA coisa compartilhada
/// é a arte do Salem ([CatHeroArt]): ela é a assinatura visual do app.

/// O herói do avulso: o MESMO desenho e as MESMAS medidas do herói da
/// assinatura (Salem em 120 no halo, Lora + Cinzel, degradê lilás na linha
/// de força). Os quatro textos são obrigatórios: um avulso sempre fala do
/// produto dele, nunca da copy do Premium.
class AvulsoHero extends StatelessWidget {
  const AvulsoHero({
    super.key,
    required this.access,
    required this.power,
    required this.magic,
    required this.tagline,
  });

  /// A linha de abertura, em Lora (o nome do produto).
  final String access;

  /// As duas linhas grandes em Cinzel — a primeira leva o degradê lilás.
  final String power;
  final String magic;

  /// A linha de fecho, pequena (o período lido, em geral).
  final String tagline;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 300;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [context.gc.background, context.gc.surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: compact
              ? Column(
                  children: [
                    const CatHeroArt(height: 92),
                    _copy(context, centered: true, compact: true),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      flex: 4,
                      child: CatHeroArt(height: 120),
                    ),
                    const SizedBox(width: 6),
                    Expanded(flex: 7, child: _copy(context)),
                  ],
                ),
        );
      },
    );
  }

  Widget _copy(
    BuildContext context, {
    bool centered = false,
    bool compact = false,
  }) {
    final alignment =
        centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.left;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: alignment,
      children: [
        // Em FittedBox porque o nome do produto é mais longo que o "ACESSE"
        // do Premium: encolher um pouco preserva a linha única sem perder o
        // corpo da tipografia oficial.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            access,
            textAlign: textAlign,
            style: GoogleFonts.lora(
              color: context.gc.textPrimary,
              fontSize: compact ? 18 : 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 3),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Color.lerp(context.gc.lilac, context.gc.textPrimary, 0.55)!,
              context.gc.lilac,
            ],
          ).createShader(bounds),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              power,
              textAlign: textAlign,
              style: GoogleFonts.cinzelDecorative(
                color: context.gc.textPrimary,
                fontSize: compact ? 20 : 23,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            magic,
            textAlign: textAlign,
            style: GoogleFonts.cinzelDecorative(
              color: context.gc.textPrimary,
              fontSize: compact ? 19 : 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          tagline,
          textAlign: textAlign,
          style: GoogleFonts.lora(
            color: context.gc.textSecondary,
            fontSize: compact ? 11 : 12,
            height: 1.34,
          ),
        ),
      ],
    );
  }
}

/// A divisória de losango — o mesmo desenho da divisória da assinatura.
class AvulsoDivider extends StatelessWidget {
  const AvulsoDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: context.gc.surfaceBorder)),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 9),
          width: 8,
          height: 8,
          transform: Matrix4.rotationZ(0.78),
          decoration: BoxDecoration(
            color: context.gc.lilac,
            border: Border.all(
              color: Color.lerp(
                context.gc.lilac,
                context.gc.textPrimary,
                0.55,
              )!,
            ),
          ),
        ),
        Expanded(child: Divider(color: context.gc.surfaceBorder)),
      ],
    );
  }
}

/// Uma peça da oferta avulsa: selo circular com o EMOJI da seção no papel
/// das artes pintadas do Premium, o rótulo limpo ao lado e o vislumbre do
/// que ela entrega — a anatomia e as MEDIDAS das peças da assinatura.
class AvulsoBeneficioRow extends StatelessWidget {
  const AvulsoBeneficioRow({
    super.key,
    required this.emoji,
    required this.rotulo,
    this.vislumbre,
  });

  final String emoji;
  final String rotulo;
  final String? vislumbre;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: context.gc.lilac.withValues(alpha: 0.30),
              ),
              boxShadow: [
                BoxShadow(
                  color: context.gc.lilac.withValues(alpha: 0.20),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 19)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  rotulo,
                  style: GoogleFonts.lora(
                    color: context.gc.textPrimary,
                    fontSize: 14.5,
                    height: 1.22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (vislumbre != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    vislumbre!,
                    style: TextStyle(
                      color: context.gc.textSecondary,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// O botão de pagar do avulso — o gradiente, a forma e a ALTURA (50) do
/// botão da assinatura, com o verbo do produto. A meia altura anterior
/// cortava o próprio texto (visto no preview, 23/08).
class AvulsoBotaoComprar extends StatelessWidget {
  const AvulsoBotaoComprar({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              Color.lerp(context.gc.lilac, context.gc.background, 0.22)!,
              context.gc.lilac,
              Color.lerp(context.gc.lilac, context.gc.background, 0.30)!,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: context.gc.lilac.withValues(alpha: 0.27),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            // O fundo de verdade é o gradiente lilás do DecoratedBox de
            // fora: o texto usa onPrimary, o token que os testes de
            // contraste garantem sobre o acento.
            foregroundColor: context.gc.onPrimary,
            shape: const StadiumBorder(),
          ),
          child: Text(
            label,
            style: GoogleFonts.lora(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
