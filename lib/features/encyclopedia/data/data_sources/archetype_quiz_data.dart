import '../../../../core/content/content_locale.dart';
import '../models/archetype_quiz_model.dart';
import 'archetype_quiz_data_en.dart';
import 'archetype_quiz_data_es.dart';
import 'archetype_quiz_data_pt.dart';

export '../models/archetype_quiz_model.dart'
    show ArchetypeQuizQuestion, ArchetypeQuizOption;

/// Perguntas do Teste de Arquétipo no idioma atual do aplicativo.
List<ArchetypeQuizQuestion> get archetypeQuizQuestions =>
    ContentLocale.instance.select(
      pt: archetypeQuizQuestionsPt,
      en: archetypeQuizQuestionsEn,
      es: archetypeQuizQuestionsEs,
    );
