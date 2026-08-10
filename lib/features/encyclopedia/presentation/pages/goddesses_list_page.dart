import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/living_emblem.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/models/goddess_model.dart';
import '../../../../core/utils/accents.dart';
import '../../data/data_sources/goddesses_data.dart';
import 'goddess_detail_page.dart';
import '../widgets/entry_pager.dart';
import '../../../../core/widgets/magical_search_field.dart';

class GoddessesListPage extends StatefulWidget {
  const GoddessesListPage({super.key});

  @override
  State<GoddessesListPage> createState() => _GoddessesListPageState();
}

class _GoddessesListPageState extends State<GoddessesListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<GoddessModel> _filteredGoddesses = goddessesData;
  /// A busca com foco recolhe o emblema (cede o palco).
  bool _searchFocused = false;

  /// A lista rolou? Então o emblema cede o palco (volta no topo).
  bool _scrolled = false;


  @override
  void initState() {
    super.initState();
    _filteredGoddesses = List.from(goddessesData)
      ..sort((a, b) =>
        removeAccents(a.name.toUpperCase()).compareTo(removeAccents(b.name.toUpperCase()))
      );
  }

  void _filterGoddesses(String query) {
    setState(() {
      _filteredGoddesses = goddessesData.where((goddess) {
        final matchesSearch = goddess.name.toLowerCase().contains(query.toLowerCase()) ||
            goddess.description.toLowerCase().contains(query.toLowerCase()) ||
            goddess.aspects.any((a) => a.displayName.toLowerCase().contains(query.toLowerCase()));

        return matchesSearch;
      }).toList()
        ..sort((a, b) =>
          removeAccents(a.name.toUpperCase()).compareTo(removeAccents(b.name.toUpperCase()))
        );
    });
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
    return Scaffold(
      backgroundColor: context.gc.darkBackground,
      body: NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: Column(
        children: [
          SectionEmblemHeader(
            emblem: SectionEmblem.goddesses,
            intro: AppLocalizations.of(context).encyGoddessesIntro,
            collapsed: _searchFocused ||
              _scrolled || _searchController.text.isNotEmpty,
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Focus(
              onFocusChange: (f) => setState(() => _searchFocused = f),
              child: MagicalSearchField(
                controller: _searchController,
                hint: AppLocalizations.of(context).encyArcaneSearchHint(AppLocalizations.of(context).encyTabGoddesses),
                onChanged: _filterGoddesses,
              ),
            ),
          ),

          // Goddesses list
          Expanded(
            child: CascadeScope(
              child: ListView.builder(
              itemCount: _filteredGoddesses.length,
              itemBuilder: (context, index) {
                final goddess = _filteredGoddesses[index];
                return CascadeIn(
                  index: index,
                  child: _buildGoddessCard(goddess, index),
                );
              },
            ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildGoddessCard(GoddessModel goddess, int index) {
    // Captura a lista exibida no momento do toque para o swipe lateral.
    final entries = List<GoddessModel>.from(_filteredGoddesses);
    return MagicalCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EntryPager(
              itemCount: entries.length,
              initialIndex: index,
              itemBuilder: (_, i) => GoddessDetailPage(goddess: entries[i]),
            ),
          ),
        );
      },
      child: Row(
          children: [
            // Image or emoji
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: goddess.imageUrl != null
                  ? Image.asset(
                      goddess.imageUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: context.gc.lilac.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              goddess.emoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: context.gc.lilac.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          goddess.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          goddess.name,
                          style: GoogleFonts.cinzelDecorative(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.gc.lilac,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(goddess.origin.emoji),
                      const SizedBox(width: 4),
                      Text(
                        goddess.origin.displayName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    goddess.description,
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
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
