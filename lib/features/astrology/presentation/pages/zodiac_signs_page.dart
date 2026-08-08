import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../data/data_sources/zodiac_signs_data.dart';

// Reexporta o conteúdo localizado dos signos para que `zodiacSignsData` e
// `ZodiacSignData` continuem acessíveis a quem importa esta página (ex.:
// test/zodiac_signs_layout_test.dart).
export '../../data/data_sources/zodiac_signs_data.dart'
    show zodiacSignsData, ZodiacSignData;

class ZodiacSignsPage extends StatelessWidget {
  const ZodiacSignsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).astroZodiacSigns),
        backgroundColor: context.gc.darkBackground,
      ),
      backgroundColor: context.gc.darkBackground,
      body: SingleChildScrollView(
        // Os MagicalCards trazem a margem padrão do app (8 vertical,
        // 16 horizontal) — a página só dá um respiro vertical extra.
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Introdução
            MagicalCard(
              child: Column(
                children: [
                  const Text('', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    'Os 12 Signos',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: context.gc.lilac,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).zodiacIntro,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.gc.softWhite.withOpacity(0.8),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Lista de signos — espaçamento entre cards vem só da margem
            // padrão dos próprios MagicalCards.
            ...zodiacSignsData.map((signData) => _buildSignCard(context, signData)),
          ],
        ),
      ),
    );
  }

  Widget _buildSignCard(BuildContext context, ZodiacSignData data) {
    return MagicalCard(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          initiallyExpanded: false,
          leading: Text(
            data.sign.symbol,
            style: const TextStyle(fontSize: 36),
          ),
          title: Text(
            data.sign.displayName,
            style: GoogleFonts.cinzelDecorative(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.gc.lilac,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                data.dateRange,
                style: TextStyle(
                  color: context.gc.softWhite.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    data.sign.element.symbol,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${data.sign.element.displayName} | ${data.sign.modality.displayName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.gc.softWhite.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          iconColor: context.gc.lilac,
          collapsedIconColor: context.gc.lilac,
          children: [
            Divider(color: context.gc.lilac),
            const SizedBox(height: 8),

            // Planeta regente
            _buildSection(
              context,
              '',
              'Planeta Regente: ${data.rulingPlanet}',
              isHighlight: true,
            ),

            // Palavras-chave
            _buildSection(context, '', data.keywords, isHighlight: true),

            const SizedBox(height: 12),

            // Personalidade
            _buildSection(context, 'Personalidade', data.personality),

            // Dons Mágicos
            _buildSection(context, AppLocalizations.of(context).zodiacGifts, data.magicalGifts),

            // Práticas Recomendadas
            _buildSection(context, AppLocalizations.of(context).zodiacPractices, data.bestPractices),

            // Cristais
            _buildSection(context, 'Cristais', data.crystals),

            // Ervas
            _buildSection(context, 'Ervas', data.herbs),

            // Cores
            _buildSection(context, 'Cores', data.colors),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String content, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: context.gc.lilac,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            content.trim(),
            textAlign: TextAlign.start,
            textWidthBasis: TextWidthBasis.parent,
            style: TextStyle(
              color: isHighlight
                  ? context.gc.starYellow
                  : context.gc.softWhite.withOpacity(0.9),
              fontSize: isHighlight ? 13 : 14,
              height: 1.5,
              fontStyle: isHighlight ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }
}
