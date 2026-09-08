import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/user_model.dart';
import 'package:grimorio_de_bolso/features/auth/data/repositories/supabase_auth_repository.dart';

// Sair da conta soltava `Bad state: Cannot add new events after calling
// close`. O logout cria um repositório só para deslogar, e o construtor
// assina o `onAuthStateChange`; o callback é assíncrono e fica pendurado numa
// consulta ao `profiles`. O `dispose` do `finally` fechava o controlador
// enquanto isso — e `cancel()` não aborta um corpo que já está a meio
// caminho. Quando a consulta voltava, o `add` caía num controlador fechado.
//
// Esta é a guarda que fecha a janela, seja qual for o disposer.
void main() {
  UserModel alguem() => UserModel(
        id: 'u1',
        role: UserRole.free,
        plan: SubscriptionPlan.free,
        createdAt: DateTime(2026, 1, 1),
        lastLoginAt: DateTime(2026, 1, 1),
      );

  test('controlador fechado: publicar não estoura, e ninguém recebe', () async {
    final controlador = StreamController<UserModel?>.broadcast();
    final recebidos = <UserModel?>[];
    controlador.stream.listen(recebidos.add);
    await controlador.close();

    // Sem a guarda, esta linha é o erro do logout.
    SupabaseAuthRepository.publicarSeAberto(controlador, alguem());
    SupabaseAuthRepository.publicarSeAberto(controlador, null);

    expect(recebidos, isEmpty);
  });

  test('controlador aberto: o valor chega inteiro', () async {
    final controlador = StreamController<UserModel?>.broadcast();
    final recebidos = <UserModel?>[];
    controlador.stream.listen(recebidos.add);

    SupabaseAuthRepository.publicarSeAberto(controlador, alguem());
    SupabaseAuthRepository.publicarSeAberto(controlador, null);
    await Future<void>.delayed(Duration.zero);

    expect(recebidos, hasLength(2));
    expect(recebidos.first?.id, 'u1');
    expect(recebidos.last, isNull);
    await controlador.close();
  });
}
