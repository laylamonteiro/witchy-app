import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/spell_provider.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/magical_fab.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import 'ai_spell_creation_page.dart';
import 'spell_detail_page.dart';
import '../../data/models/spell_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Origem dos feitiços exibidos na aba "Meu Grimório".
enum SpellSource { all, mine, ancestral }

class UserSpellsListPage extends StatefulWidget {
  /// Quando aberto a partir do hub de categorias: título da AppBar própria.
  final String? title;

  /// Restringe a lista a um grupo de categorias (null = todas).
  final Set<SpellCategory>? categoryGroup;

  final SpellSource initialSource;

  /// Quando verdadeiro, lista apenas as páginas de registro do Grimório
  /// Vivo (Meus Registros), separadas dos feitiços.
  final bool recordsOnly;

  const UserSpellsListPage({
    super.key,
    this.title,
    this.categoryGroup,
    this.initialSource = SpellSource.all,
    this.recordsOnly = false,
  });

  @override
  State<UserSpellsListPage> createState() => _UserSpellsListPageState();
}

class _UserSpellsListPageState extends State<UserSpellsListPage> {
  String _searchQuery = '';
  SpellCategory? _filterCategory;
  late SpellSource _source = widget.initialSource;

  @override
  void initState() {
    super.initState();
    // Carrega feitiços do usuário + ancestrais (gatilho antes vivia no
    // AppSpellsListPage, agora mesclado nesta aba).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpellProvider>().loadSpells();
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildBody(context);
    if (widget.title == null) return body;
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(widget.title!),
      ),
      body: body,
    );
  }

  Widget _buildBody(BuildContext context) {
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
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.grimoireSearchSpells,
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
                      color: _filterCategory != null ? context.gc.lilac : null,
                    ),
                    tooltip: AppLocalizations.of(context)!.spellFilterByCategory,
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
                                  ? context.gc.lilac
                                  : context.gc.softWhite,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.spellAllCategories,
                              style: TextStyle(
                                fontWeight: _filterCategory == null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...(widget.categoryGroup?.toList() ??
                              SpellCategory.values)
                          .map((category) => PopupMenuItem<String>(
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
                                  Icon(Icons.check, size: 18, color: context.gc.lilac),
                                ],
                              ],
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),

            // Filtro de origem: Todos / Meus / Ancestrais
            // (sem sentido na aba de registros do Grimório Vivo)
            if (!widget.recordsOnly) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildSourceChip(AppLocalizations.of(context)!.spellSourceAll, SpellSource.all),
                    const SizedBox(width: 8),
                    _buildSourceChip(AppLocalizations.of(context)!.spellSourceMine, SpellSource.mine),
                    const SizedBox(width: 8),
                    _buildSourceChip(AppLocalizations.of(context)!.spellSourceAncestral, SpellSource.ancestral),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Lista de feitiços
            Expanded(
              child: Consumer<SpellProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return LoadingWidget(message: AppLocalizations.of(context)!.spellLoading);
                  }

                  final isPremium = context.watch<AuthProvider>().isPremium;

                  var spells = _source == SpellSource.mine
                      ? provider.userSpells
                      : _source == SpellSource.ancestral
                          ? provider.appSpells
                          : provider.spells;
                  // Registros do Grimório Vivo ficam na aba própria.
                  spells = spells
                      .where((s) => s.isRecord == widget.recordsOnly)
                      .toList();

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
                  final group = widget.categoryGroup;
                  if (group != null) {
                    spells =
                        spells.where((s) => group.contains(s.category)).toList();
                  }

                  if (spells.isEmpty) {
                    final hasActiveFilter =
                        _searchQuery.isNotEmpty || _filterCategory != null;
                    // Ação "Adicionar Feitiço" só faz sentido quando não há
                    // filtro ativo e não estamos vendo apenas os ancestrais;
                    // registros nascem das lições do Grimório Vivo.
                    final showAddAction = !widget.recordsOnly &&
                        !hasActiveFilter &&
                        _source != SpellSource.ancestral;
                    return EmptyStateWidget(
                      message: hasActiveFilter
                          ? AppLocalizations.of(context)!.spellNoneFound
                          : widget.recordsOnly
                              ? AppLocalizations.of(context)!.grimoireNoRecords
                              : _source == SpellSource.ancestral
                                  ? AppLocalizations.of(context)!.spellNoAncestral
                                  : AppLocalizations.of(context)!.spellEmptyGrimoire,
                      icon: Icons.auto_stories,
                      actionText: showAddAction ? AppLocalizations.of(context)!.spellAdd : null,
                      onAction:
                          showAddAction ? () => _navigateToForm(context) : null,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: spells.length,
                    itemBuilder: (context, index) {
                      final spell = spells[index];
                      // Fase lunar: sempre visível nos feitiços do usuário;
                      // nos ancestrais fica atrás do gate premium.
                      final showMoon = spell.moonPhase != null &&
                          (!spell.isPreloaded || isPremium);
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
                                if (showMoon) ...[
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
                                if (spell.isPreloaded)
                                  _buildChip(AppLocalizations.of(context)!.grimoireAncestral, context.gc.starYellow),
                                _buildChip(
                                  spell.category.displayName,
                                  context.gc.lilac,
                                ),
                                if (!spell.isRecord)
                                  _buildChip(
                                    spell.type.displayName,
                                    spell.type == SpellType.attraction
                                        ? context.gc.mint
                                        : context.gc.pink,
                                  ),
                              ],
                            ),
                            if (showMoon) ...[
                              const SizedBox(height: 8),
                              Text(
                                '${AppLocalizations.of(context)!.spellMoonPrefix}: ${spell.moonPhase!.displayName}',
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
        // Registros nascem das lições do Grimório Vivo — sem botão de criar.
        if (!widget.recordsOnly)
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

  Widget _buildSourceChip(String label, SpellSource source) {
    final selected = _source == source;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        FocusScope.of(context).unfocus();
        setState(() => _source = source);
      },
      labelStyle: TextStyle(
        color: selected ? context.gc.darkBackground : context.gc.softWhite,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      selectedColor: context.gc.lilac,
      backgroundColor: context.gc.surface,
      side: BorderSide(
        color: selected ? context.gc.lilac : context.gc.surfaceBorder,
      ),
    );
  }

  void _navigateToForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AISpellCreationPage(),
      ),
    );
  }
}
