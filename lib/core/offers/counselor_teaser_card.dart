import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../ai/ai_service.dart';
import '../theme/grimoire_colors.dart';
import '../../features/auth/presentation/widgets/premium_blur_widget.dart';
import 'offer_engine.dart';
import 'teaser_cache.dart';
import 'teaser_reveal.dart';

/// Degustação do Conselheiro Místico sobre uma tiragem recém-feita.
///
/// Momento-gatilho: as cartas/runas já estão na mesa e a pessoa quer saber o
/// que elas dizem juntas. No lugar do paywall frio, ela lê 2 frases REAIS
/// sobre a própria tiragem e decide se quer o conselho inteiro.
///
/// Fail-closed como as outras degustações: a amostra nasce do tamanho da
/// amostra (o conselho completo nem chega a ser gerado) e fica cacheada por
/// tiragem — cada geração custa uma chamada de IA de verdade.
///
/// Sem moldura própria: entra no card do Conselheiro que cada tiragem já
/// desenha, no lugar exato do botão que a pessoa não pode apertar.
class CounselorTeaserCard extends StatefulWidget {
  /// Identidade da tiragem — chave do cache da amostra.
  final String readingId;

  /// Resumo da tiragem, o mesmo material que o conselho pago usaria.
  final String summary;

  const CounselorTeaserCard({
    super.key,
    required this.readingId,
    required this.summary,
  });

  @override
  State<CounselorTeaserCard> createState() => _CounselorTeaserCardState();
}

class _CounselorTeaserCardState extends State<CounselorTeaserCard> {
  static const _slot = OfferSlot.counselorTeaser;

  OfferEngine? _engine;
  String? _sample;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(CounselorTeaserCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Outra tiragem, outra amostra.
    if (oldWidget.readingId != widget.readingId) {
      setState(() => _sample = null);
      _load();
    }
  }

  Future<void> _load() async {
    final engine = await OfferEngine.load();
    final cached = await TeaserAiCache.get(_slot.name, widget.readingId);
    if (!mounted) return;
    setState(() {
      _engine = engine;
      _sample = cached;
    });
    engine.recordWallExposure(_slot);
  }

  Future<void> _generateSample() async {
    if (_isGenerating) return;
    setState(() => _isGenerating = true);
    final messenger = ScaffoldMessenger.of(context);
    final alertColor = context.gc.alert;
    try {
      final sample = await AIService.instance.generateCounselorTeaser(
        readingSummary: widget.summary,
      );
      await TeaserAiCache.put(_slot.name, widget.readingId, sample);
      if (!mounted) return;
      setState(() => _sample = sample);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text('$e'.replaceAll('Exception: ', '')),
        backgroundColor: alertColor,
      ));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _onCta() {
    _engine?.recordClick(_slot);
    showPremiumUpgradePaywall(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sample = _sample;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.counselorTeaserTitle,
          style: TextStyle(
            color: context.gc.lilac,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (sample == null) ...[
          Text(
            l10n.counselorTeaserIntro,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.gc.textSecondary,
                ),
          ),
          const SizedBox(height: 10),
          Center(
            child: OutlinedButton.icon(
              onPressed: _isGenerating ? null : _generateSample,
              icon: _isGenerating
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.gc.lilac,
                      ),
                    )
                  : const Icon(Icons.auto_awesome, size: 18),
              label: Text(l10n.counselorTeaserPeek),
            ),
          ),
        ] else
          TeaserReveal(
            sample: Text(
              sample,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
            ),
            onCta: _onCta,
          ),
      ],
    );
  }
}
