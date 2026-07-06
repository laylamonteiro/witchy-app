import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    group('factory constructors', () {
      test('defaultUser creates free local user', () {
        final user = UserModel.defaultUser();
        expect(user.id, 'local_user');
        expect(user.role, UserRole.free);
        expect(user.plan, SubscriptionPlan.free);
        expect(user.email, isNull);
        expect(user.isLocalUser, isTrue);
        expect(user.isAuthenticated, isFalse);
      });

      test('admin creates admin user', () {
        final user = UserModel.admin();
        expect(user.id, 'admin_user');
        expect(user.role, UserRole.admin);
        expect(user.plan, SubscriptionPlan.lifetime);
        expect(user.isAdmin, isTrue);
        expect(user.isPremium, isTrue);
      });
    });

    group('role checks', () {
      test('free user is not premium', () {
        final user = UserModel.defaultUser();
        expect(user.isFree, isTrue);
        expect(user.isPremium, isFalse);
        expect(user.isAdmin, isFalse);
      });

      test('premium user is premium but not admin', () {
        final user = UserModel.defaultUser().copyWith(role: UserRole.premium);
        expect(user.isFree, isFalse);
        expect(user.isPremium, isTrue);
        expect(user.isAdmin, isFalse);
      });

      test('admin user is both premium and admin', () {
        final user = UserModel.admin();
        expect(user.isPremium, isTrue);
        expect(user.isAdmin, isTrue);
        expect(user.isFree, isFalse);
      });
    });

    group('authentication checks', () {
      test('isAuthenticated returns true when email is present', () {
        final user = UserModel.defaultUser().copyWith(email: 'test@test.com');
        expect(user.isAuthenticated, isTrue);
      });

      test('isAuthenticated returns false for empty email', () {
        final user = UserModel.defaultUser().copyWith(email: '');
        expect(user.isAuthenticated, isFalse);
      });

      test('usesOAuth returns true for google auth method', () {
        final user =
            UserModel.defaultUser().copyWith(authMethod: AuthMethod.google);
        expect(user.usesOAuth, isTrue);
        expect(user.usesEmailPassword, isFalse);
      });

      test('usesEmailPassword returns true for email auth method', () {
        final user = UserModel.defaultUser()
            .copyWith(authMethod: AuthMethod.emailPassword);
        expect(user.usesEmailPassword, isTrue);
        expect(user.usesOAuth, isFalse);
      });
    });

    group('spell limits', () {
      test('free user can create spells under limit', () {
        final user = UserModel.defaultUser().copyWith(spellsCount: 5);
        expect(user.canCreateSpell, isTrue);
      });

      test('free user cannot create spells at limit', () {
        final user = UserModel.defaultUser()
            .copyWith(spellsCount: UserModel.freeSpellsLimit);
        expect(user.canCreateSpell, isFalse);
      });

      test('premium user can always create spells', () {
        final user = UserModel.defaultUser().copyWith(
          role: UserRole.premium,
          spellsCount: 100,
        );
        expect(user.canCreateSpell, isTrue);
      });
    });

    group('diary limits', () {
      test('free user can create diary entries under limit', () {
        final user = UserModel.defaultUser().copyWith(diaryEntriesThisMonth: 5);
        expect(user.canCreateDiaryEntry, isTrue);
      });

      test('free user cannot create diary entries at limit', () {
        final user = UserModel.defaultUser()
            .copyWith(diaryEntriesThisMonth: UserModel.freeDiaryEntriesLimit);
        expect(user.canCreateDiaryEntry, isFalse);
      });
    });

    group('AI limits', () {
      test('free user can use AI under limit', () {
        final user =
            UserModel.defaultUser().copyWith(aiConsultationsToday: 0);
        expect(user.canUseAi, isTrue);
        expect(user.remainingAiConsultations, 1);
      });

      test('free user cannot use AI at limit', () {
        final user = UserModel.defaultUser().copyWith(
            aiConsultationsToday: UserModel.freeAiConsultationsLimit);
        expect(user.canUseAi, isFalse);
        expect(user.remainingAiConsultations, 0);
      });

      test('premium user has unlimited AI', () {
        final user = UserModel.defaultUser().copyWith(role: UserRole.premium);
        expect(user.canUseAi, isTrue);
        expect(user.remainingAiConsultations, -1);
      });
    });

    group('pendulum limits', () {
      test('user can use pendulum under limit', () {
        final user = UserModel.defaultUser().copyWith(pendulumUsesToday: 1);
        expect(user.canUsePendulum, isTrue);
        expect(user.remainingPendulumUses, 2);
      });

      test('user cannot use pendulum at limit', () {
        final user = UserModel.defaultUser()
            .copyWith(pendulumUsesToday: UserModel.dailyPendulumLimit);
        expect(user.canUsePendulum, isFalse);
        expect(user.remainingPendulumUses, 0);
      });

      test('admin has unlimited pendulum', () {
        final user = UserModel.admin();
        expect(user.canUsePendulum, isTrue);
        expect(user.remainingPendulumUses, -1);
      });
    });

    group('affirmation limits', () {
      test('free user can use affirmations under limit', () {
        final user = UserModel.defaultUser().copyWith(affirmationsToday: 2);
        expect(user.canUseAffirmations, isTrue);
        expect(user.remainingAffirmations, 1);
      });

      test('free user cannot use affirmations at limit', () {
        final user = UserModel.defaultUser()
            .copyWith(affirmationsToday: UserModel.freeAffirmationsLimit);
        expect(user.canUseAffirmations, isFalse);
      });
    });

    group('rune limits', () {
      test('free user can use runes under limit', () {
        final user = UserModel.defaultUser().copyWith(runeReadingsToday: 0);
        expect(user.canUseRunes, isTrue);
        expect(user.remainingRuneReadings, 1);
      });

      test('free user cannot use runes at limit', () {
        final user = UserModel.defaultUser()
            .copyWith(runeReadingsToday: UserModel.freeRuneReadingsLimit);
        expect(user.canUseRunes, isFalse);
      });
    });

    group('oracle limits', () {
      test('free user can use oracle under limit', () {
        final user = UserModel.defaultUser().copyWith(oracleReadingsToday: 0);
        expect(user.canUseOracle, isTrue);
        expect(user.remainingOracleReadings, 1);
      });

      test('free user cannot use oracle at limit', () {
        final user = UserModel.defaultUser()
            .copyWith(oracleReadingsToday: UserModel.freeOracleReadingsLimit);
        expect(user.canUseOracle, isFalse);
      });

      test('premium has unlimited oracle', () {
        final user = UserModel.defaultUser().copyWith(role: UserRole.premium);
        expect(user.remainingOracleReadings, -1);
      });
    });

    group('JSON serialization', () {
      test('toJson and fromJson round-trip', () {
        final now = DateTime.now();
        final user = UserModel(
          id: 'test-id',
          email: 'test@test.com',
          displayName: 'Test User',
          role: UserRole.premium,
          plan: SubscriptionPlan.monthly,
          createdAt: now,
          lastLoginAt: now,
          authMethod: AuthMethod.google,
          spellsCount: 5,
          diaryEntriesThisMonth: 10,
          aiConsultationsToday: 1,
          pendulumUsesToday: 2,
          affirmationsToday: 3,
          runeReadingsToday: 1,
          oracleReadingsToday: 1,
        );

        final json = user.toJson();
        final restored = UserModel.fromJson(json);

        expect(restored.id, user.id);
        expect(restored.email, user.email);
        expect(restored.displayName, user.displayName);
        expect(restored.role, user.role);
        expect(restored.plan, user.plan);
        expect(restored.authMethod, user.authMethod);
        expect(restored.spellsCount, user.spellsCount);
        expect(restored.diaryEntriesThisMonth, user.diaryEntriesThisMonth);
        expect(restored.aiConsultationsToday, user.aiConsultationsToday);
        expect(restored.pendulumUsesToday, user.pendulumUsesToday);
        expect(restored.affirmationsToday, user.affirmationsToday);
        expect(restored.runeReadingsToday, user.runeReadingsToday);
        expect(restored.oracleReadingsToday, user.oracleReadingsToday);
      });

      test('fromJson handles missing fields with defaults', () {
        final user = UserModel.fromJson({'id': 'test'});
        expect(user.id, 'test');
        expect(user.role, UserRole.free);
        expect(user.plan, SubscriptionPlan.free);
        expect(user.authMethod, AuthMethod.local);
        expect(user.spellsCount, 0);
      });

      test('fromJson handles null id', () {
        final user = UserModel.fromJson({});
        expect(user.id, 'local_user');
      });
    });

    group('copyWith', () {
      test('copies with new values', () {
        final user = UserModel.defaultUser();
        final updated = user.copyWith(
          email: 'new@test.com',
          role: UserRole.premium,
          spellsCount: 42,
        );

        expect(updated.email, 'new@test.com');
        expect(updated.role, UserRole.premium);
        expect(updated.spellsCount, 42);
        expect(updated.id, user.id);
      });
    });
  });
}
