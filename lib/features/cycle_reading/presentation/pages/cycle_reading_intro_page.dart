import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/ai/ai_service.dart';
import '../../../../core/config/revenuecat_config.dart';
import '../../../../core/offers/offer_engine.dart';
import '../../../../core/offers/teaser_cache.dart';
import '../../../../core/offers/teaser_reveal.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../../../core/services/payment_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../auth/data/models/user_model.dart';
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
/// - Fora do Premium: assinar não dá leitura. A única exceção é o Vitalício,
///   que inclui a Leitura da Lunação (a da Semana segue avulsa).
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

  /// Janela escolhida a dedo (null = a janela corrente do tipo).
  ///
  /// Existe para ler um pedaço RETROATIVO: a lunação passada, aquela semana
  /// específica. Quando está preenchida, ela manda — e o [_periodType]
  /// passa a sair do TAMANHO dela (até 7 dias = semana; 8 a 31 = lunação),
  /// porque é o tamanho que define o produto, não o rótulo escolhido antes.
  ({DateTime start, DateTime end})? _customPeriod;

  ({DateTime start, DateTime end}) get _period =>
      _customPeriod ?? CycleReadingService.periodFor(_periodType);

  /// Por que a janela escolhida foi recusada (null = nenhuma recusa à
  /// vista). Fica na tela até a pessoa escolher outra.
  String? _customRejection;

  /// Esta janela sai de graça pelo Vitalício? Exige compra REAL do lifetime
  /// (entitlement sem expiração) — `SubscriptionPlan.lifetime` não serve,
  /// porque também vem de Código Premium e do admin.
  /// Este Vitalício é qualquer um: compra real, Código Premium ou admin —
  /// todos recebem `SubscriptionPlan.lifetime`. Decisão de produto: o
  /// Vitalício cobre as leituras sem cobrança, venha de onde vier.
  bool get _hasLifetime =>
      context.read<AuthProvider>().currentUser.plan ==
      SubscriptionPlan.lifetime;

  bool get _lifetimeCoversThisWindow =>
      _hasLifetime && CycleReadingService.lifetimeCovers(_periodType);

  String get _productId => _periodType == CycleReadingPeriodType.week
      ? RevenueCatConfig.cycleReadingWeekProductId
      : RevenueCatConfig.cycleReadingMonthProductId;

  bool _isLoading = true;
  bool _isWorking = false;
  int _recordCount = 0;
  CycleReadingModel? _existing;

  /// Quando a próxima leitura desta janela libera (null = já liberada).
  /// Uma semanal a cada 7 dias, uma lunação a cada 30: sem isso, a janela
  /// rolante da semana deixaria comprar "a semana" todo dia, relendo quase
  /// o mesmo período.
  DateTime? _nextAllowedAt;

  bool get _isOnCooldown => _nextAllowedAt != null;

  /// Dias que faltam para liberar (arredondando para cima: faltando 6h,
  /// ainda é "1 dia", nunca "0").
  int get _daysUntilRelease {
    final release = _nextAllowedAt;
    if (release == null) return 0;
    final remaining = release.difference(DateTime.now());
    if (remaining.isNegative) return 0;
    return remaining.inHours ~/ 24 + (remaining.inHours % 24 > 0 ? 1 : 0);
  }

  /// A amostra desta janela (null = ainda não pedida).
  String? _teaser;
  bool _isTeasing = false;

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
    _restoreCachedTeaser();
  }

  /// Preços das duas janelas — carregados juntos para o seletor já nascer
  /// com os dois valores à vista (a escolha é de preço, não só de janela).
  Future<void> _loadPrices() async {
    // A loja precisa estar configurada para haver preço. Contas que entram
    // sem passar pelo login de servidor (admin local, simulação de plano)
    // nunca chamam initialize — e aí o catálogo fica vazio e o preço some.
    // initialize é idempotente: no-op se já rodou.
    if (!_payment.isInitialized) {
      await _payment.initialize();
    }
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
    // Lido ANTES dos await: depois deles, tocar no context seria uso após
    // gap assíncrono (a tela pode ter saído).
    final incluido = _lifetimeCoversThisWindow;
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
    // O intervalo entre leituras é o RITMO do acesso incluído (Vitalício).
    // Quem paga por leitura não é limitado: cada leitura é uma compra, e o
    // app não recusa dinheiro nem autonomia. Sem Vitalício, nem consulta.
    final nextAllowedAt =
        incluido ? await _service.nextAllowedAt(userId, _periodType) : null;
    if (!mounted) return;
    setState(() {
      _recordCount = recordCount;
      _existing = existing;
      _nextAllowedAt = nextAllowedAt;
      _isLoading = false;
    });
  }

  /// Abre o seletor de datas e valida a janela escolhida.
  ///
  /// As DUAS travas valem aqui (decisão da dona): pode-se retroagir para
  /// ler um pedaço ainda não lido, mas não reler um já lido nem furar o
  /// intervalo entre compras. O veredito vem do serviço — a tela só traduz
  /// o motivo para uma frase.
  Future<void> _pickCustomPeriod() async {
    if (_isWorking) return;
    final l10n = AppLocalizations.of(context);
    final userId = context.read<AuthProvider>().currentUser.id;
    final hoje = DateTime.now();
    final ultimoDia = DateTime(hoje.year, hoje.month, hoje.day);

    final escolhido = await showDateRangePicker(
      context: context,
      // Um ano para trás cobre qualquer retroativo plausível sem oferecer
      // um calendário infinito.
      firstDate: ultimoDia.subtract(const Duration(days: 365)),
      lastDate: ultimoDia,
      currentDate: ultimoDia,
      helpText: l10n.cycleReadingCustomPeriodTitle,
    );
    if (escolhido == null || !mounted) return;

    // O picker devolve dias inclusivos (13 a 19 = 7 dias); a janela do app
    // é `>= start AND < end`, então o fim vira a meia-noite do dia seguinte.
    final start = DateTime(
      escolhido.start.year,
      escolhido.start.month,
      escolhido.start.day,
    );
    final end = DateTime(
      escolhido.end.year,
      escolhido.end.month,
      escolhido.end.day,
    ).add(const Duration(days: 1));

    final veredito = await _service.validateCustomPeriod(
      userId: userId,
      start: start,
      end: end,
      // Sobreposição e cooldown são o ritmo do acesso incluído; quem paga
      // por leitura escolhe qualquer janela, quantas vezes quiser.
      includedByLifetime: _hasLifetime,
    );
    if (!mounted) return;

    if (veredito.reason != null) {
      setState(() => _customRejection = _rejectionMessage(l10n, veredito));
      return;
    }

    setState(() {
      _customPeriod = (start: start, end: end);
      _periodType = veredito.periodType;
      _customRejection = null;
      // Amostra é por janela: janela nova, amostra nova.
      _teaser = null;
      _isLoading = true;
    });
    await _load();
    await _restoreCachedTeaser();
  }

  /// A frase de cada recusa. O cooldown NÃO passa por aqui: ele já tem a
  /// sua própria faixa na tela (com a contagem de dias), e repetir a mesma
  /// informação em dois lugares só confunde.
  String? _rejectionMessage(
    AppLocalizations l10n,
    ({
      String? reason,
      String periodType,
      DateTime? releaseAt,
      CycleReadingModel? conflict,
    }) veredito,
  ) {
    final formato = DateFormat.yMd(l10n.localeName);
    switch (veredito.reason) {
      case CycleReadingService.rejectionTooLong:
        return l10n.cycleReadingRejectTooLong;
      case CycleReadingService.rejectionFuture:
        return l10n.cycleReadingRejectFuture;
      case CycleReadingService.rejectionEmpty:
        return l10n.cycleReadingRejectEmpty;
      case CycleReadingService.rejectionOverlaps:
        final conflito = veredito.conflict!;
        return l10n.cycleReadingRejectOverlaps(
          formato.format(conflito.periodStart),
          // O fim guardado é exclusivo; mostrar o dia anterior é o que a
          // pessoa reconhece como "até tal dia".
          formato.format(
            conflito.periodEnd.subtract(const Duration(days: 1)),
          ),
        );
      case CycleReadingService.rejectionCooldown:
        // Tratado pela faixa de cooldown; aqui não vira mensagem.
        return null;
      default:
        return null;
    }
  }

  Future<void> _selectPeriod(String periodType) async {
    if (_isWorking) return;
    // Com uma janela a dedo em cena, tocar num dos dois botões volta para a
    // janela corrente daquele tipo — mesmo que o tipo não mude.
    if (periodType == _periodType && _customPeriod == null) return;
    setState(() {
      _periodType = periodType;
      _customPeriod = null;
      _customRejection = null;
      _isLoading = true;
      // A amostra é de UMA janela: trocar de janela zera o que está à vista
      // (a da outra janela continua guardada no cache).
      _teaser = null;
    });
    await _load();
    await _restoreCachedTeaser();
  }

  /// Chave da amostra: uma por janela (tipo + início do período).
  String get _teaserKey {
    final start = _period.start;
    return '${_periodType}_${start.year}-${start.month}-${start.day}';
  }

  /// Reexibe a amostra já paga em IA, sem gastar outra chamada.
  Future<void> _restoreCachedTeaser() async {
    final cached = await TeaserAiCache.get('cycle_reading', _teaserKey);
    if (!mounted || cached == null) return;
    setState(() => _teaser = cached);
  }

  /// Gera a amostra desta janela (uma única vez — depois vem do cache).
  Future<void> _loadTeaser() async {
    if (_isTeasing) return;
    setState(() => _isTeasing = true);
    final messenger = ScaffoldMessenger.of(context);
    final alertColor = context.gc.alert;
    final l10n = AppLocalizations.of(context);
    final userId = context.read<AuthProvider>().currentUser.id;
    final period = _period;
    try {
      final material = await _service.composer.compose(
        userId: userId,
        start: period.start,
        end: period.end,
        periodType: _periodType,
        options: _options,
      );
      final sample = await AIService.instance.generateCycleReadingTeaser(
        materialJson: material.compactJson,
      );
      await TeaserAiCache.put('cycle_reading', _teaserKey, sample);
      if (!mounted) return;
      setState(() => _teaser = sample);
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.cycleReadingTeaserFailed),
        backgroundColor: alertColor,
      ));
    } finally {
      if (mounted) setState(() => _isTeasing = false);
    }
  }

  CycleReadingSourceOptions get _options => CycleReadingSourceOptions(
        includeDreams: _includeDreams,
        includeFreeWriting: _includeFreeWriting,
        includeOracleQuestions: _includeQuestions,
      );

  Future<void> _buy() async {
    if (_isWorking) return;
    // Trava de segurança: a interface já esconde a compra durante o
    // intervalo, mas o CTA da degustação também chama aqui — nunca cobrar
    // por uma janela que ainda não pode ser lida.
    if (_isOnCooldown) return;
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

  /// Crédito incluído no Vitalício: sem loja, sem cobrança. Vale para todo
  /// Vitalício (compra real, Código Premium, admin) e para as duas janelas.
  Future<void> _claimLifetime() async {
    if (_isWorking) return;
    if (!_lifetimeCoversThisWindow) return;
    setState(() => _isWorking = true);
    final userId = context.read<AuthProvider>().currentUser.id;
    final period = _period;
    try {
      final credit = CycleReadingModel(
        userId: userId,
        periodType: _periodType,
        periodStart: period.start,
        periodEnd: period.end,
        origin: CycleReadingOrigin.lifetime,
      );
      await _service.repository.insert(credit);
      if (!mounted) return;
      setState(() => _existing = credit);
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

      // A leitura nasceu. Regeneração NÃO reinicia a contagem (o createdAt
      // do crédito é preservado), então o convite aponta sempre para o
      // mesmo dia.
      final release = result.reading.createdAt
          .add(CycleReadingService.cooldownFor(credit.periodType));

      // O convite de volta vale para TODO MUNDO: quem pagou para ler uma
      // vez pode querer ler de novo quando o ciclo recomeçar, e é disso que
      // o lembrete fala ("passaram-se sete dias, o que seu grimório
      // guardou?") — não de desbloqueio.
      await context.read<NotificationProvider>().scheduleCycleReadingUnlock(
            isWeekly: credit.isWeekly,
            releaseAt: release,
          );

      // Já a FAIXA de espera é outra coisa: ela bloqueia, e só o acesso
      // incluído tem ritmo. Quem paga por leitura nunca é bloqueado.
      if (_lifetimeCoversThisWindow) {
        setState(() => _nextAllowedAt =
            release.isAfter(DateTime.now()) ? release : null);
      }
      if (!mounted) return;
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
            // A degustação vem ANTES do "o que vem na leitura": o gostinho
            // real convence mais que a lista de seções.
            // Quem já tem a janela incluída no Vitalício não degusta o
            // que já é dele.
            if (!_isLoading &&
                _existing == null &&
                !_lifetimeCoversThisWindow &&
                !_isOnCooldown)
              _buildTeaserCard(l10n),
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
            // Sanfona: recolhida por padrão, para não tomar a tela. Quem quer
            // ajustar a privacidade abre; quem confia no padrão (tudo ligado)
            // segue direto para a compra.
            MagicalCard(
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  iconColor: context.gc.lilac,
                  collapsedIconColor: context.gc.lilac,
                  title: Text(
                    l10n.cycleReadingPrivacyTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.gc.lilac,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  children: [
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
                      onChanged: (v) =>
                          setState(() => _includeFreeWriting = v),
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

  /// A degustação: duas frases REAIS sobre o período, o resto sob véu.
  ///
  /// É o mesmo princípio das outras degustações do app — mostrar valor real
  /// no momento em que ele existe. A amostra nasce já do tamanho certo (o
  /// relatório completo nem é gerado) e fica cacheada por janela, porque
  /// cada geração custa uma chamada de IA de verdade.
  Widget _buildTeaserCard(AppLocalizations l10n) {
    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('✨ ', style: TextStyle(color: context.gc.starYellow)),
              Expanded(
                child: Text(
                  l10n.cycleReadingTeaserTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.gc.lilac,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_teaser == null) ...[
            Text(
              l10n.cycleReadingTeaserIntro,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.gc.textSecondary,
                  ),
            ),
            const SizedBox(height: 10),
            Center(
              child: OutlinedButton.icon(
                onPressed: _isTeasing ? null : _loadTeaser,
                icon: _isTeasing
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.gc.lilac,
                        ),
                      )
                    : const Icon(Icons.auto_awesome, size: 18),
                label: Text(l10n.cycleReadingTeaserPeek),
              ),
            ),
          ] else
            TeaserReveal(
              sample: Text(
                _teaser!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
              ),
              ctaLabel: l10n.cycleReadingTeaserCta,
              onCta: _buy,
            ),
        ],
      ),
    );
  }

  /// Seletor das duas janelas, cada uma com o próprio preço à vista.
  Widget _buildPeriodSelector(AppLocalizations l10n) {
    Widget option(String type, String label, String productId) {
      final selected = _periodType == type;
      final included =
          _hasLifetime && CycleReadingService.lifetimeCovers(type);
      final price =
          included ? l10n.cycleReadingLifetimeTag : _prices[productId];
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

    final custom = _customPeriod;
    final formato = DateFormat.yMd(l10n.localeName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
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
        ),
        const SizedBox(height: 8),
        // Ler um pedaço retroativo: a lunação passada, aquela semana
        // específica. O tamanho escolhido decide o produto.
        if (custom == null)
          TextButton.icon(
            onPressed: _isWorking ? null : _pickCustomPeriod,
            icon: const Icon(Icons.event_repeat, size: 18),
            label: Text(l10n.cycleReadingCustomPeriodButton),
          )
        else ...[
          Text(
            l10n.cycleReadingCustomPeriodLine(
              formato.format(custom.start),
              // O fim guardado é exclusivo: mostra o último dia vivido.
              formato.format(custom.end.subtract(const Duration(days: 1))),
              CycleReadingService.spanInDays(custom.start, custom.end),
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.gc.lilac,
                  fontWeight: FontWeight.bold,
                ),
          ),
          TextButton.icon(
            onPressed: _isWorking ? null : _pickCustomPeriod,
            icon: const Icon(Icons.edit_calendar, size: 18),
            label: Text(l10n.cycleReadingCustomPeriodButton),
          ),
          TextButton(
            onPressed: _isWorking
                ? null
                : () => _selectPeriod(CycleReadingPeriodType.lunation),
            child: Text(l10n.cycleReadingCustomPeriodClear),
          ),
        ],
        if (_customRejection != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _customRejection!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.gc.alert,
                  ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              l10n.cycleReadingCustomPeriodHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.gc.textSecondary,
                  ),
            ),
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

    // Ritmo do acesso INCLUÍDO (Vitalício): uma semanal a cada 7 dias, uma
    // lunação a cada 30 — `_nextAllowedAt` só é preenchido nesse caso, então
    // quem paga por leitura nunca vê esta faixa.
    //
    // Vem DEPOIS dos casos acima de propósito: crédito já pago (pendente ou
    // gerado) nunca é bloqueado por isto; o ritmo trava uma leitura NOVA,
    // não o acesso ao que já é dela.
    if (_isOnCooldown) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.gc.lilac.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.gc.lilac.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🌙 ', style: TextStyle(color: context.gc.lilac)),
            Expanded(
              child: Text(
                _periodType == CycleReadingPeriodType.week
                    ? l10n.cycleReadingCooldownWeek(_daysUntilRelease)
                    : l10n.cycleReadingCooldownLunation(_daysUntilRelease),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.gc.textSecondary,
                      height: 1.4,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    // Vitalício: esta janela está incluída. Gera direto, sem loja.
    if (_lifetimeCoversThisWindow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.cycleReadingLifetimeIncluded,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.gc.textSecondary),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _claimLifetime,
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: Text(l10n.cycleReadingGenerate),
          ),
        ],
      );
    }

    // Sem leitura nesta janela: a compra é o único caminho — a Leitura do
    // Ciclo é produto avulso e não entra no Premium (assinar não dá leitura
    // de graça; o que a assinatura desbloqueia são as features do app). A
    // única exceção é a lunação do Vitalício, tratada logo acima.
    final price = _prices[_productId];
    if (price == null) {
      return Text(
        l10n.cycleReadingUnavailable,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.gc.warning,
            ),
      );
    }
    return ElevatedButton.icon(
      onPressed: _buy,
      icon: const Icon(Icons.shopping_bag_outlined, size: 18),
      label: Text(l10n.cycleReadingBuyFor(price)),
    );
  }
}
