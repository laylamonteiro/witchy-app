import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/services/payment_service.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/staggered_entrance.dart';

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

/// O que está incluso — e a lista MUDA com o plano escolhido.
///
/// O Vitalício não é o Premium mais caro: ele carrega coisas que a assinatura
/// não dá (a Leitura do Ciclo, que é compra avulsa para todo mundo, e o fim
/// da renovação). Se a lista ficasse igual nos três planos, o preço maior
/// pareceria só um preço maior. Selecionar Vitalício acrescenta as duas
/// linhas extras, em destaque.
class PremiumBenefitsSection extends StatelessWidget {
  const PremiumBenefitsSection({super.key, this.selectedPlan});

  /// Plano em foco; nulo mostra apenas o que vale para qualquer Premium.
  final SubscriptionType? selectedPlan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final benefits = <OfferBenefit>[
      // O vislumbre de cada peça é o MESMO texto da página de descoberta,
      // de propósito: as duas telas precisam parecer a mesma ideia vista de
      // dois ângulos, e não dois times escrevendo sobre o mesmo produto.
      OfferBenefit.asset(
        'assets/premium/icon_orb.png',
        l10n.premiumBenefitAdvisor,
        vislumbre: l10n.conviteVislumbreConselheiroLinha,
      ),
      OfferBenefit.asset(
        'assets/premium/icon_book.png',
        l10n.premiumBenefitEncyclopedia,
        vislumbre: l10n.conviteVislumbreEnciclopediaLinha,
      ),
      OfferBenefit.asset(
        'assets/premium/icon_moon.png',
        l10n.premiumBenefitDailyClimate,
        vislumbre: l10n.conviteVislumbreClimaLinha,
      ),
      OfferBenefit.asset(
        'assets/premium/icon_runes.png',
        l10n.premiumBenefitUnlimitedReadings,
        vislumbre: l10n.conviteVislumbreLeiturasLinha,
      ),
      // A sincronização SAIU da lista, sem substituto: ela deixou de ser
      // exclusiva do Premium. São quatro benefícios agora — Conselheiro,
      // Enciclopédia, Clima do Dia e leituras sem limite —, mais os dois
      // extras do Vitalício. Nada de inventar uma linha nova para preencher
      // o buraco: o substituto é o redesenho do convite.
      if (selectedPlan == SubscriptionType.lifetime) ...[
        OfferBenefit.icon(Icons.auto_awesome, l10n.premiumBenefitLifetimeCycle),
        OfferBenefit.icon(Icons.all_inclusive, l10n.premiumBenefitLifetimeNoRenew),
      ],
    ];
    // A cascata que o app já usa nas outras telas dá o senso de "grandioso"
    // sem efeito novo — e sem pressa inventada. A divisória entre linhas
    // saiu: peça precisa de ar, e régua entre elas as devolvia à condição
    // de lista.
    return StaggeredEntrance(
      children: [
        for (var index = 0; index < benefits.length; index++) ...[
          OfferBenefitRow(benefit: benefits[index]),
          if (index != benefits.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

/// Uma PEÇA da oferta: a arte, o nome e — quando há — o vislumbre do que ela
/// entrega. As exclusivas do Vitalício não têm arte própria nem vislumbre:
/// são fato do plano, ganham ícone do sistema e realce lilás.
class OfferBenefit {
  const OfferBenefit._({
    required this.label,
    this.vislumbre,
    this.assetPath,
    this.iconData,
    this.highlighted = false,
  });

  factory OfferBenefit.asset(String assetPath, String label, {String? vislumbre}) =>
      OfferBenefit._(assetPath: assetPath, label: label, vislumbre: vislumbre);

  factory OfferBenefit.icon(
    IconData iconData,
    String label, {
    bool highlighted = true,
    String? vislumbre,
  }) =>
      OfferBenefit._(
        iconData: iconData,
        label: label,
        highlighted: highlighted,
        vislumbre: vislumbre,
      );

  final String label;

  /// A linha do que a feature entrega. Nula nas peças que são fato, não
  /// desejo.
  final String? vislumbre;

  final String? assetPath;
  final IconData? iconData;
  final bool highlighted;
}

class OfferBenefitRow extends StatelessWidget {
  final OfferBenefit benefit;

  const OfferBenefitRow({super.key, required this.benefit});

  @override
  Widget build(BuildContext context) {
    final destaque = benefit.highlighted;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: destaque
                  ? context.gc.lilac.withValues(alpha: 0.16)
                  : null,
              border: Border.all(
                color: context.gc.lilac.withValues(
                  alpha: destaque ? 0.55 : 0.30,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: context.gc.lilac.withValues(alpha: 0.20),
                  blurRadius: 12,
                ),
              ],
            ),
            child: benefit.assetPath != null
                ? Image.asset(
                    benefit.assetPath!,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  )
                : Icon(benefit.iconData, size: 22, color: context.gc.lilac),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  benefit.label,
                  style: GoogleFonts.lora(
                    color: destaque ? context.gc.lilac : context.gc.textPrimary,
                    fontSize: 14.5,
                    height: 1.22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // Sem vislumbre a peça vira a linha de antes — é o caso das
                // duas exclusivas do Vitalício, que são FATO do plano e não
                // desejo: explicar "sem renovação" com uma segunda frase
                // seria vender o que já está dito.
                if (benefit.vislumbre != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    benefit.vislumbre!,
                    style: TextStyle(
                      color: context.gc.textSecondary,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
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

  /// Quanto o anual economiza, em porcento — null esconde o selo.
  ///
  /// Vem calculado dos preços que a LOJA devolveu. Era texto fixo no ARB
  /// ("Economize 50%"): uma conta com dois números que a tela não tinha na
  /// mão, e que mentia se a loja mudasse o preço ou a pessoa estivesse fora
  /// do Brasil.
  final int? economiaAnual;

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
    this.economiaAnual,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 380;
        final l10n = AppLocalizations.of(context);

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
              PremiumBenefitsSection(selectedPlan: selectedPlan),
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
                economiaAnual: economiaAnual,
              ),
              // A Leitura da Lunação como nota do PAINEL, não do card (a dona
              // vetou o texto dentro do card, que é pequeno demais para uma
              // frase). Só com o Vitalício em foco: a Leitura do Ciclo é
              // produto avulso, fora do Premium, e a única verdade vendável
              // aqui é que o lifetime a inclui (regra em
              // `CycleReadingOrigin.lifetime`) — nos outros planos a mesma
              // linha faria a tela mentir.
              if (selectedPlan == SubscriptionType.lifetime) ...[
                const SizedBox(height: 10),
                Text(
                  l10n.paywallLifetimeCycleReading,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.gc.gold,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SubscriptionPurchaseButton(
                loading: purchaseLoading,
                enabled: purchaseEnabled,
                onPressed: onPurchase,
              ),
              const SizedBox(height: 8),
              SubscriptionGuarantees(selectedPlan: selectedPlan),
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

  /// Quanto o anual economiza, em porcento — null esconde o selo.
  final int? economiaAnual;

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
    this.economiaAnual,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Os três lado a lado: esconder o Vitalício embaixo o fazia parecer
    // consolo, não escolha. Quando ele existe na loja, os cards dividem a
    // largura igualmente e encolhem (compacto) para caber em tela estreita.
    final tresPlanos = lifetimeEnabled && lifetimePrice != null;

    final monthly = _SubscriptionPlanCard(
      type: SubscriptionType.monthly,
      title: l10n.premiumPlanMonthly,
      price: monthlyPrice,
      period: l10n.premiumPerMonth,
      selected: selectedPlan == SubscriptionType.monthly,
      enabled: monthlyEnabled,
      compacto: tresPlanos,
      onTap: () => onSelected(SubscriptionType.monthly),
    );
    final yearly = _SubscriptionPlanCard(
      type: SubscriptionType.yearly,
      title: l10n.premiumPlanYearly,
      price: yearlyPrice,
      period: l10n.premiumPerYear,
      // Sem número, sem selo: esconder é melhor do que mostrar uma conta
      // que pode estar errada numa tela de venda.
      savings: economiaAnual == null
          ? null
          : l10n.premiumSaveYearlyPercent(economiaAnual!),
      popular: true,
      emphasized: true,
      selected: selectedPlan == SubscriptionType.yearly,
      enabled: yearlyEnabled,
      compacto: tresPlanos,
      onTap: () => onSelected(SubscriptionType.yearly),
    );

    if (!tresPlanos) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 10, child: monthly),
          const SizedBox(width: 12),
          Expanded(flex: 11, child: yearly),
        ],
      );
    }

    final lifetime = _SubscriptionPlanCard(
      type: SubscriptionType.lifetime,
      title: l10n.premiumPlanLifetime,
      price: lifetimePrice!,
      period: l10n.premiumLifetimeShort,
      selected: selectedPlan == SubscriptionType.lifetime,
      enabled: lifetimeEnabled,
      compacto: true,
      onTap: () => onSelected(SubscriptionType.lifetime),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: monthly),
        const SizedBox(width: 8),
        Expanded(child: yearly),
        const SizedBox(width: 8),
        Expanded(child: lifetime),
      ],
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

  /// Três cards dividindo a largura: tipografia e alturas encolhem, e o
  /// período desce para baixo do preço em vez de disputar a mesma linha.
  final bool compacto;
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
    this.compacto = false,
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
            constraints: BoxConstraints(
              minHeight: compacto
                  ? (emphasized ? 132 : 120)
                  : (emphasized ? 152 : 136),
            ),
            padding: EdgeInsets.fromLTRB(
              compacto ? 6 : 10,
              emphasized ? 12 : 10,
              compacto ? 6 : 10,
              10,
            ),
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
                      : FittedBox(
                          fit: BoxFit.scaleDown,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: context.gc.lilac,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: compacto ? 7 : 10,
                                vertical: 3,
                              ),
                              child: Text(
                                tag,
                                maxLines: 1,
                                style: TextStyle(
                                  color: context.gc.textPrimary,
                                  fontSize: compacto ? 9 : 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lora(
                    color: context.gc.textPrimary,
                    fontSize: compacto ? 13 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                if (compacto) ...[
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      price,
                      maxLines: 1,
                      style: GoogleFonts.lora(
                        color: context.gc.textPrimary,
                        fontSize: emphasized ? 18 : 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      period,
                      maxLines: 1,
                      style: GoogleFonts.lora(
                        color: context.gc.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ] else
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
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      savings!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.gc.success,
                        fontSize: compacto ? 10 : 12,
                        fontWeight: FontWeight.w700,
                      ),
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

  /// Texto do botão. Nulo usa o padrão do paywall Premium ("Começar Agora").
  /// Existe para o paywall da Leitura do Ciclo usar ESTE botão — o mesmo
  /// gradiente, a mesma forma — com o verbo do produto dele.
  final String? label;

  const SubscriptionPurchaseButton({
    super.key,
    required this.loading,
    required this.enabled,
    required this.onPressed,
    this.label,
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
              // O fundo de verdade é o gradiente lilás do DecoratedBox de
              // fora: o texto usa onPrimary, o token que os testes de
              // contraste garantem sobre o acento — textPrimary sumia nos
              // temas de lilás claro.
              foregroundColor: context.gc.onPrimary,
              shape: const StadiumBorder(),
            ),
            child: loading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.gc.onPrimary,
                    ),
                  )
                : Text(
                    label ?? AppLocalizations.of(context).premiumStartNow,
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
  const SubscriptionGuarantees({super.key, required this.selectedPlan});

  /// O rodapé precisa acompanhar o plano escolhido.
  ///
  /// A lista de benefícios já respondia ao plano; este rodapé não: era `const`
  /// e dizia sempre "cancele a qualquer momento". Com o Vitalício em foco, a
  /// mesma dobra da tela prometia "sem renovação, para sempre" e, duas linhas
  /// abaixo, oferecia cancelar uma assinatura que não existe.
  final SubscriptionType selectedPlan;

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
          selectedPlan == SubscriptionType.lifetime
              ? l10n.premiumLifetimeOnce
              : l10n.premiumCancelAnytime,
          style: GoogleFonts.lora(
            color: context.gc.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        const GuaranteeBadges(),
      ],
    );
  }
}

/// Os dois selos de confiança do paywall (pagamento seguro, dados
/// protegidos) — públicos para o paywall da Leitura do Ciclo mostrar
/// exatamente os mesmos.
class GuaranteeBadges extends StatelessWidget {
  const GuaranteeBadges({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final guarantees = [
      ('assets/premium/icon_shield.png', l10n.premiumSecurePayment),
      ('assets/premium/icon_lock.png', l10n.premiumDataProtected),
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        for (final guarantee in guarantees)
          _GuaranteeItem(assetPath: guarantee.$1, label: guarantee.$2),
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
