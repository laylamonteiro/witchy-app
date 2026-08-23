import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_button.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../auth/presentation/widgets/breathing_badge.dart';
import '../../data/models/cycle_reading_model.dart';
import '../../data/services/cycle_reading_service.dart';

/// O paywall próprio da Leitura do Ciclo (decisão da dona, 23/08).
///
/// O preço saiu da tela de intro: esta folha explica primeiro O QUE a
/// leitura tece — seção por seção do produto escolhido — e só então mostra
/// o valor e o botão de pagar. Quem chega ao preço já sabe o que ele compra.
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tema = Theme.of(context);
    final format = DateFormat('dd/MM/yyyy');
    final secoes = CycleReadingSections.forPeriod(periodType);
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        padding: EdgeInsets.fromLTRB(20, 10, 20, 16 + bottomPadding),
        decoration: BoxDecoration(
          color: context.gc.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // A alça da folha.
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.gc.textSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // O emblema respirando — o mesmo idioma dos convites do app.
              Center(
                child: BreathingBadge(
                  glowColor: context.gc.lilac,
                  haloSize: 96,
                  child: Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.gc.lilac.withValues(alpha: 0.16),
                      border: Border.all(
                        color: context.gc.lilac.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Icon(
                      Icons.nightlight_round,
                      size: 30,
                      color: context.gc.lilac,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isWeek
                    ? l10n.cycleReadingWeekTitle
                    : l10n.cycleReadingLunationTitle,
                textAlign: TextAlign.center,
                style: tema.textTheme.titleLarge?.copyWith(
                  color: context.gc.lilac,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                // Fim estampado = último dia LIDO (o `end` cru é exclusivo),
                // igual ao cartão da intro e à linha do relatório.
                _isWeek
                    ? l10n.cycleReadingWeekPeriodLine(
                        format.format(periodStart),
                        format.format(CycleReadingService.lastDayOf(periodEnd)),
                      )
                    : l10n.cycleReadingPeriodLine(
                        format.format(periodStart),
                        format.format(CycleReadingService.lastDayOf(periodEnd)),
                      ),
                textAlign: TextAlign.center,
                style: tema.textTheme.bodySmall?.copyWith(
                  color: context.gc.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.cycleReadingPaywallTitle,
                style: tema.textTheme.titleMedium?.copyWith(
                  color: context.gc.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // As seções do produto, uma por linha, entrando em cascata:
              // 7 na lunação, 4 na semana — a diferença fica visível e é o
              // que justifica a diferença de preço.
              StaggeredEntrance(
                maxAnimated: secoes.length,
                children: [
                  for (final chave in secoes)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✦',
                            style: TextStyle(
                              fontSize: 14,
                              color: context.gc.lilac,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _tituloDaSecao(l10n, chave),
                              style: tema.textTheme.bodyMedium?.copyWith(
                                color: context.gc.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (_isWeek) ...[
                const SizedBox(height: 10),
                // Upsell honesto: diz o que SÓ a lunação traz, sem esconder
                // que a semana já entrega uma leitura inteira.
                Text(
                  l10n.cycleReadingPaywallWeekUpsell,
                  style: tema.textTheme.bodySmall?.copyWith(
                    color: context.gc.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
              if (recordCount < minRecords) ...[
                const SizedBox(height: 12),
                // O aviso de material raso continua vindo ANTES da cobrança
                // (regra inegociável da feature) — mesma forma do da intro.
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.gc.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    l10n.cycleReadingShallowWarning,
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: context.gc.warning,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                _isWeek
                    ? l10n.cycleReadingWeekRecordCount(recordCount)
                    : l10n.cycleReadingRecordCount(recordCount),
                textAlign: TextAlign.center,
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: context.gc.lilac,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              // A primeira aparição do preço em todo o fluxo — grande,
              // dourado e sozinho, depois de tudo o que ele compra.
              Text(
                price,
                textAlign: TextAlign.center,
                style: tema.textTheme.headlineSmall?.copyWith(
                  color: context.gc.starYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              // O CTA veste o gradiente dos primários (ver
              // MagicalButton.ctaDecoration): o gradiente fica no
              // DecoratedBox porque ElevatedButton não aceita gradiente, e o
              // texto usa onPrimary — o token garantido sobre o acento.
              DecoratedBox(
                decoration: MagicalButton.ctaDecoration(context),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Fecha ANTES de avisar: o fluxo de compra é assíncrono
                    // e não pode depender do context desta folha.
                    Navigator.pop(context);
                    onComprar();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: context.gc.onPrimary,
                  ),
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: Text(l10n.cycleReadingWantFull),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
