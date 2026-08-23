import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/services/data_sync_service.dart';
import 'package:grimorio_de_bolso/core/services/servidor_de_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const uid = '11111111-2222-3333-4444-555555555555';

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  final service = DataSyncService();
  late ServidorDeMentira servidor;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    servidor = ServidorDeMentira();
    service.configurarParaTeste(servidor, uid);
    final db = await DatabaseHelper.instance.database;
    await db.delete('dreams');
  });

  Map<String, dynamic> sonho(String id) => {
        'id': id,
        'user_id': uid,
        'title': 'Cobra no jardim',
        'content': 'Uma cobra dourada atravessava o canteiro.',
        'date': 1700000000000,
        'created_at': 1700000000000,
        'updated_at': 1700000000000,
        'synced': 0,
      };

  group('a lápide da exclusão', () {
    test('item apagado com a rede fora do ar não ressuscita no sync seguinte',
        () async {
      final db = await DatabaseHelper.instance.database;
      await db.insert('dreams', sonho('sonho-1'));

      // Primeira varredura: o sonho sobe para a nuvem.
      var resultado = await service.syncAll();
      expect(resultado.success, isTrue, reason: resultado.detailedError);
      expect(servidor.linhasDe('dreams'), hasLength(1));

      // O apagar do repositório, com a rede fora do ar: a linha local some
      // e o aviso à nuvem morre no catch do deleteItem. É o cenário de
      // avião, túnel, wifi caído — o mais comum de todos.
      servidor.foraDoAr = true;
      await db.delete('dreams', where: 'id = ?', whereArgs: ['sonho-1']);
      await service.deleteItem(SyncEntity.dreams, 'sonho-1');

      // A rede volta e a varredura roda de novo.
      servidor.foraDoAr = false;
      resultado = await service.syncAll();
      expect(resultado.success, isTrue, reason: resultado.detailedError);

      final deVolta =
          await db.query('dreams', where: 'id = ?', whereArgs: ['sonho-1']);
      expect(
        deVolta,
        isEmpty,
        reason: 'o sonho apagado ressuscitou no download da sincronização',
      );
      expect(
        servidor.linhasDe('dreams'),
        isEmpty,
        reason: 'a cópia do servidor precisa ser purgada quando a rede volta',
      );
    });
  });
}
