import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/services/payment_service.dart';
import '../../../../core/theme/grimoire_colors.dart';

class SubscriptionHero extends StatelessWidget {
  const SubscriptionHero({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 300;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [context.gc.background, context.gc.surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: compact
              ? const Column(
                  children: [
                    _CatHeroArt(height: 92),
                    _HeroCopy(centered: true, compact: true),
                  ],
                )
              : const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 4,
                      child: _CatHeroArt(height: 120),
                    ),
                    SizedBox(width: 6),
                    Expanded(flex: 7, child: _HeroCopy()),
                  ],
                ),
        );
      },
    );
  }
}

class _CatHeroArt extends StatelessWidget {
  final double height;

  const _CatHeroArt({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: -height * 0.12,
            right: -height * 0.12,
            top: -height * 0.08,
            bottom: -height * 0.06,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, 0.02),
                  radius: 0.62,
                  colors: [
                    context.gc.lilac.withValues(alpha: 0.91),
                    context.gc.lilac.withValues(alpha: 0.72),
                    context.gc.lilac.withValues(alpha: 0.45),
                    context.gc.lilac.withValues(alpha: 0.20),
                    context.gc.lilac.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.28, 0.55, 0.78, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: -height * 0.14,
            width: height * 0.68,
            top: height * 0.02,
            height: height * 0.48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.05, 0.08),
                  radius: 0.52,
                  colors: [
                    context.gc.lilac.withValues(alpha: 0.78),
                    context.gc.lilac.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -height * 0.14,
            width: height * 0.68,
            top: height * 0.18,
            height: height * 0.5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.06, 0),
                  radius: 0.52,
                  colors: [
                    context.gc.lilac.withValues(alpha: 0.74),
                    context.gc.lilac.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -height * 0.05,
            right: -height * 0.05,
            bottom: -height * 0.12,
            height: height * 0.56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.12),
                  radius: 0.58,
                  colors: [
                    context.gc.lilac.withValues(alpha: 0.84),
                    context.gc.lilac.withValues(alpha: 0.55),
                    context.gc.lilac.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.52, 1],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Image.asset(
              'assets/premium/cat_hero.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              filterQuality: FilterQuality.high,
              semanticLabel: AppLocalizations.of(context).premiumCatSemantic,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  final bool centered;
  final bool compact;

  const _HeroCopy({this.centered = false, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final alignment =
        centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.left;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: alignment,
      children: [
        Text(
          AppLocalizations.of(context).premiumHeroAccess,
          textAlign: textAlign,
          style: GoogleFonts.lora(
            color: context.gc.textPrimary,
            fontSize: compact ? 18 : 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Color.lerp(context.gc.lilac, context.gc.textPrimary, 0.55)!,
              context.gc.lilac,
            ],
          ).createShader(bounds),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              AppLocalizations.of(context).premiumHeroPower,
              textAlign: textAlign,
              style: GoogleFonts.cinzelDecorative(
                color: context.gc.textPrimary,
                fontSize: compact ? 20 : 23,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            AppLocalizations.of(context).premiumHeroMagic,
            textAlign: textAlign,
            style: GoogleFonts.cinzelDecorative(
              color: context.gc.textPrimary,
              fontSize: compact ? 19 : 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text.rich(
          textAlign: textAlign,
          TextSpan(
            style: GoogleFonts.lora(
              color: context.gc.textSecondary,
              fontSize: compact ? 11 : 12,
              height: 1.34,
            ),
            children: [
              TextSpan(text: AppLocalizations.of(context).premiumHeroTagline1),
              TextSpan(
                text: AppLocalizations.of(context).premiumHeroTaglineHighlight,
                style: TextStyle(color: context.gc.lilac),
              ),
              TextSpan(text: AppLocalizations.of(context).premiumHeroTagline2),
            ],
          ),
        ),
      ],
    );
  }
}

class PremiumOfferDivider extends StatelessWidget {
  const PremiumOfferDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: context.gc.surfaceBorder)),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 9),
          width: 8,
          height: 8,
          transform: Matrix4.rotationZ(0.78),
          decoration: BoxDecoration(
            color: context.gc.lilac,
            border: Border.all(
              color: Color.lerp(
                context.gc.lilac,
                context.gc.textPrimary,
                0.55,
              )!,
            ),
          ),
        ),
        Expanded(child: Divider(color: context.gc.surfaceBorder)),
      ],
    );
  }
}

