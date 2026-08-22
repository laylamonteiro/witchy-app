import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/debug_log_service.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/living_emblem.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../astrology/presentation/pages/birth_chart_input_page.dart';
import '../../../astrology/presentation/providers/astrology_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cycle_reading/data/models/cycle_reading_model.dart';
import '../../../cycle_reading/data/services/cycle_reading_composer.dart';
import '../../../cycle_reading/data/services/cycle_reading_service.dart';
import '../../../cycle_reading/presentation/pages/cycle_reading_intro_page.dart';
import '../../data/data_sources/life_eras_content.dart';
import '../../data/models/life_eras_state.dart';
import '../../domain/life_timeline.dart';
import '../providers/life_eras_provider.dart';
import '../providers/month_sky_provider.dart';
import '../widgets/cycle_labels.dart';
import '../widgets/cycles_emblem.dart';
import '../widgets/era_card.dart';
import '../widgets/month_sky_card.dart';
import 'life_eras_page.dart';

/// A aba Ciclos, dentro de Ferramentas.
///
/// Reúne as duas escalas de tempo do app: as **Eras**, que cobrem 120 anos e
/// vêm do mapa astral, e a **Leitura do Ciclo**, que cobre a semana ou a
/// lunação e vem do que a pessoa registrou. São produtos distintos que
/// respondem à mesma pergunta — em que momento eu estou — e por isso moram
/// juntos.
class CyclesTab extends StatelessWidget {
  const CyclesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LifeErasProvider()),
        ChangeNotifierProvider(create: (_) => MonthSkyProvider()),
      ],
      child: const _CyclesBody(),
    );
  }
}

class _CyclesBody extends StatefulWidget {
  const _CyclesBody();

  @override
  State<_CyclesBody> createState() => _CyclesBodyState();
}

