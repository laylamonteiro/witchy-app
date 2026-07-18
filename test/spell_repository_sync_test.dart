import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/models/spell_model.dart';
import 'package:grimorio_de_bolso/features/grimoire/data/repositories/spell_repository.dart';

void main() {
  group('SpellRepository sync', () {
    late _FakeSpellLocalStore localStore;
    late _FakeSpellSyncGateway syncGateway;
    late SpellRepository repository;

    setUp(() {
      localStore = _FakeSpellLocalStore();
      syncGateway = _FakeSpellSyncGateway();
      repository = SpellRepository(
        localStore: localStore,
        syncGateway: syncGateway,
      );
    });

    test('insert não sincroniza feitiço ancestral', () async {
      final spell = _spell(isPreloaded: true);

      await repository.insert(spell);

      expect(syncGateway.syncedIds, isEmpty);
      expect(syncGateway.deletedIds, isEmpty);
    });

    test('update não sincroniza feitiço ancestral', () async {
      final spell = _spell(isPreloaded: true);
      localStore.seed(spell);

      await repository.update(spell);

      expect(syncGateway.syncedIds, isEmpty);
      expect(syncGateway.deletedIds, isEmpty);
    });

    test('delete carrega registro e não sincroniza delete de feitiço ancestral',
        () async {
      final spell = _spell(id: 'ancestral-spell', isPreloaded: true);
      localStore.seed(spell);

      await repository.delete(spell.id);

      expect(localStore.loadedIds, [spell.id]);
      expect(localStore.deletedIds, [spell.id]);
      expect(syncGateway.syncedIds, isEmpty);
      expect(syncGateway.deletedIds, isEmpty);
    });

    test('feitiço pessoal continua sincronizando insert, update e delete',
        () async {
      final spell = _spell(id: 'personal-spell', isPreloaded: false);
      localStore.seed(spell);

      await repository.insert(spell);
      await repository.update(spell);
      await repository.delete(spell.id);

      expect(syncGateway.syncedIds, [spell.id, spell.id]);
      expect(syncGateway.deletedIds, [spell.id]);
    });
  });
}

SpellModel _spell({String id = 'spell-id', required bool isPreloaded}) {
  return SpellModel(
    id: id,
    userId: isPreloaded ? null : 'user-id',
    name: isPreloaded ? 'Feitiço Ancestral' : 'Feitiço Pessoal',
    purpose: 'Proteção',
    type: SpellType.attraction,
    category: SpellCategory.protection,
    ingredients: const ['sal'],
    steps: 'Mentalize sua intenção.',
    isPreloaded: isPreloaded,
  );
}

class _FakeSpellLocalStore implements SpellLocalStore {
  final Map<String, SpellModel> _spells = {};
  final List<String> loadedIds = [];
  final List<String> deletedIds = [];

  void seed(SpellModel spell) => _spells[spell.id] = spell;

  @override
  Future<int> insert(SpellModel spell) async {
    _spells[spell.id] = spell;
    return 1;
  }

  @override
  Future<int> update(SpellModel spell) async {
    _spells[spell.id] = spell;
    return 1;
  }

  @override
  Future<int> delete(String id) async {
    deletedIds.add(id);
    return _spells.remove(id) == null ? 0 : 1;
  }

  @override
  Future<SpellModel?> getById(String id) async {
    loadedIds.add(id);
    return _spells[id];
  }

  @override
  Future<List<SpellModel>> getAll() async => _spells.values.toList();

  @override
  Future<List<SpellModel>> getForUser(String userId) async => _spells.values
      .where((spell) => spell.userId == userId || spell.isPreloaded)
      .toList();

  @override
  Future<List<SpellModel>> getByPurpose(String purpose) async => _spells.values
      .where((spell) => spell.purpose.contains(purpose))
      .toList();

  @override
  Future<List<SpellModel>> getByType(SpellType type) async =>
      _spells.values.where((spell) => spell.type == type).toList();

  @override
  Future<int> count() async => _spells.length;
}

class _FakeSpellSyncGateway implements SpellSyncGateway {
  final List<String> syncedIds = [];
  final List<String> deletedIds = [];

  @override
  Future<void> sync(SpellModel spell) async {
    syncedIds.add(spell.id);
  }

  @override
  Future<void> delete(String id) async {
    deletedIds.add(id);
  }
}
