import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/spell_provider.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/magical_fab.dart';
import '../../../../core/theme/app_theme.dart';
import 'spell_form_page.dart';
import 'spell_detail_page.dart';
import '../../data/models/spell_model.dart';

class UserSpellsListPage extends StatefulWidget {
  const UserSpellsListPage({super.key});

  @override
  State<UserSpellsListPage> createState() => _UserSpellsListPageState();
}

class _UserSpellsListPageState extends State<UserSpellsListPage> {
  String _searchQuery = '';
  SpellCategory? _filterCategory;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
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
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.filter_list,
                      color: _filterCategory != null ? AppColors.lilac : null,
                    ),
                    tooltip: 'Filtrar por categoria',
                    onSelected: (value) {
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
                      ...SpellCategory.values.map((category) => PopupMenuItem<String>(
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

                  var spells = provider.userSpells;

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
                          : 'Seu grimório está vazio.\nComece adicionando seu primeiro feitiço!',
                      icon: Icons.auto_stories,
                      actionText: _searchQuery.isEmpty && _filterCategory == null
                          ? 'Adicionar Feitiço'
                          : null,
                      onAction: _searchQuery.isEmpty && _filterCategory == null
                          ? () => _navigateToForm(context)
                          : null,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
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
                                Text(
                                  spell.category.icon,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 8),
                                if (spell.moonPhase != null) ...[
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
        Positioned(
          right: 16,
          bottom: 16,
          child: MagicalFAB(
            onPressed: () => _navigateToForm(context),
            icon: Icons.auto_fix_high,
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

  void _navigateToForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SpellFormPage(),
      ),
    );
  }
}
