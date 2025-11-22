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

                  return Stack(
                    children: [
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.filter_list,
                          color: _filterCategory != null
                              ? AppColors.lilac
                              : null,
                        ),
                        tooltip: 'Filtrar por categoria',
                        onSelected: (value) {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            if (value == 'all') {
                              _filterCategory = null;
                            } else {
                              _filterCategory = SpellCategory.values.firstWhere(
                                (c) => c.name == value,
                              );
                            }
                          });
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'all',
                            child: Row(
                              children: [
                                Icon(
                                  _filterCategory == null
                                      ? Icons.check
                                      : Icons.filter_list_off,
                                  size: 18,
                                  color: _filterCategory == null
                                      ? AppColors.lilac
                                      : AppColors.softWhite,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Todas Categorias',
                                  style: TextStyle(
                                    fontWeight: _filterCategory == null
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...availableCategories.map((category) => PopupMenuItem<String>(
                                value: category.name,
                                child: Row(
                                  children: [
                                    Text(category.icon),
                                    const SizedBox(width: 8),
                                    Text(
                                      category.displayName,
                                      style: TextStyle(
                                        fontWeight: _filterCategory == category
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    if (_filterCategory == category) ...[
                                      const Spacer(),
                                      const Icon(Icons.check, size: 18, color: AppColors.lilac),
                                    ],
                                  ],
                                ),
                              )),
                        ],
                      ),
                      // Indicador de filtro ativo
                      if (_filterCategory != null)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.lilac,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
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
