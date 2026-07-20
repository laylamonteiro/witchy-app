import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/models/spell_model.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/repositories/spell_repository.dart';
import 'package:grimorio_de_bolso/features/grimoire/presentation/providers/spell_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SpellRepository repository;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    repository = SpellRepository();
    final db = await DatabaseHelper.instance.database;
    await db.delete('spells');
  });

  SpellModel buildSpell({
    required String id,
    required String name,
    bool isPreloaded = false,
  }) {
    return SpellModel(
      id: id,
      userId: isPreloaded ? 'app' : 'user-1',
      name: name,
      purpose: 'Teste',
      type: SpellType.attraction,
      category: SpellCategory.other,
      ingredients: const ['vela'],
      steps: 'Acenda a vela.',
      isPreloaded: isPreloaded,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  }

  group('SpellRepository protege feitiços pré-carregados', () {
    test('update ignora alterações em registros pré-carregados', () async {
      final preloadedSpell = buildSpell(
        id: 'preloaded-update',
        name: 'Feitiço original',
        isPreloaded: true,
      );
      await repository.insert(preloadedSpell);

      final updatedRows = await repository.update(
        preloadedSpell.copyWith(name: 'Feitiço alterado'),
      );

      final persisted = await repository.getById(preloadedSpell.id);
      expect(updatedRows, 0);
      expect(persisted, isNotNull);
      expect(persisted!.name, preloadedSpell.name);
      expect(persisted.updatedAt, preloadedSpell.updatedAt);
    });

    test('delete ignora exclusões de registros pré-carregados', () async {
      final preloadedSpell = buildSpell(
        id: 'preloaded-delete',
        name: 'Feitiço protegido',
        isPreloaded: true,
      );
      await repository.insert(preloadedSpell);

      final deletedRows = await repository.delete(preloadedSpell.id);

      final persisted = await repository.getById(preloadedSpell.id);
      expect(deletedRows, 0);
      expect(persisted, isNotNull);
      expect(persisted!.name, preloadedSpell.name);
    });

    test('continua permitindo atualizar e excluir registros do usuário', () async {
      final userSpell = buildSpell(id: 'user-spell', name: 'Feitiço editável');
      await repository.insert(userSpell);

      final updatedRows = await repository.update(
        userSpell.copyWith(name: 'Feitiço atualizado'),
      );
      final updated = await repository.getById(userSpell.id);
      expect(updatedRows, 1);
      expect(updated!.name, 'Feitiço atualizado');

      final deletedRows = await repository.delete(userSpell.id);
      final deleted = await repository.getById(userSpell.id);
      expect(deletedRows, 1);
      expect(deleted, isNull);
    });
  });

  group('SpellProvider protege feitiços pré-carregados', () {
    test('updateSpell retorna sem alterar spell pré-carregado', () async {
      final preloadedSpell = buildSpell(
        id: 'provider-preloaded-update',
        name: 'Pré-carregado original',
        isPreloaded: true,
      );
      await repository.insert(preloadedSpell);

      final provider = SpellProvider();
      await provider.updateSpell(
        preloadedSpell.copyWith(name: 'Pré-carregado alterado'),
      );

      final persisted = await repository.getById(preloadedSpell.id);
      expect(provider.error, isNull);
      expect(persisted, isNotNull);
      expect(persisted!.name, preloadedSpell.name);
    });

    test('deleteSpell retorna sem excluir spell pré-carregado', () async {
      final preloadedSpell = buildSpell(
        id: 'provider-preloaded-delete',
        name: 'Pré-carregado protegido',
        isPreloaded: true,
      );
      await repository.insert(preloadedSpell);

      final provider = SpellProvider();
      await provider.deleteSpell(preloadedSpell.id);

      final persisted = await repository.getById(preloadedSpell.id);
      expect(provider.error, isNull);
      expect(persisted, isNotNull);
      expect(persisted!.name, preloadedSpell.name);
    });
  });
}
