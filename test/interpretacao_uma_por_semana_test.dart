// Ler o que as cartas dizem JUNTAS é o que a assinatura vende — tirar é o que
// qualquer site faz. Antes isso era ZERO para quem não assina: na tiragem, o
// Free via só a prévia, nunca uma leitura. Agora tem UMA por semana, dividida
// entre tarô, runas e oráculo.
//
// É cota PRÓPRIA: a página do Conselheiro Místico segue com a dela por dia, e
// gastar uma não pode mexer na outra.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/feature_access.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/user_model.dart';
import 'package:grimorio_de_bolso/features/auth/presentation/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _id = 'a1b2c3d4-0000-4000-8000-000000000001';

UserModel _bruxa({
  int leituras = 0,
  int conselheiro = 0,
  UserRole role = UserRole.free,
}) =>
    UserModel(
      id: _id,
      email: 'bruxa@exemplo.com',
      role: role,
      plan: SubscriptionPlan.free,
      createdAt: DateTime(2026, 1, 1),
      lastLoginAt: DateTime(2026, 1, 1),
      readingInterpretationsThisWeek: leituras,
      advisorConsultationsToday: conselheiro,
    );

Future<AuthProvider> _abrir({
  required UserModel usuario,
  String? ultimoReset,
}) async {
  SharedPreferences.setMockInitialValues({
    'auth_version': AuthProvider.versaoAtualDoFluxo,
    'current_user': jsonEncode(usuario.toJson()),
    if (ultimoReset != null) 'last_interpretation_reset_$_id': ultimoReset,
    // Carimba o dia para o reset diário não disparar no meio do teste.
    'last_daily_limits_reset_$_id': DateTime.now().toIso8601String(),
  });
  final auth = AuthProvider();
  addTearDown(auth.dispose);
  await auth.initialize();
  return auth;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('as duas cotas são separadas', () {
    test('a da tiragem é semanal; a do Conselheiro continua diária', () {
      final tiragem =
          FeatureAccessService.limits[AppFeature.aiReadingInterpretation]!;
      final conselheiro =
          FeatureAccessService.limits[AppFeature.aiMysticCounselor]!;
      expect(tiragem.window, LimitWindow.weekly);
      expect(conselheiro.window, LimitWindow.daily,
          reason: 'a página de perguntas soltas não mudou');
      expect(tiragem.limit, UserModel.freeReadingInterpretationsLimit);
      expect(tiragem.used(_bruxa(leituras: 1)), 1);
    });

    test('gastar a leitura da tiragem não gasta a do Conselheiro', () async {
      final auth = await _abrir(
          usuario: _bruxa(), ultimoReset: DateTime.now().toIso8601String());
      expect(auth.podeLerOConselheiro, isTrue);
      expect(auth.canUseAdvisor, isTrue);

      await auth.incrementReadingInterpretations();

      expect(auth.podeLerOConselheiro, isFalse);
      expect(auth.canUseAdvisor, isTrue,
          reason: 'a página do Conselheiro é outra cota');
      expect(auth.currentUser.advisorConsultationsToday, 0);
    });

    test('gastar a do Conselheiro não gasta a da tiragem', () async {
      final auth = await _abrir(
          usuario: _bruxa(), ultimoReset: DateTime.now().toIso8601String());

      await auth.incrementAdvisorConsultations();

      expect(auth.canUseAdvisor, isFalse);
      expect(auth.podeLerOConselheiro, isTrue,
          reason: 'a leitura da tiragem continua de pé');
      expect(auth.currentUser.readingInterpretationsThisWeek, 0);
    });
  });

  group('a leitura da semana', () {
    test('o Free começa com uma, e ela some quando é gasta', () async {
      final auth = await _abrir(
          usuario: _bruxa(), ultimoReset: DateTime.now().toIso8601String());
      expect(auth.podeLerOConselheiro, isTrue,
          reason: 'é o que a tela de tiragem olha para mostrar o botão');
      expect(auth.remainingReadingInterpretations, 1);

      await auth.incrementReadingInterpretations();

      expect(auth.podeLerOConselheiro, isFalse,
          reason: 'gasta a leitura, a tiragem volta a mostrar a prévia');
      expect(auth.remainingReadingInterpretations, 0);
    });

    test('é UMA para as três: tarô, runas e oráculo dividem', () async {
      // As três telas chamam o mesmo contador, então uma leitura no tarô fecha
      // a das runas e a do oráculo na mesma semana.
      final auth = await _abrir(
          usuario: _bruxa(), ultimoReset: DateTime.now().toIso8601String());
      await auth.incrementReadingInterpretations();
      expect(auth.currentUser.canInterpretReading, isFalse);
      expect(auth.currentUser.readingInterpretationsThisWeek, 1);
    });

    test('dentro da mesma semana, gasta continua gasta', () async {
      final auth = await _abrir(
          usuario: _bruxa(leituras: 1),
          ultimoReset: DateTime.now().toIso8601String());
      expect(auth.podeLerOConselheiro, isFalse,
          reason: 'o reset semanal não pode disparar no mesmo dia');
    });

    test('numa semana nova, a leitura volta', () async {
      final auth = await _abrir(
        usuario: _bruxa(leituras: 1),
        ultimoReset: DateTime(2020, 1, 1).toIso8601String(),
      );
      expect(auth.podeLerOConselheiro, isTrue);
      expect(auth.currentUser.readingInterpretationsThisWeek, 0);
    });
  });

  test('Premium lê sempre, e o contador não sobe', () async {
    final auth = await _abrir(
        usuario: _bruxa(leituras: 99, role: UserRole.premium),
        ultimoReset: DateTime.now().toIso8601String());
    expect(auth.podeLerOConselheiro, isTrue);
    expect(auth.remainingReadingInterpretations, -1, reason: 'ilimitado');

    await auth.incrementReadingInterpretations();
    expect(auth.currentUser.readingInterpretationsThisWeek, 99,
        reason: 'só o Free é debitado');
  });

  test('o contador novo sobrevive ao ir e voltar do JSON', () {
    final json = _bruxa(leituras: 1).toJson();
    expect(json['readingInterpretationsThisWeek'], 1);
    expect(UserModel.fromJson(json).readingInterpretationsThisWeek, 1);
    // Quem já tem o app não tem a chave: começa com a leitura na mão.
    expect(UserModel.fromJson({...json}..remove('readingInterpretationsThisWeek'))
        .readingInterpretationsThisWeek, 0);
  });
}
