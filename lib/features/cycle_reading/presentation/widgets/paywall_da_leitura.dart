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
/// A FORMA é a do paywall oficial ([PremiumUpgradeSheet]), de propósito e
/// por construção: mesma moldura (alça + fechar, painel de superfície com a
/// mesma casca), o mesmo divisor, as MESMAS peças de benefício
/// ([OfferBenefitRow]), o MESMO botão de compra
/// ([SubscriptionPurchaseButton], só com o verbo do produto) e os mesmos
/// selos de confiança ([GuaranteeBadges]). Dois paywalls com caras
/// diferentes leriam como dois apps.
///
/// Em MEIA ESCALA, também de propósito (decisão da dona, 23/08): aqui se
/// compra uma PEÇA de um todo maior, e a peça não pode parecer maior que o
/// todo — herói baixo, selos de 30, menos ar. A língua é a mesma; o volume,
/// metade.
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
  required int recordCount,
  required int minRecords,
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
      recordCount: recordCount,
      minRecords: minRecords,
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

  /// Quantos registros a janela tem e o mínimo para uma leitura funda —
  /// o aviso de material raso continua valendo ANTES da cobrança.
  final int recordCount;
  final int minRecords;

  /// Chamado depois que a folha se fecha, quando a pessoa toca em pagar.
  final VoidCallback onComprar;

  const PaywallDaLeitura({
    super.key,
    required this.periodType,
    required this.periodStart,
    required this.periodEnd,
    required this.price,
    required this.recordCount,
    required this.minRecords,
    required this.onComprar,
  });

  bool get _isWeek => periodType == CycleReadingPeriodType.week;

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
    final secoes = CycleReadingSections.forPeriod(periodType);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
          _heroi(context, l10n),
          const SizedBox(height: 8),
          const PremiumOfferDivider(),
          const SizedBox(height: 8),
          // As seções do produto nas MESMAS peças dos benefícios do paywall
          // Premium — em meia escala: 8 na lunação, 5 na semana, e a
          // diferença visível é o que justifica a diferença de preço.
          StaggeredEntrance(
            children: [
              for (final chave in secoes)
                OfferBenefitRow(
                  compacto: true,
                  benefit: OfferBenefit.emoji(
                    separarEmoji(_tituloDaSecao(l10n, chave)).emoji,
                    separarEmoji(_tituloDaSecao(l10n, chave)).rotulo,
                  ),
                ),
            ],
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
          if (recordCount < minRecords) ...[
            const SizedBox(height: 8),
            // O aviso de material raso continua vindo ANTES da cobrança
            // (regra inegociável da feature).
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.gc.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                l10n.cycleReadingShallowWarning,
                style: TextStyle(color: context.gc.warning, fontSize: 11.5),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            _isWeek
                ? l10n.cycleReadingWeekRecordCount(recordCount)
                : l10n.cycleReadingRecordCount(recordCount),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.gc.textSecondary,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 6),
          // O preço na MESMA tipografia dos cards de plano do paywall
          // Premium — e é a primeira aparição dele no fluxo inteiro.
          Text(
            price,
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(
              color: context.gc.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          // O MESMO botão do paywall Premium, com o verbo do produto. Fecha
          // ANTES de avisar: o fluxo de compra é assíncrono e não pode
          // depender do context desta folha.
          SubscriptionPurchaseButton(
            loading: false,
            enabled: true,
            label: l10n.cycleReadingWantFull,
            onPressed: () {
              Navigator.pop(context);
              onComprar();
            },
          ),
          const SizedBox(height: 8),
          const GuaranteeBadges(),
        ],
      ),
    );
  }

  /// O herói da folha — mesma moldura e tipografia do [SubscriptionHero]:
  /// caixa em gradiente com a arte à esquerda (aqui, o emblema da lua que a
  /// feature já usa) e o texto à direita, com o título no dourado-lilás em
  /// Cinzel que assina os heróis do app.
  Widget _heroi(BuildContext context, AppLocalizations l10n) {
    final format = DateFormat('dd/MM/yyyy');
    // Fim estampado = último dia LIDO (o `end` cru é exclusivo), igual ao
    // cartão da intro e à linha do relatório.
    final periodo = _isWeek
        ? l10n.cycleReadingWeekPeriodLine(
            format.format(periodStart),
            format.format(CycleReadingService.lastDayOf(periodEnd)),
          )
        : l10n.cycleReadingPeriodLine(
            format.format(periodStart),
            format.format(CycleReadingService.lastDayOf(periodEnd)),
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [context.gc.background, context.gc.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // A MESMA arte do paywall Premium — o Salem no halo lilás — em
          // altura menor: é a assinatura que faz as duas folhas lerem como
          // o mesmo app.
          const SizedBox(width: 72, child: CatHeroArt(height: 72)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Color.lerp(
                        context.gc.lilac,
                        context.gc.textPrimary,
                        0.55,
                      )!,
                      context.gc.lilac,
                    ],
                  ).createShader(bounds),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _isWeek
                          ? l10n.cycleReadingWeekTitle
                          : l10n.cycleReadingLunationTitle,
                      style: GoogleFonts.cinzelDecorative(
                        color: context.gc.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  periodo,
                  style: GoogleFonts.lora(
                    color: context.gc.textSecondary,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.cycleReadingPaywallTitle,
                  style: GoogleFonts.lora(
                    color: context.gc.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
