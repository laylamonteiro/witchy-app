import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../../core/i18n/tratamento_do_contexto.dart';
import 'package:flutter/services.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/navigation/app_deep_link.dart';
import '../../../../core/navigation/grimoire_route.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../core/widgets/estrela_de_quatro_pontas.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../diary/data/models/gratitude_model.dart';
import '../../../diary/presentation/providers/dream_provider.dart';
import '../../../diary/presentation/providers/gratitude_provider.dart';
import '../../../divination/presentation/pages/oracle_cards_page.dart';
import '../../../divination/presentation/pages/pendulum_page.dart';
import '../../../encyclopedia/presentation/widgets/nature_guide_launcher.dart';
import '../../../learning/presentation/providers/learning_provider.dart';
import '../../../palmistry/presentation/pages/palmistry_page.dart';
import '../../../runes/presentation/pages/rune_reading_page.dart';
import '../../../tarot/presentation/pages/tarot_page.dart';
import '../providers/daily_checkin_provider.dart';

/// Os ritos de hoje: três práticas curtas que fecham o dia da Bruxa.
///
/// A regra é atrito baixo — a gratidão se escreve aqui mesmo, o sonho vai
/// para o diário onírico e o terceiro slot REVEZA a cada dia entre as
/// ferramentas (tarot, oráculo, quiromancia, runas, identificação na
/// natureza, pêndulo), levando a pessoa a conhecer outras partes do app.
/// Concluir os três mantém a sequência viva, que é o que traz de volta
/// amanhã.
///
/// Um rito só fica marcado quando a ação ACONTECEU: gratidão e sonho são
/// lidos dos registros do dia (se existe a entrada, está feito) e o rito
/// exploratório é marcado pela própria ferramenta ao concluir a ação.
/// Tocar no rito apenas leva até lá.
///
/// O feedback (pop do check, selo do dia, haptic) dispara apenas quando um
/// rito VIRA feito com o card em cena — nunca porque a tela reconstruiu ou
/// porque o dia já veio 3/3 do banco.
class DailyRitesCard extends StatefulWidget {
  const DailyRitesCard({super.key});

  @override
  State<DailyRitesCard> createState() => _DailyRitesCardState();
}

