import 'package:flutter/material.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/models/arcane_entry_model.dart';
import 'arcane_detail_page.dart';

/// Lista genérica para as categorias arcanas (Arquétipos, Anjos,
/// Demônios, Símbolos Sagrados) — busca + cards no padrão da Enciclopédia.
class ArcaneListPage extends StatefulWidget {
  final String categoryTitle;
  final String intro;
  final List<ArcaneEntry> entries;

  const ArcaneListPage({
    super.key,
    required this.categoryTitle,
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
      ..sort((a, b) => a.name.toUpperCase().compareTo(b.name.toUpperCase()));
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

  String _imageAssetForEntry(ArcaneEntry entry) {
    const folders = {
      'Arquétipos': 'arquetipos',
      'Anjos': 'anjos',
      'Demônios': 'demonios',
      'Símbolos Sagrados': 'simbolos',
    };
    const accents = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const plain = 'aaaaaeeeeiiiiooooouuuucn';

    var slug = entry.name.trim().toLowerCase();
    for (var i = 0; i < accents.length; i++) {
      slug = slug.replaceAll(accents[i], plain[i]);
    }
    slug = slug.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return 'assets/images/${folders[widget.categoryTitle] ?? 'outros'}/$slug.webp';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar em ${widget.categoryTitle}...',
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: _filter,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
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
                    'Nada encontrado 🔍',
                    style: TextStyle(color: context.gc.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final entry = _filtered[index];
                    return MagicalCard(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ArcaneDetailPage(
                            entry: entry,
                            categoryTitle: widget.categoryTitle,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              _imageAssetForEntry(entry),
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, _, __) => Container(
                                width: 48,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: context.gc.lilac.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: context.gc.lilac.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(entry.emoji,
                                    style: const TextStyle(fontSize: 24)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: context.gc.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  entry.summary,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: context.gc.textSecondary,
                                      ),
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
