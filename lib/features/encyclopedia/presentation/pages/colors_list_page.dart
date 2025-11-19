import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/encyclopedia_provider.dart';
import '../../data/models/color_model.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import 'color_detail_page.dart';

class ColorsListPage extends StatefulWidget {
  const ColorsListPage({super.key});

  @override
  State<ColorsListPage> createState() => _ColorsListPageState();
}

class _ColorsListPageState extends State<ColorsListPage> {
  String _searchQuery = '';

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

  // Ordena lista de cores alfabeticamente
  List<ColorModel> _sortColors(List<ColorModel> colors) {
    final sorted = List<ColorModel>.from(colors);
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
            decoration: const InputDecoration(
              hintText: 'Buscar cores...',
              prefixIcon: Icon(Icons.search),
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
              final unsortedColors = _searchQuery.isEmpty
                  ? provider.colors
                  : provider.searchColors(_searchQuery);

              // Ordena alfabeticamente
              final colors = _sortColors(unsortedColors);

              return ListView.builder(
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  final colorModel = colors[index];
                  return MagicalCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ColorDetailPage(colorModel: colorModel),
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
                              color: AppColors.surfaceBorder,
                              width: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                colorModel.name,
                                style: Theme.of(context).textTheme.titleLarge,
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
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
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
