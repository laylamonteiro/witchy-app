import '../../../../core/content/content_locale.dart';
import '../models/arcane_entry_model.dart';
import 'angels_data_en.dart';
import 'angels_data_es.dart';
import 'angels_data_pt.dart';

/// Anjos no idioma atual do aplicativo — abordagem informativa e histórica,
/// diferenciando tradições religiosas, folclóricas, ocultistas e literárias,
/// sem apresentar uma única interpretação como verdade absoluta.
List<ArcaneEntry> get angelsData =>
    ContentLocale.instance.select(pt: angelsPt, en: angelsEn, es: angelsEs);
