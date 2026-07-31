import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/herb_model.dart';
import '../../../../core/utils/accents.dart';
import '../providers/encyclopedia_provider.dart';
import 'herb_detail_page.dart';
import '../widgets/entry_pager.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/grimoire_colors.dart';

class HerbsListPage extends StatefulWidget {
  const HerbsListPage({super.key});

  @override
  State<HerbsListPage> createState() => _HerbsListPageState();
}

class _HerbsListPageState extends State<HerbsListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EncyclopediaProvider>(context);
    final unsortedHerbs = _searchQuery.isEmpty
        ? provider.herbs
        : provider.searchHerbs(_searchQuery);

    // Ordena alfabeticamente
    final herbs = _sortHerbs(unsortedHerbs);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar ervas...',
              prefixIcon: Icon(Icons.search, color: context.gc.lilac),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: context.gc.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(
            AppLocalizations.of(context).encyHerbsIntro,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.gc.textSecondary,
                ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: herbs.length,
            itemBuilder: (context, index) {
              final herb = herbs[index];
              return MagicalCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EntryPager(
                        itemCount: herbs.length,
                        initialIndex: index,
                        itemBuilder: (_, i) => HerbDetailPage(herb: herbs[i]),
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: herb.imageUrl != null
                          ? Image.asset(
                              herb.imageUrl!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
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
                                child: Text(
                                  herb.name,
                                  style: GoogleFonts.cinzelDecorative(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: context.gc.lilac,
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
              );
            },
          ),
        ),
      ],
    );
  }
}
