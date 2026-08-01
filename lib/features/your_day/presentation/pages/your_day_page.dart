import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/navigation/section_reset_notifier.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/mascot/tour_targets.dart';
import '../../../../core/widgets/staggered_entrance.dart';
import '../../../guided_rituals/presentation/widgets/magical_moment_card.dart';
import '../../../lunar/presentation/widgets/moon_day_carousel.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../providers/daily_checkin_provider.dart';
import '../widgets/continue_trail_card.dart';
import '../widgets/daily_affirmation_card.dart';
import '../widgets/daily_rites_card.dart';
import '../widgets/greeting_header.dart';
import '../widgets/magical_weather_card.dart';
import '../widgets/next_moon_phases_card.dart';
import '../widgets/ritual_of_moment_card.dart';
import '../widgets/shortcuts_grid.dart';
import '../widgets/spell_recommendations_card.dart';

/// Aba "Seu Dia" — o hub diário da Bruxa (primeira aba da bottom bar).
///
/// A ordem segue a intenção de quem abre o app: quem sou eu hoje (saudação,
/// sequência, nível) → o que faço agora (rito em destaque) → ganhos rápidos
/// (ritos do dia, afirmação) → retomar (trilha) → contexto (lua, momento,
/// clima) → consulta (recolhida) → atalhos. Tudo gratuito.
class YourDayPage extends StatefulWidget {
  final SectionResetNotifier? resetNotifier;

  const YourDayPage({super.key, this.resetNotifier});

  @override
  State<YourDayPage> createState() => _YourDayPageState();
}

class _YourDayPageState extends State<YourDayPage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    widget.resetNotifier?.addListener(_onResetRequested);
  }

  @override
  void dispose() {
    widget.resetNotifier?.removeListener(_onResetRequested);
    _scrollController.dispose();
    super.dispose();
  }

  /// Puxar para atualizar: recarrega a sequência/ritos do dia (o resto da
  /// tela é derivado e se reconstrói junto).
  Future<void> _refresh() async {
    await context.read<DailyCheckinProvider>().load();
  }

  void _onResetRequested() {
    if (mounted && _scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).yourDayTitle),
        actions: [
          // Alvo do tour do Salem (passo das Configurações).
          TourTarget(
            id: TourTargetIds.settings,
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: context.gc.lilac,
        backgroundColor: context.gc.surface,
        onRefresh: _refresh,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: StaggeredEntrance(
            children: [
              const GreetingHeader(),
              // Só no DIA do evento: aí ele merece o topo da tela.
              const RitualOfMomentCard(mode: RitualCardMode.todayHero),
              // Sem ação no toque: o carrossel é leitura do dia, não atalho.
              const MoonDayCarousel(),
              // Enquanto o dia não chega: a faixa discreta de contagem, no
              // lugar de sempre.
              const RitualOfMomentCard(mode: RitualCardMode.countdown),
              // Consulta lunar logo abaixo da Lua, onde ela faz sentido.
              const NextMoonPhasesCard(),
              const SpellRecommendationsCard(),
              const DailyRitesCard(),
              const MagicalMomentCard(),
              const MagicalWeatherCard(),
              const DailyAffirmationCard(),
              const ContinueTrailCard(),
              const ShortcutsGrid(),
            ],
          ),
        ),
      ),
    );
  }
}
