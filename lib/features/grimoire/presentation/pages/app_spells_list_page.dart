import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/spell_provider.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/theme/app_theme.dart';
import 'spell_detail_page.dart';
import '../../data/models/spell_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AppSpellsListPage extends StatefulWidget {
  const AppSpellsListPage({super.key});

  @override
  State<AppSpellsListPage> createState() => _AppSpellsListPageState();
}

class _AppSpellsListPageState extends State<AppSpellsListPage> {
  String _searchQuery = '';
  SpellCategory? _filterCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpellProvider>().loadSpells();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de busca
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar feitiços...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Consumer<SpellProvider>(
                builder: (context, provider, _) {
                  // Obter categorias únicas dos feitiços do app
                  final availableCategories = provider.appSpells
                      .map((s) => s.category)
                      .toSet()
                      .toList()
                    ..sort((a, b) => a.displayName.compareTo(b.displayName));

                  return PopupMenuButton<SpellCategory?>(
                    icon: const Icon(Icons.filter_list),
                    tooltip: 'Filtrar por categoria',
                    onSelected: (category) {
                      setState(() {
                        _filterCategory = category;
                      });
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: null,
                        child: Text('Todas Categorias'),
                      ),
                      ...availableCategories.map((category) => PopupMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Text(category.icon),
                                const SizedBox(width: 8),
                                Text(category.displayName),
                              ],
                            ),
                          )),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        // Lista de feitiços
        Expanded(
          child: Consumer<SpellProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const LoadingWidget(message: 'Carregando feitiços...');
              }

              var spells = provider.appSpells;

              // Aplicar filtros
              if (_searchQuery.isNotEmpty) {
                spells = spells
                    .where((s) =>
                        s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        s.purpose.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        s.category.displayName
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                    .toList();
              }
              if (_filterCategory != null) {
                spells = spells.where((s) => s.category == _filterCategory).toList();
              }

              if (spells.isEmpty) {
                return EmptyStateWidget(
                  message: _searchQuery.isNotEmpty || _filterCategory != null
                      ? 'Nenhum feitiço encontrado'
                      : 'Nenhum feitiço do app disponível',
                  icon: Icons.auto_stories,
                );
              }

              return Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  final isPremium = authProvider.isPremium;

                  return ListView.builder(
                    itemCount: spells.length,
                    itemBuilder: (context, index) {
                      final spell = spells[index];
                      return MagicalCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SpellDetailPage(spell: spell),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Emoji da categoria - sempre visível
                                // Emoji da fase lunar - apenas para premium
                                if (isPremium && spell.moonPhase != null) ...[
                                  Text(
                                    spell.moonPhase!.emoji,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Text(
                                    spell.name,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                _buildChip(
                                  spell.category.displayName,
                                  AppColors.lilac,
                                ),
                                _buildChip(
                                  spell.type.displayName,
                                  spell.type == SpellType.attraction
                                      ? AppColors.mint
                                      : AppColors.pink,
                                ),
                              ],
                            ),
                            // Fase lunar recomendada - apenas para premium
                            if (isPremium && spell.moonPhase != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Lua: ${spell.moonPhase!.displayName}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: color.withOpacity(0.2),
      side: BorderSide(color: color),
    );
  }
}
