import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/navigation/app_deep_link.dart';
import '../../../../core/navigation/section_reset_notifier.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/mascot/tour_targets.dart';
import '../../../guided_rituals/presentation/widgets/magical_moment_card.dart';
import '../../../lunar/presentation/widgets/moon_day_carousel.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../widgets/continue_trail_card.dart';
import '../widgets/daily_affirmation_card.dart';
import '../widgets/daily_rites_card.dart';
import '../widgets/greeting_header.dart';
import '../widgets/magical_weather_card.dart';
import '../widgets/next_moon_phases_card.dart';
import '../widgets/ritual_of_moment_card.dart';
import '../widgets/shortcuts_grid.dart';
import '../widgets/spell_recommendations_card.dart';

/// Aba "Seu Dia" — o hub diário da Bruxa (primeira aba da bottom bar):
/// saudação, lua de hoje, momento mágico, clima do dia (cache), afirmação,
/// ritual do momento e atalhos personalizáveis. Tudo gratuito.
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
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ordem: quem sou eu hoje → o que faço agora → ganhos rápidos →
            // retomar o que comecei → contexto do dia → consulta → atalhos.
            const GreetingHeader(),
            const RitualOfMomentCard(),
            const DailyRitesCard(),
            const DailyAffirmationCard(),
            const ContinueTrailCard(),
            MoonDayCarousel(
              onDayTap: () => DeepLinkService.instance
                  .dispatch(AppDeepLink.moonEncyclopedia),
            ),
            const MagicalMomentCard(),
            const MagicalWeatherCard(),
            const NextMoonPhasesCard(),
            const SpellRecommendationsCard(),
            const ShortcutsGrid(),
          ],
        ),
      ),
    );
  }
}
