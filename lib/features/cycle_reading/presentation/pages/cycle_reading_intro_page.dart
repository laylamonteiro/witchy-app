import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/revenuecat_config.dart';
import '../../../../core/offers/offer_engine.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../diary/data/repositories/free_writing_repository.dart';
import '../../data/models/cycle_reading_model.dart';
import '../../data/services/cycle_reading_composer.dart';
import '../../data/services/cycle_reading_service.dart';
import 'cycle_reading_report_page.dart';

/// Tela de compra/geração da Leitura do Ciclo (semana ou lunação).
///
/// Regras de produto (inegociáveis):
/// - Diz o QUE é enviado para análise e deixa excluir fontes íntimas.
/// - Avisa ANTES da compra quando o período tem poucos registros.
/// - A compra só é consumida quando o relatório foi gerado e salvo — falha
///   de geração mantém o crédito e oferece tentar de novo sem nova cobrança.
/// - Assinante Pro tem 1 leitura inclusa por mês (de qualquer janela).
/// - Regeneração da MESMA janela limitada a 2×.
class CycleReadingIntroPage extends StatefulWidget {
  /// Janela pré-selecionada ao abrir (o convite do Seu Dia chega pela
  /// lunação; a porta de entrada barata é a semana).
  final String initialPeriodType;

  const CycleReadingIntroPage({
    super.key,
    this.initialPeriodType = CycleReadingPeriodType.lunation,
  });

  @override
  State<CycleReadingIntroPage> createState() => _CycleReadingIntroPageState();
}

class _CycleReadingIntroPageState extends State<CycleReadingIntroPage> {
  final CycleReadingService _service = CycleReadingService();
  final PaymentService _payment = PaymentService();

  late String _periodType = widget.initialPeriodType;
  ({DateTime start, DateTime end}) get _period =>
      CycleReadingService.periodFor(_periodType);

  String get _productId => _periodType == CycleReadingPeriodType.week
      ? RevenueCatConfig.cycleReadingWeekProductId
      : RevenueCatConfig.cycleReadingMonthProductId;

  bool _isLoading = true;
  bool _isWorking = false;
  int _recordCount = 0;
  CycleReadingModel? _existing;
  bool _proGrantUsed = false;

  /// Preço por janela (null = produto indisponível nesta plataforma/loja).
  final Map<String, String?> _prices = {};

  bool _includeDreams = true;
  bool _includeFreeWriting = true;
  bool _includeQuestions = true;

  @override
  void initState() {
    super.initState();
    _load();
    _loadPrices();
  }

  /// Preços das duas janelas — carregados juntos para o seletor já nascer
  /// com os dois valores à vista (a escolha é de preço, não só de janela).
  Future<void> _loadPrices() async {
    for (final id in [
      RevenueCatConfig.cycleReadingWeekProductId,
      RevenueCatConfig.cycleReadingMonthProductId,
    ]) {
      final price = await _payment.getConsumablePriceString(id);
      if (!mounted) return;
      setState(() => _prices[id] = price);
    }
  }

  /// Recarrega o que depende da janela escolhida.
  Future<void> _load() async {
    final userId = context.read<AuthProvider>().currentUser.id;
    final period = _period;
    final recordCount = await _service.composer.countPeriodRecords(
      userId: userId,
      start: period.start,
      end: period.end,
    );
    final existing = await _service.repository.findForPeriod(
      userId,
      period.start,
      periodType: _periodType,
    );
    final proGrantUsed =
        await _service.repository.proGrantUsedThisMonth(userId);
    if (!mounted) return;
    setState(() {
      _recordCount = recordCount;
      _existing = existing;
      _proGrantUsed = proGrantUsed;
      _isLoading = false;
    });
  }

  Future<void> _selectPeriod(String periodType) async {
    if (periodType == _periodType || _isWorking) return;
    setState(() {
      _periodType = periodType;
      _isLoading = true;
    });
    await _load();
  }

  CycleReadingSourceOptions get _options => CycleReadingSourceOptions(
        includeDreams: _includeDreams,
        includeFreeWriting: _includeFreeWriting,
        includeOracleQuestions: _includeQuestions,
      );

