import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'crystals_list_page.dart';
import 'colors_list_page.dart';
import '../../../grimoire/presentation/pages/spell_categories_hub_page.dart';
import 'herbs_list_page.dart';
import 'metals_list_page.dart';
import 'altar_page.dart';
import 'elements_page.dart';
import 'goddesses_list_page.dart';
import 'arcane_list_page.dart';
import 'encyclopedia_index_page.dart';
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
import '../../../../core/navigation/encyclopedia_section.dart';
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
  // A Enciclopédia abre SEMPRE na capa do livro (Índice, aba 0); a última
  // aba visitada deixou de ser restaurada de propósito.
  late TabController _tabController;

  /// Trocado para recriar o TabBarView quando o re-toque na bottom bar pede
  /// "voltar ao início" já estando na primeira aba.
  int _viewEpoch = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: EncyclopediaSection.values.length,
      vsync: this,
    );
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

  /// Sumário do livro-índice → abre a aba da seção escolhida.
  void _openSection(EncyclopediaSection section) {
    if (!mounted) return;
    _tabController.animateTo(section.index);
  }

  void _onResetRequested() {
    if (!mounted) return;
    if (_tabController.index != 0) {
      _tabController.animateTo(0);
      return;
    }
    // Já na primeira aba: recria a view para o conteúdo voltar ao topo
    // (as sub-páginas não mantêm estado fora de cena, então trocar de aba
    // já volta ao topo sozinho — este é o único caso que faltava).
    setState(() => _viewEpoch++);
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
        // Sem a lupa (a busca vive no Índice) o título ganha o centro.
        centerTitle: true,
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
                // A ordem vem da declaração de EncyclopediaSection — a mesma
                // fonte que gera as views abaixo e resolve os deep links.
                tabs: [
                  for (final section in EncyclopediaSection.values)
                    Tab(text: _labelFor(section, l10n)),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        key: ValueKey(_viewEpoch),
        controller: _tabController,
        // MESMA fonte da TabBar acima: EncyclopediaSection.values.
        children: [
          for (final section in EncyclopediaSection.values)
            _pageFor(section, l10n),
        ],
      ),
    );
  }

  /// Rótulo da aba de cada seção. Switch exaustivo: seção nova sem rótulo
  /// vira erro de compilação, não aba em branco.
  String _labelFor(EncyclopediaSection section, AppLocalizations l10n) =>
      switch (section) {
        EncyclopediaSection.bookIndex => l10n.encyTabIndex,
        EncyclopediaSection.myGrimoire => l10n.grimoireTabMyGrimoire,
        EncyclopediaSection.moon => l10n.encyTabMoon,
        EncyclopediaSection.sun => l10n.encyTabSun,
        EncyclopediaSection.sabbats => l10n.encyTabSabbats,
        EncyclopediaSection.crystals => l10n.encyTabCrystals,
        EncyclopediaSection.herbs => l10n.encyTabHerbs,
        EncyclopediaSection.colors => l10n.encyTabColors,
        EncyclopediaSection.goddesses => l10n.encyTabGoddesses,
        EncyclopediaSection.elements => l10n.encyTabElements,
        EncyclopediaSection.runes => l10n.encyTabRunes,
        EncyclopediaSection.altar => l10n.encyTabAltar,
        EncyclopediaSection.metals => l10n.encyTabMetals,
        EncyclopediaSection.archetypes => l10n.encyTabArchetypes,
        EncyclopediaSection.symbols => l10n.encyCatSacredSymbols,
        EncyclopediaSection.angels => l10n.encyTabAngels,
        EncyclopediaSection.demons => l10n.encyTabDemons,
      };

  /// View de cada seção, na mesma ordem canônica.
  Widget _pageFor(EncyclopediaSection section, AppLocalizations l10n) =>
      switch (section) {
        EncyclopediaSection.bookIndex =>
          EncyclopediaIndexPage(onSectionSelected: _openSection),
        EncyclopediaSection.myGrimoire => const SpellCategoriesHubPage(),
        EncyclopediaSection.moon => const LunarCalendarPage(embedded: true),
        EncyclopediaSection.sun => const SunPage(),
        EncyclopediaSection.sabbats => const WheelOfYearPage(embedded: true),
        EncyclopediaSection.crystals => const CrystalsListPage(),
        EncyclopediaSection.herbs => const HerbsListPage(),
        EncyclopediaSection.colors => const ColorsListPage(),
        EncyclopediaSection.goddesses => const GoddessesListPage(),
        EncyclopediaSection.elements => const ElementsPage(),
        EncyclopediaSection.runes => const RunesListPage(),
        EncyclopediaSection.altar => const AltarPage(),
        EncyclopediaSection.metals => const MetalsListPage(),
        EncyclopediaSection.archetypes => ArcaneListPage(
            category: ArcaneCategory.archetypes,
            title: l10n.encyTabArchetypes,
            intro: l10n.encyArcaneIntroArchetypes,
            entries: archetypesData,
          ),
        EncyclopediaSection.symbols => ArcaneListPage(
            category: ArcaneCategory.sacredSymbols,
            title: l10n.encyCatSacredSymbols,
            intro: l10n.encyArcaneIntroSymbols,
            entries: sacredSymbolsData,
          ),
        EncyclopediaSection.angels => ArcaneListPage(
            category: ArcaneCategory.angels,
            title: l10n.encyTabAngels,
            intro: l10n.encyArcaneIntroAngels,
            entries: angelsData,
          ),
        EncyclopediaSection.demons => ArcaneListPage(
            category: ArcaneCategory.demons,
            title: l10n.encyTabDemons,
            intro: l10n.encyArcaneIntroDemons,
            entries: demonsData,
          ),
      };
}