class _CyclesBodyState extends State<_CyclesBody> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Adiado para depois do frame de propósito: `sync` notifica de forma
    // síncrona, e mexer num provider com a árvore ainda montando é erro em
    // tempo de execução — do tipo que nem o analisador nem os testes pegam.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _sincronizar();
    });
  }

  void _sincronizar() {
    final chart = context.read<AstrologyProvider>().birthChart;
    final userId = context.read<AuthProvider>().currentUser.id;
    // Repetições com o mesmo mapa saem cedo dentro do provider.
    context.read<LifeErasProvider>().sync(userId: userId, chart: chart);
    // O céu do mês não depende do mapa: vale para todo mundo, com ou sem
    // dados de nascimento.
    context.read<MonthSkyProvider>().sync(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Observar o mapa: quando ele é recalculado, as Eras precisam acompanhar.
    context.watch<AstrologyProvider>();
    final eras = context.watch<LifeErasProvider>();
    final estado = eras.state;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: StaggeredEntrance(
        children: [
          // O emblema vivo abre a seção, como nas outras abas.
          SectionEmblemHeader.custom(
            customArt: const CyclesEmblemArt(),
            intro: l10n.cyclesTabIntro,
          ),
          // A Leitura do Ciclo abre a aba: é a única coisa aqui que fala do
          // que a PESSOA viveu (as Eras e o mês falam do céu), a única que
          // muda toda semana, e a única que se compra.
          const _CartaoDaLeituraDoCiclo(),
          if (estado == null || eras.carregando)
            const _Carregando()
          else
            ...switch (estado) {
              LifeErasReady(:final linha, :final horaIncerta) => [
                  if (horaIncerta) const _AvisoDeHoraIncerta(),
                  _CartaoDasEras(linha: linha),
                ],
              LifeErasIncomplete() => [const _SemMapa()],
              LifeErasError() => [const _DeuErrado()],
            },
          const MonthSkyCard(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _Carregando extends StatelessWidget {
  const _Carregando();

  @override
  Widget build(BuildContext context) => const MagicalCard(
        child: SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
}

/// O bloco das Eras: Era corrente, Fase corrente e a porta para a linha
/// do tempo inteira.
class _CartaoDasEras extends StatelessWidget {
  const _CartaoDasEras({required this.linha});

  final LinhaDoTempo linha;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final agora = DateTime.now().toUtc();
    final era = linha.eraEm(agora);
    final fase = linha.faseEm(agora);
    final textoEra = LifeErasContent.daEra(era.regente);
    final textoFase = LifeErasContent.daFase(fase.regente);
    final tema = Theme.of(context);

    void abrir() => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => LifeErasPage(linha: linha)),
        );

    return MagicalCard(
      onTap: abrir,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.cyclesErasTitle,
                      style: tema.textTheme.titleLarge?.copyWith(
                        color: context.gc.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.cyclesErasSubtitle,
                      style: tema.textTheme.bodySmall
                          ?.copyWith(color: context.gc.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_outward, size: 18, color: context.gc.lilac),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.cyclesCurrentEraLabel,
            style:
                tema.textTheme.bodySmall?.copyWith(color: context.gc.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            textoEra.titulo,
            style: tema.textTheme.titleMedium?.copyWith(
              color: context.gc.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          CycleTagChips(tags: textoEra.tags),
          const SizedBox(height: 6),
          Text(
            '${l10n.cyclesPeriodRange(
              formatarMesAno(context, era.inicio),
              formatarMesAno(context, era.fim),
            )}  ·  ${l10n.cyclesEraLength(formatarDuracao(l10n, era.anosCompletos))}',
            style:
                tema.textTheme.bodySmall?.copyWith(color: context.gc.textSecondary),
          ),
          const SizedBox(height: 16),
          Divider(color: context.gc.surfaceBorder),
          const SizedBox(height: 10),
          Text(
            l10n.cyclesCurrentPhaseLabel,
            style:
                tema.textTheme.bodySmall?.copyWith(color: context.gc.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            textoFase.titulo,
            style: tema.textTheme.titleMedium?.copyWith(
              color: context.gc.lilac,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${l10n.cyclesPeriodRange(
              formatarMesAno(context, fase.inicio),
              formatarMesAno(context, fase.fim),
            )}  ·  ${formatarIntervalo(l10n, fase.inicio, fase.fim)}',
            style:
                tema.textTheme.bodySmall?.copyWith(color: context.gc.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Sem mapa astral não há longitude da Lua, e sem ela não há linha do tempo.
class _SemMapa extends StatelessWidget {
  const _SemMapa();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tema = Theme.of(context);

    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.cyclesNoChartTitle,
            style: tema.textTheme.titleMedium?.copyWith(
              color: context.gc.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.cyclesNoChartBody,
            style:
                tema.textTheme.bodySmall?.copyWith(color: context.gc.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BirthChartInputPage()),
            ),
            child: Text(l10n.cyclesNoChartCta),
          ),
        ],
      ),
    );
  }
}

/// Quem não sabe a hora de nascimento vê a linha do tempo assim mesmo, mas
/// nunca sem este aviso: doze horas de incerteza podem trocar a Era regente.
class _AvisoDeHoraIncerta extends StatelessWidget {
  const _AvisoDeHoraIncerta();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tema = Theme.of(context);

    return MagicalCard.accent(
      accent: context.gc.starYellow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, size: 18, color: context.gc.starYellow),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.cyclesUncertainTitle,
                  style: tema.textTheme.titleMedium?.copyWith(
                    color: context.gc.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.cyclesUncertainBody,
            style:
                tema.textTheme.bodySmall?.copyWith(color: context.gc.textSecondary),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BirthChartInputPage()),
            ),
            child: Text(l10n.cyclesUncertainCta),
          ),
        ],
      ),
    );
  }
}

