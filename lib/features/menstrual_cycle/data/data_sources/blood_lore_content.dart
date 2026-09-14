import '../../../../core/content/content_locale.dart';
import '../models/blood_lore_model.dart';
import 'blood_lore_content_en.dart';
import 'blood_lore_content_es.dart';
import 'blood_lore_content_pt.dart';

export '../models/blood_lore_model.dart'
    show
        BloodLoreCategory,
        BloodLoreCategoryEmoji,
        BloodLoreContent,
        BloodLoreCta,
        BloodLoreEntry,
        BloodLoreLink,
        BloodLoreSection,
        BloodLoreShortcut,
        BloodLoreTag,
        BloodLoreTagEmoji;

/// Os "Saberes do Sangue" no idioma atual do aplicativo.
///
/// Mesmo padrão do altar e dos elementos: a camada de conteúdo resolve o
/// idioma sem `BuildContext`, e o português é o fallback (o pt_BR lê o pt,
/// como em toda a camada).
BloodLoreContent get bloodLoreContent => ContentLocale.instance.select(
      pt: bloodLoreContentPt,
      en: bloodLoreContentEn,
      es: bloodLoreContentEs,
    );
