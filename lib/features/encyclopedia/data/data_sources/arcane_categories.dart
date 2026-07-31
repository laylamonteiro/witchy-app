import '../models/arcane_entry_model.dart';
import 'angels_data.dart';
import 'angels_data_pt.dart';
import 'archetypes_data.dart';
import 'archetypes_data_pt.dart';
import 'demons_data.dart';
import 'demons_data_pt.dart';
import 'sacred_symbols_data.dart';
import 'sacred_symbols_data_pt.dart';

/// Categorias arcanas da Enciclopédia (Arquétipos, Anjos, Demônios e
/// Símbolos Sagrados).
///
/// A identidade da categoria (pasta de assets) e o slug de imagem derivado do
/// NOME PT são invariantes entre idiomas — os títulos exibidos vêm do ARB nos
/// call sites, e as listas por idioma são index-alinhadas (paridade testada).
enum ArcaneCategory {
  archetypes('arquetipos'),
  angels('anjos'),
  demons('demonios'),
  sacredSymbols('simbolos');

  /// Subpasta em assets/images/ — invariante.
  final String assetFolder;

  const ArcaneCategory(this.assetFolder);

  /// Entradas da categoria no idioma atual do aplicativo.
  List<ArcaneEntry> get entries => switch (this) {
        ArcaneCategory.archetypes => archetypesData,
        ArcaneCategory.angels => angelsData,
        ArcaneCategory.demons => demonsData,
        ArcaneCategory.sacredSymbols => sacredSymbolsData,
      };

  List<ArcaneEntry> get _entriesPt => switch (this) {
        ArcaneCategory.archetypes => archetypesPt,
        ArcaneCategory.angels => angelsPt,
        ArcaneCategory.demons => demonsPt,
        ArcaneCategory.sacredSymbols => sacredSymbolsPt,
      };

  /// Caminho da imagem do verbete: slug do nome PT correspondente ao índice
  /// de [entry] na lista do idioma atual (as listas são index-alinhadas).
  /// Para entradas fora da lista, cai no slug do próprio nome — o fallback
  /// visual das páginas é o emoji do verbete.
  String imageAssetFor(ArcaneEntry entry) {
    final index = entries.indexOf(entry);
    final ptName = index >= 0 && index < _entriesPt.length
        ? _entriesPt[index].name
        : entry.name;
    return arcaneImageAsset(assetFolder, ptName);
  }
}
