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
  }) =>
      MenstrualAccess(gender: gender, consented: consented);

  group('who the feature is for', () {
    test('it is offered in the feminine and the neutral, never in the masculine',
        () {
      expect(access(gender: Gender.feminine).isOffered, isTrue);
      expect(access(gender: Gender.neutral).isOffered, isTrue);
      final masculine = access(gender: Gender.masculine);
      expect(masculine.isOffered, isFalse);
      expect(masculine.canRecord, isFalse,
          reason: 'No card, no teaser and no offer for this feature');
    });
  });

  group('the whole feature is free', () {
    test('consent opens recording, and nothing else is asked for', () {
      expect(access().canRecord, isTrue);
    });

    test('without consent nothing is recorded', () {
      expect(access(consented: false).canRecord, isFalse);
    });

    test('taking the data away or erasing it never needs a subscription', () {
      expect(access(consented: false).canManageOwnData, isTrue,
          reason: 'Changing your mind cannot lock you out of your own data');
      expect(access(gender: Gender.masculine).canManageOwnData, isFalse);
    });
  });

  group('consent is explicit, kept per account, and given in one gesture', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));
    const store = MenstrualConsentStore();

    test('nothing is allowed before the person says so', () async {
      expect(await store.recordingAllowed('a'), isFalse);
      expect(await store.syncAllowed('a'), isFalse);
    });

    test('accept is ONE gesture that opens recording and the account copy',
        () async {
      // Eram dois sins, em telas diferentes, e a pessoa tinha de achar os
      // dois. O consentimento continua explícito — isto é dado de saúde —,
      // mas o gesto é um só, e o texto da porta diz as duas coisas.
      await store.accept('a');
      expect(await store.recordingAllowed('a'), isTrue);
      expect(await store.syncAllowed('a'), isTrue);
    });

    test('the account copy can be turned off without losing the record',
        () async {
      await store.accept('a');
      await store.setSyncAllowed('a', false);
      expect(await store.syncAllowed('a'), isFalse);
      expect(await store.recordingAllowed('a'), isTrue,
          reason: 'Turning off the copy is not giving up the record');
    });

    test('taking back the recording consent also stops the sending', () async {
      await store.accept('a');
      await store.setRecordingAllowed('a', false);
      expect(await store.recordingAllowed('a'), isFalse);
      expect(await store.syncAllowed('a'), isFalse);
    });

    test('one account answering does not answer for another', () async {
      await store.accept('a');
      expect(await store.recordingAllowed('b'), isFalse);
      expect(await store.syncAllowed('b'), isFalse);
      await store.forget('a');
      expect(await store.recordingAllowed('a'), isFalse);
    });
  });
}
