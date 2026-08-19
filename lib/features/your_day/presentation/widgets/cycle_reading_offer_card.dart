import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/offers/offer_engine.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cycle_reading/data/models/cycle_reading_model.dart';
import '../../../cycle_reading/data/services/cycle_reading_composer.dart';
import '../../../cycle_reading/data/services/cycle_reading_service.dart';
import '../../../cycle_reading/presentation/pages/cycle_reading_intro_page.dart';
import '../../data/daily_checkin_repository.dart';

/// Convite da Leitura do Ciclo no Seu Dia (Motor de Ofertas, B2).
///
/// Gatilho de engajamento: streak ≥ [minStreak] E ≥ [minRecords] registros
/// na lunação corrente — o número concreto de registros é o gancho. O
/// OfferEngine aplica os guardrails (1 oferta/dia no app, 1 convite por
/// ciclo, cooldown/silêncio após dispensas). Quem já tem a leitura desta
/// janela não vê o convite.
class CycleReadingOfferCard extends StatefulWidget {
  const CycleReadingOfferCard({super.key});

  static const int minStreak = 7;
  static const int minRecords = CycleReadingComposer.minRecordsForDepth;

  @override
  State<CycleReadingOfferCard> createState() => _CycleReadingOfferCardState();
}

class _CycleReadingOfferCardState extends State<CycleReadingOfferCard> {
  static const _slot = OfferSlot.cycleReading;

  OfferEngine? _engine;
  bool _visible = false;
  int _recordCount = 0;
  late final String _periodKey = CycleReadingService.lunationKey();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = context.read<AuthProvider>().currentUser.id;
    final engine = await OfferEngine.load();

    // O convite não aparece para quem já garantiu a leitura desta janela.
    final service = CycleReadingService();
    final period = CycleReadingService.currentLunation();
    final existing = await service.repository.findForPeriod(
      userId,
      period.start,
      periodType: CycleReadingPeriodType.lunation,
    );
    if (existing != null) return;

    if (!engine.shouldShow(_slot, periodKey: _periodKey)) return;

    final streak = await DailyCheckinRepository().currentStreak(userId);
    if (streak < CycleReadingOfferCard.minStreak) return;

    final recordCount = await service.composer.countPeriodRecords(
      userId: userId,
      start: period.start,
      end: period.end,
    );
    if (recordCount < CycleReadingOfferCard.minRecords) return;

    await engine.recordExposure(_slot);
    if (!mounted) return;
    setState(() {
      _engine = engine;
      _recordCount = recordCount;
      _visible = true;
    });
  }

  Future<void> _dismiss() async {
    await _engine?.recordDismissal(_slot, periodKey: _periodKey);
    if (mounted) setState(() => _visible = false);
  }

  void _open() {
    _engine?.recordClick(_slot);
    Navigator.of(context).push(
      MaterialPageRoute(
        // O gancho falou da lunação: a tela abre nessa janela (a semana
        // continua a um toque, no seletor).
        builder: (_) => const CycleReadingIntroPage(
          initialPeriodType: CycleReadingPeriodType.lunation,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);

    return MagicalCard.accent(
      accent: context.gc.lilac,
      onTap: _open,
      child: Row(
        children: [
          const Text('🌙', style: TextStyle(fontSize: 30)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.cycleReadingOfferTitle(_recordCount),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: context.gc.lilac,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.cycleReadingOfferBody,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.cycleReadingOfferCta,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.lilac,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: _dismiss,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                size: 18,
                color: context.gc.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
