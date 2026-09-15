import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/feature_access.dart';
import 'package:grimorio_de_bolso/features/auth/data/models/user_model.dart';
import 'package:grimorio_de_bolso/features/subscription/domain/convite_do_plano.dart';

/// O cartão de "Uso do Plano Gratuito" montava as linhas à mão, e uma delas
/// lia o contador ERRADO: "Conselheiro Místico" mostrava
/// `aiConsultationsToday` (a cota de analisar sonho, sugerir feitiço e clima
/// mágico) contra `freeAiConsultationsLimit`. Os dois limites valem 1, então
/// o denominador batia por coincidência e ninguém percebeu — mas a barra
/// errava nos DOIS sentidos: consultar o Conselheiro não a movia, e analisar
/// um sonho movia.
///
/// A correção não foi trocar um campo: foi tirar os números da mão e passar
/// a lê-los do mesmo mapa que DECIDE o bloqueio. Estes testes trancam isso.
UserModel _bruxa({
  int feiticos = 0,
  int diario = 0,
  int conselheiro = 0,
  int ia = 0,
  int runas = 0,
  int pendulo = 0,
  int oraculo = 0,
  int afirmacoes = 0,
}) {
  return UserModel(
    id: 'bruxa',
    role: UserRole.free,
    plan: SubscriptionPlan.free,
    createdAt: DateTime(2026, 1, 1),
    lastLoginAt: DateTime(2026, 1, 1),
    spellsCount: feiticos,
    diaryEntriesThisMonth: diario,
    advisorConsultationsToday: conselheiro,
    aiConsultationsToday: ia,
    runeReadingsToday: runas,
    pendulumUsesToday: pendulo,
    oracleReadingsToday: oraculo,
    affirmationsToday: afirmacoes,
  );
}

const _rotulos = {
  BalcaoDoLimite.feiticos: 'Feitiços',
  BalcaoDoLimite.diario: 'Diário',
  BalcaoDoLimite.conselheiro: 'Conselheiro',
  BalcaoDoLimite.ia: 'Consultas místicas',
  BalcaoDoLimite.runas: 'Runas',
  BalcaoDoLimite.pendulo: 'Pêndulo',
  BalcaoDoLimite.oraculo: 'Oráculo e Tarô',
  BalcaoDoLimite.afirmacoes: 'Afirmações',
};

LimiteVisivel _cota(List<LimiteVisivel> lista, BalcaoDoLimite chave) =>
    lista.firstWhere((l) => l.chave == chave);

