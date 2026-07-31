import '../../../core/content/content_locale.dart';
import 'numerology_meanings_data_en.dart';
import 'numerology_meanings_data_es.dart';
import 'numerology_meanings_data_pt.dart';

export 'numerology_meanings_models.dart';

/// Significados numerológicos no idioma atual do aplicativo.
///
/// O conteúdo por idioma vive em `numerology_meanings_data_{pt,en,es}.dart`;
/// estes acessores apenas selecionam a variante via ContentLocale, mantendo
/// os símbolos públicos originais (`numberMeanings`, `profileNumberInfos`,
/// `repeatedSequenceMessages`) para os call sites existentes.
Map<int, NumberMeaning> get numberMeanings => ContentLocale.instance.select(
    pt: numberMeaningsPt, en: numberMeaningsEn, es: numberMeaningsEs);

Map<String, ProfileNumberInfo> get profileNumberInfos =>
    ContentLocale.instance.select(
        pt: profileNumberInfosPt,
        en: profileNumberInfosEn,
        es: profileNumberInfosEs);

Map<String, String> get repeatedSequenceMessages =>
    ContentLocale.instance.select(
        pt: repeatedSequenceMessagesPt,
        en: repeatedSequenceMessagesEn,
        es: repeatedSequenceMessagesEs);
