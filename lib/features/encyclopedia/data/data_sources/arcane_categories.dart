import '../models/arcane_entry_model.dart';
import 'angels_data.dart';
import 'angels_data_pt.dart';
import 'archetype_identity.dart';
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

  /// O id do DESENHO de [entry], ou null quando a categoria ainda é escrita
  /// com o emoji do próprio verbete.
  ///
  /// É a costura entre o desenho e o emoji, e ela mora AQUI porque é a
  /// categoria que sabe a resposta — as páginas de verbete são genéricas e
  /// servem às quatro. Quem decidisse olhando só para o emoji erraria: o
  /// demônio Stolas usa 🦉 e o Buer usa 🌿, os mesmos símbolos da Sábia e da
  /// Curandeira, e os dois passariam a aparecer com o desenho de um
  /// arquétipo. Com a categoria na frente, o verbete de arquétipo mostra o
  /// desenho e o de demônio continua com o emoji dele.
  ///
  /// Dentro dos Arquétipos a resolução é pelo emoji de propósito: ele é
  /// invariante entre idiomas (paridade testada) e já é a chave que
  /// `archetypeIdForEmoji` usa para achar o id gravado no aparelho — uma
  /// segunda tabela de correspondência seria uma segunda coisa para
  /// desencontrar.
  String? glyphIdFor(ArcaneEntry entry) => switch (this) {
        ArcaneCategory.archetypes => archetypeIdForEmoji(entry.emoji),
        ArcaneCategory.angels ||
        ArcaneCategory.demons ||
        ArcaneCategory.sacredSymbols =>
          null,
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
