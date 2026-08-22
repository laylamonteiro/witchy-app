import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/highlighted_text.dart';
import '../../../../core/widgets/paged_reading.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/data/models/feature_access.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../data/data_sources/life_eras_content.dart';
import '../../domain/life_timeline.dart';
import '../widgets/cycle_labels.dart';
import '../widgets/era_card.dart';

/// A leitura completa de uma Era ou de uma Fase.
///
/// Em páginas que deslizam, e não numa rolagem única: cada página carrega uma
/// ideia, e os pontinhos mostram quanto ainda falta. Texto longo em coluna
/// única cansa no celular e esconde o fim.
class EraReadingPage extends StatelessWidget {
  const EraReadingPage.era({super.key, required this.era}) : fase = null;

  const EraReadingPage.fase({
    super.key,
    required this.era,
    required Fase this.fase,
  });

  final Era era;

  /// Quando presente, a leitura é da Fase e a Era entra como pano de fundo.
  final Fase? fase;

  bool get _ehFase => fase != null;

  /// Qual feature governa ESTA leitura.
  ///
  /// A Era e a Fase que estão acontecendo agora são a isca: abertas para todo
  /// mundo. Passado e futuro são Premium.
  ///
  /// Decidido a partir da janela, e não recebido de quem abre a tela: a lista
  /// de eras e os cartões de "Agora" chegam aqui por caminhos diferentes, e um
  /// parâmetro esquecido num deles voltaria a trancar a isca em silêncio.
  @visibleForTesting
  static AppFeature featureDaLeitura({
    required Era era,
    required Fase? fase,
    required DateTime agora,
  }) {
    // Em UTC, como a linha do tempo guarda.
    final quando = agora.toUtc();
    final ehAgora = fase != null ? fase.contem(quando) : era.contem(quando);
    return ehAgora ? AppFeature.lifeErasNow : AppFeature.lifeErasFull;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textoEra = LifeErasContent.daEra(era.regente);
    final f = fase;
    final textoFase = f == null ? null : LifeErasContent.daFase(f.regente);

    final titulo = textoFase?.titulo ?? textoEra.titulo;
    final tags = textoFase?.tags ?? textoEra.tags;
    final inicio = f?.inicio ?? era.inicio;
    final fim = f?.fim ?? era.fim;

    // A tela pedia `lifeErasFull` para QUALQUER leitura, inclusive a atual.
    // O resultado era o pior arranjo possível: os dois cartões de "Agora" não
    // tinham cadeado e pareciam abertos, a pessoa tocava na isca e batia numa
    // tela travada — enquanto as listas de passado e futuro, essas sim,
    // mostravam cadeado. A única coisa que ela podia ver de graça era a que
    // parecia proibida.
    final acesso = context.watch<AuthProvider>().checkFeatureAccess(
          featureDaLeitura(era: era, fase: fase, agora: DateTime.now()),
        );

    return Scaffold(
      appBar: AppBar(title: ResponsiveAppBarTitle(titulo)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _ehFase
                        ? l10n.cyclesPhaseWithin(textoEra.titulo)
                        : l10n.cyclesRuledBy(era.regente.nome(l10n)),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 10),
                  CycleTagChips(tags: tags),
                  const SizedBox(height: 10),
                  Text(
                    '${l10n.cyclesPeriodRange(
                      formatarMesAno(context, inicio),
                      formatarMesAno(context, fim),
                    )}  ·  ${formatarIntervalo(l10n, inicio, fim)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Divider(color: context.gc.surfaceBorder),
                ],
              ),
            ),
            Expanded(
              child: acesso.hasFullAccess
                  ? PagedReading(pages: _paginas(context, l10n))
                  : const _LeituraBloqueada(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _paginas(BuildContext context, AppLocalizations l10n) {
    final textoEra = LifeErasContent.daEra(era.regente);
    final f = fase;

    if (f != null) {
      final textoFase = LifeErasContent.daFase(f.regente);
      return [
        _Trecho(titulo: l10n.cyclesReadingBodyTitle, corpo: textoFase.sabor),
        _Trecho(
          titulo: l10n.cyclesPhaseWithin(textoEra.titulo),
          corpo: textoEra.convite,
        ),
      ];
    }

    return [
      _Trecho(titulo: l10n.cyclesReadingBodyTitle, corpo: textoEra.corpo),
      _Trecho(titulo: l10n.cyclesReadingShadowTitle, corpo: textoEra.sombra),
      _Trecho(titulo: l10n.cyclesReadingInviteTitle, corpo: textoEra.convite),
    ];
  }
}

class _Trecho extends StatelessWidget {
  const _Trecho({required this.titulo, required this.corpo});

  final String titulo;
  final String corpo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          titulo,
          style: tema.textTheme.titleMedium?.copyWith(
            color: context.gc.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // As expressões marcadas no conteúdo saem realçadas: dão pontos de
        // apoio para o olho e fazem a leitura parecer escrita para a pessoa.
        HighlightedText(
          corpo,
          style: tema.textTheme.bodyMedium?.copyWith(
            color: context.gc.textPrimary,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

/// Sem Premium, o cabeçalho continua visível e só a leitura fica guardada.
class _LeituraBloqueada extends StatelessWidget {
  const _LeituraBloqueada();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tema = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock, size: 40, color: context.gc.starYellow),
            const SizedBox(height: 16),
            Text(
              l10n.cyclesLockedTitle,
              textAlign: TextAlign.center,
              style: tema.textTheme.titleMedium?.copyWith(
                color: context.gc.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.cyclesLockedBody,
              textAlign: TextAlign.center,
              style: tema.textTheme.bodySmall?.copyWith(
                color: context.gc.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => showPremiumUpgradePaywall(context),
              child: Text(l10n.premiumBePremium),
            ),
          ],
        ),
      ),
    );
  }
}
