import 'package:flutter/foundation.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/services/data_sync_service.dart';
import '../models/free_writing_model.dart';
import '../repositories/free_writing_repository.dart';
import 'reading_archive_composer.dart';

/// Escreve a página de uma leitura no acervo "Meus Registros" no instante em
/// que a leitura acontece.
///
/// Antes havia um botão "Salvar nos Registros" ao pé de cada tiragem. A
/// consulta já era gravada no histórico da própria ferramenta — é dele que
/// saem as Jornadas, o rito do dia e a Leitura do Ciclo —, mas só virava
/// página do acervo se a pessoa tocasse ali. Quem não tocasse ficava com um
/// acervo que não contava a própria prática, e não havia como voltar atrás:
/// meses depois, na hora de pedir a Leitura do Ciclo, o que ficou de fora
/// ficou de fora. Agora a página nasce junto com a tiragem — a Bruxa não tem
/// que se lembrar de guardar o que ela já fez.
///
/// O id da entrada é o MESMO id da leitura, e é isso que sustenta a
/// idempotência: o Conselheiro que chega depois reescreve a página em vez de
/// criar uma segunda, e reabrir uma mesa já tirada (o tarô é idempotente por
/// assinatura) cai na mesma linha.
class ReadingArchiveRecorder {
  ReadingArchiveRecorder({
    FreeWritingRepository? repository,
    DatabaseHelper? dbHelper,
  })  : _repository = repository ?? FreeWritingRepository(),
        _dbHelper = dbHelper ?? DatabaseHelper.instance;

  final FreeWritingRepository _repository;
  final DatabaseHelper _dbHelper;

  /// Onde cada origem do acervo guarda a consulta que gerou a página.
  ///
  /// A quiromancia não está aqui porque não tem tabela: a página É a leitura.
  static const Map<String, ({String table, SyncEntity entity})> _historico = {
    FreeWritingSource.runes: (
      table: 'rune_readings',
      entity: SyncEntity.runeReadings,
    ),
    FreeWritingSource.pendulum: (
      table: 'pendulum_consultations',
      entity: SyncEntity.pendulumConsultations,
    ),
    FreeWritingSource.oracle: (
      table: 'oracle_readings',
      entity: SyncEntity.oracleReadings,
    ),
    FreeWritingSource.tarot: (
      table: 'tarot_readings',
      entity: SyncEntity.tarotReadings,
    ),
  };

  /// Grava (ou reescreve) a página da leitura [readingId].
  ///
  /// Best-effort de propósito: a tiragem já aconteceu na tela e o histórico
  /// da ferramenta já a registrou — uma falha ao escrever o acervo não pode
  /// derrubar a leitura na cara da pessoa. Falhou, fica o debugPrint.
  Future<void> record({
    required String readingId,
    required String userId,
    required String source,
    required ArchiveEntry page,
    DateTime? createdAt,
  }) async {
    try {
      // A data de criação é a da TIRAGEM, não a da reescrita: o Conselheiro
      // muda o texto, nunca o momento. É por `created_at` que a Leitura do
      // Ciclo põe a leitura no dia certo da linha do tempo.
      final existing = await _repository.getById(readingId);
      await _repository.insert(
        FreeWritingModel(
          id: readingId,
          userId: userId,
          title: page.title,
          content: page.content,
          source: source,
          createdAt: existing?.createdAt ?? createdAt,
        ),
      );
    } catch (e) {
      debugPrint('ReadingArchiveRecorder: falhou ao gravar $source: $e');
    }
  }

  /// Apaga a consulta que deu origem à página [readingId], quando ela tem
  /// uma tabela de histórico.
  ///
  /// Jogar a página fora tem que jogar a consulta junto: elas são o MESMO
  /// registro, com o mesmo id, e só a página é visível. Sem isto, apagar uma
  /// tiragem em "Meus Registros" deixava a linha da ferramenta viva — o
  /// contador do Ciclo não baixava (é ela que conta) e, pior, a tiragem
  /// voltava para o material da IA pelo bloco `oracle`, com pergunta e
  /// resposta, depois de a pessoa ter mandado apagar.
  ///
  /// A lápide é o que faz a exclusão sobreviver à sincronização: sem ela,
  /// outro aparelho traria a linha de volta.
  Future<void> discardReading({
    required String readingId,
    required String source,
  }) async {
    final historico = _historico[source];
    if (historico == null) return;
    try {
      final db = await _dbHelper.database;
      await db.delete(
        historico.table,
        where: 'id = ?',
        whereArgs: [readingId],
      );
      await DataSyncService().deleteItem(historico.entity, readingId);
    } catch (e) {
      debugPrint('ReadingArchiveRecorder: falhou ao apagar $source: $e');
    }
  }
}
