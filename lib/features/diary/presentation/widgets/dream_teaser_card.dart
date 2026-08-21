import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/offers/offer_engine.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/premium_locked_preview.dart';
import '../../../auth/data/models/feature_access.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../data/models/dream_model.dart';

/// O que a interpretação deste sonho traria (Motor de Ofertas, B1).
///
/// Momento-gatilho: a pessoa está RELENDO um sonho salvo sem interpretação
/// (tela de leitura — nunca interrompe a escrita). Mostra as seções da
/// interpretação pelo nome, com o texto sob véu: nada é gerado, então este
/// card não custa uma chamada de IA e o conteúdo real nunca chega ao
/// aparelho de quem não tem acesso.
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final engine = await OfferEngine.load();
    if (!mounted) return;
    setState(() => _engine = engine);
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
          PremiumLockedPreview(
            titles: [
              l10n.dreamLockedTitle1,
              l10n.dreamLockedTitle2,
              l10n.dreamLockedTitle3,
              l10n.dreamLockedTitle4,
              l10n.dreamLockedTitle5,
            ],
            linesPerSection: 1,
            onCta: _onCta,
          ),
        ],
      ),
    );
  }
}
