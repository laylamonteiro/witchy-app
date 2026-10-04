import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/auth/data/repositories/supabase_auth_repository.dart';

/// Contas Google criadas na web nasciam com `signup_platform` NULL: o trigger
/// handle_new_user cria a linha sem plataforma (o Google não a manda no
/// metadata) e, ao voltar do login, o app só chamava `_createProfile` quando o
/// perfil NÃO existia. Agora a origem é preenchida sempre que o perfil lido
/// chega sem ela — a decisão mora em [SupabaseAuthRepository.perfilSemOrigem].
void main() {
  bool semOrigem(Map<String, dynamic>? perfil) =>
      SupabaseAuthRepository.perfilSemOrigem(perfil);

  group('perfilSemOrigem', () {
    test('perfil sem signup_platform ⇒ preenche (o caso do bug)', () {
      expect(semOrigem({'id': 'x', 'signup_platform': null}), isTrue);
    });

    test('perfil sem a chave signup_platform ⇒ preenche', () {
      expect(semOrigem({'id': 'x'}), isTrue);
    });

    test('perfil com origem ⇒ não mexe (nunca sobrescreve)', () {
      expect(semOrigem({'id': 'x', 'signup_platform': 'android'}), isFalse);
      expect(semOrigem({'id': 'x', 'signup_platform': 'web'}), isFalse);
    });

    test('sem perfil ⇒ não preenche aqui (o _createProfile cuida)', () {
      expect(semOrigem(null), isFalse);
    });
  });
}
