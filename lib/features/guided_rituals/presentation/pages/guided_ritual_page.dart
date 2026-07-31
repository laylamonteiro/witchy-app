import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_button.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../grimoire/presentation/pages/spell_form_page.dart';
import '../../data/models/guided_ritual_model.dart';
import '../../data/models/guided_rituals_data.dart';
import 'ritual_player_page.dart';

/// Página guiada de um ritual (sabbat, lua ou água mágica), aberta por
/// notificação (deep link), pelo detalhe do sabbat ou pelo calendário lunar.
///
/// O conteúdo (intro, quando fazer, materiais, correspondências, usos) é
/// gratuito; o player passo a passo tem preview free + gate premium.
class GuidedRitualPage extends StatelessWidget {
  final String ritualId;

  const GuidedRitualPage({super.key, required this.ritualId});

  @override
  Widget build(BuildContext context) {
    final ritual = AllGuidedRituals.byId(ritualId);
    final l10n = AppLocalizations.of(context);

    if (ritual == null) {
      // Id desconhecido (ex.: notificação antiga): página vazia amigável.
      return Scaffold(
        appBar: AppBar(title: ResponsiveAppBarTitle(l10n.guidedRitualTitle)),
        body: Center(
          child: Text(
            l10n.guidedRitualNotFound,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: ResponsiveAppBarTitle(ritual.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, ritual),
            _buildMaterials(context, ritual),
            _buildCorrespondences(context, ritual),
            if (ritual.usesAfter.isNotEmpty) _buildUses(context, ritual),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MagicalButton(
                    text: l10n.guidedRitualStartCta,
                    icon: Icons.auto_awesome,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RitualPlayerPage(ritual: ritual),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  MagicalButton(
                    text: l10n.guidedRitualCreateSpellCta,
                    icon: Icons.auto_fix_high,
                    isOutlined: true,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SpellFormPage(
                            initialCategory: ritual.suggestedSpellCategory,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, GuidedRitual ritual) {
    final l10n = AppLocalizations.of(context);
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(ritual.emoji, style: const TextStyle(fontSize: 56)),
          ),
          const SizedBox(height: 12),
          Text(
            ritual.intro,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.gc.lilac.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: context.gc.lilac.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.schedule, color: context.gc.lilac, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.guidedRitualWhenTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: context.gc.lilac,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ritual.timing,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterials(BuildContext context, GuidedRitual ritual) {
    if (ritual.materials.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.guidedRitualMaterialsTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          ...ritual.materials.map((material) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('✦',
                        style: TextStyle(
                            fontSize: 16, color: context.gc.starYellow)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        material,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCorrespondences(BuildContext context, GuidedRitual ritual) {
    final l10n = AppLocalizations.of(context);
    final sections = <Widget>[];

    void addChips(String title, List<String> items, Color color) {
      if (items.isEmpty) return;
      sections.addAll([
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map((item) => Chip(
                    label: Text(item),
                    backgroundColor: color.withValues(alpha: 0.2),
                    side: BorderSide(color: color),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
      ]);
    }

    addChips(l10n.encyTabCrystals, ritual.crystals, context.gc.lilac);
    addChips(l10n.encyTabHerbs, ritual.herbs, context.gc.mint);
    addChips(l10n.encyTabColors, ritual.colors, context.gc.starYellow);
    addChips(l10n.guidedRitualFoodsTitle, ritual.foods, context.gc.pink);

    if (sections.isEmpty) return const SizedBox.shrink();

    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.guidedRitualCorrespondencesTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          ...sections,
        ],
      ),
    );
  }

  Widget _buildUses(BuildContext context, GuidedRitual ritual) {
    final l10n = AppLocalizations.of(context);
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.guidedRitualUsesTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          ...ritual.usesAfter.map((use) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('◈',
                        style:
                            TextStyle(fontSize: 16, color: context.gc.lilac)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        use,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
