import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../subscription/presentation/widgets/subscription_offer_widgets.dart';
import '../../data/models/cycle_reading_model.dart';
import '../../data/services/cycle_reading_service.dart';

/// O paywall próprio da Leitura do Ciclo (decisão da dona, 23/08).
///
/// O preço saiu da tela de intro: esta folha explica primeiro O QUE a
/// leitura tece — seção por seção do produto escolhido — e só então mostra
/// o valor e o botão de pagar. Quem chega ao preço já sabe o que ele compra.
///
/// A FORMA é a do paywall oficial ([PremiumUpgradeSheet]) por construção
/// ("o mesmo exato componente, alterando apenas os textos necessários"),
/// em MEIA ESCALA (as duas, decisão da dona, 23/08): produto avulso tem
/// metade do tamanho do paywall de assinatura. São os MESMOS componentes
/// nos modos compactos deles — [SubscriptionHero] com [HeroTexts] e
/// `meiaEscala`, [OfferBenefitRow] `compacto`, o preço na casca dos cards
/// de plano e o [SubscriptionPurchaseButton] `compacto`. E SEM o rodapé de
/// mensagens ("cancele quando quiser", selos): isso é conversa de
/// assinatura, e aqui se compra uma leitura, uma vez.
///
/// A folha só APRESENTA: nenhuma lógica de compra mora aqui. Ao tocar o CTA
/// ela se fecha e devolve a decisão pelo [onComprar] — o pop acontece ANTES
/// do callback, então nenhum context desta folha sobrevive a um await do
/// fluxo de pagamento.
Future<void> mostrarPaywallDaLeitura(
  BuildContext context, {
  required String periodType,
  required DateTime periodStart,
  required DateTime periodEnd,
  required String price,
  required VoidCallback onComprar,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PaywallDaLeitura(
      periodType: periodType,
      periodStart: periodStart,
      periodEnd: periodEnd,
      price: price,
      onComprar: onComprar,
    ),
  );
}

/// A folha em si — pública para os testes montarem direto.
class PaywallDaLeitura extends StatelessWidget {
  /// [CycleReadingPeriodType]: decide título, seções e o upsell da semana.
  final String periodType;

  /// Janela lida, com fim EXCLUSIVO (padrão da feature).
  final DateTime periodStart;
  final DateTime periodEnd;

  /// Preço já formatado pela loja — a folha é o ÚNICO lugar do fluxo em que
  /// ele aparece.
  final String price;

  /// Chamado depois que a folha se fecha, quando a pessoa toca em pagar.
  final VoidCallback onComprar;

  const PaywallDaLeitura({
    super.key,
    required this.periodType,
    required this.periodStart,
    required this.periodEnd,
    required this.price,
    required this.onComprar,
  });

  bool get _isWeek => periodType == CycleReadingPeriodType.week;

  /// Só os DESTAQUES viram bullet (decisão da dona, 23/08: no máximo 3-4).
  /// A lista completa mora na tela anterior, no "O que vem na leitura"; a
  /// folha fecha a venda com o essencial — e a linha "+ N seções" diz que
  /// há mais sem listar.
  List<String> get _destaques => _isWeek
      ? const [
          CycleReadingSections.portrait,
          CycleReadingSections.sky,
          CycleReadingSections.forecast,
        ]
      : const [
          CycleReadingSections.portrait,
          CycleReadingSections.sky,
          CycleReadingSections.forecast,
          CycleReadingSections.rituals,
        ];

  /// O título de cada seção, no idioma da tela — mesmo mapeamento da intro
  /// (as chaves são invariantes; os títulos, não).
  String _tituloDaSecao(AppLocalizations l10n, String chave) =>
      switch (chave) {
        CycleReadingSections.portrait => l10n.cycleReadingSectionPortrait,
        CycleReadingSections.threads => l10n.cycleReadingSectionThreads,
        CycleReadingSections.sky => l10n.cycleReadingSectionSky,
        CycleReadingSections.practice => l10n.cycleReadingSectionPractice,
        CycleReadingSections.forecast => l10n.cycleReadingSectionForecast,
        CycleReadingSections.rituals => l10n.cycleReadingSectionRituals,
        CycleReadingSections.affirmation => l10n.cycleReadingSectionAffirmation,
        _ => l10n.cycleReadingSectionSeal,
      };

  /// O que cada seção entrega, em uma linha — a MESMA anatomia das peças do
  /// paywall Premium, onde todo benefício tem título e vislumbre. Sem esta
  /// linha as seções liam como índice de livro, não como o que se compra.
  String _vislumbreDaSecao(AppLocalizations l10n, String chave) =>
      switch (chave) {
        CycleReadingSections.portrait => l10n.cycleSectionHintPortrait,
        CycleReadingSections.threads => l10n.cycleSectionHintThreads,
        CycleReadingSections.sky => l10n.cycleSectionHintSky,
        CycleReadingSections.practice => l10n.cycleSectionHintPractice,
        CycleReadingSections.forecast => l10n.cycleSectionHintForecast,
        CycleReadingSections.rituals => l10n.cycleSectionHintRituals,
        CycleReadingSections.affirmation => l10n.cycleSectionHintAffirmation,
        _ => l10n.cycleSectionHintSeal,
      };

