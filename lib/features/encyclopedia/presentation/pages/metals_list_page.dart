import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/encyclopedia_provider.dart';
import '../../data/models/metal_model.dart';
import '../../../../core/utils/accents.dart';
import '../../data/models/crystal_model.dart'; // Para ElementExtension
import '../../data/models/herb_model.dart'; // Para PlanetExtension
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/grimoire_colors.dart';
import 'metal_detail_page.dart';
import '../widgets/entry_pager.dart';
import '../../../../core/widgets/magical_search_field.dart';

class MetalsListPage extends StatefulWidget {
  const MetalsListPage({super.key});

  @override
  State<MetalsListPage> createState() => _MetalsListPageState();
}

class _MetalsListPageState extends State<MetalsListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  // Ordena lista de metais alfabeticamente
  List<MetalModel> _sortMetals(List<MetalModel> metals) {
    final sorted = List<MetalModel>.from(metals);
    sorted.sort((a, b) =>
      removeAccents(a.name.toUpperCase()).compareTo(removeAccents(b.name.toUpperCase()))
    );
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: MagicalSearchField(
            controller: _searchController,
            hint: AppLocalizations.of(context).encyArcaneSearchHint(AppLocalizations.of(context).encyTabMetals),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(
            AppLocalizations.of(context).encyMetalsIntro,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.gc.textSecondary,
                ),
          ),
        ),
        Expanded(
          child: Consumer<EncyclopediaProvider>(
            builder: (context, provider, _) {
              final unsortedMetals = _searchQuery.isEmpty
                  ? provider.metals
                  : provider.searchMetals(_searchQuery);

              // Ordena alfabeticamente
              final metals = _sortMetals(unsortedMetals);

              return ListView.builder(
                itemCount: metals.length,
                itemBuilder: (context, index) {
                  final metal = metals[index];
                  return MagicalCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EntryPager(
                            itemCount: metals.length,
                            initialIndex: index,
                            itemBuilder: (_, i) =>
                                MetalDetailPage(metal: metals[i]),
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: metal.imageUrl != null
                              ? Image.asset(
                                  metal.imageUrl!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: context.gc.starYellow.withAlpha((0.2 * 255).round()),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: context.gc.starYellow.withAlpha((0.5 * 255).round()),
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        _getMetalIcon(metal.name),
                                        color: context.gc.starYellow,
                                        size: 32,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: context.gc.starYellow.withAlpha((0.2 * 255).round()),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: context.gc.starYellow.withAlpha((0.5 * 255).round()),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    _getMetalIcon(metal.name),
                                    color: context.gc.starYellow,
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
                                      metal.name,
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
                                  Text(metal.planet.emoji),
                                  const SizedBox(width: 4),
                                  Text(
                                    metal.planet.displayName,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(metal.element.emoji),
                                  const SizedBox(width: 4),
                                  Text(
                                    metal.element.displayName,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                metal.description,
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
    );
  }

  IconData _getMetalIcon(String metalName) {
    // Nomes nos 3 idiomas, sem acentos (removeAccents), para que o ícone
    // acompanhe o metal independentemente do idioma do conteúdo.
    switch (removeAccents(metalName.toLowerCase())) {
      case 'ouro':
      case 'gold':
      case 'oro':
        return Icons.auto_awesome;
      case 'prata':
      case 'silver':
      case 'plata':
        return Icons.nightlight;
      case 'cobre':
      case 'copper':
        return Icons.favorite;
      case 'ferro':
      case 'iron':
      case 'hierro':
        return Icons.shield;
      case 'estanho':
      case 'tin':
      case 'estano':
        return Icons.calendar_view_week;
      case 'chumbo':
      case 'lead':
      case 'plomo':
        return Icons.lock;
      case 'bronze':
      case 'bronce':
        return Icons.history_edu;
      case 'latao':
      case 'brass':
      case 'laton':
        return Icons.light_mode;
      case 'aluminio':
      case 'aluminum':
        return Icons.speed;
      default:
        return Icons.blur_circular;
    }
  }
}
