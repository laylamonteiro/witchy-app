import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/widgets/magical_card.dart';
import '../../../astrology/data/data_sources/daily_weather_content.dart';
import '../../../astrology/data/repositories/daily_weather_repository.dart';
import '../../../astrology/presentation/pages/daily_magical_weather_page.dart';
import '../../../astrology/presentation/providers/astrology_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Card do Clima Mágico no Seu Dia: SÓ lê o cache do dia (nunca dispara a
/// geração por IA ao montar). Sem cache → convite para gerar, que abre a
/// página completa (o gate diário e a geração acontecem LÁ). Ao voltar da
/// página, o cache é reconsultado e o resumo aparece.
class MagicalWeatherCard extends StatefulWidget {
  const MagicalWeatherCard({super.key});

  @override
  State<MagicalWeatherCard> createState() => _MagicalWeatherCardState();
}

class _MagicalWeatherCardState extends State<MagicalWeatherCard> {
  final DailyWeatherRepository _repository = DailyWeatherRepository();
  String? _cachedText;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCache());
  }

  Future<void> _loadCache() async {
    if (!mounted) return;
    final userId = context.read<AuthProvider>().currentUser.id;
    final natalChart = context.read<AstrologyProvider>().birthChart;
    final contextKey = DailyWeatherRepository.contextKeyFor(natalChart);
    final cache =
        await _repository.getCachedWeather(DateTime.now(), userId, contextKey);
    if (!mounted) return;
    setState(() {
      _loaded = true;
      _cachedText = (cache != null &&
              DailyWeatherContent.looksComplete(cache.aiGeneratedText))
          ? cache.aiGeneratedText
          : null;
    });
  }

  /// Primeira frase "de verdade" do markdown (ignora cabeçalhos `#`).
  String _preview(String markdown) {
    for (final line in markdown.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      return trimmed;
    }
    return '';
  }

  Future<void> _openFullPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DailyMagicalWeatherPage()),
    );
    // O clima pode ter sido gerado lá dentro — reconsultar o cache.
    await _loadCache();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MagicalCard(
      onTap: _openFullPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔮', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.yourDayWeatherTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Icon(Icons.chevron_right, color: context.gc.textSecondary),
            ],
          ),
          const SizedBox(height: 10),
          if (!_loaded)
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (_cachedText != null) ...[
            Text(
              _preview(_cachedText!),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.yourDayWeatherSeeFull,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.gc.lilac,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ] else
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 18, color: context.gc.starYellow),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.yourDayWeatherGenerateCta,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.gc.starYellow,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
