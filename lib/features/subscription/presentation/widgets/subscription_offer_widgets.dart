import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/payment_service.dart';
import '../../../../core/theme/app_theme.dart';

class PremiumBenefitItem {
  final IconData icon;
  final String emphasizedText;
  final String detailText;
  final String compactText;
  final String description;
  final String assetPath;

  const PremiumBenefitItem(
    this.icon,
    this.emphasizedText,
    this.detailText,
    this.compactText,
    this.description,
    this.assetPath,
  );

  String get text => '$emphasizedText$detailText';
}

const List<PremiumBenefitItem> premiumBenefitItems = [
  PremiumBenefitItem(
    Icons.psychology,
    'Converse à vontade com o Conselheiro Místico',
    ', sem limite de perguntas',
    'Conselheiro Místico ilimitado',
    'Converse à vontade com seu guia, sempre que precisar',
    'assets/premium/icon_orb.png',
  ),
  PremiumBenefitItem(
    Icons.menu_book,
    'Descubra os segredos da Enciclopédia Mágica',
    ', com conteúdos e práticas exclusivas',
    'Enciclopédia com conteúdos completos',
    'Descubra os segredos da magia com conteúdos e práticas exclusivas',
    'assets/premium/icon_book.png',
  ),
  PremiumBenefitItem(
    Icons.nightlight_round,
    'Receba um Clima Mágico Diário feito para você',
    ', com interpretações e sugestões do seu mapa',
    'Clima Mágico Diário personalizado',
    'Previsões e sugestões feitas para você, com base no seu mapa astral',
    'assets/premium/icon_moon.png',
  ),
  PremiumBenefitItem(
    Icons.auto_fix_high,
    'Faça leituras ilimitadas de Runas, Oráculo e Sigilos',
    ', sempre que precisar de orientação',
    'Leituras ilimitadas de Runas, Oráculo e Sigilos',
    'Busque respostas e aprofunde sua conexão espiritual sempre que quiser',
    'assets/premium/icon_runes.png',
  ),
  PremiumBenefitItem(
    Icons.cloud_done,
    'Mantenha seu Grimório protegido na nuvem',
    ' e sincronizado entre seus dispositivos',
    'Sincronização entre dispositivos',
    'Seu Grimório protegido na nuvem e sempre com você, onde estiver',
    'assets/premium/icon_cloud.png',
  ),
];

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
            gradient: const LinearGradient(
              colors: [Color(0xFF0E0E19), Color(0xFF151020)],
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
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, 0.02),
                  radius: 0.62,
                  colors: [
                    Color(0xE8C69ADB),
                    Color(0xD18D58AD),
                    Color(0xA25E2F80),
                    Color(0x53351B50),
                    Color(0x00351B50),
                  ],
                  stops: [0, 0.28, 0.55, 0.78, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: -height * 0.14,
            width: height * 0.68,
            top: height * 0.02,
            height: height * 0.48,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.05, 0.08),
                  radius: 0.52,
                  colors: [Color(0xC89566AD), Color(0x007A4899)],
                ),
              ),
            ),
          ),
          Positioned(
            right: -height * 0.14,
            width: height * 0.68,
            top: height * 0.18,
            height: height * 0.5,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.06, 0),
                  radius: 0.52,
                  colors: [Color(0xBE8755A5), Color(0x006E3F8E)],
                ),
              ),
            ),
          ),
          Positioned(
            left: -height * 0.05,
            right: -height * 0.05,
            bottom: -height * 0.12,
            height: height * 0.56,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.12),
                  radius: 0.58,
                  colors: [
                    Color(0xD79462B0),
                    Color(0x985D3478),
                    Color(0x005D3478),
                  ],
                  stops: [0, 0.52, 1],
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
              semanticLabel: 'Gato mágico do Grimório de Bolso',
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
          'ACESSE',
          textAlign: textAlign,
          style: GoogleFonts.lora(
            color: AppColors.textPrimary,
            fontSize: compact ? 18 : 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFD8B8FF), Color(0xFFA54CDC)],
          ).createShader(bounds),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'TODO O PODER',
              textAlign: textAlign,
              style: GoogleFonts.cinzelDecorative(
                color: Colors.white,
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
            'DA SUA MAGIA',
            textAlign: textAlign,
            style: GoogleFonts.cinzelDecorative(
              color: AppColors.textPrimary,
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
              color: AppColors.textSecondary,
              fontSize: compact ? 11 : 12,
              height: 1.34,
            ),
            children: const [
              TextSpan(text: 'Mais conhecimento, mais orientação e mais '),
              TextSpan(
                text: 'conexão',
                style: TextStyle(color: AppColors.lilac),
              ),
              TextSpan(text: ' com o seu caminho'),
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
        const Expanded(child: Divider(color: Color(0xFF33283F))),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 9),
          width: 8,
          height: 8,
          transform: Matrix4.rotationZ(0.78),
          decoration: BoxDecoration(
            color: AppColors.lilac,
            border: Border.all(color: const Color(0xFFE0C8F7)),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFF33283F))),
      ],
    );
  }
}

