import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/paged_reading.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/magical_profile_report.dart';
import '../providers/astrology_provider.dart';

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
///
/// A seção é tecida AQUI, na primeira vez que a pessoa abre o card. Antes as
/// dez saíam juntas ao calcular o mapa: dez chamadas de IA de uma vez, para
/// alguém que talvez lesse duas — e cada uma disputando o mesmo teto de
/// tokens. Aberta uma por vez, cada seção tem a chamada inteira para si.
class MagicalProfileSectionPage extends StatefulWidget {
  const MagicalProfileSectionPage({
    super.key,
    required this.title,
    required this.sectionKey,
    this.section,
  });

  final String title;

  /// A chave da seção; nula em perfis do formato antigo, que já vêm prontos
  /// e não são tecidos sob demanda.
  final String? sectionKey;

  /// A seção já guardada, quando existe.
  final ProfileSection? section;

  @override
  State<MagicalProfileSectionPage> createState() =>
      _MagicalProfileSectionPageState();
}

class _MagicalProfileSectionPageState extends State<MagicalProfileSectionPage> {
  @override
  void initState() {
    super.initState();
    if (widget.section == null && widget.sectionKey != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tecer());
    }
  }

  Future<void> _tecer() async {
    final chave = widget.sectionKey;
    if (chave == null) return;
    await context.read<AstrologyProvider>().generateProfileSection(
          chave,
          hasFullAccess: context.read<AuthProvider>().isPremiumEffective,
        );
  }

  Future<void> _tecerDeNovo() async {
    final chave = widget.sectionKey;
    if (chave == null) return;
    await context.read<AstrologyProvider>().regenerateProfileSection(
          chave,
          hasFullAccess: context.read<AuthProvider>().isPremiumEffective,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<AstrologyProvider>(
      builder: (context, provider, _) {
        final chave = widget.sectionKey;
        final secao =
            chave == null ? widget.section : provider.profileSection(chave);
        final tecendo = chave != null && provider.generatingSection == chave;

        return Scaffold(
          backgroundColor: context.gc.background,
          appBar: AppBar(
            title: ResponsiveAppBarTitle(widget.title),
            backgroundColor: context.gc.darkBackground,
            actions: [
              if (secao != null && chave != null && !tecendo)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _tecerDeNovo,
                  tooltip: l10n.profileSectionRegenerate,
                ),
            ],
          ),
          body: SafeArea(
            child: switch ((tecendo, secao)) {
              (true, _) => _Tecendo(title: widget.title),
              (false, final ProfileSection s) => PagedReading(
                  pages: [for (final slide in s.slides) _Pagina(slide: slide)],
                ),
              _ => _Falhou(onRetry: _tecer, message: provider.error),
            },
          ),
        );
      },
    );
  }
}

class _Tecendo extends StatelessWidget {
  const _Tecendo({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: context.gc.lilac),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzelDecorative(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.gc.lilac,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.profileSectionWeaving,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.gc.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Falhou extends StatelessWidget {
  const _Falhou({required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: context.gc.alert, size: 44),
            const SizedBox(height: 16),
            Text(
              l10n.profileSectionFailed,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.gc.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.commonTryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.gc.lilac,
                foregroundColor: context.gc.onPrimary,
              ),
            ),
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
