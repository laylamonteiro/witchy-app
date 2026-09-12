import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/i18n/gender.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/data/menstrual_consent_store.dart';
import 'package:grimorio_de_bolso/features/menstrual_cycle/domain/menstrual_access.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/short_test_timeout.dart';

void main() {
  useShortTestTimeout();

  MenstrualAccess access({
    Gender gender = Gender.feminine,
    bool consented = true,
    bool premium = false,
  }) =>
      MenstrualAccess(gender: gender, consented: consented, premium: premium);

  group('who the feature is for', () {
    test('it is offered in the feminine and the neutral, never in the masculine', () {
      expect(access(gender: Gender.feminine).isOffered, isTrue);
      expect(access(gender: Gender.neutral).isOffered, isTrue);
      final masculine = access(gender: Gender.masculine, premium: true);
      expect(masculine.isOffered, isFalse);
      expect(masculine.canRecord, isFalse);
      expect(masculine.canSeeDerived, isFalse);
      expect(masculine.showsGenericPremiumInvite, isFalse,
          reason: 'No card, no teaser and no offer for this feature');
    });
  });

  group('recording is free, results are not', () {
    test('consent opens recording without any purchase', () {
      final free = access();
      expect(free.canRecord, isTrue);
      expect(free.canSeeDerived, isFalse,
          reason: 'Cycle day, averages and estimates are derived');
      expect(free.showsGenericPremiumInvite, isTrue);
    });

    test('without consent nothing is recorded, and results stay closed', () {
      final refused = access(consented: false, premium: true);
      expect(refused.canRecord, isFalse);
      expect(refused.canSeeDerived, isFalse);
    });

    test('premium plus consent is what opens the derived side', () {
      expect(access(premium: true).canSeeDerived, isTrue);
      expect(access(premium: true).showsGenericPremiumInvite, isFalse);
    });

    test('taking the data away or erasing it never needs a subscription', () {
      expect(access(consented: false).canManageOwnData, isTrue,
          reason: 'Changing your mind cannot lock you out of your own data');
      expect(access(gender: Gender.masculine).canManageOwnData, isFalse);
    });
  });

  group('consent is kept per account, and sync is a separate yes', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));
    const store = MenstrualConsentStore();

    test('nothing is allowed before the person says so', () async {
      expect(await store.recordingAllowed('a'), isFalse);
      expect(await store.syncAllowed('a'), isFalse);
    });

    test('saying yes to recording does not say yes to sending', () async {
      await store.setRecordingAllowed('a', true);
      expect(await store.recordingAllowed('a'), isTrue);
      expect(await store.syncAllowed('a'), isFalse,
          reason: 'Sending to the account is its own decision');
      await store.setSyncAllowed('a', true);
      expect(await store.syncAllowed('a'), isTrue);
    });

    test('taking back the recording consent also stops the sending', () async {
      await store.setRecordingAllowed('a', true);
      await store.setSyncAllowed('a', true);
      await store.setRecordingAllowed('a', false);
      expect(await store.recordingAllowed('a'), isFalse);
      expect(await store.syncAllowed('a'), isFalse);
    });

    test('one account answering does not answer for another', () async {
      await store.setRecordingAllowed('a', true);
      expect(await store.recordingAllowed('b'), isFalse);
      await store.forget('a');
      expect(await store.recordingAllowed('a'), isFalse);
    });
  });
}
