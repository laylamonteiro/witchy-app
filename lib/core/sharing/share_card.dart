import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/grimoire_colors.dart';

/// Moldura do cartão compartilhável como imagem (afirmação do dia,
/// trilha encadernada, novo título…).
///
/// Usa SEMPRE a paleta clássica (índigo + lilás), independente do tema
/// escolhido pela pessoa: a imagem que sai do app é a identidade visual
/// pública do Grimório de Bolso, com o nome do app assinado no rodapé.
///
/// Tamanho lógico fixo de 360×450 (proporção 4:5, a do feed do Instagram);
/// capturado com pixelRatio 3.0 vira um PNG de 1080×1350.
class ShareCard extends StatelessWidget {
  final Widget child;

  const ShareCard({super.key, required this.child});

  static const double width = 360;
  static const double height = 450;

  /// Paleta fixa do cartão (ver comentário da classe).
  static const GrimoireColors colors = GrimoireColors.classico;

  @override
  Widget build(BuildContext context) {
    // Fundo SÓLIDO até as bordas do retângulo: o PNG capturado não pode
    // ter cantos transparentes (viram "pontinhas pretas" ao postar).
    // A moldura arredondada vive DENTRO desse fundo.
    return Container(
      width: width,
      height: height,
      color: colors.background,
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.alphaBlend(
                colors.lilac.withValues(alpha: 0.10),
                colors.background,
              ),
              colors.background,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.surfaceBorder, width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(painter: _StarsPainter()),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                child: Column(
                  children: [
                    Expanded(child: Center(child: child)),
                    const SizedBox(height: 12),
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      color: colors.lilac.withValues(alpha: 0.25),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/app_icon.png',
                          width: 22,
                          height: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Grimório de Bolso',
                          style: GoogleFonts.cinzelDecorative(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colors.lilac,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Conteúdo do cartão para a Afirmação do Dia.
class AffirmationShareContent extends StatelessWidget {
  final String title;
  final String text;

  const AffirmationShareContent({
    super.key,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    const colors = ShareCard.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.cinzelDecorative(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colors.textSecondary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '❝',
          style: TextStyle(
            fontSize: 40,
            height: 1.1,
            color: colors.lilac.withValues(alpha: 0.55),
          ),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w600,
            height: 1.5,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Conteúdo do cartão para conquistas da jornada (trilha encadernada,
/// novo título mágico).
class AchievementShareContent extends StatelessWidget {
  final String emoji;
  final String title;

  /// O nome da conquista em si (título da trilha ou do novo nível).
  final String highlight;

  /// Linha extra opcional (ex.: novo título ganho junto da encadernação).
  final String? extraLine;

  /// Acento da conquista (dourado para trilha, lilás para nível).
  final Color accent;

  const AchievementShareContent({
    super.key,
    required this.emoji,
    required this.title,
    required this.highlight,
    required this.accent,
    this.extraLine,
  });

  @override
  Widget build(BuildContext context) {
    const colors = ShareCard.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 64)),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.cinzelDecorative(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colors.textSecondary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          highlight,
          textAlign: TextAlign.center,
          style: GoogleFonts.cinzelDecorative(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: accent,
            height: 1.3,
          ),
        ),
        if (extraLine != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: colors.lilac.withValues(alpha: 0.15),
            ),
            child: Text(
              extraLine!,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colors.lilac,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Estrelas fixas de fundo. Posições determinísticas (seed constante) para
/// o cartão sair idêntico em toda captura.
class _StarsPainter extends CustomPainter {
  const _StarsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(7);
    final paint = Paint();
    for (var i = 0; i < 34; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = 0.6 + random.nextDouble() * 1.1;
      paint.color = ShareCard.colors.starYellow
          .withValues(alpha: 0.15 + random.nextDouble() * 0.35);
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) => false;
}
