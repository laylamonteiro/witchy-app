import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/diary/data/models/free_writing_model.dart';

/// O acervo unificado: title/source no round-trip e a garantia de que o
/// copyWith do autosave nunca "des-tipa" uma página gerada.
void main() {
  test('round-trip toMap/fromMap com título e origem', () {
    final entry = FreeWritingModel(
      id: 'id-1',
      userId: 'user-1',
      title: 'Leitura de Runas',
      content: '✦ Pergunta\nResposta',
      source: FreeWritingSource.runes,
      createdAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(1700000001000),
      synced: true,
    );

    final restored = FreeWritingModel.fromMap(entry.toMap());
    expect(restored.title, 'Leitura de Runas');
    expect(restored.source, FreeWritingSource.runes);
    expect(restored.content, entry.content);
    expect(restored.synced, isTrue);
  });

  test('mapa legado (sem title/source) vira reflexão livre', () {
    final restored = FreeWritingModel.fromMap({
      'id': 'antiga',
      'user_id': 'user-1',
      'content': 'Só o texto de antes',
      'created_at': 1700000000000,
      'updated_at': null,
      'synced': 1,
    });
    expect(restored.title, isNull);
    expect(restored.source, FreeWritingSource.free);
    expect(restored.updatedAt, restored.createdAt);
  });

  test('reflexão nova nasce source=free e sem título', () {
    final entry = FreeWritingModel(content: 'pensamento');
    expect(entry.source, FreeWritingSource.free);
    expect(entry.title, isNull);
  });

  test('copyWith preserva source (autosave não des-tipa página gerada)', () {
    final page = FreeWritingModel(
      content: 'página da lição',
      title: 'Página',
      source: FreeWritingSource.grimorioVivo,
    );
    final edited = page.copyWith(content: 'página editada');
    expect(edited.source, FreeWritingSource.grimorioVivo);
    expect(edited.title, 'Página');
    expect(edited.id, page.id);
  });

  test('grupo de leituras cobre as quatro origens de adivinhação', () {
    expect(
      FreeWritingSource.readings,
      containsAll([
        FreeWritingSource.palmistry,
        FreeWritingSource.runes,
        FreeWritingSource.pendulum,
        FreeWritingSource.oracle,
      ]),
    );
    expect(FreeWritingSource.readings,
        isNot(contains(FreeWritingSource.grimorioVivo)));
    expect(
        FreeWritingSource.readings, isNot(contains(FreeWritingSource.free)));
  });
}
