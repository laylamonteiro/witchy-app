import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/astrology_provider.dart';
import 'birth_chart_input_page.dart';
import 'birth_chart_view_page.dart';
import 'magical_profile_page.dart';
import 'daily_magical_weather_page.dart';
import 'personalized_suggestions_page.dart';

class AstrologyPage extends StatefulWidget {
  const AstrologyPage({super.key});

  @override
  State<AstrologyPage> createState() => _AstrologyPageState();
}

class _AstrologyPageState extends State<AstrologyPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AstrologyProvider>();
      provider.loadBirthChart('current_user');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Astrologia'),
        backgroundColor: AppColors.darkBackground,
      ),
      backgroundColor: AppColors.darkBackground,
      body: Consumer<AstrologyProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.lilac),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                MagicalCard(
                  child: Column(
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      Text(
                        'Astrologia Mágica',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.lilac,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Descubra seu mapa astral e perfil mágico personalizado',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.softWhite.withOpacity(0.8),
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Mapa Natal
                _buildOption(
                  context,
                  icon: '🌟',
                  title: 'Mapa Astral',
                  description: provider.hasBirthChart
                      ? 'Ver seu mapa natal completo'
                      : 'Criar seu mapa natal',
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

                const SizedBox(height: 12),

                // Perfil Mágico
                if (provider.hasMagicalProfile)
                  _buildOption(
                    context,
                    icon: '✨',
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

                const SizedBox(height: 12),

                // Clima Mágico Diário
                _buildOption(
                  context,
                  icon: '🌙',
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

                const SizedBox(height: 12),

                // Sugestões Personalizadas
                _buildOption(
                  context,
                  icon: '🔮',
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

                const SizedBox(height: 12),

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

                const SizedBox(height: 24),

                // Informações
                MagicalCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.lilac,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sobre a Astrologia',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.lilac,
                                ),
                          ),
                        ],
                      ),
                      const Divider(color: AppColors.lilac),
                      Text(
                        'Seu mapa astral é calculado com base na posição dos planetas '
                        'no momento e local do seu nascimento. O perfil mágico interpreta '
                        'essas posições de forma específica para práticas de bruxaria.',
                        style: TextStyle(
                          color: AppColors.softWhite.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Para melhores resultados, tenha em mãos:',
                        style: TextStyle(
                          color: AppColors.softWhite,
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
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.softWhite,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.softWhite.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.lilac,
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
          const Text(
            '• ',
            style: TextStyle(
              color: AppColors.lilac,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.softWhite.withOpacity(0.8),
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
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Recalcular Mapa Astral?',
          style: TextStyle(color: AppColors.softWhite),
        ),
        content: const Text(
          'Isso irá substituir seu mapa astral atual. '
          'Você tem certeza?',
          style: TextStyle(color: AppColors.softWhite),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.lilac),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Continuar',
              style: TextStyle(color: AppColors.lilac),
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
