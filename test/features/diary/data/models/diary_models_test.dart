import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/diary/data/models/dream_model.dart';
import 'package:grimorio_de_bolso/features/diary/data/models/desire_model.dart';
import 'package:grimorio_de_bolso/features/diary/data/models/gratitude_model.dart';
import 'package:grimorio_de_bolso/features/diary/data/models/affirmation_model.dart';

void main() {
  final fixedDate = DateTime(2024, 6, 15, 10, 30);

  group('DreamModel', () {
    test('constructor generates UUID when id is null', () {
      final dream = DreamModel(
        title: 'Test',
        content: 'Content',
        tags: ['lucid'],
      );
      expect(dream.id, isNotEmpty);
    });

    test('constructor defaults synced to false', () {
      final dream = DreamModel(
        title: 'Test',
        content: 'Content',
        tags: [],
      );
      expect(dream.synced, isFalse);
    });

    group('toMap / fromMap', () {
      test('round-trip preserves all fields', () {
        final dream = DreamModel(
          id: 'dream-1',
          userId: 'user-1',
          title: 'Flying Dream',
          content: 'I was flying',
          tags: ['lucid', 'recurring'],
          feeling: 'happy',
          date: fixedDate,
          createdAt: fixedDate,
          updatedAt: fixedDate,
          synced: true,
        );

        final map = dream.toMap();
        final restored = DreamModel.fromMap(map);

        expect(restored.id, dream.id);
        expect(restored.userId, dream.userId);
        expect(restored.title, dream.title);
        expect(restored.content, dream.content);
        expect(restored.tags, dream.tags);
        expect(restored.feeling, dream.feeling);
        expect(restored.synced, dream.synced);
      });

      test('tags serialized with ||| separator', () {
        final dream = DreamModel(
          title: 'Test',
          content: 'Content',
          tags: ['a', 'b', 'c'],
          date: fixedDate,
          createdAt: fixedDate,
          updatedAt: fixedDate,
        );
        expect(dream.toMap()['tags'], 'a|||b|||c');
      });

      test('fromMap handles empty tags', () {
        final dream = DreamModel(
          title: 'Test',
          content: 'Content',
          tags: [],
          date: fixedDate,
          createdAt: fixedDate,
          updatedAt: fixedDate,
        );
        final map = dream.toMap();
        map['tags'] = '';
        final restored = DreamModel.fromMap(map);
        expect(restored.tags, isEmpty);
      });

      test('fromMap handles null tags', () {
        final map = {
          'id': 'test',
          'user_id': 'user',
          'title': 'Test',
          'content': 'Content',
          'tags': null,
          'feeling': null,
          'date': fixedDate.millisecondsSinceEpoch,
          'created_at': fixedDate.millisecondsSinceEpoch,
          'updated_at': fixedDate.millisecondsSinceEpoch,
          'synced': 0,
        };
        final restored = DreamModel.fromMap(map);
        expect(restored.tags, isEmpty);
      });

      test('toMap uses local_user when userId is null', () {
        final dream = DreamModel(
          title: 'Test',
          content: 'Content',
          tags: [],
        );
        expect(dream.toMap()['user_id'], 'local_user');
      });
    });

    group('copyWith', () {
      test('copies with new values and resets synced', () {
        final dream = DreamModel(
          id: 'dream-1',
          title: 'Original',
          content: 'Content',
          tags: ['a'],
          synced: true,
        );
        final copy = dream.copyWith(title: 'Updated');
        expect(copy.title, 'Updated');
        expect(copy.id, dream.id);
        expect(copy.synced, isFalse);
      });
    });
  });

  group('DesireModel', () {
    test('constructor defaults status to open', () {
      final desire = DesireModel(
        title: 'Test',
        description: 'Description',
      );
      expect(desire.status, DesireStatus.open);
    });

    group('toMap / fromMap', () {
      test('round-trip preserves all fields', () {
        final desire = DesireModel(
          id: 'desire-1',
          userId: 'user-1',
          title: 'Wish',
          description: 'I wish for...',
          status: DesireStatus.manifesting,
          evolution: 'Getting closer',
          createdAt: fixedDate,
          updatedAt: fixedDate,
          synced: true,
        );

        final map = desire.toMap();
        final restored = DesireModel.fromMap(map);

        expect(restored.id, desire.id);
        expect(restored.title, desire.title);
        expect(restored.status, DesireStatus.manifesting);
        expect(restored.evolution, desire.evolution);
        expect(restored.synced, isTrue);
      });

      test('fromMap defaults to open for unknown status', () {
        final map = {
          'id': 'test',
          'user_id': 'user',
          'title': 'Test',
          'description': 'Desc',
          'status': 'unknown',
          'evolution': null,
          'created_at': fixedDate.millisecondsSinceEpoch,
          'updated_at': fixedDate.millisecondsSinceEpoch,
          'synced': 0,
        };
        final restored = DesireModel.fromMap(map);
        expect(restored.status, DesireStatus.open);
      });
    });

    group('copyWith', () {
      test('copies status correctly', () {
        final desire = DesireModel(
          title: 'Wish',
          description: 'I wish',
        );
        final manifested =
            desire.copyWith(status: DesireStatus.manifested);
        expect(manifested.status, DesireStatus.manifested);
        expect(manifested.id, desire.id);
      });
    });
  });

  group('DesireStatus extension', () {
    test('all statuses have displayName', () {
      for (final status in DesireStatus.values) {
        expect(status.displayName, isNotEmpty);
      }
    });

    test('all statuses have emoji', () {
      for (final status in DesireStatus.values) {
        expect(status.emoji, isNotEmpty);
      }
    });

    test('specific displayNames', () {
      expect(DesireStatus.open.displayName, 'Em Aberto');
      expect(DesireStatus.manifested.displayName, 'Manifestado');
    });
  });

  group('GratitudeModel', () {
    group('toMap / fromMap', () {
      test('round-trip preserves all fields', () {
        final gratitude = GratitudeModel(
          id: 'grat-1',
          userId: 'user-1',
          title: 'Grateful for...',
          content: 'The morning sun',
          tags: ['nature', 'peace'],
          date: fixedDate,
          createdAt: fixedDate,
          updatedAt: fixedDate,
          synced: true,
        );

        final map = gratitude.toMap();
        final restored = GratitudeModel.fromMap(map);

        expect(restored.id, gratitude.id);
        expect(restored.title, gratitude.title);
        expect(restored.tags, gratitude.tags);
        expect(restored.synced, isTrue);
      });

      test('fromMap handles null tags', () {
        final map = {
          'id': 'test',
          'user_id': 'user',
          'title': 'Test',
          'content': 'Content',
          'tags': null,
          'date': fixedDate.millisecondsSinceEpoch,
          'created_at': fixedDate.millisecondsSinceEpoch,
          'updated_at': fixedDate.millisecondsSinceEpoch,
          'synced': 0,
        };
        final restored = GratitudeModel.fromMap(map);
        expect(restored.tags, isEmpty);
      });

      test('fromMap falls back to created_at when updated_at is null', () {
        final map = {
          'id': 'test',
          'user_id': 'user',
          'title': 'Test',
          'content': 'Content',
          'tags': '',
          'date': fixedDate.millisecondsSinceEpoch,
          'created_at': fixedDate.millisecondsSinceEpoch,
          'updated_at': null,
          'synced': 0,
        };
        final restored = GratitudeModel.fromMap(map);
        expect(restored.updatedAt, restored.createdAt);
      });
    });
  });

  group('AffirmationModel', () {
    test('constructor defaults', () {
      final aff = AffirmationModel(
        text: 'I am powerful',
        category: AffirmationCategory.power,
      );
      expect(aff.isPreloaded, isFalse);
      expect(aff.synced, isFalse);
      expect(aff.isFavorite, isFalse);
    });

    group('toMap / fromMap', () {
      test('round-trip preserves all fields', () {
        final aff = AffirmationModel(
          id: 'aff-1',
          userId: 'user-1',
          text: 'I am powerful',
          category: AffirmationCategory.power,
          isPreloaded: true,
          createdAt: fixedDate,
          updatedAt: fixedDate,
          synced: true,
          isFavorite: true,
        );

        final map = aff.toMap();
        final restored = AffirmationModel.fromMap(map);

        expect(restored.id, aff.id);
        expect(restored.text, aff.text);
        expect(restored.category, AffirmationCategory.power);
        expect(restored.isPreloaded, isTrue);
        expect(restored.synced, isTrue);
        expect(restored.isFavorite, isTrue);
      });

      test('fromMap defaults to manifestation for unknown category', () {
        final map = {
          'id': 'test',
          'user_id': 'user',
          'text': 'Test',
          'category': 'unknown',
          'is_preloaded': 0,
          'created_at': fixedDate.millisecondsSinceEpoch,
          'updated_at': fixedDate.millisecondsSinceEpoch,
          'synced': 0,
          'is_favorite': 0,
        };
        final restored = AffirmationModel.fromMap(map);
        expect(restored.category, AffirmationCategory.manifestation);
      });
    });

    group('copyWith', () {
      test('toggles favorite', () {
        final aff = AffirmationModel(
          text: 'Test',
          category: AffirmationCategory.love,
        );
        final fav = aff.copyWith(isFavorite: true);
        expect(fav.isFavorite, isTrue);
        expect(fav.id, aff.id);
      });
    });

    group('getPreloadedAffirmations', () {
      test('returns non-empty list', () {
        final preloaded = AffirmationModel.getPreloadedAffirmations();
        expect(preloaded, isNotEmpty);
      });

      test('all preloaded affirmations have isPreloaded true', () {
        final preloaded = AffirmationModel.getPreloadedAffirmations();
        for (final aff in preloaded) {
          expect(aff.isPreloaded, isTrue);
        }
      });

      test('covers all categories', () {
        final preloaded = AffirmationModel.getPreloadedAffirmations();
        final categories = preloaded.map((a) => a.category).toSet();
        expect(categories, containsAll(AffirmationCategory.values));
      });
    });
  });

  group('AffirmationCategory extension', () {
    test('all categories have displayName', () {
      for (final cat in AffirmationCategory.values) {
        expect(cat.displayName, isNotEmpty);
      }
    });

    test('all categories have icon', () {
      for (final cat in AffirmationCategory.values) {
        expect(cat.icon, isNotEmpty);
      }
    });
  });
}
