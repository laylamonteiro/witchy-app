import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/i18n/treatment_preference.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/user_model.dart';

void main() {
  group('TreatmentText', () {
    test('seleciona variante feminina', () {
      expect(
        TreatmentText.select(
          preference: TreatmentPreference.feminine,
          feminine: 'acolhida',
          masculine: 'acolhido',
          neutral: 'em acolhimento',
        ),
        'acolhida',
      );
    });

    test('seleciona variante masculina', () {
      expect(
        TreatmentText.select(
          preference: TreatmentPreference.masculine,
          feminine: 'acolhida',
          masculine: 'acolhido',
          neutral: 'em acolhimento',
        ),
        'acolhido',
      );
    });

    test('seleciona variante neutra', () {
      expect(
        TreatmentText.select(
          preference: TreatmentPreference.neutral,
          feminine: 'acolhida',
          masculine: 'acolhido',
          neutral: 'em acolhimento',
        ),
        'em acolhimento',
      );
    });

    test('fallback seguro usa linguagem sem marcação', () {
      expect(TreatmentPreference.fromJson('invalido'), TreatmentPreference.neutral);
      expect(TreatmentPreference.fromJson(null), TreatmentPreference.neutral);
    });
  });

  group('UserModel treatmentPreference', () {
    test('persiste preferência no JSON', () {
      final user = UserModel.defaultUser().copyWith(
        treatmentPreference: TreatmentPreference.masculine,
      );

      expect(user.toJson()['treatmentPreference'], 'masculine');
      expect(
        UserModel.fromJson(user.toJson()).treatmentPreference,
        TreatmentPreference.masculine,
      );
    });

    test('usa fallback neutro quando preferência não existe', () {
      final user = UserModel.fromJson({
        'id': 'legacy',
        'role': 'free',
        'plan': 'free',
      });

      expect(user.treatmentPreference, TreatmentPreference.neutral);
    });
  });
}
