import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../runes/presentation/pages/rune_reading_page.dart';
import '../../../auth/auth.dart';
import 'pendulum_page.dart';
import 'oracle_cards_page.dart';

class DivinationHubPage extends StatelessWidget {
  const DivinationHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveAppBarTitle(AppLocalizations.of(context).divinationTitle),
        backgroundColor: context.gc.darkBackground,
      ),
      backgroundColor: context.gc.darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MagicalCard(
              child: Column(
                children: [
                  const Text('🔮', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).divArtsTitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: context.gc.lilac,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).divArtsSub,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.gc.softWhite.withValues(alpha: 0.8),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildDivinationOption(
              context,
              icon: 'ᚱᚢᚾᚨ',
              title: AppLocalizations.of(context).runesListTitle,
              description: AppLocalizations.of(context).divRunesDesc,
              feature: AppFeature.runesReadings,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RuneReadingPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildDivinationOption(
              context,
              icon: '⟟',
              title: AppLocalizations.of(context).pendulumTitle,
              description: AppLocalizations.of(context).divPendulumDesc,
              feature: AppFeature.divinationPendulum,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PendulumPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildDivinationOption(
              context,
              icon: '🔮',
              title: AppLocalizations.of(context).divOracleTitle,
              description: AppLocalizations.of(context).divOracleDesc,
              feature: AppFeature.divinationOracle,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const OracleCardsPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivinationOption(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required AppFeature feature,
  }) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final access = authProvider.checkFeatureAccess(feature);

        return InkWell(
          onTap: access.hasFullAccess
              ? onTap
              : () => _showPremiumDialog(context, title),
          borderRadius: BorderRadius.circular(12),
          child: MagicalCard(
            child: Row(
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: context.gc.softWhite,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (!access.hasFullAccess) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF9C27B0),
                                    Color(0xFFE91E63)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'PREMIUM',
                                style: TextStyle(
                                  color: context.gc.textPrimary,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.gc.softWhite.withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  access.hasFullAccess ? Icons.arrow_forward_ios : Icons.lock,
                  color: access.hasFullAccess
                      ? context.gc.lilac
                      : const Color(0xFF9C27B0),
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPremiumDialog(BuildContext context, String featureName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PremiumUpgradeSheet(),
    );
  }
}
