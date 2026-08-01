import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/accents.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../diary/presentation/pages/dream_themes_page.dart';
import '../../../diary/presentation/pages/dreams_list_page.dart';
import '../../../divination/presentation/pages/oracle_cards_page.dart';
import '../../../divination/presentation/pages/pendulum_page.dart';
import '../../../grimoire/data/models/spell_model.dart';
import '../../../grimoire/presentation/pages/spell_categories_hub_page.dart';
import '../../../lunar/presentation/pages/lunar_calendar_page.dart';
import '../../../runes/presentation/pages/runes_list_page.dart';
import '../../../sigils/presentation/pages/sigil_step1_intention_page.dart';
import '../../../wheel_of_year/presentation/pages/wheel_of_year_page.dart';
import '../../data/data_sources/arcane_categories.dart';
import '../../data/data_sources/colors_data.dart';
import '../../data/data_sources/crystals_data.dart';
import '../../data/data_sources/goddesses_data.dart';
import '../../data/data_sources/herbs_data.dart';
import '../../data/data_sources/metals_data.dart';
import '../pages/altar_page.dart';
import '../pages/arcane_detail_page.dart';
import '../pages/arcane_list_page.dart';
import '../pages/color_detail_page.dart';
import '../pages/colors_list_page.dart';
import '../pages/crystal_detail_page.dart';
import '../pages/crystals_list_page.dart';
import '../pages/elements_page.dart';
import '../pages/goddess_detail_page.dart';
import '../pages/goddesses_list_page.dart';
import '../pages/herb_detail_page.dart';
import '../pages/herbs_list_page.dart';
import '../pages/metal_detail_page.dart';
import '../pages/metals_list_page.dart';

