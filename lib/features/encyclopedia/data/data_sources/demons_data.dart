import '../../../../core/content/content_locale.dart';
import '../models/arcane_entry_model.dart';
import 'demons_data_en.dart';
import 'demons_data_es.dart';
import 'demons_data_pt.dart';

/// Demônios no idioma atual do aplicativo — abordagem informativa e
/// histórica: goécia, folclore, demonologia literária e releituras modernas,
/// sem apresentar uma única interpretação como verdade absoluta e sem
/// incentivo a práticas de dano.
List<ArcaneEntry> get demonsData =>
    ContentLocale.instance.select(pt: demonsPt, en: demonsEn, es: demonsEs);
