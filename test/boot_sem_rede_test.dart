import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/services/payment_service.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/user_model.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/widgets/relogin_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// "O app não abre sem internet, mesmo logada."
///
/// Três peças do boot dependiam da rede sem precisar dela:
/// - `PaymentService.initialize()` esperava o RevenueCat responder ANTES do
///   runApp — sem internet, dezenas de segundos na tela nativa;
/// - `AuthProvider.initialize()` não tinha `finally`: uma exceção em qualquer
///   passo deixava `isInitialized=false` para sempre e o router preso em
///   /carregando;
/// - o `ReloginDialog` pedia a senha sempre que a sessão em memória faltava —
///   e offline a sessão pode estar expirada sem renovar, mas gravada no disco.
///
/// Estes testes trancam as regras puras e o boot do AuthProvider sem rede
/// nenhuma (sem Supabase nem RevenueCat configurados, que é o caso do
/// `flutter test`: `--dart-define` vazio).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const idDaBruxa = 'a1b2c3d4-0000-4000-8000-000000000001';

  UserModel bruxa() => UserModel(
        id: idDaBruxa,
        email: 'bruxa@exemplo.com',
        role: UserRole.free,
        plan: SubscriptionPlan.free,
        createdAt: DateTime(2026, 1, 1),
        lastLoginAt: DateTime(2026, 1, 1),
        authMethod: AuthMethod.emailPassword,
      );

  group('boot do AuthProvider sem rede', () {
    test('sessão gravada no aparelho sobe sem rede', () async {
      SharedPreferences.setMockInitialValues({
        'auth_version': AuthProvider.versaoAtualDoFluxo,
        'current_user': jsonEncode(bruxa().toJson()),
      });
      final auth = AuthProvider();
      addTearDown(auth.dispose);

      await auth.initialize();

      expect(auth.isInitialized, isTrue);
      expect(auth.currentUser.isAuthenticated, isTrue);
      expect(auth.currentUser.id, idDaBruxa);
    });

    test('sem usuário gravado, o boot também termina', () async {
      SharedPreferences.setMockInitialValues({
        'auth_version': AuthProvider.versaoAtualDoFluxo,
      });
      final auth = AuthProvider();
      addTearDown(auth.dispose);

      await auth.initialize();

      expect(auth.isInitialized, isTrue);
      expect(auth.currentUser.isAuthenticated, isFalse);
    });
  });

  group('PaymentService.deveAvisarAuth', () {
    bool avisa({
      required bool statusEraDesconhecido,
      required bool isProAntes,
      required bool isProAgora,
    }) =>
        PaymentService.deveAvisarAuth(
          statusEraDesconhecido: statusEraDesconhecido,
          isProAntes: isProAntes,
          isProAgora: isProAgora,
        );

    test('desconhecido → conhecido avisa, mesmo false → false', () {
      // A primeira resposta do RevenueCat chega depois do boot: o
      // AuthProvider precisa dela para a conferência de expiração que fez
      // com status desconhecido.
      expect(
        avisa(statusEraDesconhecido: true, isProAntes: false, isProAgora: false),
        isTrue,
      );
      expect(
        avisa(statusEraDesconhecido: true, isProAntes: false, isProAgora: true),
        isTrue,
      );
    });

    test('conhecido e sem mudança não avisa', () {
      expect(
        avisa(statusEraDesconhecido: false, isProAntes: false, isProAgora: false),
        isFalse,
      );
      expect(
        avisa(statusEraDesconhecido: false, isProAntes: true, isProAgora: true),
        isFalse,
      );
    });

    test('mudança avisa', () {
      expect(
        avisa(statusEraDesconhecido: false, isProAntes: false, isProAgora: true),
        isTrue,
      );
      expect(
        avisa(statusEraDesconhecido: false, isProAntes: true, isProAgora: false),
        isTrue,
      );
    });
  });

  group('ReloginDialog', () {
    test('a chave da sessão persistida espelha o supabase_flutter', () {
      expect(
        ReloginDialog.chaveDaSessaoPersistida('https://abcdefg.supabase.co'),
        'sb-abcdefg-auth-token',
      );
    });

    test('só reconecta sem sessão viva E sem sessão no disco', () {
      expect(
        ReloginDialog.deveReconectar(sessaoViva: false, sessaoPersistida: false),
        isTrue,
      );
      // Offline, expirada e sem renovar — mas no disco: o supabase_flutter
      // renova quando a rede voltar. Pedir senha aqui trancaria a pessoa.
      expect(
        ReloginDialog.deveReconectar(sessaoViva: false, sessaoPersistida: true),
        isFalse,
      );
      expect(
        ReloginDialog.deveReconectar(sessaoViva: true, sessaoPersistida: false),
        isFalse,
      );
      expect(
        ReloginDialog.deveReconectar(sessaoViva: true, sessaoPersistida: true),
        isFalse,
      );
    });
  });
}
