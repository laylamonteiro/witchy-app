import 'dart:async';
import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../data/models/rune_spread_model.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/data/services/reading_archive_composer.dart';
import '../../../diary/presentation/widgets/save_to_records_button.dart';
import '../../data/data_sources/runes_data.dart';
import '../../data/repositories/rune_reading_repository.dart';
import 'rune_detail_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../../core/services/ad_service.dart';
import '../../../your_day/presentation/providers/daily_checkin_provider.dart';

class RuneReadingPage extends StatefulWidget {
  const RuneReadingPage({super.key});

  @override
  State<RuneReadingPage> createState() => _RuneReadingPageState();
}

class _RuneReadingPageState extends State<RuneReadingPage>
    with SingleTickerProviderStateMixin {
  final _questionController = TextEditingController();
  final _repository = RuneReadingRepository();

  RuneSpreadType _selectedSpread = RuneSpreadType.single;
  List<RunePosition>? _drawnRunes;
  late AnimationController _animController;
  bool _isDrawing = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _drawRunes() async {
    // Verificar limite diário para usuários free
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.canUseRunes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context).oracleDailyLimit),
          backgroundColor: context.gc.alert,
          duration: Duration(seconds: 4),
        ),
      );
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const PremiumUpgradeSheet(),
      );
      return;
    }

    setState(() {
      _isDrawing = true;
    });

    // Aguardar um momento para efeito dramático
    await Future.delayed(const Duration(milliseconds: 500));

    // Embaralhar runas
    final allRunes = List<RuneModel>.from(runesData)..shuffle();

    // Tirar número de runas baseado no spread
    final count = _selectedSpread.runeCount;
    final drawn = <RunePosition>[];

    for (int i = 0; i < count; i++) {
      final rune = allRunes[i];
      final isReversed = Random().nextBool(); // 50% chance de invertida

      drawn.add(RunePosition(
        position: i,
        rune: rune,
        isReversed: isReversed,
        positionMeaning: _selectedSpread.getPositionMeaning(i),
      ));
    }

    // Incrementar uso de runas
    await authProvider.incrementRuneReadings();

    // Anúncio ANTES de revelar as runas (free, cooldown interno).
    await AdService.instance.showBeforeResult();
    if (!mounted) return;

    setState(() {
      _drawnRunes = drawn;
      _isDrawing = false;
    });

    _animController.forward(from: 0);

    // Salvar leitura
    await _saveReading(drawn);
    // A tiragem aconteceu: se as runas são o rito de hoje, está cumprido.
    if (mounted) {
      unawaited(
          context.read<DailyCheckinProvider>().completeRite(DailyRites.runes));
    }
  }

  /// Última leitura salva — alimenta o botão "Salvar nos Registros".
  RuneReading? _lastReading;

  Future<void> _saveReading(List<RunePosition> positions) async {
    final reading = RuneReading(
      id: const Uuid().v4(),
      question: _questionController.text.isNotEmpty
          ? _questionController.text
          : AppLocalizations.of(context).runesNoQuestion,
      spreadType: _selectedSpread,
      positions: positions,
      date: DateTime.now(),
    );

    await _repository.saveReading(
      reading,
      context.read<AuthProvider>().currentUser.id,
    );
    if (mounted) setState(() => _lastReading = reading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).runesReadingTitle),
        backgroundColor: context.gc.darkBackground,
      ),
      backgroundColor: context.gc.darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_drawnRunes == null) ...[
              MagicalCard(
                child: Column(
                  children: [
                    const Text('ᚱᚢᚾᚨ', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).runesReadingTitle,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: context.gc.lilac,
                              ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context).runesReadingIntro,
                      style: TextStyle(
                        color: context.gc.softWhite.withValues(alpha: 0.8),
                        fontSize: 14,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context).runesReversedNote,
                      style: TextStyle(
                        color: context.gc.lilac.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                AppLocalizations.of(context).runesChooseLayout,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: context.gc.lilac,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Opções de spread
              _buildSpreadOption(
                RuneSpreadType.single,
                Icons.crop_square,
              ),
              const SizedBox(height: 12),
              _buildSpreadOption(
                RuneSpreadType.threeCast,
                Icons.view_column,
              ),
              const SizedBox(height: 12),
              _buildSpreadOption(
                RuneSpreadType.nordicCross,
                Icons.add,
              ),
              const SizedBox(height: 12),
              _buildSpreadOption(
                RuneSpreadType.nineWorlds,
                Icons.grid_3x3,
              ),

              const SizedBox(height: 16),

              // Campo de pergunta
              MagicalCard(
                child: TextField(
                  controller: _questionController,
                  style: TextStyle(color: context.gc.softWhite),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).runesQuestionOptional,
                    labelStyle: TextStyle(color: context.gc.lilac),
                    hintText: AppLocalizations.of(context).runesQuestionHint,
                    hintStyle: TextStyle(
                      color: context.gc.softWhite.withValues(alpha: 0.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.gc.lilac),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: context.gc.lilac.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.gc.lilac),
                    ),
                  ),
                  maxLines: 2,
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _isDrawing ? null : _drawRunes,
                icon: _isDrawing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            context.gc.darkBackground,
                          ),
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_isDrawing ? AppLocalizations.of(context).runesDrawing : AppLocalizations.of(context).runesDraw),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.gc.lilac,
                  foregroundColor: context.gc.darkBackground,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  disabledBackgroundColor: context.gc.lilac.withValues(alpha: 0.3),
                ),
              ),

              // Exibir usos restantes para usuários free
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  if (authProvider.isPremium) return const SizedBox.shrink();
                  final remaining =
                      authProvider.currentUser.remainingRuneReadings;
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      AppLocalizations.of(context).oracleRemainingToday('$remaining/${UserModel.freeRuneReadingsLimit}'),
                      style: TextStyle(
                        color: remaining > 0
                            ? context.gc.softWhite.withValues(alpha: 0.6)
                            : context.gc.alert,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ],

            // Resultado
            if (_drawnRunes != null) ...[
              _buildReadingResult(_drawnRunes!),
              if (_lastReading != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: SaveToRecordsButton(
                    key: ValueKey('save_${_lastReading!.id}'),
                    buildEntry: () {
                      final page =
                          ReadingArchiveComposer.runes(_lastReading!);
                      return FreeWritingModel(
                        userId: context.read<AuthProvider>().currentUser.id,
                        title: page.title,
                        content: page.content,
                        source: FreeWritingSource.runes,
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _drawnRunes = null;
                    _animController.reset();
                    _questionController.clear();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context).oracleNewReading),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.gc.lilac,
                  side: BorderSide(color: context.gc.lilac),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpreadOption(RuneSpreadType spread, IconData icon) {
    final isSelected = _selectedSpread == spread;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSpread = spread;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? context.gc.lilac.withValues(alpha: 0.2)
              : context.gc.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.gc.lilac : context.gc.surfaceBorder,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? context.gc.lilac : context.gc.softWhite,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spread.displayName,
                    style: TextStyle(
                      color: isSelected ? context.gc.lilac : context.gc.softWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    spread.description,
                    style: TextStyle(
                      color: context.gc.softWhite.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: context.gc.lilac,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingResult(List<RunePosition> positions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MagicalCard(
          child: Column(
            children: [
              const Text('✨', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).oracleYourReading,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: context.gc.lilac,
                    ),
              ),
              if (_questionController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _questionController.text,
                  style: TextStyle(
                    color: context.gc.softWhite.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Runas tiradas
        ...positions.map((position) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: _animController,
                      curve: Interval(
                        position.position * 0.1,
                        (position.position * 0.1) + 0.3,
                        curve: Curves.easeOut,
                      ),
                    ),
                  ),
                  child: child,
                );
              },
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RuneDetailPage(rune: position.rune),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: context.gc.lilac.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                position.rune.symbol,
                                style: TextStyle(
                                  fontSize: 32,
                                  color: context.gc.lilac,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  position.positionMeaning,
                                  style: TextStyle(
                                    color: context.gc.softWhite.withValues(alpha: 0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  position.rune.name,
                                  style: TextStyle(
                                    color: context.gc.lilac,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (position.isReversed)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.gc.alert.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                AppLocalizations.of(context).runesReversed,
                                style: TextStyle(
                                  color: context.gc.alert,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        position.isReversed &&
                                position.rune.reversedMeaning != null
                            ? position.rune.reversedMeaning!
                            : position.rune.divination,
                        style: TextStyle(
                          color: context.gc.softWhite,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
