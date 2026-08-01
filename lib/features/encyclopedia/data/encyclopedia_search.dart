import 'package:flutter/widgets.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../core/utils/accents.dart';
import '../../runes/data/data_sources/runes_data.dart';
import '../../runes/presentation/pages/rune_detail_page.dart';
import '../../wheel_of_year/data/models/sabbat_model.dart';
import '../../wheel_of_year/presentation/pages/wheel_of_year_page.dart';
import 'data_sources/arcane_categories.dart';
import 'data_sources/colors_data.dart';
import 'data_sources/crystals_data.dart';
import 'data_sources/elements_content.dart';
import 'data_sources/goddesses_data.dart';
import 'data_sources/herbs_data.dart';
import 'data_sources/metals_data.dart';
import 'models/user_entry_model.dart';
import '../presentation/pages/arcane_detail_page.dart';
import '../presentation/pages/color_detail_page.dart';
import '../presentation/pages/crystal_detail_page.dart';
import '../presentation/pages/elements_page.dart';
import '../presentation/pages/goddess_detail_page.dart';
import '../presentation/pages/herb_detail_page.dart';
import '../presentation/pages/metal_detail_page.dart';

/// Um resultado da busca global: verbete + seção de origem + destino.
typedef EncyclopediaHit = ({
  String name,
  String emoji,
  String section,
  String? subtitle,
  WidgetBuilder open,
});

/// Busca em TODA a Enciclopédia (15 abas + entradas pessoais), sem acento.
///
/// Sem cache de propósito: as listas são getters trilíngues resolvidos pelo
/// ContentLocale, então montar na hora garante que trocar o idioma nunca
/// devolva resultado no idioma velho. São ~centenas de itens — barato.
///
/// Resultados na ordem das abas; dentro da seção, nome primeiro, depois
/// descrição (quem digitou "amor" quer o verbete Amor antes de tudo que
/// menciona amor).
List<EncyclopediaHit> searchEncyclopedia(
  String query,
  AppLocalizations l10n, {
  List<UserEncyclopediaEntry> userEntries = const [],
}) {
  final q = removeAccents(query.trim().toLowerCase());
  if (q.length < 2) return [];

  final byName = <EncyclopediaHit>[];
  final byContent = <EncyclopediaHit>[];

  void add({
    required String name,
    required String emoji,
    required String section,
    String? subtitle,
    required WidgetBuilder open,
    required String haystack,
  }) {
    final normName = removeAccents(name.toLowerCase());
    if (normName.contains(q)) {
      byName.add((
        name: name,
        emoji: emoji,
        section: section,
        subtitle: subtitle,
        open: open,
      ));
    } else if (removeAccents(haystack.toLowerCase()).contains(q)) {
      byContent.add((
        name: name,
        emoji: emoji,
        section: section,
        subtitle: subtitle,
        open: open,
      ));
    }
  }

  // Entradas pessoais primeiro: o que a Bruxa criou vale mais que o catálogo.
  for (final entry in userEntries) {
    final (emoji, section, WidgetBuilder open) = switch (entry.category) {
      UserEntryCategory.crystal => (
          '💎',
          l10n.encyTabCrystals,
          (_) => CrystalDetailPage(crystal: entry.toCrystalModel()),
        ),
      UserEntryCategory.herb => (
          '🌿',
          l10n.encyTabHerbs,
          (_) => HerbDetailPage(herb: entry.toHerbModel()),
        ),
      UserEntryCategory.color => (
          '🎨',
          l10n.encyTabColors,
          (_) => ColorDetailPage(colorModel: entry.toColorModel()),
        ),
    };
    add(
      name: entry.name,
      emoji: emoji,
      section: section,
      subtitle: null,
      open: open,
      haystack: entry.data.values.join(' '),
    );
  }

  // Sabbats — sem página própria: leva à Roda do Ano.
  for (final type in SabbatType.values) {
    add(
      name: type.name,
      emoji: type.emoji,
      section: l10n.encyTabSabbats,
      subtitle: type.southernHemisphereDate,
      open: (_) => const WheelOfYearPage(),
      haystack: type.description,
    );
  }

  for (final crystal in crystalsData) {
    add(
      name: crystal.name,
      emoji: '💎',
      section: l10n.encyTabCrystals,
      subtitle: crystal.intentions.take(3).join(' · '),
      open: (_) => CrystalDetailPage(crystal: crystal),
      haystack: '${crystal.description} ${crystal.intentions.join(' ')}',
    );
  }

  for (final herb in herbsData) {
    add(
      name: herb.name,
      emoji: '🌿',
      section: l10n.encyTabHerbs,
      subtitle: herb.magicalProperties.take(3).join(' · '),
      open: (_) => HerbDetailPage(herb: herb),
      haystack: '${herb.description} ${herb.magicalProperties.join(' ')}',
    );
  }

  for (final color in colorsData) {
    add(
      name: color.name,
      emoji: '🎨',
      section: l10n.encyTabColors,
      subtitle: color.meaning,
      open: (_) => ColorDetailPage(colorModel: color),
      haystack: '${color.meaning} ${color.intentions.join(' ')}',
    );
  }

  for (final goddess in goddessesData) {
    add(
      name: goddess.name,
      emoji: goddess.emoji,
      section: l10n.encyTabGoddesses,
      subtitle: null,
      open: (_) => GoddessDetailPage(goddess: goddess),
      haystack: '${goddess.description} ${goddess.correspondences} '
          '${goddess.alternateNames ?? ''}',
    );
  }

  // Elementos — sem detalhe por item: leva à página de Elementos.
  for (final element in elementsContent.elements) {
    add(
      name: element.name,
      emoji: element.emoji,
      section: l10n.encyTabElements,
      subtitle: null,
      open: (_) => const ElementsPage(),
      haystack: '${element.essence} ${element.qualities}',
    );
  }

  for (final rune in runesData) {
    add(
      name: rune.name,
      emoji: rune.symbol,
      section: l10n.encyTabRunes,
      subtitle: rune.keywords.take(3).join(' · '),
      open: (_) => RuneDetailPage(rune: rune),
      haystack: '${rune.description} ${rune.keywords.join(' ')}',
    );
  }

  for (final metal in metalsData) {
    add(
      name: metal.name,
      emoji: '🔩',
      section: l10n.encyTabMetals,
      subtitle: metal.magicalProperties.take(3).join(' · '),
      open: (_) => MetalDetailPage(metal: metal),
      haystack: '${metal.description} ${metal.magicalProperties.join(' ')}',
    );
  }

  for (final category in ArcaneCategory.values) {
    final section = switch (category) {
      ArcaneCategory.archetypes => l10n.encyTabArchetypes,
      ArcaneCategory.angels => l10n.encyTabAngels,
      ArcaneCategory.demons => l10n.encyTabDemons,
      ArcaneCategory.sacredSymbols => l10n.encyCatSacredSymbols,
    };
    for (final entry in category.entries) {
      add(
        name: entry.name,
        emoji: entry.emoji,
        section: section,
        subtitle: entry.summary,
        open: (_) => ArcaneDetailPage(entry: entry, category: category),
        haystack: '${entry.summary} ${entry.symbolism.join(' ')}',
      );
    }
  }

  return [...byName, ...byContent];
}
