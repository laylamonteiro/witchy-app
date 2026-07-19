import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/magical_fab.dart';
import '../../data/models/spell_model.dart';
import '../providers/spell_provider.dart';
import 'ai_spell_creation_page.dart';
import 'spell_detail_page.dart';
import 'user_spells_list_page.dart';

/// Grupo temático de categorias de feitiços exibido como card no hub.
class _SpellGroup {
  final String emoji;
  final String title;
  final String subtitle;
  final Set<SpellCategory> categories;

  const _SpellGroup({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.categories,
  });
}

List<_SpellGroup> _spellGroups(AppLocalizations l10n) => [
  _SpellGroup(
    emoji: '🛡️',
    title: l10n.spellGroupProtection,
    subtitle: l10n.spellGroupProtectionSub,
    categories: const {
      SpellCategory.protection,
      SpellCategory.cleansing,
      SpellCategory.banishing,
    },
  ),
  _SpellGroup(
    emoji: '💗',
    title: l10n.spellGroupLove,
    subtitle: l10n.spellGroupLoveSub,
    categories: const {
      SpellCategory.love,
      SpellCategory.selfLove,
      SpellCategory.friendship,
    },
  ),
  _SpellGroup(
    emoji: '🍀',
    title: l10n.spellGroupProsperity,
    subtitle: l10n.spellGroupProsperitySub,
    categories: const {
      SpellCategory.prosperity,
      SpellCategory.luck,
      SpellCategory.work,
      SpellCategory.study,
    },
  ),
  _SpellGroup(
    emoji: '🌙',
    title: l10n.spellGroupDreams,
    subtitle: l10n.spellGroupDreamsSub,
    categories: const {
      SpellCategory.dreams,
      SpellCategory.divination,
      SpellCategory.wisdom,
    },
  ),
  _SpellGroup(
    emoji: '🔥',
    title: l10n.spellGroupEnergy,
    subtitle: l10n.spellGroupEnergySub,
    categories: const {
      SpellCategory.healing,
      SpellCategory.energy,
      SpellCategory.courage,
    },
  ),
  _SpellGroup(
    emoji: '🗣️',
    title: l10n.spellGroupCreation,
    subtitle: l10n.spellGroupCreationSub,
    categories: const {
      SpellCategory.creativity,
      SpellCategory.communication,
    },
  ),
  _SpellGroup(
    emoji: '🏠',
    title: l10n.spellGroupHome,
    subtitle: l10n.spellGroupHomeSub,
    categories: const {
      SpellCategory.home,
      SpellCategory.other,
    },
  ),
];

/// Aba "Meu Grimório": busca + cards de grupos de feitiços.
///
/// Os feitiços pessoais têm um card próprio; os grupos reúnem as categorias
/// (pessoais + ancestrais) com contagem. Tocar abre a lista filtrada.
class SpellCategoriesHubPage extends StatefulWidget {
  const SpellCategoriesHubPage({super.key});

  @override
  State<SpellCategoriesHubPage> createState() => _SpellCategoriesHubPageState();
}

class _SpellCategoriesHubPageState extends State<SpellCategoriesHubPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpellProvider>().loadSpells();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.grimoireSearchSpells,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            Expanded(
              child: Consumer<SpellProvider>(
                builder: (context, provider, _) {
                  if (_searchQuery.trim().isNotEmpty) {
                    return _buildSearchResults(context, provider);
                  }
                  return _buildGroupCards(context, provider);
                },
              ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: MagicalFAB(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AISpellCreationPage()),
            ),
            icon: Icons.auto_fix_high,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupCards(BuildContext context, SpellProvider provider) {
    final userCount = provider.userSpells.length;

    return ListView(
      padding: const EdgeInsets.only(bottom: 90),
      children: [
        _buildHubCard(
          context,
          emoji: '✨',
          title: AppLocalizations.of(context)!.grimoireMySpells,
          subtitle: AppLocalizations.of(context)!.grimoireMySpellsSub,
          count: userCount,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserSpellsListPage(
                title: AppLocalizations.of(context)!.grimoireMySpells,
                initialSource: SpellSource.mine,
              ),
            ),
          ),
        ),
        for (final group in _spellGroups(AppLocalizations.of(context)!))
          _buildHubCard(
            context,
            emoji: group.emoji,
            title: group.title,
            subtitle: group.subtitle,
            count: provider.spells
                .where((s) => group.categories.contains(s.category))
                .length,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserSpellsListPage(
                  title: group.title,
                  categoryGroup: group.categories,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHubCard(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: MagicalCard(
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: context.gc.lilac.withOpacity(0.12),
                border: Border.all(
                  color: context.gc.lilac.withOpacity(0.35),
                ),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.gc.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$count',
              style: TextStyle(
                color: context.gc.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(Icons.chevron_right, color: context.gc.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, SpellProvider provider) {
    final query = _searchQuery.toLowerCase();
    final results = provider.spells
        .where((s) =>
            s.name.toLowerCase().contains(query) ||
            s.purpose.toLowerCase().contains(query) ||
            s.category.displayName.toLowerCase().contains(query))
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.grimoireNoSpellsFound,
          style: TextStyle(color: context.gc.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final spell = results[index];
        return MagicalCard(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SpellDetailPage(spell: spell),
            ),
          ),
          child: Row(
            children: [
              Text(
                spell.category.icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spell.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      spell.isPreloaded
                          ? '${AppLocalizations.of(context)!.grimoireAncestral} · ${spell.category.displayName}'
                          : spell.category.displayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.gc.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: context.gc.textSecondary),
            ],
          ),
        );
      },
    );
  }
}
