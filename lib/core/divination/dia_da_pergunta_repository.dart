import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../services/usage_coordinator.dart';
import 'regra_da_tiragem.dart';

/// O que o app lembra da pessoa NAQUELE dia, NAQUELA ferramenta.
///
/// Os dois campos parecem o mesmo e não são:
///
/// - [perguntaDoDia] é a ÂNCORA da cota, guardada normalizada. É ela que
///   [decidirTiragem] compara para saber se a pergunta é nova. Só muda quando
///   uma tiragem é de fato cobrada.
/// - [ultimaPergunta] é o RASCUNHO, na grafia original. É o que repõe o texto
///   no campo quando a pessoa volta à tela, e muda a cada edição, sem cobrar
///   nada.
///
/// Trocar os dois de lugar não quebra a comparação (normalizado contra
/// normalizado), mas faz o campo repor a pergunta em minúsculas — um defeito
/// silencioso e chato de rastrear.
class EstadoDoDia {
  const EstadoDoDia({this.perguntaDoDia, this.ultimaPergunta});
  final String? perguntaDoDia;
  final String? ultimaPergunta;
}

/// A memória do dia, uma por ferramenta.
///
/// Antes só o tarô tinha (`tarot_day_state`), e por isso só ele sabia dizer
/// "esta é a pergunta de hoje". Runas e oráculo passam a ter a sua, cada uma
/// com a sua cota e a sua âncora: a pergunta escrita no tarô não gasta nem
/// libera a tiragem das runas.
///
/// A escrita participa da MESMA transação do resultado da tiragem — é o que
/// impede o estado de dizer que cobrou uma tiragem que não chegou a existir.
class DiaDaPerguntaRepository {
  DiaDaPerguntaRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;
  final DatabaseHelper _dbHelper;

  static const tarot = 'tarot';
  static const runas = 'runes';
  static const oraculo = 'oracle';

  Future<EstadoDoDia> read(String userId, DateTime day,
      {required String tool}) async {
    final seed = await legacySeed(userId, day, tool: tool);
    final db = await _dbHelper.database;
    return db.transaction((txn) => ensureIn(txn,
        userId: userId,
        dayKey: UsageCoordinator.dayKey(day),
        tool: tool,
        seed: seed));
  }

  /// Guarda o que a pessoa escreveu. Com [ancorar] em false — o padrão —
  /// só o rascunho muda: digitar não pode cobrar nem mover a âncora da cota.
  Future<void> remember({
    required String userId,
    required DateTime day,
    required String tool,
    required String question,
    bool ancorar = false,
  }) async {
    final seed = await legacySeed(userId, day, tool: tool);
    final db = await _dbHelper.database;
    final key = UsageCoordinator.dayKey(day);
    await db.transaction((txn) async {
      await ensureIn(txn,
          userId: userId, dayKey: key, tool: tool, seed: seed);
      await txn.update(
        'day_question_state',
        {
          if (ancorar) 'daily_question': normalizarPergunta(question),
          'last_question': question.trim(),
        },
        where: 'user_id = ? AND day_key = ? AND tool = ?',
        whereArgs: [userId, key, tool],
      );
    });
  }

  /// O que as preferências antigas do tarô ainda sabem sobre hoje.
  ///
  /// Só o tarô tem semente: as chaves `tarot_daily_q_` / `tarot_last_q_`
  /// nasceram antes de qualquer outra ferramenta ter pergunta, e não há nada
  /// equivalente a resgatar para runas e oráculo.
  static Future<EstadoDoDia> legacySeed(String userId, DateTime day,
      {required String tool}) async {
    if (tool != tarot) return const EstadoDoDia();
    final prefs = await SharedPreferences.getInstance();
    final key = UsageCoordinator.dayKey(day);
    return EstadoDoDia(
      perguntaDoDia: perguntaSeForDeHoje(
          guardada: prefs.getString('tarot_daily_q_$userId'), hoje: key),
      ultimaPergunta: perguntaSeForDeHoje(
          guardada: prefs.getString('tarot_last_q_$userId'), hoje: key),
    );
  }

  static Future<EstadoDoDia> ensureIn(
    DatabaseExecutor db, {
    required String userId,
    required String dayKey,
    required String tool,
    required EstadoDoDia seed,
  }) async {
    await db.insert(
      'day_question_state',
      {
        'user_id': userId,
        'day_key': dayKey,
        'tool': tool,
        'daily_question': seed.perguntaDoDia,
        'last_question': seed.ultimaPergunta,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    final rows = await db.query('day_question_state',
        where: 'user_id = ? AND day_key = ? AND tool = ?',
        whereArgs: [userId, dayKey, tool]);
    return EstadoDoDia(
      perguntaDoDia: rows.single['daily_question'] as String?,
      ultimaPergunta: rows.single['last_question'] as String?,
    );
  }
}
