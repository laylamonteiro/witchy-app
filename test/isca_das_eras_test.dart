import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/feature_access.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/user_model.dart';
import 'package:grimorio_de_bolso/features/cycles/domain/life_eras_calculator.dart';
import 'package:grimorio_de_bolso/features/cycles/domain/life_timeline.dart';
import 'package:grimorio_de_bolso/features/cycles/presentation/pages/era_reading_page.dart';

/// A Era e a Fase de agora são a isca de Suas Eras: sem elas abertas, ninguém
/// descobre que existem 120 anos de linha do tempo por trás.
///
/// `AppFeature.lifeErasNow` foi criada, posta em `freeFeatures` com o
/// comentário "a isca da feature" — e nunca lida por ninguém. A tela de
/// leitura exigia `lifeErasFull` para QUALQUER leitura, inclusive a atual.
///
/// O resultado na tela era o pior arranjo possível: os dois cartões de "Agora"
/// não tinham cadeado e pareciam abertos, a pessoa tocava na isca e batia numa
/// tela travada — enquanto as listas de passado e futuro, essas sim, tinham
/// cadeado. A única coisa que ela podia ver de graça era a que parecia
/// proibida, e vice-versa.
void main() {
  // Caso de referência do cálculo, o mesmo de life_eras_calculator_test.
  final nascimento = DateTime.utc(1994, 8, 15, 12, 0);
  final linha = calcularLinhaDoTempo(
    longitudeLuaTropical: 83.4598,
    nascimentoUtc: nascimento,
  );
  final agora = DateTime.utc(2026, 8, 22, 12);

  group('qual feature governa a leitura', () {
    test('a Era de agora é aberta', () {
      expect(
        EraReadingPage.featureDaLeitura(
          era: linha.eraEm(agora),
          fase: null,
          agora: agora,
        ),
        AppFeature.lifeErasNow,
      );
    });

    test('a Fase de agora é aberta', () {
      expect(
        EraReadingPage.featureDaLeitura(
          era: linha.eraEm(agora),
          fase: linha.faseEm(agora),
          agora: agora,
        ),
        AppFeature.lifeErasNow,
      );
    });

    test('a Era do passado é Premium', () {
      final passadas = linha.eras.where((e) => e.fim.isBefore(agora)).toList();
      expect(passadas, isNotEmpty, reason: 'o caso precisa ter passado');
      expect(
        EraReadingPage.featureDaLeitura(
          era: passadas.first,
          fase: null,
          agora: agora,
        ),
        AppFeature.lifeErasFull,
      );
    });

    test('a Era do futuro é Premium', () {
      final futuras = linha.eras.where((e) => e.inicio.isAfter(agora)).toList();
      expect(futuras, isNotEmpty, reason: 'o caso precisa ter futuro');
      expect(
        EraReadingPage.featureDaLeitura(
          era: futuras.first,
          fase: null,
          agora: agora,
        ),
        AppFeature.lifeErasFull,
      );
    });

    test('uma Fase que não é a de agora é Premium, mesmo na Era de agora',
        () {
      // O caso mais escorregadio: a Era está acontecendo, a Fase não. Quem
      // decide é a janela mais estreita.
      final eraAtual = linha.eraEm(agora);
      final faseAtual = linha.faseEm(agora);
      final outraFase = eraAtual.fases.firstWhere(
        (f) => f.inicio != faseAtual.inicio,
        orElse: () => faseAtual,
      );
      if (outraFase.inicio == faseAtual.inicio) {
        return; // Era de fase única: nada a distinguir.
      }

      expect(
        EraReadingPage.featureDaLeitura(
          era: eraAtual,
          fase: outraFase,
          agora: agora,
        ),
        AppFeature.lifeErasFull,
      );
    });

    test('a isca é mesmo de graça — senão escolhê-la não adianta', () {
      // A tela apontar para `lifeErasNow` só resolve se `lifeErasNow` for
      // aberta. Os dois lados da regra, no mesmo teste.
      final free = UserModel(
        id: 'bruxa-free',
        role: UserRole.free,
        plan: SubscriptionPlan.free,
        createdAt: DateTime(2026, 1, 1),
        lastLoginAt: DateTime(2026, 1, 1),
      );

      expect(
        FeatureAccess.checkAccess(AppFeature.lifeErasNow, free,
                isPremiumEffective: false)
            .hasFullAccess,
        isTrue,
        reason: 'a Era de agora precisa abrir sem Premium',
      );
      expect(
        FeatureAccess.checkAccess(AppFeature.lifeErasFull, free,
                isPremiumEffective: false)
            .hasFullAccess,
        isFalse,
        reason: 'passado e futuro continuam Premium',
      );
    });
  });

  test('a hora local não muda a resposta na virada do dia', () {
    // A linha do tempo guarda tudo em UTC; a tela pergunta com DateTime.now(),
    // que é local. Sem o toUtc, quem está longe de Greenwich veria a isca
    // trancar sozinha por algumas horas.
    final eraAtual = linha.eraEm(agora);
    final localEquivalente = agora.toLocal();

    expect(
      EraReadingPage.featureDaLeitura(
        era: eraAtual,
        fase: null,
        agora: localEquivalente,
      ),
      AppFeature.lifeErasNow,
    );
  });
}
