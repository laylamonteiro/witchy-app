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
          // Do longo ao curto: as Eras (120 anos), o mês, e a semana/lunação.
          const MonthSkyCard(),
          _CartaoDaLeituraDoCiclo(titulo: l10n.cycleReadingTitle),
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

/// A escala curta: a Leitura do Ciclo, que já existe, agora com casa própria.
class _CartaoDaLeituraDoCiclo extends StatelessWidget {
  const _CartaoDaLeituraDoCiclo({required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tema = Theme.of(context);

    return MagicalCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CycleReadingIntroPage()),
      ),
      child: Row(
        children: [
          const Text('🌙', style: TextStyle(fontSize: 34)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: tema.textTheme.titleMedium?.copyWith(
                    color: context.gc.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.cyclesReadingCardSubtitle,
                  style: tema.textTheme.bodySmall
                      ?.copyWith(color: context.gc.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: context.gc.lilac),
        ],
      ),
    );
  }
}
