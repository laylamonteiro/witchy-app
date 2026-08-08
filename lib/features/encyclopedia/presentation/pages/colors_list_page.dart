import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/encyclopedia_provider.dart';
import '../../data/models/color_model.dart';
import '../../../../core/utils/accents.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/grimoire_colors.dart';
import 'color_detail_page.dart';
import '../widgets/entry_pager.dart';
import '../../../../core/widgets/magical_search_field.dart';

/// Catálogo oficial dos 20 tons — sem entradas pessoais nem identificação
/// por foto: em Cores, o conteúdo é a roda e as páginas completas.
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: MagicalSearchField(
            controller: _searchController,
            hint: AppLocalizations.of(context).encyArcaneSearchHint(AppLocalizations.of(context).encyTabColors),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(
            'A linguagem das cores na magia — significados e formas de aplicar cada tom. '
            'As correspondências variam entre tradições: use como inspiração, não como regra.',
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

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  final colorModel = colors[index];
                  return MagicalCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EntryPager(
                            itemCount: colors.length,
                            initialIndex: index,
                            itemBuilder: (_, i) => ColorDetailPage(
                              colorModel: colors[i],
                            ),
                          ),
                        ),
                      );
                    },
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
                                child: FittedBox(
                                  // Uma linha SEMPRE: nomes longos
                                  // encolhem a fonte — o card fica
                                  // do tamanho padrão da lista.
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    colorModel.name,
                                    maxLines: 1,
                                    style: GoogleFonts.cinzelDecorative(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: context.gc.lilac,
                                      ),
                                  ),
                                ),
                              ),
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
    );
  }
}
