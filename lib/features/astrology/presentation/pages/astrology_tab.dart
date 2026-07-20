import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../providers/astrology_provider.dart';
import 'birth_chart_input_page.dart';
import 'birth_chart_view_page.dart';
import 'magical_profile_page.dart';
import 'daily_magical_weather_page.dart';
import 'personalized_suggestions_page.dart';
import 'zodiac_signs_page.dart';

/// Aba de Astrologia dentro da página "Grimório Digital".
///
/// Corpo (sem Scaffold/AppBar) — a chrome vem da TabBar da GrimoirePage.
/// Segue o mesmo padrão de espaçamento de `_ToolsTab` (padding vertical 16,
/// ritmo entre cards vindo das margens do MagicalCard).
class AstrologyTab extends StatefulWidget {
  const AstrologyTab({super.key});

  @override
  State<AstrologyTab> createState() => _AstrologyTabState();
}

class _AstrologyTabState extends State<AstrologyTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AstrologyProvider>();
      provider.loadBirthChart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AstrologyProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(context.gc.lilac),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              MagicalCard(
                child: Column(
                  children: [
                    const Text('‧ ☽◯☾ ‧', style: TextStyle(fontSize: 45)),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.astroMysticTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: context.gc.lilac,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.astroMysticSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.gc.softWhite.withOpacity(0.8),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Signos do Zodíaco
              _buildOption(
                context,
                icon: '🌌',
                title: AppLocalizations.of(context)!.astroZodiacSigns,
                description:
                    AppLocalizations.of(context)!.astroZodiacSignsDesc,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ZodiacSignsPage(),
                    ),
                  );
                },
              ),

              // Mapa Astral
              _buildOption(
                context,
                icon: '🌟',
                title: AppLocalizations.of(context)!.astroBirthChart,
                description: provider.hasBirthChart
                    ? AppLocalizations.of(context)!.astroSeeChart
                    : AppLocalizations.of(context)!.astroCreateChart,
                onTap: () {
                  if (provider.hasBirthChart) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BirthChartViewPage(),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BirthChartInputPage(),
                      ),
                    );
                  }
                },
              ),

              // Perfil Mágico
              if (provider.hasMagicalProfile)
                _buildOption(
                  context,
                  icon: '✨',
                  iconWidget: SvgPicture.asset(
                    'assets/icons/magic_mirror.svg',
                    width: 40,
                    height: 40,
                    semanticsLabel: AppLocalizations.of(context)!.astroMagicMirror,
                  ),
                  title: AppLocalizations.of(context)!.astroMagicalProfile,
                  description: AppLocalizations.of(context)!.astroMagicalProfileDesc,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MagicalProfilePage(),
                      ),
                    );
                  },
                ),

              // Clima Mágico Diário
              _buildOption(
                context,
                icon: '🪐',
                title: AppLocalizations.of(context)!.astroDailyWeather,
                description: AppLocalizations.of(context)!.astroDailyWeatherDesc,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DailyMagicalWeatherPage(),
                    ),
                  );
                },
              ),

              // Sugestões Personalizadas
              _buildOption(
                context,
                icon: '✨',
                title: AppLocalizations.of(context)!.astroSuggestions,
                description: AppLocalizations.of(context)!.astroSuggestionsDesc,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PersonalizedSuggestionsPage(),
                    ),
                  );
                },
              ),

              // Opção de recriar mapa (se já existe)
              if (provider.hasBirthChart)
                _buildOption(
                  context,
                  icon: '🔄',
                  title: AppLocalizations.of(context)!.astroRecalculate,
                  description: AppLocalizations.of(context)!.astroRecalculateDesc,
                  onTap: () {
                    _showRecalculateDialog(context, provider);
                  },
                ),

              // Informações
              MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: context.gc.lilac,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.astroAbout,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: context.gc.lilac,
                              ),
                        ),
                      ],
                    ),
                    Divider(color: context.gc.lilac),
                    Text(
                      AppLocalizations.of(context)!.astroAboutText,
                      style: TextStyle(
                        color: context.gc.softWhite.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.astroHaveOnHand,
                      style: TextStyle(
                        color: context.gc.softWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoItem(AppLocalizations.of(context)!.astroBirthDate),
                    _buildInfoItem(AppLocalizations.of(context)!.astroBirthTime),
                    _buildInfoItem(AppLocalizations.of(context)!.astroBirthPlace),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(
    BuildContext context, {
    String? icon,
    Widget? iconWidget,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    assert(icon != null || iconWidget != null,
        'Informe um emoji em icon ou um widget em iconWidget.');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: MagicalCard(
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: iconWidget ??
                    Text(
                      icon!,
                      // 32 dentro da caixa de 40: o glifo do emoji é mais alto
                      // que o corpo da fonte e em 40 estourava o padrão visual.
                      style: const TextStyle(fontSize: 32),
                    ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.gc.softWhite,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.gc.softWhite.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: context.gc.lilac,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: context.gc.lilac,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: context.gc.softWhite.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRecalculateDialog(
    BuildContext context,
    AstrologyProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.gc.cardBackground,
        title: Text(
          AppLocalizations.of(context)!.astroRecalcTitle,
          style: TextStyle(color: context.gc.softWhite),
        ),
        content: Text(
          AppLocalizations.of(context)!.astroRecalcConfirm,
          style: TextStyle(color: context.gc.softWhite),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              AppLocalizations.of(context)!.commonCancel,
              style: TextStyle(color: context.gc.lilac),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              AppLocalizations.of(context)!.commonContinue,
              style: TextStyle(color: context.gc.lilac),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!context.mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const BirthChartInputPage(),
        ),
      );
    }
  }
}
