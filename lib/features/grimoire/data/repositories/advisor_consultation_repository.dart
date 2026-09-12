import 'package:uuid/uuid.dart';

import '../../../../core/database/database_helper.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/data/repositories/free_writing_repository.dart';
import '../../domain/advisor_consultation.dart';

/// Local history of Mystic Advisor questions. Rows are the request state:
/// started before the call, answered or failed after it. Nothing here calls
/// the AI, and "Save advice" is idempotent per consultation.
class AdvisorConsultationRepository {
  AdvisorConsultationRepository({
    DatabaseHelper? dbHelper,
    FreeWritingRepository? writings,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _writings = writings ?? FreeWritingRepository();

  final DatabaseHelper _dbHelper;
  final FreeWritingRepository _writings;

  Future<AdvisorConsultation> start({
    required String userId,
    required String question,
    DateTime? now,
  }) async {
    final asked = question.trim();
    if (asked.isEmpty) throw ArgumentError.value(question, 'question');
    final instant = (now ?? DateTime.now()).millisecondsSinceEpoch;
    final row = <String, Object?>{
      'id': const Uuid().v4(),
      'user_id': userId,
      'question': asked,
      'answer': null,
      'status': AdvisorConsultationStatus.pending.name,
      'writing_id': null,
      'created_at': instant,
      'updated_at': instant,
    };
    final db = await _dbHelper.database;
    await db.insert('advisor_consultations', row);
    return AdvisorConsultation.fromRow(row);
  }

  /// Stores the answer received for [id]. Only a pending consultation can be
  /// answered; a late response for a finished one changes nothing.
  Future<AdvisorConsultation?> answer({
    required String id,
    required String userId,
    required String answer,
  }) => _finish(id, userId, AdvisorConsultationStatus.answered, answer);

  Future<AdvisorConsultation?> fail({required String id, required String userId}) =>
      _finish(id, userId, AdvisorConsultationStatus.failed, null);

  Future<AdvisorConsultation?> _finish(String id, String userId,
      AdvisorConsultationStatus status, String? answer) async {
    final db = await _dbHelper.database;
    await db.update('advisor_consultations', {
      'status': status.name,
      'answer': answer,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, where: 'id = ? AND user_id = ? AND status = ?',
        whereArgs: [id, userId, AdvisorConsultationStatus.pending.name]);
    return byId(id, userId);
  }

  Future<AdvisorConsultation?> byId(String id, String userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query('advisor_consultations',
        where: 'id = ? AND user_id = ?', whereArgs: [id, userId], limit: 1);
    return rows.isEmpty ? null : AdvisorConsultation.fromRow(rows.single);
  }

  /// The most recent consultation of [userId], whatever its state.
  Future<AdvisorConsultation?> latest(String userId) async {
    final db = await _dbHelper.database;
    final rows = await db.query('advisor_consultations',
        where: 'user_id = ?', whereArgs: [userId],
        orderBy: 'created_at DESC, rowid DESC', limit: 1);
    return rows.isEmpty ? null : AdvisorConsultation.fromRow(rows.single);
  }

  /// Marks every pending row of [userId] as failed: after a restart no
  /// answer can still arrive, and a new attempt must be explicit.
  Future<void> abandonPending(String userId) async {
    final db = await _dbHelper.database;
    await db.update('advisor_consultations', {
      'status': AdvisorConsultationStatus.failed.name,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, where: 'user_id = ? AND status = ?',
        whereArgs: [userId, AdvisorConsultationStatus.pending.name]);
  }

  /// "Save advice": one archive page per consultation, with the same id, so
  /// a repeated tap or a reopened page never creates a second copy.
  Future<AdvisorConsultation> save({
    required AdvisorConsultation consultation,
    required String title,
    required String content,
  }) async {
    if (!consultation.isAnswered) {
      throw StateError('Only an answered consultation can be saved');
    }
    final current = await byId(consultation.id, consultation.userId);
    if (current == null) throw StateError('Unknown consultation');
    if (current.writingId != null) {
      final existing = await _writings.getById(current.writingId!);
      if (existing != null) return current;
    }
    await _writings.insert(FreeWritingModel(
      id: consultation.id,
      userId: consultation.userId,
      title: title,
      content: content,
      source: FreeWritingSource.advisor,
      createdAt: consultation.createdAt,
    ));
    final db = await _dbHelper.database;
    await db.update('advisor_consultations', {
      'writing_id': consultation.id,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, where: 'id = ? AND user_id = ?', whereArgs: [consultation.id, consultation.userId]);
    return (await byId(consultation.id, consultation.userId))!;
  }

}
