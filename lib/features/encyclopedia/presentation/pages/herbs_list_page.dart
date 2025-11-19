import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/herb_model.dart';
import '../providers/encyclopedia_provider.dart';
import 'herb_detail_page.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';

class HerbsListPage extends StatefulWidget {
  const HerbsListPage({super.key});

  @override
  State<HerbsListPage> createState() => _HerbsListPageState();
}

class _HerbsListPageState extends State<HerbsListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EncyclopediaProvider>(context);
    final herbs = _searchQuery.isEmpty
        ? provider.herbs
        : provider.searchHerbs(_searchQuery);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Buscar ervas...',
              prefixIcon: const Icon(Icons.search, color: AppColors.mint),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.mint),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.mint),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: herbs.length,
            itemBuilder: (context, index) {
              final herb = herbs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MagicalCard(
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.mint.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          herb.element.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            herb.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (herb.toxic)
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.alert,
                            size: 20,
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          herb.scientificName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          herb.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.mint),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HerbDetailPage(herb: herb),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