  Future<void> _buy() async {
    if (_isWorking) return;
    setState(() => _isWorking = true);
    final messenger = ScaffoldMessenger.of(context);
    final userId = context.read<AuthProvider>().currentUser.id;
    final period = _period;
    try {
      final result = await _payment.purchaseConsumable(_productId);
      if (!result.success) {
        if (result.errorMessage != null &&
            result.errorMessage != 'Compra cancelada' &&
            mounted) {
          messenger.showSnackBar(SnackBar(
            content: Text(result.errorMessage!),
            backgroundColor: context.gc.alert,
          ));
        }
        return;
      }

      // Compra confirmada: registra o crédito ANTES de gerar — se a geração
      // falhar, o crédito sobrevive e a pessoa tenta de novo sem pagar.
      final credit = CycleReadingModel(
        userId: userId,
        periodType: _periodType,
        periodStart: period.start,
        periodEnd: period.end,
        productId: _productId,
      );
      await _service.repository.insert(credit);
      final engine = await OfferEngine.load();
      await engine.recordConversion(OfferSlot.cycleReading);
      if (!mounted) return;
      setState(() => _existing = credit);
      await _generate(credit);
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _useProGrant() async {
    if (_isWorking) return;
    setState(() => _isWorking = true);
    final userId = context.read<AuthProvider>().currentUser.id;
    final period = _period;
    try {
      final credit = CycleReadingModel(
        userId: userId,
        periodType: _periodType,
        periodStart: period.start,
        periodEnd: period.end,
        origin: CycleReadingOrigin.pro,
      );
      await _service.repository.insert(credit);
      if (!mounted) return;
      setState(() {
        _existing = credit;
        _proGrantUsed = true;
      });
      await _generate(credit);
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _generate(CycleReadingModel credit,
      {bool regenerate = false}) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final userId = context.read<AuthProvider>().currentUser.id;
    setState(() => _isWorking = true);
    try {
      final result = await _service.generateForCredit(
        credit: credit,
        userId: userId,
        options: _options,
        regenerate: regenerate,
      );
      if (!mounted) return;
      setState(() => _existing = result.reading);
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CycleReadingReportPage(
            writing: result.writing,
            affirmation: result.affirmation,
            sealKeywords: result.sealKeywords,
            periodStart: credit.periodStart,
            periodEnd: credit.periodEnd,
            periodType: credit.periodType,
          ),
        ),
      );
    } catch (_) {
      // Inclui AiRateLimitException: o crédito segue pendente e a tela
      // continua oferecendo gerar de novo — sem nova cobrança.
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.cycleReadingGenerationFailed),
        backgroundColor: context.gc.alert,
      ));
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _openExistingReport() async {
    final writingId = _existing?.writingId;
    if (writingId == null) return;
    final writing = await FreeWritingRepository().getById(writingId);
    if (writing == null || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CycleReadingReportPage(
          writing: writing,
          periodStart: _existing?.periodStart,
          periodEnd: _existing?.periodEnd,
          periodType: _existing?.periodType ??
              CycleReadingPeriodType.lunation,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final format = DateFormat('dd/MM/yyyy');
    final period = _period;
    final isWeek = _periodType == CycleReadingPeriodType.week;

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(l10n.cycleReadingTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🌙✨', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(
                    l10n.cycleReadingIntroTagline,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildPeriodSelector(l10n),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          color: context.gc.lilac,
                        ),
                      ),
                    )
                  else ...[
                    Text(
                      isWeek
                          ? l10n.cycleReadingWeekPeriodLine(
                              format.format(period.start),
                              format.format(period.end),
                            )
                          : l10n.cycleReadingPeriodLine(
                              format.format(period.start),
                              format.format(period.end),
                            ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.gc.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isWeek
                          ? l10n.cycleReadingWeekRecordCount(_recordCount)
                          : l10n.cycleReadingRecordCount(_recordCount),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.gc.lilac,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (_recordCount <
                        CycleReadingComposer.minRecordsFor(_periodType)) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: context.gc.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          l10n.cycleReadingShallowWarning,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: context.gc.warning),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.cycleReadingIntroWhatTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.gc.lilac,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isWeek
                        ? l10n.cycleReadingWeekWhatBody
                        : l10n.cycleReadingIntroWhatBody,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.cycleReadingDisclaimer,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
            MagicalCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.cycleReadingPrivacyTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.gc.lilac,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.cycleReadingPrivacyBody,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.cycleReadingIncludeDreams),
                    value: _includeDreams,
                    onChanged: (v) => setState(() => _includeDreams = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.cycleReadingIncludeFreeWriting),
                    value: _includeFreeWriting,
                    onChanged: (v) => setState(() => _includeFreeWriting = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.cycleReadingIncludeQuestions),
                    value: _includeQuestions,
                    onChanged: (v) => setState(() => _includeQuestions = v),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildActions(l10n),
            ),
          ],
        ),
      ),
    );
  }

  /// Seletor das duas janelas, cada uma com o próprio preço à vista.
  Widget _buildPeriodSelector(AppLocalizations l10n) {
    Widget option(String type, String label, String productId) {
      final selected = _periodType == type;
      final price = _prices[productId];
      return Expanded(
        child: InkWell(
          onTap: _isWorking ? null : () => _selectPeriod(type),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: selected
                  ? context.gc.lilac.withValues(alpha: 0.18)
                  : Colors.transparent,
              border: Border.all(
                color: selected
                    ? context.gc.lilac
                    : context.gc.surfaceBorder,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: selected
                            ? context.gc.lilac
                            : context.gc.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  price ?? '—',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.gc.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        option(
          CycleReadingPeriodType.week,
          l10n.cycleReadingWeekTitle,
          RevenueCatConfig.cycleReadingWeekProductId,
        ),
        const SizedBox(width: 10),
        option(
          CycleReadingPeriodType.lunation,
          l10n.cycleReadingLunationTitle,
          RevenueCatConfig.cycleReadingMonthProductId,
        ),
      ],
    );
  }

  Widget _buildActions(AppLocalizations l10n) {
    if (_isWorking) {
      return Column(
        children: [
          CircularProgressIndicator(color: context.gc.lilac),
          const SizedBox(height: 12),
          Text(
            l10n.cycleReadingGenerating,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.gc.textSecondary),
          ),
        ],
      );
    }

    final existing = _existing;

    // Crédito pendente: a compra já aconteceu — gerar sem nova cobrança.
    if (existing != null && existing.isPending) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.cycleReadingPendingCredit,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.gc.textSecondary),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _generate(existing),
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: Text(l10n.cycleReadingGenerate),
          ),
        ],
      );
    }

    // Leitura desta janela já gerada: abrir (e regenerar, se ainda der).
    if (existing != null && existing.isGenerated) {
      final remaining =
          CycleReadingModel.maxRegenerations - existing.regenerationsUsed;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton.icon(
            onPressed: _openExistingReport,
            icon: const Icon(Icons.menu_book, size: 18),
            label: Text(l10n.cycleReadingOpenReport),
          ),
          const SizedBox(height: 8),
          if (existing.canRegenerate)
            OutlinedButton.icon(
              onPressed: () => _generate(existing, regenerate: true),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(l10n.cycleReadingRegenerate(remaining)),
            )
          else
            Text(
              l10n.cycleReadingRegenerateLimit,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.gc.textSecondary,
                  ),
            ),
        ],
      );
    }

    // Sem leitura nesta janela ainda: comprar — ou usar a inclusa do Pro.
    final isPro = context.watch<AuthProvider>().isPremiumEffective;
    final price = _prices[_productId];
    final storeAvailable = price != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isPro && !_proGrantUsed) ...[
          Text(
            l10n.cycleReadingProIncluded,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.gc.lilac,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _useProGrant,
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: Text(l10n.cycleReadingUseProReading),
          ),
          const SizedBox(height: 8),
        ],
        if (storeAvailable)
          (isPro && !_proGrantUsed)
              ? OutlinedButton.icon(
                  onPressed: _buy,
                  icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                  label: Text(l10n.cycleReadingBuyFor(price)),
                )
              : ElevatedButton.icon(
                  onPressed: _buy,
                  icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                  label: Text(l10n.cycleReadingBuyFor(price)),
                )
        else if (!isPro || _proGrantUsed)
          Text(
            l10n.cycleReadingUnavailable,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.gc.warning,
                ),
          ),
      ],
    );
  }
}
