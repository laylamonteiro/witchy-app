import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/encyclopedia_provider.dart';
import '../../data/models/crystal_model.dart';
import '../../data/models/user_entry_model.dart';
import '../../../../core/utils/accents.dart';
import '../../../../core/widgets/magical_card.dart';
import '../widgets/encyclopedia_image.dart';
import '../widgets/entry_pager.dart';
import '../widgets/user_entry_helpers.dart';
import '../../../../core/theme/grimoire_colors.dart';
import 'crystal_detail_page.dart';
import '../../../../core/widgets/magical_search_field.dart';

class CrystalsListPage extends StatefulWidget {
  const CrystalsListPage({super.key});

  @override
  State<CrystalsListPage> createState() => _CrystalsListPageState();
}

class _CrystalsListPageState extends State<CrystalsListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Ordena lista de cristais alfabeticamente
  List<CrystalModel> _sortCrystals(List<CrystalModel> crystals) {
    final sorted = List<CrystalModel>.from(crystals);
    sorted.sort((a, b) =>
      removeAccents(a.name.toUpperCase()).compareTo(removeAccents(b.name.toUpperCase()))
    );
    return sorted;
  }

  bool _matchesQuery(CrystalModel crystal) {
    if (_searchQuery.isEmpty) return true;
    final lowerQuery = _searchQuery.toLowerCase();
    return crystal.name.toLowerCase().contains(lowerQuery) ||
        crystal.description.toLowerCase().contains(lowerQuery) ||
        crystal.intentions.any((i) => i.toLowerCase().contains(lowerQuery));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: MagicalSearchField(
            controller: _searchController,
            hint: AppLocalizations.of(context).encyArcaneSearchHint(AppLocalizations.of(context).encyTabCrystals),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(
            AppLocalizations.of(context).encyCrystalsIntro,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.gc.textSecondary,
                ),
          ),
        ),
        Expanded(
          child: Consumer<EncyclopediaProvider>(
            builder: (context, provider, _) {
              final unsortedCrystals = _searchQuery.isEmpty
                  ? provider.crystals
                  : provider.searchCrystals(_searchQuery);

              // Ordena alfabeticamente
              final crystals = _sortCrystals(unsortedCrystals);

              // Entradas pessoais (foto + IA) aparecem antes das oficiais.
              final userEntries = provider
                  .userEntries(UserEntryCategory.crystal)
                  .where((e) => _matchesQuery(e.toCrystalModel()))
                  .toList();
              final userModels =
                  userEntries.map((e) => e.toCrystalModel()).toList();
              final combined = [...userModels, ...crystals];

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 88),
                itemCount: combined.length,
                itemBuilder: (context, index) {
                  final crystal = combined[index];
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
                                CrystalDetailPage(crystal: combined[i]),
                          ),
                        ),
                      );
                    },
                    onLongPress: isUserEntry
                        ? () => confirmDeleteUserEntry(
                            context, userEntries[index])
                        : null,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: crystal.imageUrl != null
                              ? EncyclopediaImage(
                                  path: crystal.imageUrl!,
                                  width: 60,
                                  height: 60,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: context.gc.lilac.withAlpha((0.2 * 255).round()),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.diamond,
                                        color: context.gc.lilac,
                                        size: 32,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: context.gc.lilac.withAlpha((0.2 * 255).round()),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.diamond,
                                    color: context.gc.lilac,
                                    size: 32,
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
                                      crystal.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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
                                  Text(crystal.element.emoji),
                                  const SizedBox(width: 4),
                                  Text(
                                    crystal.element.displayName,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                crystal.description,
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
        AddUserEntryFab(category: UserEntryCategory.crystal),
      ],
    );
  }
}
