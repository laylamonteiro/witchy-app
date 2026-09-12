import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/grimoire_colors.dart';
import '../core/widgets/motion/tool_scene_frame.dart';
import '../features/divination/presentation/widgets/card_selection_surface.dart';
import '../features/tarot/data/data_sources/tarot_cards_data.dart';
import '../features/tarot/presentation/widgets/tarot_card_view.dart';
import '../features/runes/data/data_sources/runes_data.dart';
import '../features/runes/data/models/rune_spread_model.dart';
import '../features/runes/presentation/widgets/rune_selection_surface.dart';
import '../features/runes/presentation/widgets/rune_spread_board.dart';
import '../l10n/generated/app_localizations.dart';

/// Developer-only target: flutter run -t lib/dev/motion_gallery.dart.
/// No auth, ads, quota, database or AI calls. Never linked from product routes.
void main() {
  if (kReleaseMode) return;
  runApp(MaterialApp(
    title: 'Motion gallery',
    theme: AppTheme.build(AppThemes.colorsById(AppThemes.defaultId)),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const _Gallery(),
  ));
}

class _Gallery extends StatefulWidget {
  const _Gallery();
  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  bool _reduced = false;
  String? _selected;
  int _generation = 0;
  final _runes = <String>[];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Motion gallery')),
    body: MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: _reduced),
      child: ToolSceneFrame(child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          SwitchListTile(title: const Text('Reduce motion'), value: _reduced,
              onChanged: (value) => setState(() => _reduced = value)),
          TextButton(onPressed: () => setState(() {
              _selected = null; _runes.clear(); _generation++;
            }), child: const Text('Reset fixture')),
          Wrap(spacing: 12, runSpacing: 12, children: [
            for (var i = 0; i < 6; i++)
              TarotCardBack(width: 72, deckPosition: i),
          ]),
          const SizedBox(height: 20),
          CardSelectionSurface(key: ValueKey(_generation),
              cardIds: tarotCards.map((c) => c.id).toList(),
              enabled: _selected == null,
              onSelected: (id) => setState(() => _selected = id)),
          if (_selected != null) ...[
            const SizedBox(height: 20),
            TarotCardView(card: tarotCards.firstWhere((c) => c.id == _selected)),
          ],
          const SizedBox(height: 32),
          RuneSpreadBoard(spread: RuneSpreadType.nineWorlds,
            stoneSlots: _runes.map((id) => runesData.indexWhere((r) => r.id == id)).toList(),
            progress: _runes.length == 9 ? 1 : 0,
            positions: _runes.length < 9 ? const [] : [for (var i = 0; i < 9; i++)
              RunePosition(position: i, rune: runesData.firstWhere((r) => r.id == _runes[i]),
                isReversed: i.isOdd, positionMeaning: RuneSpreadType.nineWorlds.getPositionMeaning(i))],
          ),
          const SizedBox(height: 16),
          RuneSelectionSurface(key: ValueKey('runes-$_generation'),
            stoneIds: runesData.map((r) => r.id).toList(), selectedIds: _runes,
            enabled: _runes.length < 9,
            onSelected: (id) => setState(() => _runes.add(id))),
        ]),
      )),
    ),
  );
}
