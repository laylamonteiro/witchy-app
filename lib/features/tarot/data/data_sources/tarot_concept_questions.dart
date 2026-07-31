import '../../../../core/content/content_locale.dart';
import 'tarot_concept_questions_en.dart';
import 'tarot_concept_questions_es.dart';
import 'tarot_concept_questions_pt.dart';

/// Perguntas conceituais do quiz de Tarot no idioma atual do aplicativo.
/// A alternativa correta é sempre a primeira ([0]) — regra invariante.
List<(String, List<String>)> get tarotConceptQuestions =>
    ContentLocale.instance.select(
        pt: tarotConceptQuestionsPt,
        en: tarotConceptQuestionsEn,
        es: tarotConceptQuestionsEs);