class PremiumBenefitsSection extends StatelessWidget {
  const PremiumBenefitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final benefits = [
      ('assets/premium/icon_orb.png', l10n.premiumBenefitAdvisor),
      ('assets/premium/icon_book.png', l10n.premiumBenefitEncyclopedia),
      ('assets/premium/icon_moon.png', l10n.premiumBenefitDailyClimate),
      ('assets/premium/icon_runes.png', l10n.premiumBenefitUnlimitedReadings),
      ('assets/premium/icon_cloud.png', l10n.premiumBenefitCloudSync),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < benefits.length; index++) ...[
          _PremiumBenefitRow(
            assetPath: benefits[index].$1,
            label: benefits[index].$2,
          ),
          if (index != benefits.length - 1)
            Divider(height: 10, color: context.gc.surfaceBorder),
        ],
      ],
    );
  }
}

class _PremiumBenefitRow extends StatelessWidget {
  final String assetPath;
  final String label;

  const _PremiumBenefitRow({required this.assetPath, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: context.gc.lilac.withValues(alpha: 0.30),
              ),
              boxShadow: [
                BoxShadow(
                  color: context.gc.lilac.withValues(alpha: 0.20),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.lora(
                color: context.gc.textPrimary,
                fontSize: 14.5,
                height: 1.22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumOfferPanel extends StatelessWidget {
  final SubscriptionType selectedPlan;
  final ValueChanged<SubscriptionType> onSelected;
  final String monthlyPrice;
  final String yearlyPrice;
  final String? lifetimePrice;
  final bool monthlyEnabled;
  final bool yearlyEnabled;
  final bool lifetimeEnabled;
  final bool purchaseLoading;
  final bool purchaseEnabled;
  final VoidCallback onPurchase;
  final Widget? unavailableNotice;

  const PremiumOfferPanel({
    super.key,
    required this.selectedPlan,
    required this.onSelected,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.purchaseLoading,
    required this.purchaseEnabled,
    required this.onPurchase,
    this.lifetimePrice,
    this.monthlyEnabled = true,
    this.yearlyEnabled = true,
    this.lifetimeEnabled = false,
    this.unavailableNotice,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 380;

        return Container(
          key: const ValueKey('premium_offer_panel'),
          padding: EdgeInsets.fromLTRB(
            compact ? 10 : 14,
            compact ? 10 : 14,
            compact ? 10 : 14,
            14,
          ),
          decoration: BoxDecoration(
            color: context.gc.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.gc.surfaceBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              const SubscriptionHero(),
              const SizedBox(height: 10),
              const PremiumOfferDivider(),
              const SizedBox(height: 12),
              const PremiumBenefitsSection(),
              const SizedBox(height: 14),
              if (unavailableNotice != null) ...[
                unavailableNotice!,
                const SizedBox(height: 14),
              ],
              SubscriptionPlanSelector(
                selectedPlan: selectedPlan,
                onSelected: onSelected,
                monthlyPrice: monthlyPrice,
                yearlyPrice: yearlyPrice,
                lifetimePrice: lifetimePrice,
                monthlyEnabled: monthlyEnabled,
                yearlyEnabled: yearlyEnabled,
                lifetimeEnabled: lifetimeEnabled,
              ),
              const SizedBox(height: 12),
              SubscriptionPurchaseButton(
                loading: purchaseLoading,
                enabled: purchaseEnabled,
                onPressed: onPurchase,
              ),
              const SizedBox(height: 8),
              const SubscriptionGuarantees(),
            ],
          ),
        );
      },
    );
  }
}

class SubscriptionPlanSelector extends StatelessWidget {
  final SubscriptionType selectedPlan;
  final ValueChanged<SubscriptionType> onSelected;
  final String monthlyPrice;
  final String yearlyPrice;
  final String? lifetimePrice;
  final bool monthlyEnabled;
  final bool yearlyEnabled;
  final bool lifetimeEnabled;

  const SubscriptionPlanSelector({
    super.key,
    required this.selectedPlan,
    required this.onSelected,
    required this.monthlyPrice,
    required this.yearlyPrice,
    this.lifetimePrice,
    this.monthlyEnabled = true,
    this.yearlyEnabled = true,
    this.lifetimeEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final monthly = _SubscriptionPlanCard(
      type: SubscriptionType.monthly,
      title: AppLocalizations.of(context).premiumPlanMonthly,
      price: monthlyPrice,
      period: AppLocalizations.of(context).premiumPerMonth,
      selected: selectedPlan == SubscriptionType.monthly,
      enabled: monthlyEnabled,
      onTap: () => onSelected(SubscriptionType.monthly),
    );
    final yearly = _SubscriptionPlanCard(
      type: SubscriptionType.yearly,
      title: AppLocalizations.of(context).premiumPlanYearly,
      price: yearlyPrice,
      period: AppLocalizations.of(context).premiumPerYear,
      savings: AppLocalizations.of(context).premiumSave33,
      popular: true,
      emphasized: true,
      selected: selectedPlan == SubscriptionType.yearly,
      enabled: yearlyEnabled,
      onTap: () => onSelected(SubscriptionType.yearly),
    );

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 10, child: monthly),
            const SizedBox(width: 12),
            Expanded(flex: 11, child: yearly),
          ],
        ),
        // Vitalício: card LARGO abaixo do par mensal/anual, de propósito.
        // Três cards lado a lado espremeriam em tela estreita (o mesmo
        // aperto da tela de login); aqui a compra única respira e ainda
        // ganha destaque. Só aparece quando o produto existe na loja.
        if (lifetimeEnabled && lifetimePrice != null) ...[
          const SizedBox(height: 12),
          _LifetimeOfferCard(
            title: AppLocalizations.of(context).premiumPlanLifetime,
            subtitle: AppLocalizations.of(context).premiumLifetimeOnce,
            price: lifetimePrice!,
            selected: selectedPlan == SubscriptionType.lifetime,
            onTap: () => onSelected(SubscriptionType.lifetime),
          ),
        ],
      ],
    );
  }
}

