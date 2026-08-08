import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../analytics/presentation/pages/magical_analytics_page.dart';
import 'journeys_page.dart';

/// Evolução Mágica: Jornadas e Estatísticas numa página só, uma aba para
/// cada — no menu, uma única entrada em vez de duas páginas irmãs.
class MagicalProgressPage extends StatelessWidget {
  /// Aba inicial: 0 = Jornadas, 1 = Estatísticas (para os atalhos do Seu
  /// Dia continuarem caindo direto onde apontavam).
  final int initialTab;

  const MagicalProgressPage({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        backgroundColor: context.gc.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: ResponsiveAppBarTitle(
            l10n.progressPageTitle,
            style: TextStyle(
              color: context.gc.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.gc.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            indicatorColor: context.gc.lilac,
            labelColor: context.gc.lilac,
            unselectedLabelColor: context.gc.textSecondary,
            tabs: [
              Tab(text: l10n.progressTabJourneys),
              Tab(text: l10n.progressTabStats),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            JourneysPage(embedded: true),
            MagicalAnalyticsPage(embedded: true),
          ],
        ),
      ),
    );
  }
}
