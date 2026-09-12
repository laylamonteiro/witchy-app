import '../models/arcane_entry_model.dart';
import 'archetypes_data.dart';
import 'archetypes_data_pt.dart';

/// Identidade GRAVADA de cada arquétipo: um id ASCII por arquétipo, na mesma
/// ordem das listas de conteúdo (pt/en/es são index-alinhadas, paridade
/// testada em `test/encyclopedia_parity_test.dart`).
///
/// O resultado do Teste de Arquétipo era gravado no aparelho pelo EMOJI do
/// arquétipo. Emoji é desenho: a mesma figura tem grafias diferentes
/// (seletor de variação, ZWJ) conforme a plataforma e a versão do teclado, e
/// depende da fonte do aparelho para sequer aparecer. Quando o que estava
/// gravado não casava com nenhuma entrada, a tela entregava o PRIMEIRO
/// arquétipo da lista como se fosse o resultado da pessoa. O id não passa
/// por fonte nenhuma e não muda com o idioma; o emoji continua sendo só o
/// desenho que a tela mostra.
///
/// Os ids repetem o slug das imagens (assets/images/arquetipos/<id>.webp),
/// que já era a identidade invariante do verbete entre idiomas. São chaves
/// de armazenamento: uma vez publicados, não mudam nem quando o texto do
/// verbete muda.
const List<String> archetypeIds = [
  'a_bruxa',
  'a_curandeira',
  'a_vidente',
  'a_guardia',
  'a_sabia',
  'a_donzela',
  'a_mae',
  'a_cacadora',
  'a_tecela',
  'a_alquimista',
  'a_rainha_sombria',
];

/// O id do arquétipo cujo emoji de catálogo é [emoji], ou null se nenhum.
///
/// O emoji segue sendo a chave que o conteúdo do teste usa para apontar a
/// opção para o arquétipo (`ArchetypeQuizOption.archetypeEmoji`); esta função
/// é a fronteira entre esse apontamento e o que vai para o aparelho.
String? archetypeIdForEmoji(String emoji) =>
    _idAt(archetypesPt.indexWhere((entry) => entry.emoji == emoji));

/// O verbete do arquétipo [id] no idioma atual, ou null se o id não é de
/// nenhum arquétipo.
ArcaneEntry? archetypeForId(String id) {
  final index = archetypeIds.indexOf(id);
  final entries = archetypesData;
  return index < 0 || index >= entries.length ? null : entries[index];
}

/// Traduz um valor já gravado no aparelho para o id de hoje.
///
/// Aceita as três identidades que o teste já usou, nesta ordem: o id atual, o
/// emoji (como gravava até aqui) e o nome em português (como gravava antes do
/// emoji). Devolve null quando não casa com nada — e aí é AUSÊNCIA de
/// resultado, não erro: quem lê recomeça o teste, em vez de mostrar um
/// arquétipo que não foi o da pessoa.
String? archetypeIdForStoredKey(String stored) {
  if (archetypeIds.contains(stored)) return stored;
  final byEmoji = archetypeIdForEmoji(stored);
  if (byEmoji != null) return byEmoji;
  return _idAt(archetypesPt.indexWhere((entry) => entry.name == stored));
}

String? _idAt(int index) =>
    index < 0 || index >= archetypeIds.length ? null : archetypeIds[index];
