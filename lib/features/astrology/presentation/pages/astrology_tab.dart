import 'package:flutter/material.dart';
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
                      'Astrologia Mística',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: context.gc.lilac,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Descubra seu mapa astral e perfil mágico personalizado',
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
                title: 'Signos do Zodíaco',
                description:
                    'Conheça os 12 signos e seus significados mágicos',
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
                title: 'Mapa Astral',
                description: provider.hasBirthChart
                    ? 'Ver seu mapa astral completo'
                    : 'Criar seu mapa astral',
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
                    semanticsLabel: 'Espelho mágico',
                  ),
                  title: 'Perfil Mágico',
                  description: 'Interpretação astrológica para bruxaria',
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
                title: 'Clima Mágico Diário',
                description: 'Trânsitos planetários e energia do dia',
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
                title: 'Sugestões Personalizadas',
                description: 'Práticas baseadas nos seus trânsitos',
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
                  title: 'Recalcular Mapa',
                  description: 'Criar novo mapa astral',
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
                          'Sobre a Astrologia',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: context.gc.lilac,
                              ),
                        ),
                      ],
                    ),
                    Divider(color: context.gc.lilac),
                    Text(
                      'Seu mapa astral é calculado com base na posição dos planetas '
                      'no momento e local do seu nascimento. O perfil mágico interpreta '
                      'essas posições de forma específica para práticas de bruxaria.',
                      style: TextStyle(
                        color: context.gc.softWhite.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Para melhores resultados, tenha em mãos:',
                      style: TextStyle(
                        color: context.gc.softWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoItem('Data de nascimento'),
                    _buildInfoItem('Hora exata de nascimento'),
                    _buildInfoItem('Local de nascimento (cidade e país)'),
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
          'Recalcular Mapa Astral?',
          style: TextStyle(color: context.gc.softWhite),
        ),
        content: Text(
          'Isso irá substituir seu mapa astral atual. '
          'Você tem certeza?',
          style: TextStyle(color: context.gc.softWhite),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: context.gc.lilac),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Continuar',
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
