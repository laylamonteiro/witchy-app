import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/feature_access.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/user_model.dart';

void main() {
  group('FeatureAccess', () {
    group('admin access', () {
      test('admin has full access to everything', () {
        final admin = UserModel.admin();
        expect(
          FeatureAccess.checkAccess(AppFeature.diagnosticPanel, admin)
              .hasFullAccess,
          isTrue,
        );
        expect(
          FeatureAccess.checkAccess(AppFeature.grimoireCreate, admin)
              .hasFullAccess,
          isTrue,
        );
        expect(
          FeatureAccess.checkAccess(AppFeature.aiMysticCounselor, admin)
              .hasFullAccess,
          isTrue,
        );
      });
    });

    group('premium access', () {
      late UserModel premiumUser;

      setUp(() {
        premiumUser =
            UserModel.defaultUser().copyWith(role: UserRole.premium);
      });

      test('premium has full access to most features', () {
        expect(
          FeatureAccess.checkAccess(AppFeature.grimoireCreate, premiumUser)
              .hasFullAccess,
          isTrue,
        );
        expect(
          FeatureAccess.checkAccess(
                  AppFeature.encyclopediaCrystalsDetails, premiumUser)
              .hasFullAccess,
          isTrue,
        );
        expect(
          FeatureAccess.checkAccess(AppFeature.astrologyBirthChart, premiumUser)
              .hasFullAccess,
          isTrue,
        );
      });

      test('premium cannot access diagnostic panel', () {
        final result = FeatureAccess.checkAccess(
            AppFeature.diagnosticPanel, premiumUser);
        expect(result.isBlocked, isTrue);
      });
    });

    group('free user access', () {
      late UserModel freeUser;

      setUp(() {
        freeUser = UserModel.defaultUser();
      });

      test('free user has full access to basic features', () {
        expect(
          FeatureAccess.checkAccess(AppFeature.lunarCalendarBasic, freeUser)
              .hasFullAccess,
          isTrue,
        );
        expect(
          FeatureAccess.checkAccess(AppFeature.encyclopediaList, freeUser)
              .hasFullAccess,
          isTrue,
        );
        expect(
          FeatureAccess.checkAccess(AppFeature.wheelOfYearBasic, freeUser)
              .hasFullAccess,
          isTrue,
        );
        expect(
          FeatureAccess.checkAccess(AppFeature.settingsBasic, freeUser)
              .hasFullAccess,
          isTrue,
        );
      });

      test('free user gets preview for encyclopedia details', () {
        expect(
          FeatureAccess.checkAccess(
                  AppFeature.encyclopediaCrystalsDetails, freeUser)
              .isPreview,
          isTrue,
        );
        expect(
          FeatureAccess.checkAccess(
                  AppFeature.encyclopediaHerbsDetails, freeUser)
              .isPreview,
          isTrue,
        );
      });

      test('free user gets preview for astrology advanced', () {
        expect(
          FeatureAccess.checkAccess(
                  AppFeature.astrologyBirthChart, freeUser)
              .isPreview,
          isTrue,
        );
        expect(
          FeatureAccess.checkAccess(
                  AppFeature.astrologyMagicalProfile, freeUser)
              .isPreview,
          isTrue,
        );
      });

      test('free user gets preview for divination', () {
        expect(
          FeatureAccess.checkAccess(AppFeature.divinationPendulum, freeUser)
              .isPreview,
          isTrue,
        );
        expect(
          FeatureAccess.checkAccess(AppFeature.divinationOracle, freeUser)
              .isPreview,
          isTrue,
        );
      });

      test('free user spell limit enforced', () {
        final atLimit = freeUser.copyWith(
            spellsCount: UserModel.freeSpellsLimit);
        final result =
            FeatureAccess.checkAccess(AppFeature.grimoireCreate, atLimit);
        expect(result.isPreview, isTrue);
        expect(result.remainingUses, 0);
      });

      test('free user spell creation allowed under limit', () {
        final underLimit = freeUser.copyWith(spellsCount: 3);
        final result =
            FeatureAccess.checkAccess(AppFeature.grimoireCreate, underLimit);
        expect(result.hasFullAccess, isTrue);
        expect(result.remainingUses, 7);
      });

      test('free user diary limit enforced', () {
        final atLimit = freeUser.copyWith(
            diaryEntriesThisMonth: UserModel.freeDiaryEntriesLimit);
        final result = FeatureAccess.checkAccess(
            AppFeature.diaryDreamsCreate, atLimit);
        expect(result.isPreview, isTrue);
      });

      test('free user AI limit enforced', () {
        final atLimit = freeUser.copyWith(
            aiConsultationsToday: UserModel.freeAiConsultationsLimit);
        final result = FeatureAccess.checkAccess(
            AppFeature.aiMysticCounselor, atLimit);
        expect(result.isPreview, isTrue);
      });

      test('free user AI allowed under limit', () {
        final underLimit = freeUser.copyWith(aiConsultationsToday: 0);
        final result = FeatureAccess.checkAccess(
            AppFeature.aiMysticCounselor, underLimit);
        expect(result.hasFullAccess, isTrue);
      });

      test('diagnostic panel is blocked for free user', () {
        final result =
            FeatureAccess.checkAccess(AppFeature.diagnosticPanel, freeUser);
        expect(result.isBlocked, isTrue);
      });

      test('grimoire view/edit/delete are free', () {
        expect(
          FeatureAccess.checkAccess(AppFeature.grimoireView, freeUser)
              .hasFullAccess,
          isTrue,
        );
        expect(
          FeatureAccess.checkAccess(AppFeature.grimoireEdit, freeUser)
              .hasFullAccess,
          isTrue,
        );
        expect(
          FeatureAccess.checkAccess(AppFeature.grimoireDelete, freeUser)
              .hasFullAccess,
          isTrue,
        );
      });

      test('diary view features are free', () {
        expect(
          FeatureAccess.checkAccess(AppFeature.diaryDreamsView, freeUser)
              .hasFullAccess,
          isTrue,
        );
        expect(
          FeatureAccess.checkAccess(AppFeature.diaryDesiresView, freeUser)
              .hasFullAccess,
          isTrue,
        );
      });
    });

    group('helper methods', () {
      test('canViewEncyclopediaDetails', () {
        expect(FeatureAccess.canViewEncyclopediaDetails(UserModel.admin()),
            isTrue);
        expect(
            FeatureAccess.canViewEncyclopediaDetails(
                UserModel.defaultUser().copyWith(role: UserRole.premium)),
            isTrue);
        expect(FeatureAccess.canViewEncyclopediaDetails(UserModel.defaultUser()),
            isFalse);
      });

      test('canViewDiagnostic', () {
        expect(FeatureAccess.canViewDiagnostic(UserModel.admin()), isTrue);
        expect(
            FeatureAccess.canViewDiagnostic(
                UserModel.defaultUser().copyWith(role: UserRole.premium)),
            isFalse);
      });
    });
  });

  group('AccessResult', () {
    test('full access result', () {
      final result = AccessResult.full();
      expect(result.hasFullAccess, isTrue);
      expect(result.isPreview, isFalse);
      expect(result.isBlocked, isFalse);
    });

    test('preview access result', () {
      final result = AccessResult.preview(message: 'Test');
      expect(result.hasFullAccess, isFalse);
      expect(result.isPreview, isTrue);
      expect(result.message, 'Test');
    });

    test('blocked access result', () {
      final result = AccessResult.blocked(message: 'Blocked');
      expect(result.isBlocked, isTrue);
      expect(result.message, 'Blocked');
    });

    test('limited access with remaining uses', () {
      final result = AccessResult.limited(remaining: 3, limit: 10);
      expect(result.hasFullAccess, isTrue);
      expect(result.remainingUses, 3);
      expect(result.limit, 10);
    });

    test('limited access with no remaining uses becomes preview', () {
      final result = AccessResult.limited(remaining: 0, limit: 10);
      expect(result.isPreview, isTrue);
      expect(result.remainingUses, 0);
    });
  });
}
