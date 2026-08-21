import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/models/month_sky_event.dart';
import '../providers/month_sky_provider.dart';
import 'cycle_labels.dart';

/// A escala do meio: o que o céu faz neste mês.
///
/// Entre a Leitura do Ciclo (a semana, a lunação) e as Eras (120 anos),
/// faltava o mês. Tudo aqui é calculado no aparelho, com data exata — nada
/// de IA e nada de conteúdo por signo: são fatos do céu, apresentados.
class MonthSkyCard extends StatelessWidget {
  const MonthSkyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ceu = context.watch<MonthSkyProvider>();
    final tema = Theme.of(context);

    // Informação a mais nunca justifica uma tela quebrada: se o efeméride
    // falhar, o bloco simplesmente não aparece.
    if (ceu.falhou) return const SizedBox.shrink();

    final eventos = ceu.eventos;

    return MagicalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.cyclesMonthTitle,
            style: tema.textTheme.titleLarge?.copyWith(
              color: context.gc.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            l10n.cyclesMonthSubtitle,
            style: tema.textTheme.bodySmall
                ?.copyWith(color: context.gc.textSecondary),
          ),
          const SizedBox(height: 14),
          if (eventos == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (eventos.isEmpty)
            Text(
              l10n.cyclesMonthEmpty,
              style: tema.textTheme.bodyMedium
                  ?.copyWith(color: context.gc.textSecondary),
            )
          else
            for (final evento in eventos) _LinhaDoEvento(evento: evento),
        ],
      ),
    );
  }
}

class _LinhaDoEvento extends StatelessWidget {
  const _LinhaDoEvento({required this.evento});

  final MonthSkyEvent evento;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tema = Theme.of(context);
    final local = evento.instanteUtc.toLocal();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // O dia, em coluna própria: a pessoa varre as datas primeiro.
          SizedBox(
            width: 42,
            child: Column(
              children: [
                Text(
                  '${local.day}',
                  style: tema.textTheme.titleMedium?.copyWith(
                    color: context.gc.lilac,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  formatarMesCurto(context, local),
                  style: tema.textTheme.bodySmall
                      ?.copyWith(color: context.gc.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titulo(l10n),
                  style: tema.textTheme.bodyMedium?.copyWith(
                    color: context.gc.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _pista(l10n),
                  style: tema.textTheme.bodySmall
                      ?.copyWith(color: context.gc.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _titulo(AppLocalizations l10n) {
    final signo = evento.signo?.displayName ?? '';
    final planeta = evento.planeta?.displayName ?? '';
    return switch (evento.kind) {
      MonthSkyKind.newMoon => l10n.cyclesMonthNewMoon(signo),
      MonthSkyKind.fullMoon => l10n.cyclesMonthFullMoon(signo),
      MonthSkyKind.sunIngress => l10n.cyclesMonthSunIngress(signo),
      MonthSkyKind.retrogradeStart => l10n.cyclesMonthRetroStart(planeta),
      MonthSkyKind.retrogradeEnd => l10n.cyclesMonthRetroEnd(planeta),
    };
  }

  String _pista(AppLocalizations l10n) => switch (evento.kind) {
        MonthSkyKind.newMoon => l10n.cyclesMonthNewMoonHint,
        MonthSkyKind.fullMoon => l10n.cyclesMonthFullMoonHint,
        MonthSkyKind.sunIngress => l10n.cyclesMonthIngressHint,
        MonthSkyKind.retrogradeStart => l10n.cyclesMonthRetroStartHint,
        MonthSkyKind.retrogradeEnd => l10n.cyclesMonthRetroEndHint,
      };
}
