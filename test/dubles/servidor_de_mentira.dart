import 'package:grimorio_de_bolso/core/services/servidor_de_sync.dart';

/// O item apagado num aparelho não pode ressuscitar na sincronização.
///
/// O caminho da ressurreição: o repositório apaga a linha local e chama
/// `deleteItem`, que avisa a nuvem — mas se a rede está fora do ar, o aviso
/// morre num catch. A cópia do servidor sobrevive, e o passo de download do
/// `syncAll` seguinte ("baixar o que só existe no servidor") traz o registro
/// de volta. Com a sincronização aberta para todo mundo, isso alcança as 116
/// contas, sobre o tipo de dado mais íntimo do app.
///
/// Não há dublê do syncAll, do deleteItem nem do fullDownload: o risco mora
/// neles, e eles rodam de verdade contra um sqlite de verdade. O dublê é só a
/// borda de rede ([ServidorDeSync]) — um servidor de mentira que guarda
/// linhas em memória e sabe ficar fora do ar.
class ServidorDeMentira implements ServidorDeSync {
  final Map<String, List<Map<String, dynamic>>> tabelas = {};

  /// Fora do ar: toda chamada falha, como um aparelho sem rede.
  bool foraDoAr = false;

  /// Simula o painel sem a migração `sync_tombstones_migration.sql`: as
  /// operações de lápide falham, o resto do servidor funciona.
  bool semTabelaDeLapides = false;

  List<Map<String, dynamic>> _tabela(String nome) =>
      tabelas.putIfAbsent(nome, () => []);

  List<Map<String, dynamic>> linhasDe(String nome) =>
      List.unmodifiable(_tabela(nome));

  void _exigirRede() {
    if (foraDoAr) throw Exception('rede fora do ar');
  }

  @override
  Future<List<Map<String, dynamic>>> linhasDoUsuario(
    String tabela,
    String userId,
  ) async {
    _exigirRede();
    return _tabela(tabela)
        .where((l) => l['user_id'] == userId)
        .map(Map<String, dynamic>.from)
        .toList();
  }

  @override
  Future<void> upsert(
    String tabela,
    Map<String, dynamic> linha, {
    String? onConflict,
  }) async {
    _exigirRede();
    final lista = _tabela(tabela);
    final chaves = onConflict?.split(',') ?? ['id'];
    lista.removeWhere((l) => chaves.every((c) => l[c] == linha[c]));
    lista.add(Map<String, dynamic>.from(linha));
  }

  @override
  Future<String?> ritesDoDia(
    String tabela,
    String userId,
    String date,
  ) async {
    _exigirRede();
    final linhas = _tabela(tabela)
        .where((l) => l['user_id'] == userId && l['date'] == date);
    return linhas.isEmpty ? null : linhas.first['rites'] as String?;
  }

  @override
  Future<void> apagarLinha(String tabela, String userId, dynamic id) async {
    _exigirRede();
    _tabela(tabela)
        .removeWhere((l) => l['user_id'] == userId && l['id'] == id);
  }

  @override
  Future<void> apagarOutrosDias(
    String tabela,
    String userId,
    String date,
  ) async {
    _exigirRede();
    _tabela(tabela)
        .removeWhere((l) => l['user_id'] == userId && l['date'] != date);
  }

  void _exigirTabelaDeLapides() {
    _exigirRede();
    if (semTabelaDeLapides) {
      throw Exception('relation "public.sync_tombstones" does not exist');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> lapidesDoUsuario(String userId) async {
    _exigirTabelaDeLapides();
    return _tabela('sync_tombstones')
        .where((l) => l['user_id'] == userId)
        .map(Map<String, dynamic>.from)
        .toList();
  }

  @override
  Future<void> gravarLapide(Map<String, dynamic> lapide) async {
    _exigirTabelaDeLapides();
    final lista = _tabela('sync_tombstones');
    lista.removeWhere((l) =>
        l['user_id'] == lapide['user_id'] &&
        l['entity'] == lapide['entity'] &&
        l['item_id'] == lapide['item_id']);
    lista.add(Map<String, dynamic>.from(lapide));
  }

  @override
  Future<void> apagarLapide(
    String userId,
    String entity,
    String itemId,
  ) async {
    _exigirTabelaDeLapides();
    _tabela('sync_tombstones').removeWhere((l) =>
        l['user_id'] == userId &&
        l['entity'] == entity &&
        l['item_id'] == itemId);
  }

  @override
  Future<void> apagarLinhaAteQuando(
    String tabela,
    String userId,
    dynamic id,
    String updatedAtIso,
  ) async {
    _exigirRede();
    final limite = DateTime.parse(updatedAtIso);
    _tabela(tabela).removeWhere((l) {
      if (l['user_id'] != userId || l['id'] != id) return false;
      final updatedAt = DateTime.tryParse(l['updated_at']?.toString() ?? '');
      return updatedAt == null || !updatedAt.isAfter(limite);
    });
  }
}