  /// Divide o título da seção em (emoji, rótulo): o emoji vai para DENTRO
  /// do selo circular — o papel das artes pintadas dos benefícios Premium —
  /// e o rótulo fica limpo ao lado, sem o emoji duplicado.
  @visibleForTesting
  static ({String emoji, String rotulo}) separarEmoji(String titulo) {
    final corte = titulo.indexOf(' ');
    if (corte <= 0) return (emoji: '✦', rotulo: titulo);
    return (
      emoji: titulo.substring(0, corte),
      rotulo: titulo.substring(corte + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    // Moldura idêntica à do PremiumUpgradeSheet: alça + fechar, altura
    // máxima, teto de largura e rolagem interna.
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.96,
        ),
        padding: EdgeInsets.fromLTRB(10, 10, 10, 10 + bottomPadding),
        decoration: BoxDecoration(
          color: context.gc.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Spacer(),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.gc.textSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: l10n.commonClose,
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: context.gc.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
            Flexible(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = math.min(constraints.maxWidth - 8, 720.0);
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: _painel(context, l10n),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// O painel da oferta — a mesma casca do [PremiumOfferPanel].
  Widget _painel(BuildContext context, AppLocalizations l10n) {
    final secoes = _destaques;
    final restantes =
        CycleReadingSections.forPeriod(periodType).length - secoes.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
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
          // O MESMO herói do paywall Premium — Salem, halo, tipografia —
          // com os textos da Leitura nos mesmos quatro lugares.
          SubscriptionHero(
            meiaEscala: true,
            textos: HeroTexts(
              access: _isWeek
                  ? l10n.cycleReadingWeekTitle
                  : l10n.cycleReadingLunationTitle,
              power: l10n.cycleHeroPower,
              magic: l10n.cycleHeroMagic,
              tagline: _linhaDoPeriodo(l10n),
            ),
          ),
          const SizedBox(height: 6),
          const PremiumOfferDivider(),
          const SizedBox(height: 8),
          // As seções do produto nas MESMAS peças dos benefícios do paywall
          // Premium — em meia escala: 8 na lunação, 5 na semana, e a
          // diferença visível é o que justifica a diferença de preço.
          StaggeredEntrance(
            children: [
              for (var i = 0; i < secoes.length; i++) ...[
                OfferBenefitRow(
                  compacto: true,
                  benefit: OfferBenefit.emoji(
                    separarEmoji(_tituloDaSecao(l10n, secoes[i])).emoji,
                    separarEmoji(_tituloDaSecao(l10n, secoes[i])).rotulo,
                    vislumbre: _vislumbreDaSecao(l10n, secoes[i]),
                  ),
                ),
                if (i != secoes.length - 1) const SizedBox(height: 6),
              ],
            ],
          ),
          const SizedBox(height: 6),
          // As seções que não viraram bullet continuam contadas: a folha
          // vende o produto inteiro, só não o lista inteiro.
          Text(
            l10n.cyclePaywallMoreSections(restantes),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.gc.textSecondary,
              fontSize: 11.5,
            ),
          ),
          if (_isWeek) ...[
            const SizedBox(height: 8),
            // Upsell honesto: diz o que SÓ a lunação traz, sem esconder que
            // a semana já entrega uma leitura inteira.
            Text(
              l10n.cycleReadingPaywallWeekUpsell,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.gc.textSecondary,
                fontSize: 11.5,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 10),
          // O preço no MESMO cartão dos planos do paywall Premium: caixa com
          // borda, valor em Lora e o rótulo do que ele é. O aviso de leitura
          // rasa NÃO mora aqui (decisão da dona, 23/08) — ele já está na
          // tela de onde esta folha nasceu, e repetir vira alarme.
          _cartaoDoPreco(context, l10n),
          const SizedBox(height: 8),
          // O MESMO botão do paywall Premium, com o verbo do produto. Fecha
          // ANTES de avisar: o fluxo de compra é assíncrono e não pode
          // depender do context desta folha.
          // O CTA fecha a folha: sem rodapé de mensagens depois dele
          // (decisão da dona, 23/08) — "cancele quando quiser" e selos são
          // conversa de assinatura, e aqui se compra uma leitura, uma vez.
          SubscriptionPurchaseButton(
            loading: false,
            enabled: true,
            compacto: true,
            label: l10n.cycleReadingWantFull,
            onPressed: () {
              Navigator.pop(context);
              onComprar();
            },
          ),
        ],
      ),
    );
  }

  /// O preço no formato dos cards de plano do paywall Premium.
  Widget _cartaoDoPreco(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Color.lerp(context.gc.surface, context.gc.lilac, 0.16)!,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.gc.lilac, width: 2),
        boxShadow: [
          BoxShadow(
            color: context.gc.lilac.withValues(alpha: 0.17),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            price,
            style: GoogleFonts.lora(
              color: context.gc.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            l10n.cycleReadingOneTime,
            style: GoogleFonts.lora(
              color: context.gc.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// A linha do período para a tagline do herói. Fim estampado = último dia
  /// LIDO (o `end` cru é exclusivo), igual ao cartão da intro e à linha do
  /// relatório.
  String _linhaDoPeriodo(AppLocalizations l10n) {
    final format = DateFormat('dd/MM/yyyy');
    final fim = format.format(CycleReadingService.lastDayOf(periodEnd));
    return _isWeek
        ? l10n.cycleReadingWeekPeriodLine(format.format(periodStart), fim)
        : l10n.cycleReadingPeriodLine(format.format(periodStart), fim);
  }
}
