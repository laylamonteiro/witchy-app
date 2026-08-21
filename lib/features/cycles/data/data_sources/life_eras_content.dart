import '../../../../core/content/content_locale.dart';
import '../../domain/era_ruler.dart';
import '../models/cycle_content.dart';
import 'life_eras_content_en.dart';
import 'life_eras_content_es.dart';
import 'life_eras_content_pt.dart';

/// Conteúdo das Eras e Fases no idioma ativo.
///
/// O conteúdo por idioma vive em `life_eras_content_pt/en/es.dart`; esta classe
/// apenas seleciona a variante via [ContentLocale], como o resto do app faz.
class LifeErasContent {
  const LifeErasContent._();

  static List<EraContent> get eras => ContentLocale.instance.select(
        pt: erasPt,
        en: erasEn,
        es: erasEs,
      );

  static List<FaseContent> get fases => ContentLocale.instance.select(
        pt: fasesPt,
        en: fasesEn,
        es: fasesEs,
      );

  /// Texto da Era regida por [regente].
  static EraContent daEra(EraRegente regente) =>
      eras.firstWhere((e) => e.regente == regente);

  /// Texto da Fase regida por [regente].
  static FaseContent daFase(EraRegente regente) =>
      fases.firstWhere((f) => f.regente == regente);
}