class PremiumBenefitsSection extends StatelessWidget {
  const PremiumBenefitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < premiumBenefitItems.length; index++) ...[
          _PremiumBenefitRow(item: premiumBenefitItems[index]),
          if (index != premiumBenefitItems.length - 1)
            const Divider(height: 10, color: Color(0xFF292735)),
        ],
      ],
    );
  }
}

class _PremiumBenefitRow extends StatelessWidget {
  final PremiumBenefitItem item;

  const _PremiumBenefitRow({required this.item});

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
                color: AppColors.lilac.withValues(alpha: 0.30),
              ),
              boxShadow: const [
                BoxShadow(color: Color(0x332B0A3F), blurRadius: 12),
              ],
            ),
            child: Image.asset(
              item.assetPath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.compactText,
              style: GoogleFonts.lora(
                color: AppColors.textPrimary,
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
  final bool monthlyEnabled;
  final bool yearlyEnabled;
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
    this.monthlyEnabled = true,
    this.yearlyEnabled = true,
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
            color: const Color(0xFF10111D),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF343342)),
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
                monthlyEnabled: monthlyEnabled,
                yearlyEnabled: yearlyEnabled,
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
  final bool monthlyEnabled;
  final bool yearlyEnabled;

  const SubscriptionPlanSelector({
    super.key,
    required this.selectedPlan,
    required this.onSelected,
    required this.monthlyPrice,
    required this.yearlyPrice,
    this.monthlyEnabled = true,
    this.yearlyEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final monthly = _SubscriptionPlanCard(
      type: SubscriptionType.monthly,
      title: 'Mensal',
      price: monthlyPrice,
      period: '/mês',
      selected: selectedPlan == SubscriptionType.monthly,
      enabled: monthlyEnabled,
      onTap: () => onSelected(SubscriptionType.monthly),
    );
    final yearly = _SubscriptionPlanCard(
      type: SubscriptionType.yearly,
      title: 'Anual',
      price: yearlyPrice,
      period: '/ano',
      savings: 'Economize 33%',
      popular: true,
      emphasized: true,
      selected: selectedPlan == SubscriptionType.yearly,
      enabled: yearlyEnabled,
      onTap: () => onSelected(SubscriptionType.yearly),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 10, child: monthly),
        const SizedBox(width: 12),
        Expanded(flex: 11, child: yearly),
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
    final accent = selected ? const Color(0xFFA934C4) : AppColors.surfaceBorder;
    final tag = selected ? 'SELECIONADO' : (popular ? 'POPULAR' : null);

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: 'Plano $title, $price $period',
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
              color: selected ? const Color(0xFF2A1938) : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accent,
                width: selected ? 2.5 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFA934C4).withValues(alpha: 0.17),
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
                            color: const Color(0xFF8E24AA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                color: Colors.white,
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
                    color: AppColors.textPrimary,
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
                          color: AppColors.textPrimary,
                          fontSize: emphasized ? 23 : 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        period,
                        style: GoogleFonts.lora(
                          color: AppColors.textSecondary,
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
                    style: const TextStyle(
                      color: AppColors.success,
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
            gradient: const LinearGradient(
              colors: [Color(0xFF8E1FB8), Color(0xFFB32CC9), Color(0xFF7C2AAA)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x449E2BC6),
                blurRadius: 16,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: enabled && !loading ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Começar Agora',
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
    const guarantees = [
      ('assets/premium/icon_shield.png', 'Pagamento seguro'),
      ('assets/premium/icon_lock.png', 'Seus dados protegidos'),
    ];

    return Column(
      children: [
        Text(
          'Cancele a qualquer momento',
          style: GoogleFonts.lora(
            color: AppColors.textSecondary,
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
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}
