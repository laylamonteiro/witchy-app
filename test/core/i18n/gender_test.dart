import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/i18n/gender.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/user_model.dart';

void main() {
  group('GenderText', () {
    test('seleciona variante feminina', () {
      expect(
        GenderText.select(
          preference: Gender.feminine,
          feminine: 'acolhida',
          masculine: 'acolhido',
          neutral: 'em acolhimento',
        ),
        'acolhida',
      );
    });

    test('seleciona variante masculina', () {
      expect(
        GenderText.select(
          preference: Gender.masculine,
          feminine: 'acolhida',
          masculine: 'acolhido',
          neutral: 'em acolhimento',
        ),
        'acolhido',
      );
    });

    test('seleciona variante neutra', () {
      expect(
        GenderText.select(
          preference: Gender.neutral,
          feminine: 'acolhida',
          masculine: 'acolhido',
          neutral: 'em acolhimento',
        ),
        'em acolhimento',
      );
    });

    test('fallback seguro usa linguagem sem marcação', () {
      expect(Gender.fromJson('invalido'), Gender.neutral);
      expect(Gender.fromJson(null), Gender.neutral);
    });
  });

  group('UserModel gender', () {
    test('persiste preferência no JSON', () {
      final user = UserModel.defaultUser().copyWith(
        gender: Gender.masculine,
      );

      expect(user.toJson()['gender'], 'masculine');
      expect(
        UserModel.fromJson(user.toJson()).gender,
        Gender.masculine,
      );
    });

    // O app trata a pessoa no feminino quando não há preferência salva —
    // decisão de produto, escrita no próprio UserModel ("Default do app é
    // tratamento feminino quando nao ha valor salvo"). Vale para contas
    // antigas, criadas antes do campo existir.
    test('usa tratamento feminino quando preferência não existe', () {
      final user = UserModel.fromJson({
        'id': 'legacy',
        'role': 'free',
        'plan': 'free',
      });

      expect(user.gender, Gender.feminine);
    });
  });
}
