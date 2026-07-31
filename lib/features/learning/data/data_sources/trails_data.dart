import '../../../../core/content/content_locale.dart';
import '../models/trail_model.dart';
import 'trails/trail_bruxaria_tradicional_en.dart';
import 'trails/trail_bruxaria_tradicional_es.dart';
import 'trails/trail_bruxaria_tradicional_pt.dart';
import 'trails/trail_magia_branca_en.dart';
import 'trails/trail_magia_branca_es.dart';
import 'trails/trail_magia_branca_pt.dart';
import 'trails/trail_magia_do_caos_en.dart';
import 'trails/trail_magia_do_caos_es.dart';
import 'trails/trail_magia_do_caos_pt.dart';
import 'trails/trail_magia_negra_en.dart';
import 'trails/trail_magia_negra_es.dart';
import 'trails/trail_magia_negra_pt.dart';
import 'trails/trail_magia_verde_en.dart';
import 'trails/trail_magia_verde_es.dart';
import 'trails/trail_magia_verde_pt.dart';
import 'trails/trail_quiromancia_en.dart';
import 'trails/trail_quiromancia_es.dart';
import 'trails/trail_quiromancia_pt.dart';
import 'trails/trail_tarot_en.dart';
import 'trails/trail_tarot_es.dart';
import 'trails/trail_tarot_pt.dart';
import 'trails/trail_wicca_en.dart';
import 'trails/trail_wicca_es.dart';
import 'trails/trail_wicca_pt.dart';

/// As trilhas do Grimório Vivo, resolvidas pelo idioma atual do conteúdo
/// estático (fallback: português). A primeira lição de cada trilha é gratuita;
/// as demais são Premium (regra centralizada no FeatureAccess).
///
/// A ordem das 7 trilhas é idêntica entre os idiomas e é preservada aqui.
/// Paridade pt/en/es verificada em test/trails_parity_test.dart.
List<LearningTrail> get learningTrails => ContentLocale.instance.select(
      pt: const [
        magiaBrancaTrailPt,
        magiaVerdeTrailPt,
        wiccaTrailPt,
        bruxariaTradicionalTrailPt,
        magiaNegraTrailPt,
        magiaDoCaosTrailPt,
        tarotTrailPt,
        quiromanciaTrailPt,
      ],
      en: const [
        magiaBrancaTrailEn,
        magiaVerdeTrailEn,
        wiccaTrailEn,
        bruxariaTradicionalTrailEn,
        magiaNegraTrailEn,
        magiaDoCaosTrailEn,
        tarotTrailEn,
        quiromanciaTrailEn,
      ],
      es: const [
        magiaBrancaTrailEs,
        magiaVerdeTrailEs,
        wiccaTrailEs,
        bruxariaTradicionalTrailEs,
        magiaNegraTrailEs,
        magiaDoCaosTrailEs,
        tarotTrailEs,
        quiromanciaTrailEs,
      ],
    );