void main() {
  setUpAll(() {
    // Os limites carregam mensagens traduzidas ao serem montados.
    ContentLocale.instance.setLocale(const Locale('pt', 'BR'));
  });

  group('de onde cada cota tira o número', () {
    test('o Conselheiro anda com a consulta AO CONSELHEIRO', () {
      final antes = _cota(
        limitesDoPlanoGratuito(_bruxa(), _rotulos),
        BalcaoDoLimite.conselheiro,
      );
      expect(antes.usado, 0);

      final depois = _cota(
        limitesDoPlanoGratuito(_bruxa(conselheiro: 1), _rotulos),
        BalcaoDoLimite.conselheiro,
      );
      expect(depois.usado, 1, reason: 'era o defeito: não andava');
      expect(depois.esgotado, isTrue);
    });

    test('analisar um sonho NÃO move a barra do Conselheiro', () {
      // O outro sentido do mesmo defeito, e o mais confuso de todos: a
      // pessoa via a barra do Conselheiro andar por ter feito outra coisa.
      final limites = limitesDoPlanoGratuito(_bruxa(ia: 1), _rotulos);

      expect(_cota(limites, BalcaoDoLimite.conselheiro).usado, 0);
      expect(_cota(limites, BalcaoDoLimite.ia).usado, 1);
    });

    test('o Tarô consome a leitura do Oráculo do dia', () {
      // Regra invisível do app: as duas features leem `oracleReadingsToday`.
      // Uma linha por FEATURE faria a mesma cota aparecer duas vezes, cada
      // uma andando quando a pessoa usou "outra coisa".
      final limites = limitesDoPlanoGratuito(_bruxa(oraculo: 1), _rotulos);
      final oraculo = _cota(limites, BalcaoDoLimite.oraculo);

      expect(oraculo.usado, 1);
      expect(oraculo.esgotado, isTrue);
      expect(
        limites.where((l) => l.chave == BalcaoDoLimite.oraculo).length,
        1,
        reason: 'uma cota, uma linha',
      );
    });

    test('todas as cotas do plano Free aparecem', () {
      // O cartão antigo mostrava três. Ficavam de fora Runas, Pêndulo,
      // Oráculo/Tarô, as consultas de IA e as afirmações — todas com limite
      // real, todas capazes de parar a pessoa sem aviso nenhum.
      final limites = limitesDoPlanoGratuito(_bruxa(), _rotulos);
      expect(
        limites.map((l) => l.chave).toSet(),
        BalcaoDoLimite.values.toSet(),
      );
    });

    test('o número e o teto vêm do mesmo mapa que bloqueia', () {
      // Se algum dia o limite do Conselheiro mudar, a tela acompanha
      // sozinha — era essa a classe de defeito, não o campo trocado.
      final registro = FeatureAccessService.limits[AppFeature.aiMysticCounselor]!;
      final cota = _cota(
        limitesDoPlanoGratuito(_bruxa(conselheiro: 1), _rotulos),
        BalcaoDoLimite.conselheiro,
      );

      expect(cota.limite, registro.limit);
      expect(cota.usado, registro.used(_bruxa(conselheiro: 1)));
      expect(cota.janela, registro.window);
    });
  });

  group('em que estado o cartão fica', () {
    test('sem nada usado, fica longe — e não mostra número nenhum', () {
      // "0/10 · 0/30 · 0/1" era o pior uso possível do melhor espaço da
      // tela: zero usado é quando o limite parece generoso e distante.
      final momento = lerOMomento(limitesDoPlanoGratuito(_bruxa(), _rotulos));

      expect(momento.estado, EstadoDoConvite.longe);
      expect(momento.emFoco, isNull);
    });

    test('uma cota na última põe ELA em foco', () {
      // 9 de 10 feitiços: resta um.
      final momento =
          lerOMomento(limitesDoPlanoGratuito(_bruxa(feiticos: 9), _rotulos));

      expect(momento.estado, EstadoDoConvite.perto);
      expect(momento.emFoco!.chave, BalcaoDoLimite.feiticos);
      expect(momento.emFoco!.restante, 1);
    });

    test('cota de 1 intocada não é "perto"', () {
      // O caso escorregadio: numa cota de 1, quem não usou nada também tem
      // "resta 1". Chamar isso de aviso transformaria o começo do dia em
      // contagem regressiva.
      final momento = lerOMomento(limitesDoPlanoGratuito(_bruxa(), _rotulos));
      expect(momento.estado, EstadoDoConvite.longe);
    });

    test('cota esgotada vence cota na última', () {
      final momento = lerOMomento(limitesDoPlanoGratuito(
        _bruxa(feiticos: 9, runas: 1),
        _rotulos,
      ));

      expect(momento.estado, EstadoDoConvite.noLimite);
      expect(momento.emFoco!.chave, BalcaoDoLimite.runas);
    });

    test('entre duas esgotadas, a de teto menor fica em foco', () {
      // Perder a única consulta do dia dói mais do que a trigésima entrada
      // do diário.
      final momento = lerOMomento(limitesDoPlanoGratuito(
        _bruxa(diario: 30, conselheiro: 1),
        _rotulos,
      ));

      expect(momento.estado, EstadoDoConvite.noLimite);
      expect(momento.emFoco!.chave, BalcaoDoLimite.conselheiro);
    });

    test('usar mais do que o teto não vira restante negativo', () {
      // Acontece de verdade: o contador do servidor pode chegar adiantado
      // depois de um sync. "-1 restante" na tela seria pior que o limite.
      final limites = limitesDoPlanoGratuito(_bruxa(runas: 3), _rotulos);
      final runas = _cota(limites, BalcaoDoLimite.runas);

      expect(runas.restante, 0);
      expect(runas.fracao, greaterThan(1));
      expect(lerOMomento(limites).estado, EstadoDoConvite.noLimite);
    });
  });

  group('o vislumbre roda por dia', () {
    test('o mesmo dia devolve o mesmo vislumbre', () {
      // Trocar a cada abertura de tela viraria ruído: a pessoa nunca
      // terminaria de ler o mesmo.
      expect(
        indiceDoVislumbre(DateTime(2026, 8, 22, 9), 6),
        indiceDoVislumbre(DateTime(2026, 8, 22, 23), 6),
      );
    });

    test('o dia seguinte devolve outro', () {
      expect(
        indiceDoVislumbre(DateTime(2026, 8, 22), 6),
        isNot(indiceDoVislumbre(DateTime(2026, 8, 23), 6)),
      );
    });

    test('nunca sai da lista, em nenhuma data', () {
      for (var d = 0; d < 400; d++) {
        final i = indiceDoVislumbre(DateTime(2026, 1, 1).add(Duration(days: d)), 6);
        expect(i, inInclusiveRange(0, 5));
      }
      expect(indiceDoVislumbre(DateTime(1999, 5, 3), 6), inInclusiveRange(0, 5));
      expect(indiceDoVislumbre(DateTime(2026, 8, 22), 0), 0);
    });
  });
}
