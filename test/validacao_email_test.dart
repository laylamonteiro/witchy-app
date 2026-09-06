import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/utils/validacao_email.dart';

/// Origem: o Supabase avisou que quase metade dos cadastros nunca confirma o
/// e-mail e os endereços viram "hard bounce", ameaçando a reputação de envio.
/// A validação antiga (só `contains('@') && contains('.')`) deixava passar
/// endereços malformados. Estes testes fixam o contrato do reforço: barrar o
/// que é malformado de fato, sem NUNCA barrar um e-mail válido de verdade —
/// porque barrar um e-mail bom custa um cadastro real.
void main() {
  group('emailTemFormatoValido — aceita e-mail válido de verdade', () {
    for (final ok in const [
      'joao@gmail.com',
      'joao.silva@gmail.com',
      'joao+promo@gmail.com', // tag com '+': válido, não pode barrar
      'nome_com_underscore@hotmail.com',
      'joao-silva@meu-dominio.com', // hífen no local e no domínio
      'a@b.co', // curtinho, mas válido
      'user@sub.dominio.co.uk', // subdomínios
    ]) {
      test('aceita "$ok"', () => expect(emailTemFormatoValido(ok), isTrue));
    }

    test('normaliza antes de validar (espaços nas pontas e MAIÚSCULAS)', () {
      expect(emailTemFormatoValido('  Joao@Gmail.COM  '), isTrue);
    });
  });

  group('emailTemFormatoValido — barra o que é malformado', () {
    for (final ruim in const [
      '', // vazio
      '   ', // só espaço
      'joao', // sem @
      'joao@gmail', // sem TLD
      'joao@gmail.c', // TLD de uma letra
      'joao @gmail.com', // espaço no meio
      'joao@@gmail.com', // @ a mais
      'joao..silva@gmail.com', // pontos duplos no local
      'joao@gmail..com', // pontos duplos no domínio
      '@gmail.com', // sem parte local
      'joao@.com', // domínio começando em ponto
      'joao@gmail.com.', // ponto sobrando no fim
      'joao@-gmail.com', // rótulo começando com hífen
    ]) {
      test('barra "$ruim"', () => expect(emailTemFormatoValido(ruim), isFalse));
    }

    test('barra endereço acima do limite prático (254 chars)', () {
      final gigante = '${'a' * 250}@gmail.com';
      expect(emailTemFormatoValido(gigante), isFalse);
    });
  });

  group('normalizarEmail', () {
    test('tira espaços das pontas e baixa a caixa', () {
      expect(normalizarEmail('  Joao@Gmail.COM  '), 'joao@gmail.com');
    });
  });
}
