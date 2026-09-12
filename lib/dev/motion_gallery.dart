import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/grimoire_colors.dart';
import '../core/theme/grimoire_motion.dart';
import '../core/widgets/motion/tool_scene_frame.dart';
import '../features/divination/data/data_sources/oracle_cards_data.dart';
import '../features/divination/presentation/oracle_art_registry.dart';
import '../features/divination/presentation/widgets/card_selection_surface.dart';
import '../features/divination/presentation/widgets/oracle_card_face.dart';
import '../features/runes/data/data_sources/runes_data.dart';
import '../features/runes/presentation/widgets/rune_selection_surface.dart';
import '../features/palmistry/presentation/widgets/palm_scan_view.dart';
import '../features/runes/presentation/widgets/rune_stone_view.dart';
import '../features/sigils/data/models/sigil_model.dart';
import '../features/sigils/presentation/widgets/sigil_drawing_painter.dart';
import '../features/sigils/presentation/widgets/sigil_letters_transition.dart';
import '../features/sigils/presentation/widgets/witch_wheel_painter.dart';
import '../features/tarot/data/data_sources/tarot_cards_data.dart';
import '../features/tarot/presentation/widgets/tarot_card_view.dart';
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
  final List<String> _stones = [];
  int _generation = 0;

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
              _selected = null; _stones.clear(); _generation++;
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
          Wrap(spacing: 12, runSpacing: 12, children: [
            for (var i = 0; i < 4; i++) RuneStoneView(size: 56, deckPosition: i),
            for (var i = 0; i < 2; i++)
              RuneStoneView(size: 56, deckPosition: i + 4,
                  symbol: runesData[i].symbol, reversed: i == 1),
          ]),
          const SizedBox(height: 20),
          Builder(builder: (context) {
            final available = [for (var i = 0; i < runesData.length; i++)
              if (!_stones.contains(runesData[i].name)) i];
            if (available.isEmpty) return const Text('Every stone was chosen');
            return RuneSelectionSurface(key: ValueKey('runes-$_generation'),
                stoneIds: [for (final i in available) runesData[i].name],
                deckPositions: available,
                onSelected: (id) => setState(() => _stones.add(id)));
          }),
          if (_stones.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Chosen: ${_stones.join(', ')}'),
          ],
          const SizedBox(height: 32),
          // The six animated Oracle scenes replay from the reset button.
          Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
            for (final id in OracleArtRegistry.scenes.keys)
              OracleSceneCard(
                key: ValueKey('scene-$id-$_generation'),
                card: oracleCardsData.firstWhere((c) => c.id == id),
                width: 96, playToken: _generation,
              ),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
            for (final card in oracleCardsData.take(8)) OracleCardFace(card: card, width: 64),
          ]),
          const SizedBox(height: 32),
          // O sigilo: as letras repetidas se dissipam e o traço percorre os
          // pontos até o símbolo assentar. O botão de reiniciar repete.
          SigilLettersTransition(
            key: ValueKey('sigil-letters-$_generation'),
            intention: 'PROTECAO',
            letters: Sigil.fromIntention('PROTECAO').processedLetters,
          ),
          const SizedBox(height: 24),
          // A mão sob leitura: a faixa só anda enquanto a requisição dura.
          Wrap(spacing: 16, runSpacing: 16, alignment: WrapAlignment.center, children: [
            PalmScanView(size: 120, active: !_reduced),
            const PalmScanView(size: 120),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: 260,
            height: 260,
            child: TweenAnimationBuilder<double>(
              key: ValueKey('sigil-trace-$_generation'),
              tween: Tween<double>(begin: _reduced ? 1 : 0, end: 1),
              duration: _reduced ? Duration.zero : GrimoireMotion.celebration,
              curve: Curves.easeInOut,
              builder: (context, progress, _) => CustomPaint(
                size: const Size(260, 260),
                painter: WitchWheelPainter(
                  borderColor: context.gc.surfaceBorder,
                  starColor: context.gc.starYellow,
                  accentColor: context.gc.lilac,
                  highlightedLetters:
                      Sigil.fromIntention('PROTECAO').processedLetters.split('').toSet(),
                ),
                foregroundPainter: SigilDrawingPainter(
                  intention: 'PROTECAO',
                  lineColor: context.gc.starYellow,
                  pointColor: context.gc.lilac,
                  progress: progress,
                ),
              ),
            ),
          ),
        ]),
      )),
    ),
  );
}
