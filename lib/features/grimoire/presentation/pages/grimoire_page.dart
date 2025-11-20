import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/diagnostic/diagnostic_page.dart';
import 'app_spells_list_page.dart';
import 'user_spells_list_page.dart';
import 'ai_spell_creation_page.dart';
import '../../../astrology/presentation/pages/astrology_page.dart';
import '../../../divination/presentation/pages/divination_hub_page.dart';

class GrimoirePage extends StatelessWidget {
  const GrimoirePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Grimório Digital'),
          bottom: const TabBar(
            indicatorColor: AppColors.lilac,
            isScrollable: true,
            labelPadding: EdgeInsets.symmetric(horizontal: 12),
            labelStyle: TextStyle(fontSize: 14),
            unselectedLabelStyle: TextStyle(fontSize: 14),
            tabs: [
              Tab(text: 'Meu Grimório'),
              Tab(text: 'Grimório Ancestral'),
              Tab(text: 'Ferramentas'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            UserSpellsListPage(),
            AppSpellsListPage(),
            _ToolsTab(),
          ],
        ),
      ),
    );
  }

}

class _ToolsTab extends StatelessWidget {
  const _ToolsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MagicalCard(
            child: Column(
              children: [
                const Text('✨', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  'Ferramentas Mágicas',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.lilac,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Recursos avançados para sua prática',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.softWhite.withOpacity(0.8),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildToolCard(
            context,
            icon: '🌟',
            title: 'Astrologia',
            description: 'Mapa astral e perfil mágico personalizado',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AstrologyPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildToolCard(
            context,
            icon: '✨',
            title: 'Conselheiro Místico',
            description: 'Manifeste feitiços personalizados com sabedoria arcana',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AISpellCreationPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildToolCard(
            context,
            icon: '🔮',
            title: 'Divinação',
            description: 'Runas, pêndulo e oracle cards para orientação',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DivinationHubPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildToolCard(
            context,
            icon: '🔍',
            title: 'Diagnóstico Completo',
            description: 'Testar todas as funcionalidades do app',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DiagnosticPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
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
}