class _DailyRitesCardState extends State<DailyRitesCard>
    with SingleTickerProviderStateMixin {
  /// Selamento do dia: dirige o respiro do selo (1.12 → 1) e as estrelinhas
  /// que escapam. Fica em 0 no dia aberto e em 1 no dia selado; só ANIMA na
  /// transição observada 2/3 → 3/3.
  late final AnimationController _seal = AnimationController(
    vsync: this,
    duration: GrimoireMotion.celebration,
  );

  // Último estado visto de cada rito. null = ainda não houve build carregado,
  // então nada "acabou de acontecer" — cold start com o dia já 3/3 assenta o
  // estado final em silêncio.
  bool? _prevGratitude;
  bool? _prevDream;
  bool? _prevFeatured;
  bool? _prevComplete;

  // Na conta local o id nunca muda, então GratitudeProvider/DreamProvider
  // podem responder lista vazia sem NUNCA ter lido o banco. Os registros
  // que chegam quando a pessoa abre o Diário são passado assentando, não
  // rito feito agora — até um diário fechar seu primeiro ciclo de load, as
  // transições dele são silenciadas. A gratidão escrita AQUI no card é a
  // exceção (_gratidaoDaqui): ela merece a celebração mesmo no primeiro load.
  bool _gratidoesAssentando = false;
  bool _sonhosAssentando = false;
  bool _gratidoesLidas = false;
  bool _sonhosLidos = false;
  bool _gratidaoDaqui = false;

  @override
  void dispose() {
    _seal.dispose();
    super.dispose();
  }

  /// O card está de fato diante da pessoa? Fora da aba ativa o HomePage
  /// desliga o TickerMode desta subárvore, e embaixo de outra rota a página
  /// não é a atual — rebuilds acontecem do mesmo jeito (sync, completeRite
  /// das ferramentas), mas haptic fora de cena é só ruído (e dobraria com o
  /// da ferramenta) e a celebração se perderia sem ninguém ver. Lido no
  /// build: a consulta ao TickerMode registra dependência, então voltar à
  /// aba reconstrói o card e a transição pendente é celebrada aí.
  static bool _lerEmCena(BuildContext context) {
    final route = ModalRoute.of(context);
    return TickerMode.of(context) && (route?.isCurrent ?? true);
  }

  /// Emoji, rótulo e ação do rito exploratório do dia (emojis do
  /// ShortcutRegistry, para a identidade se manter).
  static (String, String, VoidCallback) _featuredSpec(
    BuildContext context,
    AppLocalizations l10n,
    String riteId,
  ) {
    switch (riteId) {
      case DailyRites.oracle:
        return ('🃏', l10n.yourDayRiteOracle,
            () => _push(context, const OracleCardsPage()));
      case DailyRites.palmistry:
        return ('🖐️', l10n.yourDayRitePalm,
            () => _push(context, const PalmistryPage()));
      case DailyRites.runes:
        return (' ᚱ ', l10n.yourDayRiteRunes,
            () => _push(context, const RuneReadingPage()));
      case DailyRites.natureIdentify:
        return ('🍃', l10n.yourDayRiteNature, () => openNatureGuide(context));
      case DailyRites.pendulum:
        return (' ⟟ ', l10n.yourDayRitePendulum,
            () => _push(context, const PendulumPage()));
      case DailyRites.divination:
      default:
        return ('🎴', l10n.yourDayRiteTarot,
            () => _push(context, const TarotPage()));
    }
  }

  static void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(GrimoireRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final checkin = context.watch<DailyCheckinProvider>();
    if (!checkin.isLoaded) return const SizedBox.shrink();

    // Provas de que a ação aconteceu de verdade.
    final gratidoes = context.watch<GratitudeProvider>();
    final sonhos = context.watch<DreamProvider>();
    final gratitudeDone = gratidoes.gratitudes.any((g) => _isToday(g.createdAt));
    final dreamDone = sonhos.dreams.any((d) => _isToday(d.createdAt));
    final featuredId = DailyRites.featuredToday();
    final featured = _featuredSpec(context, l10n, featuredId);
    final featuredDone = checkin.isRiteDone(featuredId);

    // Um dos seis ritos do revezamento é exclusivo do Premium (a
    // Quiromancia), então há dias em que quem é Free não fecha o dia. Isso
    // é decisão de produto e continua valendo — o que muda aqui é só como
    // ele APARECE: um rito que a pessoa não pode fazer, exibido igual aos
    // outros, lê-se como tarefa falhada. Com o selo, lê-se como convite.
    //
    // Nada de contagem: o rito continua entrando no `total` de três. Mexer
    // nisso mudaria o selo do dia e o bônus de XP, que é outra decisão.
    final featuredPremium = featuredId == DailyRites.palmistry &&
        !context.watch<AuthProvider>().isPremiumEffective;

    const total = 3;
    final done =
        [gratitudeDone, dreamDone, featuredDone].where((e) => e).length;

    // Sela o dia quando os três caem. Gratidão e sonho vêm dos registros
    // do diário, então o fechamento só pode ser detectado aqui — o selo
    // gravado é o que vale o bônus de XP (completeRite é idempotente).
    if (done == total && !checkin.isRiteDone(DailyRites.dayComplete)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        checkin.completeRite(DailyRites.dayComplete);
      });
    }
    final complete = done == total;

    // Transições observadas: feedback só quando algo VIRA feito agora.
    //
    // Enquanto um dos diários está no load, a contabilidade fica desarmada:
    // a lista velha/vazia não decide nada. E o PRIMEIRO ciclo de load de
    // cada diário é passado assentando (o dia já feito chegando do banco não
    // vira celebração de abertura).
    final gratLoading = gratidoes.isLoading;
    final dreamLoading = sonhos.isLoading;
    if (gratLoading && !_gratidoesLidas) _gratidoesAssentando = true;
    if (dreamLoading && !_sonhosLidos) _sonhosAssentando = true;
    final diariosCarregando = gratLoading || dreamLoading;

    if (!diariosCarregando) {
      // A gratidão escrita no próprio card celebra mesmo sendo o primeiro
      // load do convidado; o resto do primeiro load assenta calado.
      final assentando =
          (_gratidoesAssentando && !_gratidaoDaqui) || _sonhosAssentando;
      // Ciclo de load fechado → diário confiável daqui em diante.
      if (_gratidoesAssentando) {
        _gratidoesLidas = true;
        _gratidoesAssentando = false;
      }
      if (_sonhosAssentando) {
        _sonhosLidos = true;
        _sonhosAssentando = false;
      }
      // A marca da gratidão-do-card cumpriu o papel assim que o diário virou
      // confiável (ou se já era) — limpa para não vazar.
      if (_gratidoesLidas) _gratidaoDaqui = false;

      final reduced = GrimoireMotion.reduced(context);
      final emCena = _lerEmCena(context);
      final firstSight = _prevComplete == null;
      final silencioso = firstSight || assentando;
      final sealedNow = _prevComplete == false && complete;
      final riteNow = (_prevGratitude == false && gratitudeDone) ||
          (_prevDream == false && dreamDone) ||
          (_prevFeatured == false && featuredDone);

      // Fora de cena a transição fica PENDENTE (os prevs não avançam) e é
      // celebrada quando a aba volta. Silencioso (primeiro build / primeiro
      // load) consome os prevs sem festa. As duas coisas só avançam os prevs
      // quando há o que registrar.
      if (silencioso || emCena) {
        _prevGratitude = gratitudeDone;
        _prevDream = dreamDone;
        _prevFeatured = featuredDone;
        _prevComplete = complete;
      }

      if (silencioso) {
        final alvo = complete ? 1.0 : 0.0;
        if (firstSight) {
          // Sem listeners ainda: seguro no próprio build.
          _seal.value = alvo;
        } else if (_seal.value != alvo) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _seal.value = alvo;
          });
        }
      } else if (sealedNow && emCena) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          HapticFeedback.lightImpact();
          if (reduced) {
            _seal.value = 1.0;
          } else {
            _seal.forward(from: 0);
          }
        });
      } else if (riteNow && emCena) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) HapticFeedback.selectionClick();
        });
      } else if (!complete && _seal.value > 0) {
        // Virada de meia-noite: o dia reabriu, o selo sai sem cerimônia
        // (silencioso e sem gate de cena — precisa acompanhar o dia).
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _seal.value = 0.0;
        });
      }
    }

    final accent = complete ? context.gc.mint : context.gc.lilac;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // O selo do dia: o check entra com um respiro (1.12 → 1) e solta
            // estrelinhas que somem. Montado já completo, fica parado no
            // estado final (controller em 1).
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _seal,
                  builder: (context, child) {
                    if (!complete) return child!;
                    final t = GrimoireMotion.emphasis.transform(_seal.value);
                    return Transform.scale(
                        scale: 1.12 - 0.12 * t, child: child);
                  },
                  child: Icon(
                    complete
                        ? Icons.check_circle
                        : Icons.brightness_2_outlined,
                    color: accent,
                  ),
                ),
                if (complete)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ExcludeSemantics(
                        child: AnimatedBuilder(
                          animation: _seal,
                          builder: (context, _) => CustomPaint(
                            painter: _SealStarsPainter(
                              t: _seal.value,
                              color: context.gc.starYellow,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.yourDayRitesTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Text(
              l10n.yourDayRitesProgress(done, total),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _RiteTile(
          done: gratitudeDone,
          emoji: '🙏',
          label: l10n.yourDayRiteGratitude,
          onStart: () => _writeGratitude(context),
        ),
        _RiteTile(
          done: dreamDone,
          emoji: '🌙',
          label: l10n.yourDayRiteDream,
          // Só leva até lá: quem marca é o sonho registrado.
          onStart: () =>
              DeepLinkService.instance.dispatch(AppDeepLink.dreamsDiary),
        ),
        // Terceiro slot rotativo: quem marca é a ferramenta, lá dentro.
        _RiteTile(
          done: featuredDone,
          emoji: featured.$1,
          label: featured.$2,
          onStart: featured.$3,
          premium: featuredPremium,
        ),
        const SizedBox(height: 6),
        // Só a celebração do dia completo: a linha de apoio prometia que
        // "cada rito alimenta suas Jornadas Mágicas", mas nem toda ação
        // daqui gera XP — melhor não prometer do que prometer errado.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: complete
              ? Row(
                  key: const ValueKey('complete'),
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.yourDayRitesComplete(
                            LearningProvider.xpPerFullDay),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.gc.mint,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(key: ValueKey('hint')),
        ),
      ],
    );

    // Dia selado vira o card de acento mint — o "estado mint" é permanente,
    // só a entrada dele é que é celebrada.
    return complete
        ? MagicalCard.accent(accent: context.gc.mint, child: content)
        : MagicalCard(child: content);
  }

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Gratidão em um gesto: uma linha, salvar, pronto — e o registro vai para
  /// o Diário de Gratidão como qualquer outro.
  ///
  /// O haptic não fica aqui: quem sente a mudança é o card, quando o rito
  /// VIRA feito no rebuild (um só clique, mesmo caminho de qualquer rito).
  Future<void> _writeGratitude(BuildContext context) async {
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.gc.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _GratitudeSheet(),
    );

    if (text == null || text.isEmpty || !context.mounted) return;

    // A gratidão nasceu de um toque no card: mesmo que este seja o primeiro
    // load do diário (convidado em cold start), ela merece a celebração.
    _gratidaoDaqui = true;
    await context.read<GratitudeProvider>().addGratitude(
          GratitudeModel(
            title: text.length > 40 ? '${text.substring(0, 40)}…' : text,
            content: text,
            tags: const [],
          ),
        );
  }
}

