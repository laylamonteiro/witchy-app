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
import '../widgets/cycle_period_picker_sheet.dart';
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

  /// A tela abre no CALENDÁRIO e mais nada: escolher o pedaço da vida a ser
  /// lido é a primeira decisão, e é ela que define o produto e o preço.
  /// Enquanto isto for falso, a oferta e o resto da tela nem existem.
  bool _periodoEscolhido = false;

  /// Mapa de calor do último ano (null = ainda carregando).
  Map<String, int>? _densidade;

  /// Leitura já gerada que cruza a janela escolhida — AVISO, nunca recusa.
  CycleReadingModel? _conflito;

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

  /// A amostra desta janela (null = ainda não pedida).
  String? _teaser;
  bool _isTeasing = false;

  /// Preço por janela (null = produto indisponível nesta plataforma/loja).
  final Map<String, String?> _prices = {};

  // Grupos de fontes que a pessoa pode desligar antes de enviar à análise.
  // Agrupados (e não um interruptor por tabela) para a tela continuar
  // legível: oito chaves viram um painel, não uma escolha.
  bool _includeDreams = true;
  bool _includeJournals = true;
  bool _includePractice = true;
  bool _includeDivination = true;

  @override
  void initState() {
    super.initState();
    // Sem `_load()` aqui: nada da tela depende de janela antes de haver
    // janela. O que a primeira tela precisa é do calendário.
    _loadPrices();
    _carregarDensidade();
  }

  /// O mapa de calor do último ano — quantos registros em cada dia.
  ///
  /// É o que faz a escolha ser informada em vez de às cegas: a pessoa vê
  /// onde a vida dela deixou marca antes de decidir o que vai ler.
  Future<void> _carregarDensidade() async {
    final userId = context.read<AuthProvider>().currentUser.id;
    final hoje = DateTime.now();
    final ultimoDia = DateTime(hoje.year, hoje.month, hoje.day);
    // Um ano para trás cobre qualquer retroativo plausível sem oferecer um
    // calendário infinito.
    final primeiroDia = ultimoDia.subtract(const Duration(days: 365));
    final densidade = await _service.composer.dailyRecordCounts(
      userId: userId,
      start: primeiroDia,
      end: ultimoDia.add(const Duration(days: 1)),
    );
    if (!mounted) return;
    setState(() => _densidade = densidade);
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
    if (!mounted) return;
    setState(() {
      _recordCount = recordCount;
      _existing = existing;
      _isLoading = false;
    });
  }

  /// A janela escolhida no calendário da primeira tela.
  ///
  /// O tamanho decide o produto (até 7 dias = semana; 8 a 31 = lunação), e é
  /// só depois disto que a oferta e o resto da tela aparecem. O serviço
  /// recusa apenas o que a leitura não consegue fazer; cruzar um período já
  /// lido volta como AVISO, não como porta fechada.
  Future<void> _escolherPeriodo(({DateTime start, DateTime end}) janela) async {
    if (_isWorking) return;
    final l10n = AppLocalizations.of(context);
    final userId = context.read<AuthProvider>().currentUser.id;

    final veredito = await _service.validateCustomPeriod(
      userId: userId,
      start: janela.start,
      end: janela.end,
    );
    if (!mounted) return;

    if (veredito.reason != null) {
      setState(() => _customRejection = _rejectionMessage(l10n, veredito));
      return;
    }

    setState(() {
      _customPeriod = janela;
      _periodType = veredito.periodType;
      _conflito = veredito.conflict;
      _customRejection = null;
      // Amostra é por janela: janela nova, amostra nova.
      _teaser = null;
      _periodoEscolhido = true;
      _isLoading = true;
    });
    await _load();
    await _restoreCachedTeaser();
  }

  /// Volta para o calendário mantendo a janela marcada — trocar de período é
  /// reabrir a mesma decisão, não recomeçar do zero.
  void _voltarAoCalendario() {
    if (_isWorking) return;
    setState(() {
      _periodoEscolhido = false;
      _customRejection = null;
    });
  }

  /// A frase de cada recusa.
  String? _rejectionMessage(
    AppLocalizations l10n,
    ({
      String? reason,
      String periodType,
      CycleReadingModel? conflict,
    }) veredito,
  ) {
    switch (veredito.reason) {
      case CycleReadingService.rejectionTooLong:
        return l10n.cycleReadingRejectTooLong;
      case CycleReadingService.rejectionFuture:
        return l10n.cycleReadingRejectFuture;
      case CycleReadingService.rejectionEmpty:
        return l10n.cycleReadingRejectEmpty;
      default:
        return null;
    }
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
        includeJournals: _includeJournals,
        includeDivination: _includeDivination,
        includePractice: _includePractice,
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
          .add(CycleReadingService.inviteBackAfter(credit.periodType));

      // O convite de volta vale para TODO MUNDO: quem pagou para ler uma
      // vez pode querer ler de novo quando o ciclo recomeçar, e é disso que
      // o lembrete fala ("passaram-se sete dias, o que seu grimório
      // guardou?") — não de desbloqueio.
      await context.read<NotificationProvider>().scheduleCycleReadingUnlock(
            isWeekly: credit.isWeekly,
            releaseAt: release,
          );
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

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(l10n.cycleReadingTitle),
      ),
      // Duas etapas, nesta ordem: escolher o pedaço da vida, e só então ver
      // a oferta que aquele pedaço fez nascer. Misturar as duas — como era
      // antes, com o seletor de janela e a oferta na mesma tela — pedia duas
      // decisões ao mesmo tempo e nenhuma ficava clara.
      body: _periodoEscolhido ? _buildOferta(l10n) : _buildCalendario(l10n),
    );
  }

  /// Etapa 1: o calendário, e mais nada.
  Widget _buildCalendario(AppLocalizations l10n) {
    final densidade = _densidade;
    if (densidade == null) {
      return Center(child: CircularProgressIndicator(color: context.gc.lilac));
    }

    final hoje = DateTime.now();
    final ultimoDia = DateTime(hoje.year, hoje.month, hoje.day);
    final primeiroDia = ultimoDia.subtract(const Duration(days: 365));

    return Column(
      children: [
        Expanded(
          child: CyclePeriodPickerSheet(
            // A chave leva a janela: mudar de período reconstrói o seletor
            // com as datas novas já marcadas, em vez de guardar o estado
            // antigo do calendário.
            key: ValueKey(_customPeriod),
            embedded: true,
            onConfirm: _escolherPeriodo,
            initialRange: _janelaSugerida(ultimoDia),
            dailyCounts: densidade,
            firstDate: primeiroDia,
            lastDate: ultimoDia,
            weekPrice: _prices[RevenueCatConfig.cycleReadingWeekProductId],
            lunationPrice:
                _prices[RevenueCatConfig.cycleReadingMonthProductId],
            lifetimeIncluded: _hasLifetime,
          ),
        ),
        if (_customRejection != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              _customRejection!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.gc.alert,
                  ),
            ),
          ),
      ],
    );
  }

  /// A janela que o calendário já abre marcada.
  ///
  /// A do ciclo corrente, cortada em HOJE: a lunação em curso termina no
  /// futuro, e um período que ainda não foi vivido não pode ser lido — sem o
  /// corte, a sugestão já nasceria recusada.
  ({DateTime start, DateTime end}) _janelaSugerida(DateTime ultimoDia) {
    final escolhida = _customPeriod;
    if (escolhida != null) return escolhida;
    final corrente = CycleReadingService.periodFor(_periodType);
    final amanha = ultimoDia.add(const Duration(days: 1));
    return (
      start: corrente.start,
      end: corrente.end.isAfter(amanha) ? amanha : corrente.end,
    );
  }

  /// Etapa 2: a oferta que a janela escolhida fez nascer, e o resto da tela.
  Widget _buildOferta(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOfferCard(l10n),
          // A degustação vem ANTES do "o que vem na leitura": o gostinho
          // real convence mais que a lista de seções.
          // Quem já tem a janela incluída no Vitalício não degusta o
          // que já é dele.
          if (!_isLoading && _existing == null && !_lifetimeCoversThisWindow)
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
                  _periodType == CycleReadingPeriodType.week
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
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
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
                    subtitle: Text(l10n.cycleReadingIncludeFreeWritingHint),
                    value: _includeJournals,
                    onChanged: (v) => setState(() => _includeJournals = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.cycleReadingIncludeQuestions),
                    subtitle: Text(l10n.cycleReadingIncludeQuestionsHint),
                    value: _includeDivination,
                    onChanged: (v) => setState(() => _includeDivination = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.cycleReadingIncludePractice),
                    subtitle: Text(l10n.cycleReadingIncludePracticeHint),
                    value: _includePractice,
                    onChanged: (v) => setState(() => _includePractice = v),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// O cartão da oferta: o produto que a janela virou, por quanto, com o que
  /// ela tem dentro — e o botão. Tudo o que decide a compra num lugar só.
  Widget _buildOfferCard(AppLocalizations l10n) {
    final format = DateFormat('dd/MM/yyyy');
    final period = _period;
    final isWeek = _periodType == CycleReadingPeriodType.week;
    final incluida = _lifetimeCoversThisWindow;
    final preco = incluida
        ? l10n.cycleReadingLifetimeTag
        : _prices[_productId];
    final titulo =
        isWeek ? l10n.cycleReadingWeekTitle : l10n.cycleReadingLunationTitle;

    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🌙✨', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: context.gc.lilac,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
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
                  ],
                ),
              ),
              if (preco != null)
                Text(
                  preco,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.gc.starYellow,
                        fontWeight: FontWeight.bold,
                      ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: CircularProgressIndicator(color: context.gc.lilac),
              ),
            )
          else ...[
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
              _aviso(l10n.cycleReadingShallowWarning, context.gc.warning),
            ],
            // Cruzar um período já lido não impede nada — mas dizer poupa
            // uma compra repetida por engano.
            if (_conflito != null) ...[
              const SizedBox(height: 8),
              _aviso(
                l10n.cycleReadingOverlapNotice(
                  DateFormat.yMd(l10n.localeName)
                      .format(_conflito!.periodStart),
                  DateFormat.yMd(l10n.localeName).format(
                    _conflito!.periodEnd.subtract(const Duration(days: 1)),
                  ),
                ),
                context.gc.textSecondary,
              ),
            ],
            const SizedBox(height: 16),
            _buildActions(l10n),
          ],
          const SizedBox(height: 4),
          Center(
            child: TextButton.icon(
              onPressed: _isWorking ? null : _voltarAoCalendario,
              icon: const Icon(Icons.edit_calendar, size: 18),
              label: Text(l10n.cycleReadingCustomPeriodButton),
            ),
          ),
        ],
      ),
    );
  }

  /// Faixa de aviso — mesma forma para "poucos registros" e "já lido".
  Widget _aviso(String texto, Color cor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cor),
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
