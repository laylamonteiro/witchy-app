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
            decoration: const InputDecoration(
              hintText: 'Buscar ervas...',
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
          child: ListView.builder(
            itemCount: herbs.length,
            itemBuilder: (context, index) {
              final herb = herbs[index];
              return MagicalCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HerbDetailPage(herb: herb),
                    ),
                  );
                },
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: herb.imageUrl != null
                          ? Image.asset(
                              herb.imageUrl!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
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
                                );
                              },
                            )
                          : Container(
                              width: 60,
                              height: 60,
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
                                  herb.name,
                                  style: Theme.of(context).textTheme.titleLarge,
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
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(herb.element.emoji),
                              const SizedBox(width: 4),
                              Text(
                                herb.element.displayName,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
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
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),
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