/// As estrelinhas que escapam do selo quando o dia fecha: três pontos de
/// starYellow subindo e sumindo, uma vez só. Fora da janela (t = 0 ou 1)
/// não pinta nada — custo zero em repouso.
class _SealStarsPainter extends CustomPainter {
  final double t;
  final Color color;

  const _SealStarsPainter({required this.t, required this.color});

  // Direções fixas (nada de aleatório): leque para cima.
  static const List<Offset> _direcoes = [
    Offset(-10, -16),
    Offset(2, -20),
    Offset(12, -13),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final center = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < _direcoes.length; i++) {
      // Cada estrela vive num terço deslocado da janela da celebração.
      final ti = ((t - i * 0.12) / 0.7).clamp(0.0, 1.0);
      if (ti <= 0 || ti >= 1) continue;
      final eased = Curves.easeOut.transform(ti);
      final pos = center + _direcoes[i] * eased;
      final paint = Paint()
        ..color = color.withValues(alpha: (1 - ti) * 0.9)
        ..style = PaintingStyle.fill;
      canvas.drawPath(
        estrelaDeQuatroPontas(pos, 2.6 * (1 - ti * 0.4), razaoInterna: 0.35),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SealStarsPainter old) =>
      old.t != t || old.color != color;
}

/// Folha de gratidão rápida.
///
/// É um StatefulWidget de propósito: o TextEditingController morre junto com
/// ela, e todo `Theme.of`/`Provider.of` usa o contexto DA FOLHA. Fazer isso
/// pelo contexto de fora quebrava a árvore quando a folha fechava
/// (`_dependents.isEmpty`).
class _GratitudeSheet extends StatefulWidget {
  const _GratitudeSheet();

