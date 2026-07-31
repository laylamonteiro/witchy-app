import '../../../../core/content/content_locale.dart';
import '../models/tarot_card_model.dart';
import 'tarot_cards_data_en.dart';
import 'tarot_cards_data_es.dart';
import 'tarot_cards_data_pt.dart';

/// Os 78 arcanos com significados estáticos (normal e invertido) no idioma
/// atual do aplicativo. Conteúdo determinístico; o Conselheiro Místico
/// apenas tece a síntese.
List<TarotCard> get tarotCards =>
    ContentLocale.instance.select(pt: tarotCardsPt, en: tarotCardsEn, es: tarotCardsEs);
