import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A política que mentia.
///
/// Documento legal não tem compilador: ele envelhece em silêncio enquanto o
/// código muda embaixo. A política afirmava que "a sincronização na nuvem é
/// opcional, exclusiva do Premium" muito depois de o paywall ter saído do
/// DataSyncService — quem lia a política na tela de cadastro recebia uma
/// informação falsa sobre para onde vão os próprios registros.
///
/// Estas são catracas de texto: elas não provam que a política está certa —
/// isso ninguém automatiza. Provam que as afirmações que JÁ divergiram do
/// código não voltam sozinhas, e que as três mudanças capazes de desmentir o
/// texto de novo — recolocar o paywall, trocar o provedor de IA, acrescentar
/// uma entidade ao sync — quebram o teste antes de quebrarem a promessa.
void main() {
  final politica =
      File('assets/legal/politica_de_privacidade.md').readAsStringSync();
  final termos = File('assets/legal/termos_de_uso.md').readAsStringSync();
  final servicoDeSync =
      File('lib/core/services/data_sync_service.dart').readAsStringSync();
  final servicoDeIa = File('lib/core/ai/ai_service.dart').readAsStringSync();

  // Os valores de um enum declarado em uma linha só, sem os comentários.
  List<String> valoresDoEnum(String fonte, String nome) {
    final declaracao = RegExp('enum $nome \\{([^}]*)\\}').firstMatch(fonte);
    expect(declaracao, isNotNull,
        reason: 'enum $nome mudou de forma — reveja esta catraca.');
    return declaracao!
        .group(1)!
        .replaceAll(RegExp('//[^\n]*'), '')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  group('política de privacidade x código', () {
    test('não promete sincronização exclusiva do Premium', () {
      // O texto exato que estava lá, e as variações vizinhas: o gate aqui é
      // a palavra Premium colada em sincronização, em qualquer ordem.
      for (final frase in [
        'exclusiva do Premium',
        'apenas se você for Premium',
        'opcional, Premium',
        'sincronização Premium',
      ]) {
        expect(politica.contains(frase), isFalse,
            reason: 'A política voltou a dizer "$frase". Quem governa o envio '
                'é DataSyncService.cloudSyncPreferenceKey, sem plano.');
      }

      // Âncora POSITIVA: proibir as frases antigas não impede que a próxima
      // reescrita simplesmente cale sobre o plano, e calar é o estado em que
      // a mentira nasceu.
      expect(politica.contains('em qualquer plano'), isTrue,
          reason: 'A política parou de dizer que a sincronização vale em '
              'qualquer plano. Dizer isso é o conserto; omitir devolve o '
              'documento ao silêncio de antes.');
    });

    test('o interruptor de nuvem continua sem plano no código', () {
      // Se o paywall voltar, a frase acima volta a ser verdade — e este teste
      // é quem manda reescrever a política ANTES de religar o cadeado.
      expect(
        servicoDeSync
            .contains('static bool resolveCloudSyncPreference(SharedPreferences'),
        isTrue,
        reason: 'resolveCloudSyncPreference mudou de assinatura. Se voltou a '
            'receber o plano, a política precisa dizer isso de novo.',
      );
    });

    test('nomeia todos os provedores de IA que o app usa', () {
      // A política citava só o Groq enquanto a visão (foto da palma,
      // identificação de plantas e pedras, escrita do verbete a partir da
      // foto) ia para o Gemini. Acrescentar um provedor ao enum passa a
      // exigir acrescentá-lo ao texto.
      const nomeNaPolitica = {'groq': 'Groq', 'gemini': 'Gemini'};
      for (final provedor in valoresDoEnum(servicoDeIa, 'AiProvider')) {
        final nome = nomeNaPolitica[provedor];
        expect(nome, isNotNull,
            reason: 'Provedor de IA novo ($provedor) sem nome conhecido na '
                'política. Acrescente-o ao texto e a este mapa.');
        expect(politica.contains(nome!), isTrue,
            reason: 'A política não menciona $nome, que recebe dados hoje.');
      }
    });

    test('a lista de categorias cobre tudo que o sync sobe', () {
      // A lista de "Conteúdo que você cria" nomeava seis coisas enquanto o
      // SyncEntity subia vinte: quem lia a política não sabia que o
      // check-in, o progresso das trilhas e a Leitura do Ciclo saíam do
      // aparelho. Cada entidade nova passa a exigir uma palavra no texto.
      final inicio = politica.indexOf('### Conteúdo que você cria');
      expect(inicio, greaterThanOrEqualTo(0),
          reason: 'A seção "Conteúdo que você cria" sumiu ou mudou de nome — '
              'é ela que lista o que sai do aparelho.');
      final resto = politica.substring(inicio + 1);
      final fim = resto.indexOf('\n### ');
      final secao = fim == -1 ? resto : resto.substring(0, fim);

      // A palavra que cada entidade precisa ter na seção. Não é o nome
      // técnico: é como a pessoa chama a coisa na tela.
      const categoriaNaPolitica = {
        'spells': 'Feitiços',
        'dreams': 'sonhos',
        'desires': 'desejos',
        'gratitudes': 'gratidão',
        'affirmations': 'afirmações',
        'freeWritings': 'reflexões',
        'dailyRituals': 'rituais',
        'ritualLogs': 'registros das práticas',
        'sigils': 'sigilos',
        'birthCharts': 'mapas de nascimento',
        'magicalProfiles': 'perfil mágico',
        'runeReadings': 'runas',
        'pendulumConsultations': 'pêndulo',
        'oracleReadings': 'oráculo',
        'tarotReadings': 'tarot',
        'dailyMagicalWeather': 'clima mágico',
        'dailyCheckins': 'check-in',
        'learningProgress': 'trilhas de aprendizado',
        'userEncyclopediaEntries': 'verbetes',
        'cycleReadings': 'Leitura do Ciclo',
      };
      for (final entidade in valoresDoEnum(servicoDeSync, 'SyncEntity')) {
        final categoria = categoriaNaPolitica[entidade];
        expect(categoria, isNotNull,
            reason: 'SyncEntity.$entidade passou a subir para a nuvem e a '
                'política não sabe que ele existe. Nomeie a categoria na '
                'seção "Conteúdo que você cria" e acrescente-a a este mapa.');
        expect(secao.contains(categoria!), isTrue,
            reason: 'A seção "Conteúdo que você cria" não nomeia '
                '"$categoria" (SyncEntity.$entidade), que sobe para a nuvem.');
      }
    });

    test('dado menstrual não sobe antes de a política falar de saúde', () {
      // A tabela `menstrual_days` guarda fluxo, sintomas, humor e anotações:
      // dado de saúde, sensível na LGPD. Hoje ela fica FORA do SyncEntity e
      // a política não tem uma palavra sobre ciclo — as duas coisas só são
      // compatíveis enquanto o dado não sai do aparelho. Quem ligar o envio
      // encontra esta catraca antes de encontrar a fiscalização.
      //
      // A busca é pelo NOME DA TABELA entre aspas e pelos valores do enum,
      // não pela palavra solta: um comentário citando o ciclo não é envio, e
      // catraca que grita por comentário é catraca que alguém desliga.
      expect(servicoDeSync.contains("'menstrual_days'"), isFalse,
          reason: 'A tabela menstrual_days entrou no DataSyncService. Antes '
              'de subir dado de saúde para a nuvem, a Política precisa de uma '
              'seção sobre dado sensível, com consentimento destacado — hoje '
              'ela não tem nenhuma. Escreva a seção e então mude este teste.');
      expect(
          valoresDoEnum(servicoDeSync, 'SyncEntity')
              .any((e) => e.toLowerCase().contains('menstrual')),
          isFalse,
          reason: 'Uma entidade menstrual entrou no SyncEntity. Veja acima: a '
              'política precisa falar de dado sensível ANTES do primeiro '
              'upload, não depois.');
    });

    test('conta deixou de ser opcional no texto, como é no app', () {
      expect(politica.contains('Dados de conta (se você criar uma)'), isFalse,
          reason: 'Não há caminho de convidado: o router manda quem não tem '
              'sessão para as telas de entrada.');
      expect(termos.contains('exige uma conta'), isTrue);
    });
  });

  group('higiene dos documentos legais', () {
    test('os dois trazem data de vigência', () {
      for (final documento in {
        'politica_de_privacidade.md': politica,
        'termos_de_uso.md': termos,
      }.entries) {
        expect(documento.value.contains('Última atualização:'), isTrue,
            reason: '${documento.key} ficou sem data de vigência.');
      }
    });

    test('o contato de dados continua no texto', () {
      expect(politica.contains('suporte.grimoriodebolso@gmail.com'), isTrue);
      expect(termos.contains('suporte.grimoriodebolso@gmail.com'), isTrue);
    });
  });
}
