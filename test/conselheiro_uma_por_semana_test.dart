// A leitura do Conselheiro Místico é o que a assinatura vende — tirar cartas
// qualquer site faz. Por isso ela deixou de ser diária e virou SEMANAL, e
// deixou de ser zero para quem não assina: o Free tem uma por semana, e gasta
// onde quiser (na página do Conselheiro ou na interpretação de uma tiragem,
// que dividem a mesma cota).
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/feature_access.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/user_model.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _id = 'a1b2c3d4-0000-4000-8000-000000000001';

UserModel _bruxa({int lidas = 0, UserRole role = UserRole.free}) => UserModel(
      id: _id,
      email: 'bruxa@exemplo.com',
      role: role,
      plan: SubscriptionPlan.free,
      createdAt: DateTime(2026, 1, 1),
      lastLoginAt: DateTime(2026, 1, 1),
      advisorConsultationsThisWeek: lidas,
    );

Future<AuthProvider> _abrir({
  required UserModel usuario,
  String? ultimoReset,
}) async {
  SharedPreferences.setMockInitialValues({
    'auth_version': AuthProvider.versaoAtualDoFluxo,
    'current_user': jsonEncode(usuario.toJson()),
    if (ultimoReset != null) 'last_advisor_reset_$_id': ultimoReset,
  });
  final auth = AuthProvider();
  addTearDown(auth.dispose);
  await auth.initialize();
  return auth;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('o limite do Conselheiro é semanal no mapa que bloqueia', () {
    final registro = FeatureAccessService.limits[AppFeature.aiMysticCounselor]!;
    expect(registro.window, LimitWindow.weekly,
        reason: 'é a única cota do app que não é diária, e de propósito');
    expect(registro.limit, UserModel.freeAdvisorConsultationsLimit);
    expect(registro.used(_bruxa(lidas: 1)), 1);
  });

  test('a chave em JSON não mudou de nome', () {
    // Trocá-la zeraria o contador de quem já tem o app — inofensivo, mas
    // gratuito. O campo em Dart mudou; a chave gravada, não.
    final json = _bruxa(lidas: 1).toJson();
    expect(json['advisorConsultationsToday'], 1);
    expect(UserModel.fromJson(json).advisorConsultationsThisWeek, 1);
  });

  group('a leitura da semana', () {
    test('o Free começa com uma, e ela some quando é gasta', () async {
      final auth = await _abrir(
          usuario: _bruxa(), ultimoReset: DateTime.now().toIso8601String());
      expect(auth.canUseAdvisor, isTrue);
      expect(auth.podeLerOConselheiro, isTrue,
          reason: 'é o que a tela de tiragem olha para mostrar o botão');
      expect(auth.remainingAdvisorConsultations, 1);

      await auth.incrementAdvisorConsultations();

      expect(auth.canUseAdvisor, isFalse);
      expect(auth.podeLerOConselheiro, isFalse,
          reason: 'gasta a leitura, a tiragem volta a mostrar a prévia');
      expect(auth.remainingAdvisorConsultations, 0);
    });

    test('dentro da mesma semana, gasta continua gasta', () async {
      final auth = await _abrir(
          usuario: _bruxa(lidas: 1),
          ultimoReset: DateTime.now().toIso8601String());
      expect(auth.canUseAdvisor, isFalse,
          reason: 'o reset semanal não pode disparar no mesmo dia');
    });

    test('numa semana nova, a leitura volta', () async {
      final auth = await _abrir(
        usuario: _bruxa(lidas: 1),
        ultimoReset: DateTime(2020, 1, 1).toIso8601String(),
      );
      expect(auth.canUseAdvisor, isTrue);
      expect(auth.currentUser.advisorConsultationsThisWeek, 0);
    });

    test('quem vinha da cota diária entra na semanal zerado', () async {
      // Sem carimbo de reset semanal ainda: o contador antigo significava
      // "hoje", e herdá-lo como "esta semana" tiraria a leitura de quem já
      // tinha consultado no dia da atualização.
      final auth = await _abrir(usuario: _bruxa(lidas: 1));
      expect(auth.currentUser.advisorConsultationsThisWeek, 0);
      expect(auth.canUseAdvisor, isTrue);
    });
  });

  group('quem assina não esbarra em nada', () {
    test('Premium lê sempre, e o contador não sobe', () async {
      final auth = await _abrir(
          usuario: _bruxa(lidas: 99, role: UserRole.premium),
          ultimoReset: DateTime.now().toIso8601String());
      expect(auth.canUseAdvisor, isTrue);
      expect(auth.podeLerOConselheiro, isTrue);
      expect(auth.remainingAdvisorConsultations, -1, reason: 'ilimitado');

      await auth.incrementAdvisorConsultations();
      expect(auth.currentUser.advisorConsultationsThisWeek, 99,
          reason: 'só o Free é debitado');
    });
  });
}