  @override
  State<_GratitudeSheet> createState() => _GratitudeSheetState();
}

class _GratitudeSheetState extends State<_GratitudeSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.yourDayRiteGratitude,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 3,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: context.porTratamento(
                feminine: l10n.yourDayGratitudeHintFeminine,
                masculine: l10n.yourDayGratitudeHintMasculine,
                neutral: l10n.yourDayGratitudeHintNeutral,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.gc.lilac,
                foregroundColor: context.gc.onPrimary,
              ),
              onPressed: _save,
              child: Text(l10n.commonSave),
            ),
          ),
        ],
      ),
    );
  }
}

/// Uma linha de rito: emoji, rótulo e o círculo que marca a conclusão.
///
/// O pop do check é do próprio tile: `didUpdateWidget` vê o `done` virar
/// true e corre a animação uma vez. Montado já feito, nasce no estado final
/// (controller em 1) — reconstrução nunca re-anima.
class _RiteTile extends StatefulWidget {
  final bool done;
  final String emoji;
  final String label;
  final VoidCallback onStart;

  /// O rito existe, mas está atrás do Premium: em vez da setinha de "vá
  /// fazer", um selo de "isto se abre". O toque continua levando à
  /// ferramenta, que mostra o que ela entrega antes de pedir qualquer coisa.
  final bool premium;

