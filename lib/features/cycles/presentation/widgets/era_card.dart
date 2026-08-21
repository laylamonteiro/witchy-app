import 'package:flutter/material.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/data_sources/life_eras_content.dart';
import '../../domain/life_timeline.dart';
import 'cycle_labels.dart';

/// As três palavras-chave de uma Era ou Fase, em pílulas.
class CycleTagChips extends StatelessWidget {
  const CycleTagChips({super.key, required this.tags, this.onAccent = false});

  final List<String> tags;

  /// Em cima de fundo de acento as pílulas invertem o contraste.
  final bool onAccent;

  @override
  Widget build(BuildContext context) {
    final cor = onAccent ? context.gc.onPrimary : context.gc.lilac;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final tag in tags)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: cor.withValues(alpha: 0.55)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tag,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cor),
            ),
          ),
      ],
    );
  }
}

/// Uma Era numa lista — passado ou futuro.
///
/// Quando [locked], o título e o período continuam visíveis e só a leitura
/// fica atrás do cadeado: o gancho é justamente ver que existe linha do tempo
/// esperando.
class EraListCard extends StatelessWidget {
  const EraListCard({
    super.key,
    required this.era,
    required this.distancia,
    required this.locked,
    required this.onTap,
  });

  final Era era;

  /// "Terminou há 3 anos" ou "Começa em 5 anos", já montado.
  final String distancia;

  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final texto = LifeErasContent.daEra(era.regente);
    final tema = Theme.of(context);

    return MagicalCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  texto.titulo,
                  style: tema.textTheme.titleMedium?.copyWith(
                    color: context.gc.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                locked ? Icons.lock : Icons.arrow_outward,
                size: 18,
                color: locked ? context.gc.starYellow : context.gc.lilac,
              ),
            ],
          ),
          const SizedBox(height: 10),
          CycleTagChips(tags: texto.tags),
          const SizedBox(height: 12),
          Text(
            distancia,
            style: tema.textTheme.bodySmall?.copyWith(
              color: context.gc.pink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${l10n.cyclesPeriodRange(
              formatarMesAno(context, era.inicio),
              formatarMesAno(context, era.fim),
            )}  ·  ${l10n.cyclesEraLength(formatarDuracao(l10n, era.anosCompletos))}',
            style: tema.textTheme.bodySmall?.copyWith(
              color: context.gc.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