class _DeuErrado extends StatelessWidget {
  const _DeuErrado();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tema = Theme.of(context);

    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.cyclesErrorTitle,
            style: tema.textTheme.titleMedium?.copyWith(
              color: context.gc.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.cyclesErrorBody,
            style:
                tema.textTheme.bodySmall?.copyWith(color: context.gc.textSecondary),
          ),
          const SizedBox(height: 16),
          // O cartão era mudo: título, corpo e mais nada. Sem botão, a única
          // saída era fechar a aba e torcer — e o `sync` do provider sairia
          // cedo de qualquer jeito, porque depois da falha a assinatura
          // continua a mesma. Por isso o botão chama `recarregar`, que ignora
          // o carimbo.
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => context.read<LifeErasProvider>().recarregar(
                    userId: context.read<AuthProvider>().currentUser.id,
                    chart: context.read<AstrologyProvider>().birthChart,
                  ),
              icon: Icon(Icons.refresh, size: 18, color: context.gc.lilac),
              label: Text(
                l10n.commonTryAgain,
                style: TextStyle(color: context.gc.lilac),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A Leitura do Ciclo na aba Ciclos — o cartão que abre a seção.
///
/// Desenhado para ser lido em dois segundos e dar vontade de tocar, sem
/// inventar urgência nenhuma. Tudo o que ele diz é verificável:
///
/// - **O que já é seu e ainda não foi lido.** "23 registros desde a sua
///   última leitura" é a conta real: quantos registros ela criou depois do
///   instante em que a última leitura foi gerada. A matéria-prima já existe,
///   é dela, e ninguém leu ainda — ver isso escrito vale mais que qualquer
///   adjetivo sobre o produto.
/// - **Uma medida honesta, não um prazo inventado.** A barra mostra o quanto
///   esse acúmulo já passa do mínimo em que a leitura ganha profundidade. Não
///   é contagem regressiva de lunação: leituras podem ser de qualquer
///   período, inclusive retroativo, e o relógio do céu não dizia nada sobre
///   o que a pessoa registrou.
/// - **Curiosidade com substância.** Em vez de "compre sua leitura", o
///   cartão nomeia o que vem dentro — o retrato do momento, os fios que se
///   repetem — sem entregar nada.
/// - **Estado antes de venda.** Crédito pago e não gerado vira o botão de
///   gerar, na janela dele. Vender de novo o que a pessoa já comprou é o
///   jeito mais rápido de perder a confiança dela.
class _CartaoDaLeituraDoCiclo extends StatefulWidget {
  const _CartaoDaLeituraDoCiclo();

  @override
  State<_CartaoDaLeituraDoCiclo> createState() =>
      _CartaoDaLeituraDoCicloState();
}

class _CartaoDaLeituraDoCicloState extends State<_CartaoDaLeituraDoCiclo> {
  final CycleReadingService _service = CycleReadingService();

  bool _carregando = true;

  /// Registros que ainda não entraram em leitura nenhuma.
  int _naoLidos = 0;

  /// A última leitura GERADA (null = nunca leu).
  CycleReadingModel? _ultima;

  /// Crédito comprado e ainda não gerado, se houver.
  CycleReadingModel? _pendente;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _carregar();
    });
  }

  /// Lê o estado do cartão. Nunca deixa o botão morto.
  ///
  /// Eram três idas ao banco sem `try`, disparadas de um `Future` que ninguém
  /// aguarda: qualquer exceção virava erro assíncrono não capturado, o
  /// `setState` nunca rodava, `_carregando` ficava `true` para sempre — e
  /// `onPressed: _carregando ? null : _abrir` deixava o CTA desabilitado,
  /// com a barra de progresso em zero. A pessoa não tinha o que fazer na
  /// tela e nem sabia por quê.
  Future<void> _carregar() async {
    try {
      await _lerEstado();
    } catch (e) {
      await debugLog('CYCLE_READING', 'Falha ao ler o cartão de Ciclos: $e');
      if (!mounted) return;
      // Sem os números, mas com o botão vivo: a tela da Leitura do Ciclo
      // sabe se virar sozinha, e é lá que a pessoa quer chegar.
      setState(() => _carregando = false);
    }
  }

  Future<void> _lerEstado() async {
    final userId = context.read<AuthProvider>().currentUser.id;
    final hoje = DateTime.now();
    final amanha = DateTime(hoje.year, hoje.month, hoje.day)
        .add(const Duration(days: 1));

    final ultima = await _service.repository.lastGenerated(userId);

    // A âncora é o INSTANTE DA GERAÇÃO, não o fim do período lido: as
    // tabelas de registro guardam `created_at`, e o que a leitura não viu é
    // exatamente o que nasceu depois dela. Com o fim do período, quem lia
    // "até hoje" e registrava algo em seguida via zero — o registro caía
    // dentro da janela já lida, mesmo tendo nascido depois do texto.
    //
    // Sem leitura anterior, conta o último ano — que é até onde o calendário
    // deixa retroagir. Contar "desde sempre" prometeria um período que a
    // leitura não aceita.
    final desde = ultima?.createdAt ??
        DateTime(hoje.year, hoje.month, hoje.day)
            .subtract(const Duration(days: 365));

    final naoLidos = desde.isBefore(amanha)
        ? await _service.composer.countPeriodRecords(
            userId: userId,
            start: desde,
            end: amanha,
          )
        : 0;

    // Crédito pendente: uma compra que ainda não virou relatório não pode
    // ficar esquecida atrás de uma oferta nova.
    final todas = await _service.repository.getAll(userId);
    final pendentes = todas.where((l) => l.isPending);

    if (!mounted) return;
    setState(() {
      _ultima = ultima;
      _naoLidos = naoLidos;
      _pendente = pendentes.isEmpty ? null : pendentes.first;
      _carregando = false;
    });
  }

  /// Quanto o acúmulo já passa do mínimo em que a leitura ganha profundidade.
  double get _profundidade =>
      (_naoLidos / CycleReadingComposer.minRecordsForDepth).clamp(0.0, 1.0);

  Future<void> _abrir() async {
    // Com crédito pendente, a tela abre na janela dele: aquilo já está pago
    // e só falta gerar.
    final pendente = _pendente;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CycleReadingIntroPage(
          initialPeriod: pendente == null
              ? null
              : (start: pendente.periodStart, end: pendente.periodEnd),
        ),
      ),
    );
    // Voltou da tela: pode ter comprado, gerado ou lido — o cartão relê o
    // seu estado em vez de continuar mostrando o de antes.
    if (mounted) _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tema = Theme.of(context);

    final String chamada;
    final String rotulo;
    if (_pendente != null) {
      chamada = l10n.cycleReadingPendingCredit;
      rotulo = l10n.cycleReadingGenerate;
    } else if (_ultima != null) {
      chamada = l10n.cyclesReadingCardUnread(_naoLidos);
      rotulo = l10n.cyclesReadingCardCta;
    } else {
      chamada = l10n.cyclesReadingCardWaiting(_naoLidos);
      rotulo = l10n.cyclesReadingCardCta;
    }

    final ultima = _ultima;
    final rodape = ultima == null
        ? l10n.cyclesReadingCardDepthHint(
            CycleReadingComposer.minRecordsForDepth)
        : l10n.cyclesReadingCardLastRead(
            formatarDiaMesAno(context, ultima.createdAt),
          );

    return MagicalCard.hero(
      accent: context.gc.lilac,
      onTap: _abrir,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🌙', style: TextStyle(fontSize: 34)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.cycleReadingTitle,
                      style: tema.textTheme.titleLarge?.copyWith(
                        color: context.gc.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      chamada,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: context.gc.lilac,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.cyclesReadingCardPitch,
            style: tema.textTheme.bodySmall?.copyWith(
              color: context.gc.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          // Quanto do material já dá uma leitura funda — medida do grimório
          // dela, não do calendário.
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _profundidade,
              minHeight: 6,
              backgroundColor: context.gc.lilac.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(context.gc.lilac),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            rodape,
            style: tema.textTheme.bodySmall
                ?.copyWith(color: context.gc.textSecondary),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              // Enquanto a contagem não chegou, o botão espera: um rótulo
              // que muda debaixo do dedo é pior que meio segundo de espera.
              onPressed: _carregando ? null : _abrir,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: Text(rotulo),
            ),
          ),
        ],
      ),
    );
  }
}
