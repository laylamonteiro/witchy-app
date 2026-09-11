import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/reading_session_schema.dart';
import 'package:grimorio_de_bolso/features/diary/data/models/free_writing_model.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/repositories/advisor_consultation_repository.dart';
import 'package:grimorio_de_bolso/features/grimoire/domain/advisor_consultation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'support/short_test_timeout.dart';

void main() {
  useShortTestTimeout();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  const user = 'advisor-user';
  final repo = AdvisorConsultationRepository();

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('advisor_consultations');
    await databaseFactory.setDatabasesPath(dir.path);
  });
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    for (final table in [...ReadingSessionSchema.tables, 'free_writings']) {
      await db.delete(table);
    }
  });

  test('a question starts pending and only a pending one can be answered or failed', () async {
    final started = await repo.start(userId: user, question: '  Which moon for protection?  ');
    expect(started.question, 'Which moon for protection?');
    expect(started.status, AdvisorConsultationStatus.pending);
    expect(started.isAnswered, isFalse);
    expect((await repo.latest(user))?.id, started.id);
    final answered = await repo.answer(id: started.id, userId: user, answer: 'The waxing moon.');
    expect(answered?.isAnswered, isTrue);
    expect(answered?.answer, 'The waxing moon.');
    final late = await repo.answer(id: started.id, userId: user, answer: 'Another answer');
    expect(late?.answer, 'The waxing moon.', reason: 'A late response never replaces one received');
    final failed = await repo.fail(id: started.id, userId: user);
    expect(failed?.status, AdvisorConsultationStatus.answered);
    await expectLater(repo.start(userId: user, question: '   '), throwsArgumentError);
  });

  test('a failed question keeps its text and a new attempt is a new consultation', () async {
    final first = await repo.start(userId: user, question: 'Q?');
    final failed = await repo.fail(id: first.id, userId: user);
    expect(failed?.status, AdvisorConsultationStatus.failed);
    expect(failed?.question, 'Q?');
    final second = await repo.start(userId: user, question: 'Q?',
        now: first.createdAt.add(const Duration(seconds: 1)));
    expect(second.id, isNot(first.id));
    expect((await repo.latest(user))?.id, second.id);
    await repo.abandonPending(user);
    expect((await repo.byId(second.id, user))?.status, AdvisorConsultationStatus.failed);
    expect((await repo.byId(first.id, user))?.status, AdvisorConsultationStatus.failed);
  });

  test('saving advice is idempotent and keeps the consultation date', () async {
    final started = await repo.start(userId: user, question: 'Q?', now: DateTime(2026, 9, 1, 8));
    await expectLater(repo.save(consultation: started, title: 't', content: 'c'),
        throwsStateError);
    final answered = (await repo.answer(id: started.id, userId: user, answer: 'A'))!;
    final saved = await repo.save(consultation: answered, title: 'Advice', content: 'Q?\nA');
    expect(saved.isSaved, isTrue);
    expect(saved.writingId, started.id);
    final again = await repo.save(consultation: answered, title: 'Other', content: 'Other');
    expect(again.writingId, started.id);
    final db = await DatabaseHelper.instance.database;
    final pages = await db.query('free_writings');
    expect(pages, hasLength(1));
    expect(pages.single['id'], started.id);
    expect(pages.single['source'], FreeWritingSource.advisor);
    expect(pages.single['title'], 'Advice');
    expect(pages.single['created_at'], DateTime(2026, 9, 1, 8).millisecondsSinceEpoch);
    expect((await repo.latest(user))?.isSaved, isTrue);
  });

  test('a deleted archive page can be saved again without a duplicate', () async {
    final started = await repo.start(userId: user, question: 'Q?');
    final answered = (await repo.answer(id: started.id, userId: user, answer: 'A'))!;
    await repo.save(consultation: answered, title: 'Advice', content: 'A');
    final db = await DatabaseHelper.instance.database;
    await db.delete('free_writings');
    await repo.save(consultation: answered, title: 'Advice', content: 'A');
    expect(await db.query('free_writings'), hasLength(1));
  });

  test('accounts never see each other', () async {
    final mine = await repo.start(userId: user, question: 'Mine?');
    final theirs = await repo.start(userId: 'someone-else', question: 'Theirs?');
    expect(await repo.byId(mine.id, 'someone-else'), isNull);
    expect(await repo.answer(id: theirs.id, userId: user, answer: 'x'), isNull);
    expect((await repo.byId(theirs.id, 'someone-else'))?.status,
        AdvisorConsultationStatus.pending);
    await repo.abandonPending(user);
    expect((await repo.byId(theirs.id, 'someone-else'))?.status,
        AdvisorConsultationStatus.pending);
    expect((await repo.latest(user))?.id, mine.id);
  });
}
