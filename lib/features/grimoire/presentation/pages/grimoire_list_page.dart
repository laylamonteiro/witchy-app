import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/spell_provider.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_assets.dart';
import 'spell_form_page.dart';
import 'spell_detail_page.dart';
import '../../data/models/spell_model.dart';

class GrimoireListPage extends StatefulWidget {
  const GrimoireListPage({super.key});

  @override
  State<GrimoireListPage> createState() => _GrimoireListPageState();
}

class _GrimoireListPageState extends State<GrimoireListPage> {
  String _searchQuery = '';
  SpellType? _filterType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpellProvider>().loadSpells();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grimório Digital'),
        actions: [
          PopupMenuButton<SpellType?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (type) {
              setState(() {
                _filterType = type;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Todos'),
              ),
              PopupMenuItem(
                value: SpellType.attraction,
                child: Text(SpellType.attraction.displayName),
              ),
              PopupMenuItem(
                value: SpellType.banishment,
                child: Text(SpellType.banishment.displayName),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar feitiços...',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SvgPicture.asset(
                    AppAssets.searchDark,
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.textSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Lista de feitiços
          Expanded(
            child: Consumer<SpellProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const LoadingWidget(message: 'Carregando feitiços...');
                }

                var spells = provider.spells;

                // Aplicar filtros
                if (_searchQuery.isNotEmpty) {
                  spells = provider.searchSpells(_searchQuery);
                }
                if (_filterType != null) {
                  spells =
                      spells.where((s) => s.type == _filterType).toList();
                }

                if (spells.isEmpty) {
                  return EmptyStateWidget(
                    message: _searchQuery.isNotEmpty
                        ? 'Nenhum feitiço encontrado'
                        : 'Seu grimório está vazio.\nComece adicionando seu primeiro feitiço!',
                    icon: Icons.auto_stories,
                    actionText: _searchQuery.isEmpty ? 'Adicionar Feitiço' : null,
                    onAction: _searchQuery.isEmpty
                        ? () => _navigateToForm(context)
                        : null,
                  );
                }

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
                              if (spell.moonPhase != null)
                                Text(
                                  spell.moonPhase!.emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              const SizedBox(width: 8),
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
                            children: [
                              _buildChip(
                                spell.type.displayName,
                                spell.type == SpellType.attraction
                                    ? AppColors.mint
                                    : AppColors.pink,
                              ),
                              _buildChip(
                                spell.purpose,
                                AppColors.lilac,
                              ),
                            ],
                          ),
                          if (spell.moonPhase != null) ...[
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
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        backgroundColor: AppColors.lilac,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            AppAssets.addDark,
            colorFilter: const ColorFilter.mode(
              Color(0xFF2B2143),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
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

  void _navigateToForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SpellFormPage(),
      ),
    );
  }
}
