import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/paged_reading.dart';
import '../../data/models/magical_profile_report.dart';

/// O título e a linha de chamada de cada seção da Análise Personalizada.
///
/// Vêm do l10n, e não do texto gerado, para que trocar o idioma do app
/// renomeie os cards sem precisar tecer o relatório de novo. O corpo, esse
/// sim, fica no idioma em que foi escrito.
({String title, String subtitle})? profileSectionLabel(
  AppLocalizations l10n,
  String? key,
) {
  return switch (key) {
    MagicalProfileSections.essence => (
        title: l10n.profileSectionEssenceTitle,
        subtitle: l10n.profileSectionEssenceSubtitle,
      ),
    MagicalProfileSections.intuition => (
        title: l10n.profileSectionIntuitionTitle,
        subtitle: l10n.profileSectionIntuitionSubtitle,
      ),
    MagicalProfileSections.voice => (
        title: l10n.profileSectionVoiceTitle,
        subtitle: l10n.profileSectionVoiceSubtitle,
      ),
    MagicalProfileSections.love => (
        title: l10n.profileSectionLoveTitle,
        subtitle: l10n.profileSectionLoveSubtitle,
      ),
    MagicalProfileSections.power => (
        title: l10n.profileSectionPowerTitle,
        subtitle: l10n.profileSectionPowerSubtitle,
      ),
    MagicalProfileSections.transformation => (
        title: l10n.profileSectionTransformationTitle,
        subtitle: l10n.profileSectionTransformationSubtitle,
      ),
    MagicalProfileSections.spirit => (
        title: l10n.profileSectionSpiritTitle,
        subtitle: l10n.profileSectionSpiritSubtitle,
      ),
    MagicalProfileSections.allies => (
        title: l10n.profileSectionAlliesTitle,
        subtitle: l10n.profileSectionAlliesSubtitle,
      ),
    MagicalProfileSections.practice => (
        title: l10n.profileSectionPracticeTitle,
        subtitle: l10n.profileSectionPracticeSubtitle,
      ),
    MagicalProfileSections.shadow => (
        title: l10n.profileSectionShadowTitle,
        subtitle: l10n.profileSectionShadowSubtitle,
      ),
    _ => null,
  };
}

/// Uma seção da Análise Personalizada, lida em páginas que deslizam.
///
/// Três páginas por seção, que é a forma que a geração pede: o que a posição
/// é no mapa, como ela aparece na prática e o que fazer com isso. Rolar um
/// texto longo até o fim é raro; deslizar três telas curtas, não.
class MagicalProfileSectionPage extends StatelessWidget {
  const MagicalProfileSectionPage({
    super.key,
    required this.title,
    required this.section,
  });

  final String title;
  final ProfileSection section;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.gc.background,
      appBar: AppBar(
        title: ResponsiveAppBarTitle(title),
        backgroundColor: context.gc.darkBackground,
      ),
      body: SafeArea(
        child: PagedReading(
          pages: [
            for (final slide in section.slides) _Pagina(slide: slide),
          ],
        ),
      ),
    );
  }
}

class _Pagina extends StatelessWidget {
  const _Pagina({required this.slide});

  final ProfileSlide slide;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (slide.title.isNotEmpty) ...[
          Text(
            slide.title,
            style: GoogleFonts.cinzelDecorative(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.gc.lilac,
            ),
          ),
          const SizedBox(height: 6),
          Divider(color: context.gc.lilac.withValues(alpha: 0.35)),
          const SizedBox(height: 10),
        ],
        MarkdownBody(
          data: slide.body,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              color: context.gc.softWhite,
              height: 1.7,
              fontSize: 16,
            ),
            listBullet: TextStyle(color: context.gc.lilac, fontSize: 16),
            strong: TextStyle(
              color: context.gc.lilac,
              fontWeight: FontWeight.bold,
            ),
            em: TextStyle(
              color: context.gc.softWhite,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