/// Resolve um rótulo de "Veja também" (texto livre localizado, com dica
/// opcional entre parênteses — ex.: "Hécate (Deusas)", "Fases da Lua",
/// "A Guardiã (Arquétipos)") para a página correspondente do app.
///
/// Ordem: verbete arcano → deusa → cristal/erva/metal/cor → categoria de
/// feitiços → seções por palavra-chave (lua, sabbats, runas, sigilos...).
/// Retorna null quando não há destino conhecido (o chip fica inerte).
WidgetBuilder? resolveRelatedLink(String label) {
  final match = RegExp(r'^(.*?)\s*\(([^)]+)\)\s*$').firstMatch(label.trim());
  final base = (match?.group(1) ?? label).trim();
  final hint = match?.group(2)?.trim() ?? '';

  String norm(String value) => removeAccents(value.toLowerCase().trim());
  final normBase = norm(base);
  final normHint = norm(hint);

  // Rótulos com múltiplos nomes ("A Donzela, A Mãe e A Sábia").
  final candidates = <String>[
    normBase,
    ...base
        .split(RegExp(r',| e | and | y '))
        .map((s) => norm(s))
        .where((s) => s.isNotEmpty),
  ];

  // 1. Verbete arcano com o mesmo nome (qualquer categoria).
  for (final category in ArcaneCategory.values) {
    for (final entry in category.entries) {
      if (candidates.contains(norm(entry.name))) {
        return (_) => ArcaneDetailPage(entry: entry, category: category);
      }
    }
  }

  // 2. Deusas ("Hécate (Deusas)" ou só o nome).
  for (final goddess in goddessesData) {
    if (candidates.contains(norm(goddess.name))) {
      return (_) => GoddessDetailPage(goddess: goddess);
    }
  }

  // 3. Demais verbetes da Enciclopédia por nome.
  for (final crystal in crystalsData) {
    if (candidates.contains(norm(crystal.name))) {
      return (_) => CrystalDetailPage(crystal: crystal);
    }
  }
  for (final herb in herbsData) {
    if (candidates.contains(norm(herb.name))) {
      return (_) => HerbDetailPage(herb: herb);
    }
  }
  for (final metal in metalsData) {
    if (candidates.contains(norm(metal.name))) {
      return (_) => MetalDetailPage(metal: metal);
    }
  }
  for (final color in colorsData) {
    if (candidates.contains(norm(color.name))) {
      return (_) => ColorDetailPage(colorModel: color);
    }
  }

  // 4. Categoria de feitiços ("Proteção & Limpeza", "Energia & Cura"...).
  for (final category in SpellCategory.values) {
    if (candidates.contains(norm(category.displayName))) {
      return (_) => const _WrappedSection(child: SpellCategoriesHubPage());
    }
  }

  // 5. Seções por palavra-chave (pt/en/es, sem acentos).
  // Match de PALAVRA INTEIRA (com plural s/es opcional) — nunca substring:
  // "Angélica" não pode casar com "angel", nem "girassol" com "sol".
  final searchText = '$normBase $normHint';
  bool has(List<String> words) => words.any((w) =>
      RegExp('\\b${RegExp.escape(w)}(es|s)?\\b').hasMatch(searchText));

  if (has(['lua', 'moon', 'luna'])) return (_) => const LunarCalendarPage();
  if (has(['sabbat', 'roda do ano', 'wheel of the year', 'rueda del ano'])) {
    return (_) => const WheelOfYearPage();
  }
  if (has(['runa', 'rune'])) return (_) => const RunesListPage();
  if (has(['sigilo', 'sigil'])) return (_) => const SigilStep1IntentionPage();
  if (has(['oraculo', 'oracle'])) return (_) => const OracleCardsPage();
  if (has(['pendulo', 'pendulum'])) return (_) => const PendulumPage();
  if (has(['deusa', 'goddess', 'diosa'])) {
    return (_) => const GoddessesListPage();
  }
  if (has(['altar'])) return (_) => const AltarPage();
  if (has(['elemento', 'element'])) return (_) => const ElementsPage();

  ArcaneCategory? arcaneList;
  if (has(['arquetipo', 'archetype'])) arcaneList = ArcaneCategory.archetypes;
  if (has(['anjo', 'angel'])) arcaneList = ArcaneCategory.angels;
  if (has(['demonio', 'demon'])) arcaneList = ArcaneCategory.demons;
  if (has(['simbolo', 'symbol'])) arcaneList = ArcaneCategory.sacredSymbols;
  if (arcaneList != null) {
    final category = arcaneList;
    return (context) {
      final l10n = AppLocalizations.of(context);
      final (title, intro) = switch (category) {
        ArcaneCategory.archetypes => (
            l10n.encyTabArchetypes,
            l10n.encyArcaneIntroArchetypes
          ),
        ArcaneCategory.angels => (
            l10n.encyTabAngels,
            l10n.encyArcaneIntroAngels
          ),
        ArcaneCategory.demons => (
            l10n.encyTabDemons,
            l10n.encyArcaneIntroDemons
          ),
        ArcaneCategory.sacredSymbols => (
            l10n.encyCatSacredSymbols,
            l10n.encyArcaneIntroSymbols
          ),
      };
      return _WrappedSection(
        title: title,
        child: ArcaneListPage(
          category: category,
          title: title,
          intro: intro,
          entries: category.entries,
        ),
      );
    };
  }

  if (has(['erva', 'herb', 'hierba'])) {
    return (_) => const _WrappedSection(child: HerbsListPage());
  }
  if (has(['cristal', 'cristais', 'crystal', 'pedra', 'stone', 'piedra'])) {
    return (_) => const _WrappedSection(child: CrystalsListPage());
  }
  if (has(['metal', 'metais', 'metales'])) {
    return (_) => const _WrappedSection(child: MetalsListPage());
  }
  if (has(['cores', 'colors', 'colores'])) {
    return (_) => const _WrappedSection(child: ColorsListPage());
  }
  if (has(['grimorio', 'grimoire', 'feitico', 'spell', 'hechizo'])) {
    return (_) => const _WrappedSection(child: SpellCategoriesHubPage());
  }
  if (has(['tema onirico', 'temas oniricos', 'dream theme'])) {
    return (_) => const DreamThemesPage();
  }
  if (has(['sonho', 'dream', 'sueno'])) return (_) => const DreamsListPage();

  return null;
}

/// Chip de correspondência/tag que navega quando o rótulo resolve para uma
/// página do app (verbete, deusa, seção...). Sem destino, fica inerte —
/// mesmo visual em ambos os casos, com seta ↗ quando é clicável.
class LinkableChip extends StatelessWidget {
  final String label;
  final Color color;

  const LinkableChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final destination = resolveRelatedLink(label);
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          if (destination != null) ...[
            const SizedBox(width: 4),
            Icon(Icons.arrow_outward, size: 13, color: context.gc.lilac),
          ],
        ],
      ),
    );
    if (destination == null) return chip;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: destination),
      ),
      child: chip,
    );
  }
}

/// Scaffold para seções que normalmente vivem como aba (sem AppBar própria).
class _WrappedSection extends StatelessWidget {
  final String? title;
  final Widget child;

  const _WrappedSection({this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(
            title ?? AppLocalizations.of(context).encyclopediaPageTitle),
      ),
      body: child,
    );
  }
}
