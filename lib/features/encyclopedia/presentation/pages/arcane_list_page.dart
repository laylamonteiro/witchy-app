import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/utils/accents.dart';
import '../../../../core/widgets/magical_card.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import '../../data/data_sources/arcane_categories.dart';
import '../../data/models/arcane_entry_model.dart';
import 'arcane_detail_page.dart';
import '../widgets/entry_pager.dart';

/// Lista genérica para as categorias arcanas (Arquétipos, Anjos,
/// Demônios, Símbolos Sagrados) — busca + cards no padrão da Enciclopédia.
class ArcaneListPage extends StatefulWidget {
  final ArcaneCategory category;
  final String title;
  final String intro;
  final List<ArcaneEntry> entries;

  const ArcaneListPage({
    super.key,
    required this.category,
    required this.title,
    required this.intro,
    required this.entries,
  });

  @override
  State<ArcaneListPage> createState() => _ArcaneListPageState();
}

class _ArcaneListPageState extends State<ArcaneListPage> {
  final _searchController = TextEditingController();
  late List<ArcaneEntry> _filtered = _sorted(widget.entries);

  List<ArcaneEntry> _sorted(List<ArcaneEntry> list) {
    final copy = List<ArcaneEntry>.from(list)
      ..sort((a, b) => removeAccents(a.name.toUpperCase())
          .compareTo(removeAccents(b.name.toUpperCase())));
    return copy;
  }

  void _filter(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filtered = _sorted(
        widget.entries.where((e) {
          return e.name.toLowerCase().contains(q) ||
              e.summary.toLowerCase().contains(q) ||
              e.origin.toLowerCase().contains(q);
        }).toList(),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _displayCardTitle(ArcaneEntry entry) {
    if (widget.category == ArcaneCategory.archetypes) {
      return entry.name.replaceFirst(
          RegExp(r'^(A|O|The|El|La)\s+', caseSensitive: false), '');
    }
    return entry.name;
  }

  String _imageAssetForEntry(ArcaneEntry entry) =>
      widget.category.imageAssetFor(entry);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)
                  .encyArcaneSearchHint(widget.title),
              prefixIcon: Icon(Icons.search, color: context.gc.lilac),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filter('');
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
            onChanged: _filter,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(
            widget.intro,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.gc.textSecondary,
                ),
          ),
        ),
        Expanded(
          child: _filtered.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context).encyNothingFound,
                    style: TextStyle(color: context.gc.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final entry = _filtered[index];
                    // Lista exibida no momento do toque, para o swipe lateral.
                    final entries = List<ArcaneEntry>.from(_filtered);
                    return MagicalCard(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EntryPager(
                            itemCount: entries.length,
                            initialIndex: index,
                            itemBuilder: (_, i) => ArcaneDetailPage(
                              entry: entries[i],
                              category: widget.category,
                            ),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              _imageAssetForEntry(entry),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, _, __) => Container(
                                width: 60,
                                height: 60,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: context.gc.lilac.withAlpha((0.12 * 255).round()),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: context.gc.lilac.withAlpha((0.3 * 255).round()),
                                  ),
                                ),
                                child: Text(entry.emoji,
                                    style: const TextStyle(fontSize: 24)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _displayCardTitle(entry),
                                  style: GoogleFonts.cinzelDecorative(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: context.gc.lilac,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  entry.summary,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: context.gc.textSecondary),
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
