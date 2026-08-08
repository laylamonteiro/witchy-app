import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/herb_model.dart';
import '../../data/models/user_entry_model.dart';
import '../../../../core/utils/accents.dart';
import '../providers/encyclopedia_provider.dart';
import 'herb_detail_page.dart';
import '../widgets/encyclopedia_image.dart';
import '../widgets/entry_pager.dart';
import '../widgets/user_entry_helpers.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/living_emblem.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../../core/widgets/magical_search_field.dart';

class HerbsListPage extends StatefulWidget {
  const HerbsListPage({super.key});

  @override
  State<HerbsListPage> createState() => _HerbsListPageState();
}

class _HerbsListPageState extends State<HerbsListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  /// A busca com foco recolhe o emblema (cede o palco).
  bool _searchFocused = false;

  /// A lista rolou? Então o emblema cede o palco (volta no topo).
  bool _scrolled = false;

  /// Filtro "Minhas": mostra só as entradas pessoais.
  bool _onlyMine = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  // Ordena lista de ervas alfabeticamente
  List<HerbModel> _sortHerbs(List<HerbModel> herbs) {
    final sorted = List<HerbModel>.from(herbs);
    sorted.sort((a, b) =>
      removeAccents(a.name.toUpperCase()).compareTo(removeAccents(b.name.toUpperCase()))
    );
    return sorted;
  }


  /// Rolagem para baixo recolhe o emblema; de volta ao TOPO, reaparece.
  /// Histerese (12px / 2px) para não tremer na beirada.
  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    final p = n.metrics.pixels;
    if (!_scrolled && p > 12) {
      setState(() => _scrolled = true);
    } else if (_scrolled && p <= 2) {
      setState(() => _scrolled = false);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EncyclopediaProvider>(context);
    final unsortedHerbs = _searchQuery.isEmpty
        ? provider.herbs
        : provider.searchHerbs(_searchQuery);

    // Ordena alfabeticamente
    final herbs = _sortHerbs(unsortedHerbs);

    // Entradas pessoais (foto + IA) entram na MESMA ordem alfabética das
    // oficiais — uma lista só, cada item sabendo se é da Bruxa.
    final lowerQuery = _searchQuery.toLowerCase();
    final userEntries = provider
        .userEntries(UserEntryCategory.herb)
        .where((e) =>
            _searchQuery.isEmpty ||
            e.name.toLowerCase().contains(lowerQuery))
        .toList();
    final combined = <({HerbModel model, UserEncyclopediaEntry? userEntry})>[
      ...userEntries.map((e) => (model: e.toHerbModel(), userEntry: e)),
      if (!_onlyMine) ...herbs.map((h) => (model: h, userEntry: null)),
    ]..sort((a, b) => removeAccents(a.model.name.toUpperCase())
        .compareTo(removeAccents(b.model.name.toUpperCase())));

    // Filtro Minhas ativo sem NENHUMA entrada pessoal: escurece a página e
    // destaca o botão Adicionar (spotlight estilo tour).
    final spotlightAdd =
        _onlyMine && provider.userEntries(UserEntryCategory.herb).isEmpty;

    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: Stack(
      children: [
        Column(
      children: [
        SectionEmblemHeader(
          emblem: SectionEmblem.herbs,
          intro: AppLocalizations.of(context).encyHerbsIntro,
          collapsed: _searchFocused ||
              _scrolled || _searchQuery.isNotEmpty,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Focus(
                  onFocusChange: (f) => setState(() => _searchFocused = f),
                  child: MagicalSearchField(
                    controller: _searchController,
                    hint: AppLocalizations.of(context).encyArcaneSearchHint(AppLocalizations.of(context).encyTabHerbs),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              MineFilterButton(
                category: UserEntryCategory.herb,
                selected: _onlyMine,
                onChanged: (v) => setState(() => _onlyMine = v),
              ),
            ],
          ),
        ),
        Expanded(
          child: CascadeScope(
                child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: combined.length,
            itemBuilder: (context, index) {
              final item = combined[index];
              final herb = item.model;
              final userEntry = item.userEntry;
              return CascadeIn(
                    index: index,
                    child: MagicalCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EntryPager(
                        itemCount: combined.length,
                        initialIndex: index,
                        itemBuilder: (_, i) => HerbDetailPage(
                          herb: combined[i].model,
                          userEntry: combined[i].userEntry,
                        ),
                      ),
                    ),
                  );
                },
                onLongPress: userEntry != null
                    ? () => confirmDeleteUserEntry(context, userEntry)
                    : null,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: herb.imageUrl != null
                          ? EncyclopediaImage(
                              path: herb.imageUrl!,
                              width: 60,
                              height: 60,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: context.gc.mint.withAlpha((0.2 * 255).round()),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      herb.element.emoji,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: context.gc.mint.withAlpha((0.2 * 255).round()),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  herb.element.emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: FittedBox(
                                  // Uma linha SEMPRE: nomes longos
                                  // encolhem a fonte — o card fica
                                  // do tamanho padrão da lista.
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    herb.name,
                                    maxLines: 1,
                                    style: GoogleFonts.cinzelDecorative(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: context.gc.lilac,
                                  ),
                                  ),
                                ),
                              ),
                              if (herb.toxic)
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: context.gc.alert,
                                  size: 20,
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(herb.element.emoji),
                              const SizedBox(width: 4),
                              Text(
                                herb.element.displayName,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            herb.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: context.gc.textSecondary,
                    ),
                  ],
                ),
              ),
                  );
            },
          ),
              ),
        ),
      ],
        ),
        if (spotlightAdd) const MineEmptySpotlight(),
        AddUserEntryFab(
          category: UserEntryCategory.herb,
          highlight: spotlightAdd,
        ),
      ],
    ),
    );
  }
}
