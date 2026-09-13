import 'dart:async';

import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';
import '../models/free_writing_model.dart';

class FreeWritingRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final DataSyncService _syncService = DataSyncService();

  Future<List<FreeWritingModel>> getAll(String userId) async {
    final db = await _dbHelper.database;
    await _recarimbarEspelhos(db);
    final List<Map<String, dynamic>> maps = await db.query(
      'free_writings',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );
    return List.generate(maps.length, (i) => FreeWritingModel.fromMap(maps[i]));
  }

  Future<FreeWritingModel?> getById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'free_writings',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return FreeWritingModel.fromMap(maps.first);
  }

  /// Esta página fica neste aparelho?
  ///
  /// São TRÊS as portas que dão da tabela `free_writings` para a nuvem, e
  /// todas passam por este repositório:
  ///
  /// 1. `syncItem`, no insert e no update — o upload direto;
  /// 2. `deleteItem`, na exclusão — ele grava uma lápide LOCAL e permanente
  ///    com o id do item e a manda ao servidor. O filtro de upload do
  ///    DataSyncService (`_isSyncableItem`) não é consultado nesse caminho,
  ///    então barrar o upload não barra a lápide;
  /// 3. a varredura periódica, que recolhe toda linha com `synced = 0`. Por
  ///    isso a linha é carimbada `synced = 1` aqui, a cada gravação: não
  ///    quer dizer "já subiu", quer dizer "não sobe" — e o carimbo tem de
  ///    ser reposto porque `copyWith` devolve `synced: false`, e um toque no
  ///    formulário do acervo entregaria a página à varredura.
  static bool _ficaNoAparelho(String source) =>
      FreeWritingSource.neverLeavesDevice.contains(source);

  /// Insere ou substitui (upsert) — reutilizado pelo autosave para manter o
  /// mesmo id ao longo da edição de uma reflexão.
  Future<int> insert(FreeWritingModel writing) async {
    final db = await _dbHelper.database;
    final row = writing.toMap();
    final local = _ficaNoAparelho(writing.source);
    if (local) row['synced'] = 1;
    final result = await db.insert(
      'free_writings',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (!local) _syncService.syncItem(SyncEntity.freeWritings, row);
    return result;
  }

  Future<int> update(FreeWritingModel writing) async {
    final db = await _dbHelper.database;
    final row = writing.toMap();
    final local = _ficaNoAparelho(writing.source);
    if (local) row['synced'] = 1;
    final result = await db.update(
      'free_writings',
      row,
      where: 'id = ?',
      whereArgs: [writing.id],
    );
    if (!local) _syncService.syncItem(SyncEntity.freeWritings, row);
    return result;
  }

  /// Repõe o carimbo de "não sobe" em espelhos que o perderam.
  ///
  /// A porta do primeiro login ESTÁ FECHADA, e é importante dizer isto aqui:
  /// este comentário já anunciou a brecha como aberta, e quem o lesse gastaria
  /// o dia consertando o que está consertado — ou, pior, afrouxaria o texto
  /// legal para caber numa brecha que não existe mais. São duas guardas, e as
  /// duas vivem fora deste arquivo:
  ///
  /// 1. `DataSyncService._isSyncableItem` devolve `false` para `free_writings`
  ///    cuja `source` está em [FreeWritingSource.neverLeavesDevice]. É o funil
  ///    por onde TODA varredura passa, inclusive a do primeiro login, que roda
  ///    antes de qualquer tela recarregar;
  /// 2. `claimLegacyData` exclui essas origens da adoção (`source NOT IN`),
  ///    então a linha anônima do ciclo não chega nem a ser carimbada
  ///    `synced = 0` sob a conta nova.
  ///
  /// Este método é a TERCEIRA camada, e continua valendo: ele alcança as
  /// linhas antigas — as que atravessaram a adoção antes de o `NOT IN` existir
  /// — e qualquer caminho futuro que grave `synced = 0` aqui sem passar por
  /// nenhuma das duas guardas. Rede de segurança, não remendo insuficiente.
  ///
  /// O `synced IS NULL` entra no filtro porque a varredura recolhe
  /// `(synced = 0 OR synced IS NULL)`: um predicado mais estreito que o dela
  /// deixaria de fora exatamente as linhas que ela levaria.
  Future<void> _recarimbarEspelhos(DatabaseExecutor db) async {
    await db.update(
      'free_writings',
      {'synced': 1},
      where: '(synced = 0 OR synced IS NULL) AND source IN '
          '(${FreeWritingSource.neverLeavesDevice.map((_) => '?').join(', ')})',
      whereArgs: FreeWritingSource.neverLeavesDevice.toList(),
    );
  }

  /// Apaga as páginas-espelho de uma origem que fica no aparelho — todas as
  /// da conta, ou só as de um dia, quando [idEndsWith] é dado.
  ///
  /// Existe para o "apagar meus registros do ciclo" e para o apagar de um dia
  /// só: a página é função da linha, e uma linha que deixou de existir não
  /// pode continuar com vitrine no Grimório. Sem lápide e sem aviso à nuvem,
  /// porque nada disto jamais esteve lá — e uma lápide por dia apagado seria
  /// o calendário menstrual inteiro subindo no exato gesto em que ela pede
  /// para apagar.
  ///
  /// O corte por FIM DE ID, e não pelo id inteiro, é o que dá conta da
  /// adoção: `claimLegacyData` troca o `user_id` da linha e não toca no `id`,
  /// então a página escrita antes do login fica com a conta nova e a chave
  /// velha. Casar pelo sufixo (o dia) alcança as duas chaves, que são da
  /// mesma pessoa e do mesmo dia — e é o que impede um espelho órfão de
  /// sobreviver ao dia que ela apagou.
  Future<int> deleteDeviceOnly({
    required String userId,
    required String source,
    String? idEndsWith,
  }) async {
    if (!_ficaNoAparelho(source)) return 0;
    final db = await _dbHelper.database;
    return db.delete(
      'free_writings',
      where: 'user_id = ? AND source = ?'
          '${idEndsWith == null ? '' : ' AND id LIKE ?'}',
      whereArgs: [
        userId,
        source,
        if (idEndsWith != null) '%$idEndsWith',
      ],
    );
  }

  /// Apaga a reflexão. Este é o caminho por onde o "apagar o registro
  /// menstrual" da tela de Privacidade derruba os relatórios derivados, em
  /// laço — por isso o aviso à nuvem é condicionado a ter havido exclusão de
  /// verdade: sem linha apagada não há cópia remota para purgar, e mandar o
  /// id assim mesmo era falar do que já não existe aqui.
  ///
  /// Continua sem `await` de propósito: `deleteItem` engole os próprios
  /// erros e faz uma ida à rede, e a tela não deve esperar por ela para
  /// mostrar que a reflexão saiu. O `unawaited` diz isso em voz alta.
  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    // Quem era a linha ANTES de sumir: depois do delete não há mais como
    // saber se este id pode ser dito à nuvem, e o id da página do ciclo
    // carrega a data em que ela sangrou.
    final existing = await getById(id);
    final result = await db.delete(
      'free_writings',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result > 0 &&
        !_ficaNoAparelho(existing?.source ?? FreeWritingSource.free)) {
      unawaited(_syncService.deleteItem(SyncEntity.freeWritings, id));
    }
    return result;
  }
}
