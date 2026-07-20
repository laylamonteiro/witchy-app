import '../../../../core/content/content_locale.dart';
import '../models/oracle_card_model.dart';
import 'oracle_cards_data_en.dart';
import 'oracle_cards_data_es.dart';
import 'oracle_cards_data_pt.dart';

/// Lista das 44 cartas do Oráculo no idioma atual do aplicativo.
List<OracleCard> get oracleCardsData => ContentLocale.instance
    .select(pt: oracleCardsPt, en: oracleCardsEn, es: oracleCardsEs);
