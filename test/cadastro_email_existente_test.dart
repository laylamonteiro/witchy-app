import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/auth/data/repositories/supabase_auth_repository.dart';

/// Bug de produção: cadastrar com um e-mail que JÁ existe dizia "confirmação
/// enviada" e o link nunca chegava — porque o Supabase, com confirmação de
/// e-mail ligada, não acusa erro nesse caso (anti-enumeração): devolve um
/// usuário ofuscado com `identities` VAZIO e não manda e-mail. A detecção mora
/// em [SupabaseAuthRepository.respostaIndicaEmailJaCadastrado].
void main() {
  bool jaCadastrado(List<Object?>? identities) =>
      SupabaseAuthRepository.respostaIndicaEmailJaCadastrado(identities);

  group('respostaIndicaEmailJaCadastrado', () {
    test('identities VAZIO ⇒ e-mail já existe (o caso do bug)', () {
      expect(jaCadastrado(const []), isTrue);
    });

    test('identities COM identidade ⇒ cadastro novo de verdade', () {
      expect(jaCadastrado([Object()]), isFalse);
    });

    test('identities nulo ⇒ desconhecido, não afirma que já existe', () {
      // Nunca barrar um cadastro legítimo por falta de informação: só o
      // sinal EXPLÍCITO (lista vazia) indica conta existente.
      expect(jaCadastrado(null), isFalse);
    });
  });
}
