import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/your_day/data/daily_checkin_repository.dart';
import '../../features/your_day/presentation/providers/daily_checkin_provider.dart';
import 'convite_de_avaliacao.dart';
import 'folha_de_avaliacao.dart';
import 'regra_do_convite.dart';

/// Fica de olho para o convite de avaliação aparecer numa boa hora.
///
/// Vive no shell, envolvendo as quatro abas, porque o convite não é de uma
/// tela: ele pode acontecer depois de tirar cartas, de consultar o pêndulo, de
/// identificar uma planta ou de selar o dia. O que essas coisas têm em comum é
/// serem o FIM de alguma coisa — e é aí que interromper não atrapalha.
///
/// Nunca no meio de um gesto. O vigia espera um rito ser CONCLUÍDO, que é
/// quando a pessoa já terminou o que veio fazer e está lendo o resultado. Um
/// pop-up que cai no meio de uma escolha é a maneira mais rápida de ganhar uma
/// avaliação de uma estrela.
///
/// Quem decide se é hora é [podeConvidar], que é pura. Aqui fica só o gatilho.
class VigiaDoConvite extends StatefulWidget {
  const VigiaDoConvite({super.key, required this.child, this.convite});

  final Widget child;

  /// Entra de fora nos testes; em produção carrega das preferências.
  final ConviteDeAvaliacao? convite;

  @override
  State<VigiaDoConvite> createState() => _VigiaDoConviteState();
}

class _VigiaDoConviteState extends State<VigiaDoConvite> {
  ConviteDeAvaliacao? _convite;
  DailyCheckinProvider? _checkin;

  /// Quantos ritos estavam feitos na última vez que olhamos. O convite só
  /// pensa em aparecer quando esse número SOBE — o provider avisa por muitos
  /// motivos (carregar, virar o dia, trocar de conta), e nenhum desses é um
  /// bom momento.
  int _ritosVistos = 0;

  /// Uma folha por vez, e nunca duas empilhadas.
  bool _mostrando = false;

  @override
  void initState() {
    super.initState();
    _prepararConvite();
  }

  Future<void> _prepararConvite() async {
    final convite = widget.convite ?? await ConviteDeAvaliacao.carregar();
    if (!mounted) return;
    setState(() => _convite = convite);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final checkin = context.read<DailyCheckinProvider>();
    if (identical(checkin, _checkin)) return;
    _checkin?.removeListener(_aoMudarOCheckin);
    _checkin = checkin..addListener(_aoMudarOCheckin);
    _ritosVistos = checkin.ritesToday.length;
  }

  @override
  void dispose() {
    _checkin?.removeListener(_aoMudarOCheckin);
    super.dispose();
  }

  void _aoMudarOCheckin() {
    final checkin = _checkin;
    if (checkin == null) return;
    final agora = checkin.ritesToday.length;
    final subiu = agora > _ritosVistos;
    _ritosVistos = agora;
    if (subiu) _talvezConvidar();
  }

  Future<void> _talvezConvidar() async {
    final convite = _convite;
    if (convite == null || _mostrando || !mounted) return;

    final userId = context.read<AuthProvider>().currentUser.id;
    final checkin = _checkin;
    if (checkin == null) return;

    // A leitura do banco vem ANTES da decisão, e só quando a memória do
    // convite já não descartou a pessoa por outros motivos — não vale ir ao
    // disco a cada rito de quem já avaliou.
    if (convite.memoria.jaAvaliou ||
        convite.memoria.dispensas >= dispensasAteDesistir) {
      return;
    }

    int dias;
    try {
      dias = await DailyCheckinRepository().diasPraticados(userId);
    } catch (e) {
      // O convite nunca pode derrubar a tela em que apareceria.
      unawaitedLog('could not count practiced days: $e');
      return;
    }
    if (!mounted) return;

    final uso = UsoAtePagora(
      sequencia: checkin.streak,
      diasPraticados: dias,
    );
    if (!convite.devoConvidar(uso)) return;

    // Um quadro de respiro: o rito acabou de fechar, e a tela dele ainda está
    // assentando. A folha entra depois que a cena parou de se mexer.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted || _mostrando) return;

    _mostrando = true;
    try {
      await convidarEGuardar(context, convite);
    } finally {
      if (mounted) _mostrando = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
