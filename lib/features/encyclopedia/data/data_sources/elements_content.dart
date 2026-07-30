import '../../../../core/content/content_locale.dart';
import '../models/elements_content_model.dart';
import 'elements_content_en.dart';
import 'elements_content_es.dart';
import 'elements_content_pt.dart';

export '../models/elements_content_model.dart'
    show ElementsContent, ElementInfo, ElementBalanceItem, ElementPractice;

/// Conteúdo da página "Os Quatro Elementos" no idioma atual do aplicativo.
ElementsContent get elementsContent => ContentLocale.instance.select(
      pt: elementsContentPt,
      en: elementsContentEn,
      es: elementsContentEs,
    );
