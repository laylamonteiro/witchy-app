import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../data/models/goddess_model.dart';
import '../../data/data_sources/goddesses_data.dart';
import 'goddess_detail_page.dart';

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
      ..sort((a, b) => a.name.compareTo(b.name));
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
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deusas'),
        backgroundColor: AppColors.darkBackground,
      ),
      backgroundColor: AppColors.darkBackground,
      body: Column(
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
                      prefixIcon: const Icon(Icons.search, color: AppColors.lilac),
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
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _filterGoddesses,
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<GoddessOrigin?>(
                  icon: Icon(
                    Icons.filter_list,
                    color: _selectedOrigin != null ? AppColors.lilac : AppColors.softWhite,
                  ),
                  tooltip: 'Filtrar por origem',
                  onSelected: (origin) {
                    setState(() {
                      _selectedOrigin = origin;
                      _filterGoddesses(_searchController.text);
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: null,
                      child: Row(
                        children: [
                          Icon(
                            Icons.public,
                            size: 20,
                            color: _selectedOrigin == null ? AppColors.lilac : AppColors.softWhite,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Todas as Origens',
                            style: TextStyle(
                              color: _selectedOrigin == null ? AppColors.lilac : null,
                              fontWeight: _selectedOrigin == null ? FontWeight.bold : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    ...GoddessOrigin.values.map((origin) => PopupMenuItem(
                          value: origin,
                          child: Row(
                            children: [
                              Text(origin.emoji, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Text(
                                origin.displayName,
                                style: TextStyle(
                                  color: _selectedOrigin == origin ? AppColors.lilac : null,
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

          // Indicador de filtro ativo
          if (_selectedOrigin != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    backgroundColor: AppColors.lilac.withOpacity(0.2),
                    side: const BorderSide(color: AppColors.lilac),
                    labelStyle: const TextStyle(color: AppColors.lilac, fontSize: 12),
                  ),
                ],
              ),
            ),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_filteredGoddesses.length} deusa${_filteredGoddesses.length != 1 ? 's' : ''} encontrada${_filteredGoddesses.length != 1 ? 's' : ''}',
                style: TextStyle(
                  color: AppColors.softWhite.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ),
          ),

          // Goddesses list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredGoddesses.length,
              itemBuilder: (context, index) {
                final goddess = _filteredGoddesses[index];
                return _buildGoddessCard(goddess);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoddessCard(GoddessModel goddess) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MagicalCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GoddessDetailPage(goddess: goddess),
            ),
          );
        },
        child: Row(
          children: [
            // Emoji
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.lilac.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  goddess.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goddess.name,
                    style: GoogleFonts.cinzelDecorative(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lilac,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        goddess.origin.emoji,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        goddess.origin.displayName,
                        style: TextStyle(
                          color: AppColors.softWhite.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: goddess.aspects.take(3).map((aspect) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${aspect.emoji} ${aspect.displayName}',
                          style: const TextStyle(
                            color: AppColors.softWhite,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.lilac,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
