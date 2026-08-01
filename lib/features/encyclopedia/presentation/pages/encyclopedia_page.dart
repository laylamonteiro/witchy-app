import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'crystals_list_page.dart';
import 'colors_list_page.dart';
import 'herbs_list_page.dart';
import 'metals_list_page.dart';
import 'altar_page.dart';
import 'elements_page.dart';
import 'goddesses_list_page.dart';
import 'arcane_list_page.dart';
import '../../data/data_sources/arcane_categories.dart';
import '../../data/data_sources/archetypes_data.dart';
import '../../data/data_sources/angels_data.dart';
import '../../data/data_sources/demons_data.dart';
import '../../data/data_sources/sacred_symbols_data.dart';
import '../../../guided_rituals/data/models/guided_rituals_data.dart';
import '../../../guided_rituals/presentation/pages/guided_ritual_page.dart';
import '../../../lunar/presentation/pages/lunar_calendar_page.dart';
import '../../../sun/presentation/pages/sun_page.dart';
import '../../../wheel_of_year/presentation/pages/wheel_of_year_page.dart';
import '../../../runes/presentation/pages/runes_list_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../../core/navigation/app_deep_link.dart';
import '../../../../core/navigation/section_reset_notifier.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/mascot/tour_targets.dart';

class EncyclopediaPage extends StatefulWidget {
  /// Notificador da HomePage: re-toque na aba "Enciclopédia" volta para a
  /// primeira aba interna.
  final SectionResetNotifier? resetNotifier;

  const EncyclopediaPage({super.key, this.resetNotifier});

  @override
  State<EncyclopediaPage> createState() => _EncyclopediaPageState();
}

class _EncyclopediaPageState extends State<EncyclopediaPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // A Enciclopédia abre SEMPRE na aba da Lua (índice 0) — é a tela inicial
  // do app; a última aba visitada deixou de ser restaurada de propósito.
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 15, vsync: this);
    widget.resetNotifier?.addListener(_onResetRequested);
    DeepLinkService.instance.pending.addListener(_onDeepLink);
    // Notificação pode ter ABERTO o app: trata o link pendente ao montar.
    WidgetsBinding.instance.addPostFrameCallback((_) => _onDeepLink());
  }

  @override
  void dispose() {
    DeepLinkService.instance.pending.removeListener(_onDeepLink);
    widget.resetNotifier?.removeListener(_onResetRequested);
    _tabController.dispose();
    super.dispose();
  }

  void _onResetRequested() {
    if (mounted && _tabController.index != 0) {
      _tabController.animateTo(0);
    }
  }

  /// Deep link para uma sub-aba da Enciclopédia (lua cheia → Lua, sabbat →
  /// Sabbats...): navega e consome o link. Destinos de outras seções são
  /// ignorados aqui (a seção dona consome). Destinos de ritual guiado abrem
  /// a sub-aba e empilham a página guiada por cima (bottom bar visível).
  void _onDeepLink() {
    final pending = DeepLinkService.instance.pending.value;
    final target = pending?.link.encyclopediaTab;
    if (pending == null || target == null || !mounted) return;
    if (_tabController.index != target) {
      _tabController.animateTo(target);
    }

    if (pending.link.isGuidedRitual) {
      // Sabbat resolve o id pelo argumento (ritual/sabbat/<nome>); os demais
      // têm ritualId fixo. Argumento inválido = só abre a sub-aba.
      final ritualId = pending.link.ritualId ??
          (pending.arg != null ? 'sabbat_${pending.arg}' : null);
      if (ritualId != null && AllGuidedRituals.byId(ritualId) != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GuidedRitualPage(ritualId: ritualId),
          ),
        );
      }
    }

    DeepLinkService.instance.consume();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).encyclopediaPageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            // rootNavigator: Configurações cobre a bottom bar (tela cheia)
            onPressed: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
            tooltip: AppLocalizations.of(context).settingsTitle,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Align(
            alignment: Alignment.centerLeft,
            // Alvo do tour do Salem (passo dos sabbats e rituais guiados).
            child: TourTarget(
              id: TourTargetIds.encyclopediaTabs,
              child: TabBar(
                controller: _tabController,
                indicatorColor: context.gc.lilac,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                padding: EdgeInsets.zero,
                labelStyle: const TextStyle(fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontSize: 14),
                tabs: [
                  Tab(text: AppLocalizations.of(context).encyTabMoon),
                  Tab(text: AppLocalizations.of(context).encyTabSun),
                  Tab(text: AppLocalizations.of(context).encyTabSabbats),
                  Tab(text: AppLocalizations.of(context).encyTabCrystals),
                  Tab(text: AppLocalizations.of(context).encyTabHerbs),
                  Tab(text: AppLocalizations.of(context).encyTabMetals),
                  Tab(text: AppLocalizations.of(context).encyTabColors),
                  Tab(text: AppLocalizations.of(context).encyTabGoddesses),
                  Tab(text: AppLocalizations.of(context).encyTabElements),
                  Tab(text: AppLocalizations.of(context).encyTabAltar),
                  Tab(text: AppLocalizations.of(context).encyTabRunes),
                  Tab(text: AppLocalizations.of(context).encyTabArchetypes),
                  Tab(text: AppLocalizations.of(context).encyTabAngels),
                  Tab(text: AppLocalizations.of(context).encyTabDemons),
                  Tab(text: AppLocalizations.of(context).encyTabSymbols),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const LunarCalendarPage(embedded: true),
          const SunPage(),
          const WheelOfYearPage(embedded: true),
          const CrystalsListPage(),
          const HerbsListPage(),
          const MetalsListPage(),
          const ColorsListPage(),
          const GoddessesListPage(),
          const ElementsPage(),
          const AltarPage(),
          const RunesListPage(),
          ArcaneListPage(
            category: ArcaneCategory.archetypes,
            title: l10n.encyTabArchetypes,
            intro: l10n.encyArcaneIntroArchetypes,
            entries: archetypesData,
          ),
          ArcaneListPage(
            category: ArcaneCategory.angels,
            title: l10n.encyTabAngels,
            intro: l10n.encyArcaneIntroAngels,
            entries: angelsData,
          ),
          ArcaneListPage(
            category: ArcaneCategory.demons,
            title: l10n.encyTabDemons,
            intro: l10n.encyArcaneIntroDemons,
            entries: demonsData,
          ),
          ArcaneListPage(
            category: ArcaneCategory.sacredSymbols,
            title: l10n.encyCatSacredSymbols,
            intro: l10n.encyArcaneIntroSymbols,
            entries: sacredSymbolsData,
          ),
        ],
      ),
    );
  }
}
