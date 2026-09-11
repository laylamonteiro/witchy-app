import '../../../../core/content/content_locale.dart';
import '../../domain/internal_season.dart';
import '../models/menstrual_season_content.dart';
import 'menstrual_phase_content_en.dart';
import 'menstrual_phase_content_es.dart';
import 'menstrual_phase_content_pt.dart';

/// O conteúdo das Estações Internas no idioma ativo.
///
/// O nome técnico do arquivo preserva "phase" pelo padrão do projeto, mas o
/// contrato público é estação simbólica: nada aqui afirma fase do corpo.
class MenstrualSeasonContentSource {
  const MenstrualSeasonContentSource._();

  static List<MenstrualSeasonContent> get all => ContentLocale.instance.select(
        pt: menstrualSeasonsPt,
        en: menstrualSeasonsEn,
        es: menstrualSeasonsEs,
      );

  static MenstrualSeasonContent of(InternalSeason season) =>
      all.firstWhere((content) => content.season == season);
}
