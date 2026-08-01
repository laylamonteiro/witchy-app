import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_search_field.dart';
import '../../data/encyclopedia_search.dart';
import '../../data/models/user_entry_model.dart';
import '../providers/encyclopedia_provider.dart';

/// Busca global da Enciclopédia: um campo, todas as 15 abas (e as entradas
/// pessoais). Resultados agrupados por seção, cada um abrindo o verbete.
class EncyclopediaSearchPage extends StatefulWidget {
  const EncyclopediaSearchPage({super.key});

  @override
  State<EncyclopediaSearchPage> createState() => _EncyclopediaSearchPageState();
}

class _EncyclopediaSearchPageState extends State<EncyclopediaSearchPage> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<EncyclopediaProvider>();
    final userEntries = [
      for (final category in UserEntryCategory.values)
        ...provider.userEntries(category),
    ];

    final hits = searchEncyclopedia(_query, l10n, userEntries: userEntries);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.commonSearch)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: MagicalSearchField(
              controller: _controller,
              hint: l10n.encySearchAll,
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(child: _buildResults(context, l10n, hits)),
        ],
      ),
    );
  }

  Widget _buildResults(
    BuildContext context,
    AppLocalizations l10n,
    List<EncyclopediaHit> hits,
  ) {
    if (_query.trim().length < 2) {
      // Convite, não erro: a Bruxa ainda está digitando.
      return Center(
        child: Text(
          l10n.encySearchAll,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.gc.textSecondary,
              ),
        ),
      );
    }
    if (hits.isEmpty) {
      return Center(
        child: Text(
          l10n.encyNothingFound,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: context.gc.textSecondary,
              ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: hits.length,
      itemBuilder: (context, index) {
        final hit = hits[index];
        // Cabeçalho de seção quando ela muda em relação ao item anterior.
        final showHeader = index == 0 || hits[index - 1].section != hit.section;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                child: Text(
                  hit.section.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ListTile(
              leading: Text(hit.emoji, style: const TextStyle(fontSize: 24)),
              title: Text(
                hit.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: context.gc.textPrimary,
                    ),
              ),
              subtitle: hit.subtitle == null
                  ? null
                  : Text(
                      hit.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.gc.textSecondary,
                          ),
                    ),
              trailing:
                  Icon(Icons.chevron_right, color: context.gc.textSecondary),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: hit.open),
              ),
            ),
          ],
        );
      },
    );
  }
}
