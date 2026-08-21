import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/living_emblem.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../astrology/presentation/pages/birth_chart_input_page.dart';
import '../../../astrology/presentation/providers/astrology_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cycle_reading/data/models/cycle_reading_model.dart';
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
/// - **O que já é seu.** "Sua lunação rendeu 14 registros" é o número real
///   do banco. A matéria-prima da leitura já existe e é dela — ver isso
///   escrito vale mais que qualquer adjetivo sobre o produto.
/// - **Um prazo de verdade.** A lunação fecha sozinha, num dia que a
///   astronomia decidiu. A barra mostra quanto do ciclo já passou e quantos
///   dias faltam: é o relógio do próprio céu, não uma contagem inventada
///   para apressar ninguém.
/// - **Curiosidade com substância.** Em vez de "compre sua leitura", o
///   cartão nomeia o que vem dentro — o retrato do momento, os fios que se
///   repetem — sem entregar nada.
/// - **Estado antes de venda.** Se a leitura desta lunação já existe, o
///   cartão vira porta para ela; se está paga e não gerada, vira o botão de
///   gerar. Vender de novo o que a pessoa já comprou é o jeito mais rápido
///   de perder a confiança dela.
class _CartaoDaLeituraDoCiclo extends StatefulWidget {
  const _CartaoDaLeituraDoCiclo();

  @override
  State<_CartaoDaLeituraDoCiclo> createState() =>
      _CartaoDaLeituraDoCicloState();
}

class _CartaoDaLeituraDoCicloState extends State<_CartaoDaLeituraDoCiclo> {
  final CycleReadingService _service = CycleReadingService();

  bool _carregando = true;
  int _registros = 0;
  CycleReadingModel? _leitura;
  late ({DateTime start, DateTime end}) _lunacao =
      CycleReadingService.currentLunation();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _carregar();
    });
  }

  Future<void> _carregar() async {
    final userId = context.read<AuthProvider>().currentUser.id;
    final lunacao = CycleReadingService.currentLunation();
    final registros = await _service.composer.countPeriodRecords(
      userId: userId,
      start: lunacao.start,
      end: lunacao.end,
    );
    final leitura = await _service.repository.findForPeriod(
      userId,
      lunacao.start,
      periodType: CycleReadingPeriodType.lunation,
    );
    if (!mounted) return;
    setState(() {
      _lunacao = lunacao;
      _registros = registros;
      _leitura = leitura;
      _carregando = false;
    });
  }

  /// Quanto da lunação já passou (0..1) — o relógio do céu.
  double get _percorrido {
    final total = _lunacao.end.difference(_lunacao.start).inMinutes;
    if (total <= 0) return 0;
    final andado = DateTime.now().difference(_lunacao.start).inMinutes;
    return (andado / total).clamp(0.0, 1.0);
  }

  /// Dias que faltam para o ciclo fechar, arredondando para cima (faltando
  /// 6 horas ainda é "1 dia", nunca "0").
  int get _diasRestantes {
    final restante = _lunacao.end.difference(DateTime.now());
    if (restante.isNegative) return 0;
    return restante.inHours ~/ 24 + (restante.inHours % 24 > 0 ? 1 : 0);
  }

  Future<void> _abrir() async {
    // Com leitura (pronta ou paga) desta lunação, a tela abre NELA: quem
    // veio de "sua leitura está pronta" não pode cair num calendário.
    final janela = _leitura == null ? null : _lunacao;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CycleReadingIntroPage(initialPeriod: janela),
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
    final leitura = _leitura;

    // Chamada e botão mudam com o estado — nunca oferecer a compra de algo
    // que a pessoa já tem.
    final (String chamada, String rotulo) = switch (leitura) {
      final l? when l.isGenerated =>
        (l10n.cyclesReadingCardReady, l10n.cycleReadingOpenReport),
      final l? when l.isPending =>
        (l10n.cycleReadingPendingCredit, l10n.cycleReadingGenerate),
      _ when _registros == 0 =>
        (l10n.cyclesReadingCardEmpty, l10n.cyclesReadingCardCta),
      _ => (l10n.cycleReadingOfferTitle(_registros), l10n.cyclesReadingCardCta),
    };

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
          // O relógio do céu: quanto da lunação já passou.
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _percorrido,
              minHeight: 6,
              backgroundColor: context.gc.lilac.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(context.gc.lilac),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.cyclesReadingCardDaysLeft(_diasRestantes),
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
