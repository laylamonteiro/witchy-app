import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/i18n/tratamento_do_contexto.dart';
import '../../../../core/navigation/grimoire_route.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/theme/grimoire_motion.dart';
import '../../../../core/providers/mascot_provider.dart';
import '../../../../core/widgets/magical_progress.dart';
import '../../../../core/widgets/starfield_background.dart';
import '../../../journeys/presentation/pages/magical_progress_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../learning/presentation/providers/learning_provider.dart';
import '../providers/daily_checkin_provider.dart';

/// Topo do "Seu Dia": saudação pelo nome + sequência de dias + anel de nível.
///
/// É o espelho de progresso da Bruxa — fica acima da dobra de propósito: ver
/// a sequência crescer (e não querer perdê-la) é o que traz de volta amanhã.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  String _greeting(AppLocalizations l10n, String name) {
    final hour = DateTime.now().hour;
    if (hour < 5) return l10n.yourDayGreetingNight(name);
    if (hour < 12) return l10n.yourDayGreetingMorning(name);
    if (hour < 18) return l10n.yourDayGreetingAfternoon(name);
    return l10n.yourDayGreetingEvening(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.watch<AuthProvider>().currentUser;
    final checkin = context.watch<DailyCheckinProvider>();
    final learning = context.watch<LearningProvider>();

    // Só o PRIMEIRO nome: "Boa noite, Layla" é caloroso; o nome completo
    // soa formulário. O perfil continua guardando o nome inteiro.
    final displayName = user.displayName?.trim();
    final name = (displayName != null && displayName.isNotEmpty)
        ? displayName.split(RegExp(r'\s+')).first
        : context.vocativo;

    final locale = Localizations.localeOf(context).toString();
    final dateText = DateFormat.yMMMMEEEEd(locale).format(DateTime.now());
    final level = learning.level;

    return StarfieldBackground(
      starCount: 18,
      intensity: 0.5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 16, 6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(l10n, name),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.textSecondary,
                        ),
                  ),
                  if (checkin.isLoaded && checkin.streak > 0) ...[
                    const SizedBox(height: 8),
                    _StreakPill(streak: checkin.streak),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Anel do nível — toque leva à Evolução Mágica, direto na aba
            // de Jornadas, onde o nível e a escada de títulos vivem.
            Semantics(
              label: '${level.title} · ${learning.xp} XP',
              button: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => Navigator.of(context).push(
                  GrimoireRoute(builder: (_) => const MagicalProgressPage()),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _AnelDeNivel(
                    level: level,
                    progresso: learning.levelProgress,
                    carregado: learning.isLoaded,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Selo da sequência de dias.
///
/// O número sobe com um pulso na chama — e SÓ quando a sequência cresce com
/// o selo em cena. Abrir o app com a sequência já alta assenta em silêncio:
/// festa por reconstrução não é festa, é ruído.
///
/// Nos marcos (7, 21 e 30 dias) o pulso ganha um brilho dourado mais longo:
/// conquista tem cor de ouro no Grimório.
///
/// Toque abre as Estatísticas Mágicas, onde a sequência vive em detalhe.
class _StreakPill extends StatefulWidget {
  final int streak;

  const _StreakPill({required this.streak});

  /// Dias que valem um brilho a mais.
  static const Set<int> marcos = {7, 21, 30};

  @override
  State<_StreakPill> createState() => _StreakPillState();
}

class _StreakPillState extends State<_StreakPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulso = AnimationController(
    vsync: this,
    duration: GrimoireMotion.state,
  );

  /// Marco em curso: o brilho dourado dura mais que o pulso de todo dia.
  bool _marco = false;

  @override
  void didUpdateWidget(covariant _StreakPill old) {
    super.didUpdateWidget(old);
    // Só o dia GANHO comemora: um degrau de exatamente um, que é o que a
    // virada do dia registra. Queda, reconstrução e o SALTO que o sync traz
    // da nuvem (5 → 21 numa reinstalação) são número que chegou, não
    // conquista de agora.
    if (widget.streak != old.streak + 1) return;
    if (GrimoireMotion.reduced(context)) return;
    _marco = _StreakPill.marcos.contains(widget.streak);
    _pulso.duration =
        _marco ? GrimoireMotion.celebration : GrimoireMotion.state;
    _pulso.forward(from: 0);

    // Marco de sequência (7, 21, 30 dias) é raro o bastante para o Salem
    // comemorar junto. Pós-frame para não notificar durante o didUpdateWidget;
    // o mascote flutua sobre esta aba, então a reação é vista.
    if (_marco) {
      final mascot = context.read<MascotProvider>();
      WidgetsBinding.instance.addPostFrameCallback((_) => mascot.react());
    }
  }

  @override
  void dispose() {
    _pulso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = context.gc.starYellow;
    final reduzido = GrimoireMotion.reduced(context);
    final duracao = reduzido ? Duration.zero : GrimoireMotion.state;

    final selo = InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.of(context).push(
        GrimoireRoute(builder: (_) => const MagicalProgressPage(initialTab: 1)),
      ),
      child: AnimatedBuilder(
        animation: _pulso,
        builder: (context, child) {
          // Meia-senoide: cresce e volta ao lugar dentro da própria janela.
          final onda = math.sin(math.pi * _pulso.value);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.55)),
              boxShadow: _marco && onda > 0.01
                  ? [
                      BoxShadow(
                        color: context.gc.gold.withValues(alpha: 0.45 * onda),
                        blurRadius: 16,
                      ),
                    ]
                  : const [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  // Chave para o teste medir o pulso sem confundi-lo com a
                  // escala de entrada, que embrulha o selo inteiro.
                  key: const ValueKey('selo_chama'),
                  scale: 1 + 0.18 * onda,
                  child: const Text('🔥', style: TextStyle(fontSize: 14)),
                ),
                const SizedBox(width: 6),
                child!,
              ],
            ),
          );
        },
        child: AnimatedSwitcher(
          duration: duracao,
          child: Text(
            l10n.yourDayStreakDays(widget.streak),
            key: ValueKey(widget.streak),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );

    return Semantics(
      label: l10n.yourDayStreakDays(widget.streak),
      button: true,
      child: reduzido
          ? selo
          : TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.9, end: 1),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: selo,
            ),
    );
  }
}

