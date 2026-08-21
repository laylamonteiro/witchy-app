import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/data/models/feature_access.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../data/data_sources/life_eras_content.dart';
import '../../domain/cycle_time.dart';
import '../../domain/life_timeline.dart';
import '../widgets/cycle_labels.dart';
import '../widgets/era_card.dart';
import '../widgets/era_progress_ring.dart';
import 'era_reading_page.dart';

/// A linha do tempo inteira: Agora, Passado e Futuro.
class LifeErasPage extends StatefulWidget {
  const LifeErasPage({super.key, required this.linha});

  final LinhaDoTempo linha;

  @override
  State<LifeErasPage> createState() => _LifeErasPageState();
}

class _LifeErasPageState extends State<LifeErasPage> {
  int _aba = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final agora = DateTime.now().toUtc();
    final liberado = context
        .watch<AuthProvider>()
        .checkFeatureAccess(AppFeature.lifeErasFull)
        .hasFullAccess;

    return Scaffold(
      appBar: AppBar(title: ResponsiveAppBarTitle(l10n.cyclesErasTitle)),
      body: SafeArea(
        child: Column(
          children: [
            _SeletorDePeriodo(
              selecionado: _aba,
              rotulos: [l10n.cyclesTabNow, l10n.cyclesTabPast, l10n.cyclesTabFuture],
              onSelecionar: (i) => setState(() => _aba = i),
            ),
            Expanded(
              child: switch (_aba) {
                0 => _Agora(linha: widget.linha, agora: agora),
                1 => _ListaDeEras(
                    eras: widget.linha.passadas(agora),
                    agora: agora,
                    passado: true,
                    liberado: liberado,
                    vazio: l10n.cyclesPastEmpty,
                  ),
                _ => _ListaDeEras(
                    eras: widget.linha.futuras(agora),
                    agora: agora,
                    passado: false,
                    liberado: liberado,
                    vazio: l10n.cyclesFutureEmpty,
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Agora / Passado / Futuro, no formato de pílulas que o app já usa.
class _SeletorDePeriodo extends StatelessWidget {
  const _SeletorDePeriodo({
    required this.selecionado,
    required this.rotulos,
    required this.onSelecionar,
  });

  final int selecionado;
  final List<String> rotulos;
  final ValueChanged<int> onSelecionar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          for (var i = 0; i < rotulos.length; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == rotulos.length - 1 ? 0 : 8),
                child: InkWell(
                  onTap: () => onSelecionar(i),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == selecionado
                          ? context.gc.lilac.withValues(alpha: 0.18)
                          : Colors.transparent,
                      border: Border.all(
                        color: i == selecionado
                            ? context.gc.lilac
                            : context.gc.surfaceBorder,
                        width: i == selecionado ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      rotulos[i],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: i == selecionado
                                ? context.gc.lilac
                                : context.gc.textSecondary,
                            fontWeight: i == selecionado
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A Era e a Fase correntes, com o anel de progresso.
class _Agora extends StatelessWidget {
  const _Agora({required this.linha, required this.agora});

  final LinhaDoTempo linha;
  final DateTime agora;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final era = linha.eraEm(agora);
    final fase = linha.faseEm(agora);
    final textoEra = LifeErasContent.daEra(era.regente);
    final textoFase = LifeErasContent.daFase(fase.regente);
    final tema = Theme.of(context);

    return SingleChildScrollView(
      child: StaggeredEntrance(
        children: [
          MagicalCard(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => EraReadingPage.era(era: era),
            )),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.cyclesCurrentEraLabel,
                  style: tema.textTheme.bodySmall
                      ?.copyWith(color: context.gc.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  textoEra.titulo,
                  style: tema.textTheme.titleLarge?.copyWith(
                    color: context.gc.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                CycleTagChips(tags: textoEra.tags),
                const SizedBox(height: 20),
                Center(
                  child: EraProgressRing(
                    eraProgress: era.progresso(agora),
                    phaseStart: _fracao(era, fase.inicio),
                    phaseEnd: _fracao(era, fase.fim),
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatarMesAno(context, era.inicio),
                          style: tema.textTheme.titleMedium?.copyWith(
                            color: context.gc.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formatarMesAno(context, era.fim),
                          style: tema.textTheme.titleMedium?.copyWith(
                            color: context.gc.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.cyclesEraLength(
                            formatarDuracao(l10n, era.anosCompletos),
                          ),
                          textAlign: TextAlign.center,
                          style: tema.textTheme.bodySmall
                              ?.copyWith(color: context.gc.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          MagicalCard.hero(
            accent: context.gc.lilac,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => EraReadingPage.fase(era: era, fase: fase),
            )),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.cyclesCurrentPhaseLabel,
                  style: tema.textTheme.bodySmall
                      ?.copyWith(color: context.gc.onPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  textoFase.titulo,
                  style: tema.textTheme.titleMedium?.copyWith(
                    color: context.gc.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                CycleTagChips(tags: textoFase.tags, onAccent: true),
                const SizedBox(height: 12),
                Text(
                  '${l10n.cyclesPeriodRange(
                    formatarMesAno(context, fase.inicio),
                    formatarMesAno(context, fase.fim),
                  )}  ·  ${formatarIntervalo(l10n, fase.inicio, fase.fim)}',
                  style: tema.textTheme.bodySmall
                      ?.copyWith(color: context.gc.onPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// Onde [quando] cai dentro da Era, de 0 a 1 — o anel desenha a fatia da
  /// Fase a partir disto.
  static double _fracao(Era era, DateTime quando) {
    final total = era.fim.difference(era.inicio).inMilliseconds;
    if (total <= 0) return 0;
    final andado = quando.difference(era.inicio).inMilliseconds;
    return (andado / total).clamp(0.0, 1.0);
  }
}

/// Passado ou futuro, em lista.
class _ListaDeEras extends StatelessWidget {
  const _ListaDeEras({
    required this.eras,
    required this.agora,
    required this.passado,
    required this.liberado,
    required this.vazio,
  });

  final List<Era> eras;
  final DateTime agora;
  final bool passado;
  final bool liberado;
  final String vazio;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (eras.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            vazio,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: context.gc.textSecondary),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: StaggeredEntrance(
        children: [
          for (final era in eras)
            EraListCard(
              era: era,
              locked: !liberado,
              distancia: passado
                  ? l10n.cyclesEndedAgo(_distancia(l10n, era.fim, agora))
                  : l10n.cyclesStartsIn(_distancia(l10n, agora, era.inicio)),
              onTap: () {
                if (!liberado) {
                  showPremiumUpgradePaywall(context);
                  return;
                }
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => EraReadingPage.era(era: era),
                ));
              },
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  static String _distancia(AppLocalizations l10n, DateTime de, DateTime ate) =>
      formatarDuracao(l10n, duracaoParaAnos(ate.difference(de)));
}
