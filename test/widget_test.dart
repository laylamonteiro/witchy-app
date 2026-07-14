// Testes de lógica pura do Grimório de Bolso.
//
// Substituem o template padrão do Flutter (contador), que referenciava um
// `MyApp` inexistente e nunca compilou. Estes testes não dependem de
// plugins nativos (SQLite, SharedPreferences, RevenueCat) e rodam com
// `flutter test`.
import 'package:flutter_test/flutter_test.dart';

import 'package:grimorio_de_bolso/core/config/supabase_config.dart';
import 'package:grimorio_de_bolso/core/widgets/mascot/cat_chat_bubble.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/feature_access.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/user_model.dart';
import 'package:grimorio_de_bolso/features/sigils/data/models/sigil_model.dart';
import 'package:grimorio_de_bolso/features/sigils/data/models/sigil_wheel_model.dart';

void main() {
  group('SigilWheel - Roda Alfabética das Bruxas', () {
    test('letterPositions contém as 26 letras do alfabeto', () {
      expect(SigilWheel.letterPositions.length, 26);
      for (var code = 'A'.codeUnitAt(0); code <= 'Z'.codeUnitAt(0); code++) {
        final letter = String.fromCharCode(code);
        expect(SigilWheel.letterPositions.containsKey(letter), isTrue,
            reason: 'Letra $letter ausente da roda');
      }
    });

    test('estrutura de 3 anéis: 6 (A-F), 8 (G-N), 12 (O-Z)', () {
      final byRing = <int, List<String>>{};
      SigilWheel.letterPositions.forEach((letter, pos) {
        byRing.putIfAbsent(pos.ring, () => []).add(letter);
      });

      expect(byRing[1]!..sort(), ['A', 'B', 'C', 'D', 'E', 'F']);
      expect(byRing[2]!..sort(), ['G', 'H', 'I', 'J', 'K', 'L', 'M', 'N']);
      expect(byRing[3]!..sort(),
          ['O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']);
    });

    test('ângulos igualmente espaçados em cada anel', () {
      SigilWheel.letterPositions.forEach((letter, pos) {
        final double step;
        if (pos.ring == 1) {
          step = 60.0;
        } else if (pos.ring == 2) {
          step = 45.0;
        } else {
          step = 30.0;
        }
        expect(pos.angle, pos.index * step,
            reason: 'Ângulo incorreto para $letter');
      });
    });

    test('textToSigilSequence remove acentos, símbolos e duplicatas', () {
      expect(SigilWheel.textToSigilSequence('PROTEÇÃO'),
          ['P', 'R', 'O', 'T', 'E', 'C', 'A']);
      expect(SigilWheel.textToSigilSequence('amor próprio!'),
          ['A', 'M', 'O', 'R', 'P', 'I']);
      expect(SigilWheel.textToSigilSequence(''), isEmpty);
      expect(SigilWheel.textToSigilSequence('123 !!!'), isEmpty);
    });

    test('generateShuffledPositions mantém cada letra em seu anel', () {
      final shuffled = SigilWheel.generateShuffledPositions();
      expect(shuffled.length, 26);
      shuffled.forEach((letter, pos) {
        final original = SigilWheel.letterPositions[letter]!;
        expect(pos.ring, original.ring,
            reason: 'Letra $letter mudou de anel ao embaralhar');
      });
    });
  });

  group('Sigil.fromIntention', () {
    test('gera um ponto por letra única da intenção', () {
      final sigil = Sigil.fromIntention('PROTEÇÃO');
      expect(sigil.processedLetters, 'PROTECA');
      expect(sigil.points.length, sigil.processedLetters.length);
    });
  });

  group('SupabaseConfig', () {
    test('sem --dart-define, o app opera em modo 100% local', () {
      // Em testes não há SUPABASE_URL/SUPABASE_ANON_KEY definidos
      expect(SupabaseConfig.isConfigured, isFalse);
    });
  });

  group('UserModel / Premium', () {
    UserModel makeUser({
      UserRole role = UserRole.free,
      SubscriptionPlan plan = SubscriptionPlan.free,
    }) {
      return UserModel(
        id: 'test_user',
        role: role,
        plan: plan,
        createdAt: DateTime(2026, 1, 1),
        lastLoginAt: DateTime(2026, 1, 1),
      );
    }

    test('role premium/admin conta como premium; free não', () {
      expect(makeUser(role: UserRole.premium).isPremium, isTrue);
      expect(makeUser(role: UserRole.admin).isPremium, isTrue);
      expect(makeUser().isPremium, isFalse);
    });

    test('código beta = role premium + plano lifetime', () {
      final betaUser = makeUser(
        role: UserRole.premium,
        plan: SubscriptionPlan.lifetime,
      );
      expect(betaUser.isPremium, isTrue);
      expect(betaUser.plan, SubscriptionPlan.lifetime);
    });
  });

  group('FeatureAccess - regra única de gating', () {
    UserModel makeUser({
      UserRole role = UserRole.free,
      int oracleToday = 0,
      int runesToday = 0,
      int pendulumToday = 0,
    }) {
      return UserModel(
        id: 'test_user',
        role: role,
        plan: SubscriptionPlan.free,
        createdAt: DateTime(2026, 1, 1),
        lastLoginAt: DateTime(2026, 1, 1),
        oracleReadingsToday: oracleToday,
        runeReadingsToday: runesToday,
        pendulumUsesToday: pendulumToday,
      );
    }

    test('premium tem acesso total a conteúdo premium', () {
      final user = makeUser(role: UserRole.premium);
      expect(
        FeatureAccess.checkAccess(AppFeature.astrologyBirthChart, user)
            .hasFullAccess,
        isTrue,
      );
    });

    test('free tem apenas preview no mapa astral', () {
      final access = FeatureAccess.checkAccess(
          AppFeature.astrologyBirthChart, makeUser());
      expect(access.hasFullAccess, isFalse);
    });

    test('oráculo/runas: free com limite diário (não premium-only)', () {
      // Com usos restantes → acesso liberado (o hub não deve mostrar cadeado)
      expect(
        FeatureAccess.checkAccess(AppFeature.divinationOracle, makeUser())
            .hasFullAccess,
        isTrue,
      );
      expect(
        FeatureAccess.checkAccess(AppFeature.runesReadings, makeUser())
            .hasFullAccess,
        isTrue,
      );
      // Limite esgotado → vira preview (bloqueio com CTA premium)
      expect(
        FeatureAccess.checkAccess(
                AppFeature.divinationOracle, makeUser(oracleToday: 1))
            .hasFullAccess,
        isFalse,
      );
      expect(
        FeatureAccess.checkAccess(
                AppFeature.runesReadings, makeUser(runesToday: 1))
            .hasFullAccess,
        isFalse,
      );
    });

    test('pêndulo: 3 usos/dia para free', () {
      expect(
        FeatureAccess.checkAccess(
                AppFeature.divinationPendulum, makeUser(pendulumToday: 2))
            .hasFullAccess,
        isTrue,
      );
      expect(
        FeatureAccess.checkAccess(
                AppFeature.divinationPendulum, makeUser(pendulumToday: 3))
            .hasFullAccess,
        isFalse,
      );
    });
  });

  group('CatBubbleMessages - balão diário do mascote', () {
    test('messageForDate sempre retorna uma das mensagens', () {
      for (var day = 1; day <= 366; day++) {
        final date = DateTime(2026, 1, 1).add(Duration(days: day - 1));
        expect(
          CatBubbleMessages.messages,
          contains(CatBubbleMessages.messageForDate(date)),
        );
      }
    });

    test('mensagens rotacionam em dias consecutivos e são determinísticas',
        () {
      final day1 = DateTime(2026, 7, 14);
      final day2 = DateTime(2026, 7, 15);

      // Determinístico: mesma data → mesma mensagem
      expect(
        CatBubbleMessages.messageForDate(day1),
        CatBubbleMessages.messageForDate(day1),
      );
      // Rotativo: dias consecutivos → mensagens diferentes
      expect(
        CatBubbleMessages.messageForDate(day1),
        isNot(CatBubbleMessages.messageForDate(day2)),
      );
      // Ciclo completo: volta à mesma mensagem após messages.length dias
      final cycled = day1.add(
        Duration(days: CatBubbleMessages.messages.length),
      );
      expect(
        CatBubbleMessages.messageForDate(day1),
        CatBubbleMessages.messageForDate(cycled),
      );
    });

    test('dateKey formata yyyy-MM-dd com zero à esquerda', () {
      expect(CatBubbleMessages.dateKey(DateTime(2026, 7, 14)), '2026-07-14');
      expect(CatBubbleMessages.dateKey(DateTime(2026, 1, 5)), '2026-01-05');
      expect(CatBubbleMessages.dateKey(DateTime(2026, 12, 31)), '2026-12-31');
    });
  });
}