/// Anel do nível.
///
/// O anel acompanha o XP o tempo todo; o que se comemora é o DEGRAU: quando
/// o nível SOBE com a tela em cena, o emoji troca com um respiro e um halo
/// dourado curto passa por trás. Montar já num nível alto não celebra nada.
class _AnelDeNivel extends StatefulWidget {
  final LearningLevel level;
  final double progresso;

  /// O XP já veio do banco? Antes disso o anel mostra o primeiro degrau por
  /// falta de dado — e o nível real chegando seria festa de abertura.
  final bool carregado;

  const _AnelDeNivel({
    required this.level,
    required this.progresso,
    required this.carregado,
  });

  @override
  State<_AnelDeNivel> createState() => _AnelDeNivelState();
}

class _AnelDeNivelState extends State<_AnelDeNivel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _subiu = AnimationController(
    vsync: this,
    duration: GrimoireMotion.celebration,
  );

  /// Degrau já visto, guardado pelo LIMIAR DE XP e não pelo título: o título
  /// é texto de tela, reescrito quando muda o idioma ou o tratamento, sem um
  /// ponto de XP de diferença. O limiar é o que só muda quando se sobe.
  int? _degrauVisto;

  @override
  void initState() {
    super.initState();
    if (widget.carregado) _degrauVisto = widget.level.minXp;
  }

  @override
  void didUpdateWidget(covariant _AnelDeNivel old) {
    super.didUpdateWidget(old);
    if (!widget.carregado) return;
    final degrau = widget.level.minXp;
    // Primeiro degrau assentado: é o ponto de partida, não uma subida.
    if (_degrauVisto == null || degrau <= _degrauVisto!) {
      _degrauVisto = degrau;
      return;
    }
    _degrauVisto = degrau;
    if (GrimoireMotion.reduced(context)) return;
    _subiu.forward(from: 0);
  }

  @override
  void dispose() {
    _subiu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ouro = context.gc.gold;
    final duracao = GrimoireMotion.reduced(context)
        ? Duration.zero
        : GrimoireMotion.state;

    return AnimatedBuilder(
      animation: _subiu,
      builder: (context, child) {
        final onda = math.sin(math.pi * _subiu.value);
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: onda > 0.01
                ? [
                    BoxShadow(
                      color: ouro.withValues(alpha: 0.5 * onda),
                      blurRadius: 18,
                    ),
                  ]
                : const [],
          ),
          child: child,
        );
      },
      child: MagicalProgressRing(
        value: widget.progresso,
        size: 48,
        strokeWidth: 4,
        center: AnimatedSwitcher(
          duration: duracao,
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Text(
            widget.level.emoji,
            key: ValueKey(widget.level.minXp),
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
