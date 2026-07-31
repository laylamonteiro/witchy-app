import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/encyclopedia_provider.dart';
import '../../data/models/color_model.dart';
import '../../data/models/user_entry_model.dart';
import '../widgets/user_entry_helpers.dart';
import '../../../../core/utils/accents.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/grimoire_colors.dart';
import 'color_detail_page.dart';
import '../widgets/entry_pager.dart';

class ColorsListPage extends StatefulWidget {
  const ColorsListPage({super.key});

  @override
  State<ColorsListPage> createState() => _ColorsListPageState();
}

class _ColorsListPageState extends State<ColorsListPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Ordena lista de cores alfabeticamente
  List<ColorModel> _sortColors(List<ColorModel> colors) {
    final sorted = List<ColorModel>.from(colors);
    sorted.sort((a, b) =>
      removeAccents(a.name.toUpperCase()).compareTo(removeAccents(b.name.toUpperCase()))
    );
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar cores...',
              prefixIcon: Icon(Icons.search, color: context.gc.lilac),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
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
            'A linguagem das cores na magia — significados e formas de aplicar cada tom.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.gc.textSecondary,
                ),
          ),
        ),
        Expanded(
          child: Consumer<EncyclopediaProvider>(
            builder: (context, provider, _) {
              final unsortedColors = _searchQuery.isEmpty
                  ? provider.colors
                  : provider.searchColors(_searchQuery);

              // Ordena alfabeticamente
              final colors = _sortColors(unsortedColors);

              // Entradas pessoais (foto + IA) aparecem antes das oficiais.
              final lowerQuery = _searchQuery.toLowerCase();
              final userEntries = provider
                  .userEntries(UserEntryCategory.color)
                  .where((e) =>
                      _searchQuery.isEmpty ||
                      e.name.toLowerCase().contains(lowerQuery))
                  .toList();
              final combined = [
                ...userEntries.map((e) => e.toColorModel()),
                ...colors,
              ];

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 88),
                itemCount: combined.length,
                itemBuilder: (context, index) {
                  final colorModel = combined[index];
                  final isUserEntry = index < userEntries.length;
                  return MagicalCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EntryPager(
                            itemCount: combined.length,
                            initialIndex: index,
                            itemBuilder: (_, i) =>
                                ColorDetailPage(colorModel: combined[i]),
                          ),
                        ),
                      );
                    },
                    onLongPress: isUserEntry
                        ? () =>
                            confirmDeleteUserEntry(context, userEntries[index])
                        : null,
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: colorModel.color,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: context.gc.surfaceBorder,
                              width: 2,
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
                                      colorModel.name,
                                      style: GoogleFonts.cinzelDecorative(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: context.gc.lilac,
                                      ),
                                    ),
                                  ),
                                  if (isUserEntry) const UserEntryBadge(),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text(
                                    '✨',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      colorModel.intentions.take(2).join(', '),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                colorModel.meaning,
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
              );
            },
          ),
        ),
      ],
        ),
        AddUserEntryFab(category: UserEntryCategory.color),
      ],
    );
  }
}