/// Card de largura cheia da compra Vitalícia — mesma lógica de seleção dos
/// cards de plano, layout horizontal (nome + subtítulo à esquerda, preço à
/// direita) para caber confortável em qualquer largura.
class _LifetimeOfferCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  const _LifetimeOfferCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? context.gc.lilac : context.gc.surfaceBorder;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected
              ? context.gc.lilac.withValues(alpha: 0.14)
              : Colors.transparent,
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
              color: selected ? context.gc.lilac : context.gc.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: selected
                              ? context.gc.lilac
                              : context.gc.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              price,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.gc.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionType type;
  final String title;
  final String price;
  final String period;
  final String? savings;
  final bool popular;
  final bool emphasized;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _SubscriptionPlanCard({
    required this.type,
    required this.title,
    required this.price,
    required this.period,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.savings,
    this.popular = false,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = selected ? context.gc.lilac : context.gc.surfaceBorder;
    final l10n = AppLocalizations.of(context);
    final tag =
        selected ? l10n.premiumTagSelected : (popular ? l10n.premiumTagPopular : null);

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: l10n.premiumPlanSemantics(title, price, period),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: enabled ? 1 : 0.45,
        child: InkWell(
          key: ValueKey('subscription_plan_${type.name}'),
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: BoxConstraints(minHeight: emphasized ? 152 : 136),
            padding: EdgeInsets.fromLTRB(10, emphasized ? 12 : 10, 10, 10),
            decoration: BoxDecoration(
              color: selected
                  ? Color.lerp(context.gc.surface, context.gc.lilac, 0.16)!
                  : context.gc.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accent,
                width: selected ? 2.5 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: context.gc.lilac.withValues(alpha: 0.17),
                        blurRadius: 16,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                  child: tag == null
                      ? null
                      : DecoratedBox(
                          decoration: BoxDecoration(
                            color: context.gc.lilac,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: context.gc.textPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.lora(
                    color: context.gc.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        price,
                        maxLines: 1,
                        style: GoogleFonts.lora(
                          color: context.gc.textPrimary,
                          fontSize: emphasized ? 23 : 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        period,
                        style: GoogleFonts.lora(
                          color: context.gc.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (savings != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    savings!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.gc.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubscriptionPurchaseButton extends StatelessWidget {
  final bool loading;
  final bool enabled;
  final VoidCallback onPressed;

  const SubscriptionPurchaseButton({
    super.key,
    required this.loading,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: enabled ? 1 : 0.45,
      child: SizedBox(
      width: double.infinity,
      height: 50,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                Color.lerp(context.gc.lilac, context.gc.background, 0.22)!,
                context.gc.lilac,
                Color.lerp(context.gc.lilac, context.gc.background, 0.30)!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: context.gc.lilac.withValues(alpha: 0.27),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: enabled && !loading ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: context.gc.textPrimary,
              shape: const StadiumBorder(),
            ),
            child: loading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.gc.textPrimary,
                    ),
                  )
                : Text(
                    AppLocalizations.of(context).premiumStartNow,
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class SubscriptionGuarantees extends StatelessWidget {
  const SubscriptionGuarantees({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final guarantees = [
      ('assets/premium/icon_shield.png', l10n.premiumSecurePayment),
      ('assets/premium/icon_lock.png', l10n.premiumDataProtected),
    ];

    return Column(
      children: [
        Text(
          l10n.premiumCancelAnytime,
          style: GoogleFonts.lora(
            color: context.gc.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: [
            for (final guarantee in guarantees)
              _GuaranteeItem(assetPath: guarantee.$1, label: guarantee.$2),
          ],
        ),
      ],
    );
  }
}

class _GuaranteeItem extends StatelessWidget {
  final String assetPath;
  final String label;

  const _GuaranteeItem({required this.assetPath, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          assetPath,
          width: 14,
          height: 14,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            style: TextStyle(
              color: context.gc.textSecondary,
              fontSize: 10,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
