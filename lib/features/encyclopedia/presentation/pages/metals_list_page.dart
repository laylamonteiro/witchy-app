import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/encyclopedia_provider.dart';
import '../../data/models/metal_model.dart';
import '../../data/models/crystal_model.dart'; // Para ElementExtension
import '../../data/models/herb_model.dart'; // Para PlanetExtension
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/grimoire_colors.dart';
import 'metal_detail_page.dart';

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

  // Remove acentos para ordenação alfabética correta
  String _removeAccents(String str) {
    const withAccents = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    const withoutAccents = 'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

    String result = str;
    for (int i = 0; i < withAccents.length; i++) {
      result = result.replaceAll(withAccents[i], withoutAccents[i]);
    }
    return result;
  }

  // Ordena lista de metais alfabeticamente
  List<MetalModel> _sortMetals(List<MetalModel> metals) {
    final sorted = List<MetalModel>.from(metals);
    sorted.sort((a, b) =>
      _removeAccents(a.name.toUpperCase()).compareTo(_removeAccents(b.name.toUpperCase()))
    );
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar metais...',
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
                          builder: (_) => MetalDetailPage(metal: metal),
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
    switch (metalName.toLowerCase()) {
      case 'ouro':
        return Icons.auto_awesome;
      case 'prata':
        return Icons.nightlight;
      case 'cobre':
        return Icons.favorite;
      case 'ferro':
        return Icons.shield;
      case 'estanho':
        return Icons.calendar_view_week;
      case 'chumbo':
        return Icons.lock;
      case 'bronze':
        return Icons.history_edu;
      case 'latão':
        return Icons.light_mode;
      case 'alumínio':
        return Icons.speed;
      default:
        return Icons.blur_circular;
    }
  }
}
