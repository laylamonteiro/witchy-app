import '../../../../core/content/content_locale.dart';
import '../models/altar_content_model.dart';
import 'altar_content_en.dart';
import 'altar_content_es.dart';
import 'altar_content_pt.dart';

export '../models/altar_content_model.dart'
    show
        AltarContent,
        AltarStep,
        AltarNumberedStep,
        AltarEmojiItem,
        AltarSpeech,
        AltarFaq;

/// Conteúdo da página "O Altar Mágico" no idioma atual do aplicativo.
AltarContent get altarContent => ContentLocale.instance
    .select(pt: altarContentPt, en: altarContentEn, es: altarContentEs);
