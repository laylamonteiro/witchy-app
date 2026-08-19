import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/ai/ai_service.dart';
import '../../../../core/offers/offer_engine.dart';
import '../../../../core/offers/teaser_cache.dart';
import '../../../../core/offers/teaser_reveal.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../auth/data/models/feature_access.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../data/models/dream_model.dart';

/// Degustação da interpretação de sonhos (Motor de Ofertas, B1).
///
/// Momento-gatilho: a pessoa está RELENDO um sonho salvo sem interpretação
/// (tela de leitura — nunca interrompe a escrita). A amostra são 2 frases
/// REAIS geradas sob demanda (o texto completo nem existe no aparelho),
/// cacheadas por sonho: nunca uma segunda chamada de IA pelo mesmo registro.
class DreamTeaserCard extends StatefulWidget {
  final DreamModel dream;

  const DreamTeaserCard({super.key, required this.dream});

  @override
  State<DreamTeaserCard> createState() => _DreamTeaserCardState();
}

class _DreamTeaserCardState extends State<DreamTeaserCard> {
  static const _slot = OfferSlot.dreamTeaser;

  OfferEngine? _engine;
  bool _visible = false;
  bool _exposureRecorded = false;
  String? _sample;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final engine = await OfferEngine.load();
    final cached = await TeaserAiCache.get(_slot.name, widget.dream.id);
    if (!mounted) return;
    setState(() {
      _engine = engine;
      _sample = cached;
    });
    _evaluate();
  }

  void _evaluate() {
    final engine = _engine;
    if (engine == null) return;
    final access = context.read<AuthProvider>().checkFeatureAccess(
          AppFeature.aiPersonalizedDreamInterpretation,
        );
    final show = engine.shouldShow(
      _slot,
      alreadyOwned: access.hasFullAccess,
    );
    if (show && !_exposureRecorded) {
      _exposureRecorded = true;
      engine.recordExposure(_slot);
    }
    if (mounted) setState(() => _visible = show);
  }

  Future<void> _generateSample() async {
    if (_isGenerating) return;
    setState(() => _isGenerating = true);
    final messenger = ScaffoldMessenger.of(context);
    final alertColor = context.gc.alert;
    try {
      final sample = await AIService.instance.generateDreamTeaser(
        dreamDescription: widget.dream.content,
        feelings: widget.dream.feeling,
      );
      await TeaserAiCache.put(_slot.name, widget.dream.id, sample);
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

  Future<void> _dismiss() async {
    await _engine?.recordDismissal(_slot);
    if (mounted) setState(() => _visible = false);
  }

  void _onCta() {
    _engine?.recordClick(_slot);
    showPremiumUpgradePaywall(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.gc.lilac.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.gc.lilac.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🌙 ', style: TextStyle(color: context.gc.starYellow)),
              Expanded(
                child: Text(
                  l10n.dreamTeaserTitle,
                  style: TextStyle(
                    color: context.gc.lilac,
                    fontWeight: FontWeight.bold,
                  ),
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
          const SizedBox(height: 8),
          if (_sample == null) ...[
            Text(
              l10n.dreamTeaserIntro,
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
                label: Text(l10n.dreamTeaserPeek),
              ),
            ),
          ] else
            TeaserReveal(
              sample: Text(
                _sample!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
              ),
              onCta: _onCta,
            ),
        ],
      ),
    );
  }
}
