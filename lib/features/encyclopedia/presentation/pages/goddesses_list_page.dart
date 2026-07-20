import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/models/goddess_model.dart';
import '../../../../core/utils/accents.dart';
import '../../data/data_sources/goddesses_data.dart';
import 'goddess_detail_page.dart';
import '../widgets/entry_pager.dart';

class GoddessesListPage extends StatefulWidget {
  const GoddessesListPage({super.key});

  @override
  State<GoddessesListPage> createState() => _GoddessesListPageState();
}

class _GoddessesListPageState extends State<GoddessesListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<GoddessModel> _filteredGoddesses = goddessesData;
  GoddessOrigin? _selectedOrigin;


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

        final matchesOrigin = _selectedOrigin == null || goddess.origin == _selectedOrigin;

        return matchesSearch && matchesOrigin;
      }).toList()
        ..sort((a, b) =>
          removeAccents(a.name.toUpperCase()).compareTo(removeAccents(b.name.toUpperCase()))
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sem Scaffold próprio: herda o da Enciclopédia, como as demais abas.
    return Column(
        children: [
          // Search bar com filtro ao lado (igual Grimório Ancestral)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar deusas...',
                      prefixIcon: Icon(Icons.search, color: context.gc.lilac),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterGoddesses('');
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
                    onChanged: _filterGoddesses,
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.filter_list,
                    color: _selectedOrigin != null ? context.gc.lilac : context.gc.softWhite,
                  ),
                  tooltip: 'Filtrar por origem',
                  onSelected: (value) {
                    setState(() {
                      if (value == 'all') {
                        _selectedOrigin = null;
                      } else {
                        _selectedOrigin = GoddessOrigin.values.firstWhere((o) => o.name == value);
                      }
                      _filterGoddesses(_searchController.text);
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'all',
                      child: Row(
                        children: [
                          Icon(
                            Icons.public,
                            size: 20,
                            color: _selectedOrigin == null ? context.gc.lilac : context.gc.softWhite,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Todas as Origens',
                            style: TextStyle(
                              color: _selectedOrigin == null ? context.gc.lilac : null,
                              fontWeight: _selectedOrigin == null ? FontWeight.bold : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    ...GoddessOrigin.values.map((origin) => PopupMenuItem(
                          value: origin.name,
                          child: Row(
                            children: [
                              Text(origin.emoji, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Text(
                                origin.displayName,
                                style: TextStyle(
                                  color: _selectedOrigin == origin ? context.gc.lilac : null,
                                  fontWeight: _selectedOrigin == origin ? FontWeight.bold : null,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'Deusas de muitos povos — mitologia, domínios e caminhos de devoção.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.gc.textSecondary,
                  ),
            ),
          ),

          // Indicador de filtro ativo
          if (_selectedOrigin != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Chip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_selectedOrigin!.emoji),
                        const SizedBox(width: 4),
                        Text(_selectedOrigin!.displayName),
                      ],
                    ),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _selectedOrigin = null;
                        _filterGoddesses(_searchController.text);
                      });
                    },
                    backgroundColor: context.gc.lilac.withOpacity(0.2),
                    side: BorderSide(color: context.gc.lilac),
                    labelStyle: TextStyle(color: context.gc.lilac, fontSize: 12),
                  ),
                ],
              ),
            ),

          // Goddesses list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredGoddesses.length,
              itemBuilder: (context, index) {
                final goddess = _filteredGoddesses[index];
                return _buildGoddessCard(goddess, index);
              },
            ),
          ),
        ],
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
                            color: context.gc.lilac.withOpacity(0.2),
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
                        color: context.gc.lilac.withOpacity(0.2),
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