  const _RiteTile({
    required this.done,
    required this.emoji,
    required this.label,
    required this.onStart,
    this.premium = false,
  });

  @override
  State<_RiteTile> createState() => _RiteTileState();
}

class _RiteTileState extends State<_RiteTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: GrimoireMotion.state,
    value: widget.done ? 1.0 : 0.0,
  );

  /// Campo (e não recriada por build): a curva do check é estável e é
  /// liberada junto do controller, como manda o padrão da casa.
  late final CurvedAnimation _popCurva = CurvedAnimation(
    parent: _pop,
    curve: GrimoireMotion.emphasis,
  );

  @override
  void didUpdateWidget(covariant _RiteTile old) {
    super.didUpdateWidget(old);
    if (old.done == widget.done) return;
    if (!widget.done) {
      // Dia novo: o círculo esvazia sem cerimônia.
      _pop.value = 0.0;
    } else if (GrimoireMotion.reduced(context)) {
      _pop.value = 1.0;
    } else {
      _pop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _popCurva.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: widget.done ? null : widget.onStart,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pop,
              builder: (context, child) {
                // O círculo respira de leve no meio do pop; o check entra
                // com um respiro além do alvo (emphasis) e assenta em 1.
                final circulo = 1 + 0.10 * math.sin(math.pi * _pop.value);
                return Transform.scale(scale: circulo, child: child);
              },
              child: AnimatedContainer(
                duration: GrimoireMotion.state,
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.done
                      ? context.gc.mint.withValues(alpha: 0.25)
                      : Colors.transparent,
                  border: Border.all(
                    color: widget.done
                        ? context.gc.mint
                        : context.gc.surfaceBorder,
                    width: 1.5,
                  ),
                ),
                child: widget.done
                    ? ScaleTransition(
                        scale: _popCurva,
                        child:
                            Icon(Icons.check, size: 16, color: context.gc.mint),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Text(widget.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: widget.done
                          ? context.gc.textSecondary
                          : context.gc.textPrimary,
                      decoration:
                          widget.done ? TextDecoration.lineThrough : null,
                      decorationColor: context.gc.textSecondary,
                    ),
              ),
            ),
            if (!widget.done && widget.premium)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, size: 14, color: context.gc.gold),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context).conviteSeloPremium,
                    style: TextStyle(
                      color: context.gc.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            else if (!widget.done)
              Icon(Icons.chevron_right, size: 18, color: context.gc.lilac),
          ],
        ),
      ),
    );
  }
}
