import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/content/content_locale.dart';
import 'package:grimorio_de_bolso/core/legal/legal_document_page.dart';

/// A política que mentia — agora em três idiomas.
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
///
/// Desde que o app passou a oferecer os documentos em inglês e espanhol, cada
/// catraca vale nos três: uma tradução que perca a seção do dado sensível, ou
/// que esqueça de nomear uma categoria nova, mente exatamente como o
/// português mentia — só que para quem tem menos como conferir. Por isso as
/// frases procuradas vivem em mapas por idioma, e não em três cópias do mesmo
/// teste: acrescentar um idioma é acrescentar uma coluna, e a coluna que
/// faltar aparece como chave ausente, não como catraca que deixou de rodar.
///
/// A catraca desceu para os ARBs porque travar só o .md consertou o documento
/// e deixou a mentira na tela: a pergunta frequente faqA2 continuou dizendo
/// "com o Premium e a sincronização ativada" muito depois de a política ter
/// sido reescrita, e faqA3 continuou vendendo a sincronização como benefício
/// pago. A frase é lida muito mais vezes no acordeão de dúvidas do que no
/// documento legal — mandá-la embora de um lugar só é trocar o leitor que
/// recebe a informação falsa, não parar de dá-la.
void main() {
  const idiomas = ['pt', 'en', 'es'];

  final politicas = {
    'pt': File('assets/legal/politica_de_privacidade.md').readAsStringSync(),
    'en': File('assets/legal/politica_de_privacidade_en.md').readAsStringSync(),
    'es': File('assets/legal/politica_de_privacidade_es.md').readAsStringSync(),
  };
  final termos = {
    'pt': File('assets/legal/termos_de_uso.md').readAsStringSync(),
    'en': File('assets/legal/termos_de_uso_en.md').readAsStringSync(),
    'es': File('assets/legal/termos_de_uso_es.md').readAsStringSync(),
  };

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

  // O trecho entre um título de terceiro nível e o próximo.
  String secao(String documento, String titulo, String idioma) {
    final inicio = documento.indexOf(titulo);
    expect(inicio, greaterThanOrEqualTo(0),
        reason: 'A seção "$titulo" sumiu ou mudou de nome na política em '
            '$idioma.');
    final resto = documento.substring(inicio + 1);
    final fim = resto.indexOf('\n### ');
    return fim == -1 ? resto : resto.substring(0, fim);
  }

  // Toma o valor do idioma e falha com nome se o mapa não tiver a coluna —
  // é assim que um idioma novo se anuncia em vez de passar despercebido.
  String no(Map<String, String> porIdioma, String idioma, String oQue) {
    final valor = porIdioma[idioma];
    expect(valor, isNotNull,
        reason: 'Falta a versão em $idioma de "$oQue" nesta catraca. Traduza '
            'a frase e acrescente-a ao mapa.');
    return valor!;
  }

  // Mesma ideia do `no`, para as listas de palavra: um idioma sem coluna
  // aparece pelo nome em vez de passar sem catraca nenhuma.
  List<String> nos(
      Map<String, List<String>> porIdioma, String idioma, String oQue) {
    final valor = porIdioma[idioma];
    expect(valor, isNotNull,
        reason: 'Falta a versão em $idioma de "$oQue" nesta catraca. Traduza '
            'as palavras e acrescente-as ao mapa.');
    return valor!;
  }

  // Os quatro ARBs, e o idioma de cada um. pt_BR entra junto porque é cópia
  // do pt: uma correção que esquece a cópia arruma o template e não arruma o
  // app de quem usa português do Brasil, que é quase todo mundo aqui.
  const idiomaDoArb = {
    'app_pt': 'pt',
    'app_pt_BR': 'pt',
    'app_en': 'en',
    'app_es': 'es',
  };

  // Só o que chega à tela: chave com '@' é metadado do ARB, e valor que não é
  // String é bloco de plural ou de placeholder, não frase.
  Map<String, String> soOsTextos(String arquivo) {
    final cru = jsonDecode(File('lib/l10n/$arquivo.arb').readAsStringSync())
        as Map<String, dynamic>;
    final textos = <String, String>{};
    cru.forEach((chave, valor) {
      if (!chave.startsWith('@') && valor is String) textos[chave] = valor;
    });
    return textos;
  }

  final textosDoArb = {
    for (final arquivo in idiomaDoArb.keys) arquivo: soOsTextos(arquivo),
  };

  const tituloDoConteudo = {
    'pt': '### Conteúdo que você cria',
    'en': '### Content you create',
    'es': '### Contenido que creas',
  };
  const tituloDoCiclo = {
    'pt': '### Registro do Ciclo Menstrual',
    'en': '### Menstrual Cycle record',
    'es': '### Registro del Ciclo Menstrual',
  };
  const meusRegistros = {
    'pt': 'Meus Registros',
    'en': 'My Records',
    'es': 'Mis Registros',
  };

  group('política de privacidade x código', () {
    test('não promete sincronização exclusiva do Premium', () {
      // O texto exato que estava lá, e as variações vizinhas: o gate aqui é
      // a palavra Premium colada em sincronização, em qualquer ordem.
      const proibidas = {
        'pt': [
          'exclusiva do Premium',
          'apenas se você for Premium',
          'opcional, Premium',
          'sincronização Premium',
        ],
        'en': [
          'exclusive to Premium',
          'only if you are Premium',
          'optional, Premium',
          'Premium sync',
        ],
        'es': [
          'exclusiva de Premium',
          'solo si eres Premium',
          'opcional, Premium',
          'sincronización Premium',
        ],
      };

      // Âncora POSITIVA: proibir as frases antigas não impede que a próxima
      // reescrita simplesmente cale sobre o plano, e calar é o estado em que
      // a mentira nasceu.
      const qualquerPlano = {
        'pt': 'em qualquer plano',
        'en': 'on any plan',
        'es': 'en cualquier plan',
      };

      for (final idioma in idiomas) {
        final politica = politicas[idioma]!;
        for (final frase in proibidas[idioma]!) {
          expect(politica.contains(frase), isFalse,
              reason: 'A política em $idioma voltou a dizer "$frase". Quem '
                  'governa o envio é '
                  'DataSyncService.cloudSyncPreferenceKey, sem plano.');
        }
        expect(politica.contains(no(qualquerPlano, idioma, 'qualquer plano')),
            isTrue,
            reason: 'A política em $idioma parou de dizer que a sincronização '
                'vale em qualquer plano. Dizer isso é o conserto; omitir '
                'devolve o documento ao silêncio de antes.');
      }
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
      // exigir acrescentá-lo ao texto — e o nome do provedor não se traduz,
      // então a mesma palavra é cobrada nos três documentos.
      const nomeNaPolitica = {'groq': 'Groq', 'gemini': 'Gemini'};
      for (final provedor in valoresDoEnum(servicoDeIa, 'AiProvider')) {
        final nome = nomeNaPolitica[provedor];
        expect(nome, isNotNull,
            reason: 'Provedor de IA novo ($provedor) sem nome conhecido na '
                'política. Acrescente-o ao texto e a este mapa.');
        for (final idioma in idiomas) {
          expect(politicas[idioma]!.contains(nome!), isTrue,
              reason: 'A política em $idioma não menciona $nome, que recebe '
                  'dados hoje.');
        }
      }
    });

    test('a lista de categorias cobre tudo que o sync sobe', () {
      // A lista de "Conteúdo que você cria" nomeava seis coisas enquanto o
      // SyncEntity subia vinte: quem lia a política não sabia que o
      // check-in, o progresso das trilhas e a Leitura do Ciclo saíam do
      // aparelho. Cada entidade nova passa a exigir uma palavra no texto —
      // em cada idioma, com o rótulo que a pessoa vê na tela daquele idioma.
      const categoriaNaPolitica = {
        'spells': {'pt': 'Feitiços', 'en': 'Spells', 'es': 'Hechizos'},
        'dreams': {'pt': 'sonhos', 'en': 'dreams', 'es': 'sueños'},
        'desires': {'pt': 'desejos', 'en': 'desires', 'es': 'deseos'},
        'gratitudes': {'pt': 'gratidão', 'en': 'gratitude', 'es': 'gratitud'},
        'affirmations': {
          'pt': 'afirmações',
          'en': 'affirmations',
          'es': 'afirmaciones',
        },
        'freeWritings': {
          'pt': 'reflexões',
          'en': 'reflections',
          'es': 'reflexiones',
        },
        'dailyRituals': {'pt': 'rituais', 'en': 'rituals', 'es': 'rituales'},
        'ritualLogs': {
          'pt': 'registros das práticas',
          'en': 'records of the practices',
          'es': 'registros de las prácticas',
        },
        'sigils': {'pt': 'sigilos', 'en': 'sigils', 'es': 'sigilos'},
        'birthCharts': {
          'pt': 'mapas de nascimento',
          'en': 'birth charts',
          'es': 'cartas natales',
        },
        'magicalProfiles': {
          'pt': 'perfil mágico',
          'en': 'magical profile',
          'es': 'perfil mágico',
        },
        'runeReadings': {'pt': 'runas', 'en': 'runes', 'es': 'runas'},
        'pendulumConsultations': {
          'pt': 'pêndulo',
          'en': 'pendulum',
          'es': 'péndulo',
        },
        'oracleReadings': {'pt': 'oráculo', 'en': 'oracle', 'es': 'oráculo'},
        'tarotReadings': {'pt': 'tarot', 'en': 'tarot', 'es': 'tarot'},
        'dailyMagicalWeather': {
          'pt': 'clima mágico',
          'en': 'magical weather',
          'es': 'clima mágico',
        },
        'dailyCheckins': {'pt': 'check-in', 'en': 'check-in', 'es': 'check-in'},
        'learningProgress': {
          'pt': 'trilhas de aprendizado',
          'en': 'learning trails',
          'es': 'rutas de aprendizaje',
        },
        'userEncyclopediaEntries': {
          'pt': 'verbetes',
          'en': 'entries',
          'es': 'entradas',
        },
        'cycleReadings': {
          'pt': 'Leitura do Ciclo',
          'en': 'Cycle Reading',
          'es': 'Lectura del Ciclo',
        },
        'menstrualDays': {
          'pt': 'Ciclo Menstrual',
          'en': 'Menstrual Cycle',
          'es': 'Ciclo Menstrual',
        },
      };

      for (final idioma in idiomas) {
        final trecho = secao(
          politicas[idioma]!,
          no(tituloDoConteudo, idioma, 'título da seção de conteúdo'),
          idioma,
        );
        for (final entidade in valoresDoEnum(servicoDeSync, 'SyncEntity')) {
          final categoria = categoriaNaPolitica[entidade];
          expect(categoria, isNotNull,
              reason: 'SyncEntity.$entidade passou a subir para a nuvem e a '
                  'política não sabe que ele existe. Nomeie a categoria na '
                  'seção "Conteúdo que você cria", nos três idiomas, e '
                  'acrescente-a a este mapa.');
          final palavra = no(categoria!, idioma, 'categoria de $entidade');
          expect(trecho.contains(palavra), isTrue,
              reason: 'A seção de conteúdo da política em $idioma não nomeia '
                  '"$palavra" (SyncEntity.$entidade), que sobe para a nuvem.');
        }
      }
    });

    test('a política tem a seção de dado sensível que o envio exige', () {
      // A catraca anterior proibia `menstrual_days` de entrar no
      // DataSyncService, e a condição para destravá-la estava escrita nela:
      // "escreva a seção sobre dado sensível e então mude este teste". A
      // seção existe, o envio existe — e a trava muda de lugar. O que se
      // trava agora não é a ausência do dado no sync: é a presença da seção
      // que o descreve, e das guardas que o prendem.
      //
      // Cada frase aqui é uma promessa que o código desta frente cumpre. A
      // que sair do texto deixa a promessa sem quem a declare — e uma
      // promessa que só existe em português não vale para quem lê o app em
      // inglês ou espanhol.
      const exigidas = {
        'que este registro é dado de saúde': {
          'pt': 'saúde',
          'en': 'health',
          'es': 'salud',
        },
        'que a LGPD o trata como dado sensível': {
          'pt': 'sensível',
          'en': 'sensitive',
          'es': 'sensible',
        },
        'que o sim dele é destacado, e não o sim geral da sincronização': {
          'pt': 'consentimento destacado',
          'en': 'separate, specific consent',
          'es': 'consentimiento destacado',
        },
        'o que nunca sai do aparelho — a página do dia no Grimório': {
          'pt': 'NÃO sobe',
          'en': 'does NOT leave',
          'es': 'NO sube',
        },
        'que desligar interrompe o envio': {
          'pt': 'Desligar interrompe',
          'en': 'Turning it off stops',
          'es': 'Apagar interrumpe',
        },
        'que desligar não apaga sozinho a cópia que já subiu': {
          'pt': 'apagá-la é um gesto próprio',
          'en': 'erasing it is a gesture of its own',
          'es': 'borrarla es un gesto aparte',
        },
      };

      for (final idioma in idiomas) {
        final trecho = secao(
            politicas[idioma]!,
            no(tituloDoCiclo, idioma, 'título da seção do Ciclo Menstrual'),
            idioma);
        expect(trecho.isNotEmpty, isTrue,
            reason: 'A seção do Ciclo Menstrual em $idioma ficou vazia. Ela é '
                'a base legal do envio: sem ela, dado de saúde sobe sem que a '
                'Política diga que sobe.');
        exigidas.forEach((promessa, porIdioma) {
          expect(trecho.contains(no(porIdioma, idioma, promessa)), isTrue,
              reason: 'A seção em $idioma deixou de dizer $promessa.');
        });
      }
    });

    test('o envio do ciclo só existe atrás do segundo sim', () {
      // A busca é no CÓDIGO como texto, como na catraca que esta substitui:
      // o que precisa quebrar é a remoção da guarda, e a guarda é uma
      // condição dentro de um `if` — a coisa mais fácil do mundo de apagar
      // sem perceber. O comportamento correspondente está em
      // test/o_ciclo_nao_sobe_test.dart, que roda o sync de verdade.
      expect(
          valoresDoEnum(servicoDeSync, 'SyncEntity')
              .any((e) => e.toLowerCase().contains('menstrual')),
          isTrue,
          reason: 'A entidade menstrual saiu do SyncEntity. Se o envio do '
              'ciclo foi removido, a Política precisa voltar a dizer que o '
              'registro não sai do aparelho — hoje ela diz que sai, com o '
              'segundo sim.');

      expect(servicoDeSync.contains('MenstrualConsentStore'), isTrue,
          reason: 'O DataSyncService parou de consultar o consentimento de '
              'envio. Sem ele, ligar a sincronização do aplicativo passa a '
              'levar dado de saúde junto — que é exatamente o que os dois '
              'sins existem para impedir.');

      expect(
        servicoDeSync.contains('bool _envioDoCicloPermitido = false;'),
        isTrue,
        reason: 'O consentimento de envio deixou de nascer DESLIGADO no '
            'serviço. Este campo é o único cujo padrão é a recusa: quem '
            'esquecer de lê-lo num caminho novo precisa errar para o lado de '
            'não enviar.',
      );

      expect(
        RegExp(r"table\s*==\s*'menstrual_days'\s*&&\s*!_envioDoCicloPermitido")
            .hasMatch(servicoDeSync),
        isTrue,
        reason: 'A guarda saiu de `_isSyncableItem`. É o único funil por onde '
            'TODA varredura passa, inclusive a do primeiro login — que roda '
            'logo depois de a adoção de dados anônimos mexer no histórico '
            'escrito antes de existir conta.',
      );
    });

    test('a página do dia no acervo não sobe, com sim nenhum', () {
      // A LINHA de menstrual_days passou a subir; a PÁGINA que cada dia ganha
      // no Grimório, não — e nenhum consentimento a libera. São dois dados
      // diferentes do mesmo dia, e o segundo é o corpo dela em prosa.
      expect(
        servicoDeSync.contains('FreeWritingSource.neverLeavesDevice'),
        isTrue,
        reason: 'O funil parou de barrar as origens do acervo que não saem do '
            'aparelho. Com o ciclo sincronizando, esta linha ficou MAIS '
            'necessária, não menos: sem ela o mesmo dia viaja duas vezes, e a '
            'segunda em texto corrido.',
      );

      for (final idioma in idiomas) {
        final trecho = secao(
            politicas[idioma]!,
            no(tituloDoCiclo, idioma, 'título da seção do Ciclo Menstrual'),
            idioma);
        expect(trecho.contains(no(meusRegistros, idioma, 'Meus Registros')),
            isTrue,
            reason: 'A seção em $idioma parou de nomear a página do dia no '
                'Grimório como o que fica no aparelho em qualquer hipótese.');
      }
    });

    test('conta deixou de ser opcional no texto, como é no app', () {
      const contaOpcional = {
        'pt': 'Dados de conta (se você criar uma)',
        'en': 'Account data (if you create one)',
        'es': 'Datos de cuenta (si creas una)',
      };
      const exigeConta = {
        'pt': 'exige uma conta',
        'en': 'requires an account',
        'es': 'exige una cuenta',
      };
      for (final idioma in idiomas) {
        expect(
            politicas[idioma]!
                .contains(no(contaOpcional, idioma, 'conta opcional')),
            isFalse,
            reason: 'Não há caminho de convidado: o router manda quem não tem '
                'sessão para as telas de entrada. A política em $idioma '
                'voltou a sugerir que a conta é opcional.');
        expect(termos[idioma]!.contains(no(exigeConta, idioma, 'exige conta')),
            isTrue,
            reason: 'Os termos em $idioma pararam de dizer que o uso do '
                'aplicativo exige uma conta.');
      }
    });
  });

  group('o ARB x código: a nuvem não é do Premium', () {
    // As palavras que nomeiam o envio à nuvem em cada idioma. A lista é curta
    // de propósito: "aparelho" e "dispositivo" aparecem em dezenas de frases
    // que não falam de sincronização, e catraca que grita à toa é catraca que
    // alguém desliga.
    const palavrasDeNuvem = {
      'pt': ['sincroniz', 'nuvem', 'backup'],
      'en': ['sync', 'cloud', 'backup'],
      'es': ['sincroniz', 'nube', 'backup'],
    };

    // As mesmas frases cobradas da política, para a resposta que a tela dá à
    // mesma pergunta. Divergir aqui seria o app responder duas coisas.
    const qualquerPlano = {
      'pt': 'em qualquer plano',
      'en': 'on any plan',
      'es': 'en cualquier plan',
    };

    test('nenhuma chave põe Premium ao lado da sincronização', () {
      // A varredura é em TODAS as chaves, e não só em faqA2, porque a frase
      // não morreu: ela migra. Ela nasceu na política, foi consertada lá,
      // reapareceu na pergunta frequente — e o próximo lugar onde ela caberia
      // (um convite de venda, um texto de onboarding, a tela de assinatura)
      // ninguém adivinha de antemão. Hoje nenhuma chave dos quatro ARBs fala
      // de Premium e de nuvem na mesma frase, e é esse zero que se trava: a
      // chave que passar a falar dos dois precisa ser lida por gente antes de
      // chegar à tela.
      idiomaDoArb.forEach((arquivo, idioma) {
        final palavras = nos(palavrasDeNuvem, idioma, 'palavras de nuvem');
        textosDoArb[arquivo]!.forEach((chave, texto) {
          final minusculo = texto.toLowerCase();
          if (!minusculo.contains('premium')) return;
          for (final palavra in palavras) {
            expect(minusculo.contains(palavra), isFalse,
                reason: '$arquivo.arb: a chave "$chave" fala de Premium e de '
                    '"$palavra" na mesma frase. Quem governa o envio é '
                    'DataSyncService.cloudSyncPreferenceKey, sem consultar '
                    'plano nenhum: a nuvem vale em qualquer plano e já vem '
                    'ligada. Se o paywall voltou, reescreva a política ANTES '
                    'de religar o cadeado — e então mude esta catraca.');
          }
        });
      });
    });

    test('faqA2 diz que a nuvem vale em qualquer plano', () {
      // Âncora POSITIVA, como na política: proibir a frase antiga não impede
      // que a próxima reescrita simplesmente cale sobre o plano, e o silêncio
      // é o estado em que a mentira nasceu. faqA2 é a resposta oficial do app
      // a "onde meus dados ficam salvos?" — calar ali faz quem é do plano
      // gratuito acreditar que nada sai do aparelho enquanto já está subindo.
      idiomaDoArb.forEach((arquivo, idioma) {
        final resposta = textosDoArb[arquivo]!['faqA2'];
        expect(resposta, isNotNull,
            reason: '$arquivo.arb ficou sem a chave faqA2, que responde onde '
                'os dados dela ficam salvos.');
        expect(resposta!.contains(no(qualquerPlano, idioma, 'qualquer plano')),
            isTrue,
            reason: '$arquivo.arb: faqA2 parou de dizer que a sincronização '
                'vale em qualquer plano. Dizer isso é o conserto; omitir '
                'devolve a resposta ao silêncio de antes.');
      });
    });

    test('faqA3 não vende a sincronização como benefício pago', () {
      // A lista inteira do que o Premium dá se confere com a tela de
      // assinatura a olho; o que se trava aqui é a peça que JÁ divergiu — a
      // sincronização, que é de todos os planos e ficou nesta lista muito
      // depois de o paywall sair. Vendida aqui, ela desmente ao mesmo tempo a
      // política e a própria tela de venda.
      idiomaDoArb.forEach((arquivo, idioma) {
        final resposta = textosDoArb[arquivo]!['faqA3'];
        expect(resposta, isNotNull,
            reason: '$arquivo.arb ficou sem a chave faqA3, que lista o que o '
                'Premium dá.');
        final minusculo = resposta!.toLowerCase();
        for (final palavra
            in nos(palavrasDeNuvem, idioma, 'palavras de nuvem')) {
          expect(minusculo.contains(palavra), isFalse,
              reason: '$arquivo.arb: faqA3 voltou a listar "$palavra" entre o '
                  'que o Premium dá. A sincronização é de todos os planos — a '
                  'tela de assinatura vende cinco outras peças.');
        }
      });
    });
  });

  group('higiene dos documentos legais', () {
    const ultimaAtualizacao = {
      'pt': 'Última atualização:',
      'en': 'Last updated:',
      'es': 'Última actualización:',
    };

    test('os seis trazem data de vigência', () {
      for (final idioma in idiomas) {
        final data = no(ultimaAtualizacao, idioma, 'data de vigência');
        expect(politicas[idioma]!.contains(data), isTrue,
            reason: 'A política em $idioma ficou sem data de vigência.');
        expect(termos[idioma]!.contains(data), isTrue,
            reason: 'Os termos em $idioma ficaram sem data de vigência.');
      }
    });

    test('o contato de dados continua no texto', () {
      // O endereço não se traduz: é o mesmo canal em qualquer idioma, e é
      // por ele que um pedido de LGPD chega.
      for (final idioma in idiomas) {
        expect(politicas[idioma]!.contains('suporte.grimoriodebolso@gmail.com'),
            isTrue,
            reason: 'A política em $idioma ficou sem o contato de dados.');
        expect(termos[idioma]!.contains('suporte.grimoriodebolso@gmail.com'),
            isTrue,
            reason: 'Os termos em $idioma ficaram sem o contato de dados.');
      }
    });

    test('nenhuma tradução perdeu um parágrafo pelo caminho', () {
      // Tradução de documento legal não é resumo: o que sumir some para quem
      // lê naquele idioma, e some em silêncio. Contar é grosseiro de
      // propósito — pega o que revisão humana cansa de pegar.
      //
      // Contar só os títulos não bastava: uma seção pode chegar inteira ao
      // outro idioma com metade dos itens dentro. A seção do dado sensível
      // tem oito itens e as catracas de frase deste arquivo tocam em dois —
      // os outros seis (os dois sins, o que sobe, "Apagar um dia, e o que
      // fica", "Apagar tudo", o caminho da IA, "Sai inteiro quando você
      // quiser") sumiriam de um idioma sem derrubar nada. Por isso a
      // contagem desce ao parágrafo e ao item.
      List<String> linhasComTexto(String documento) => documento
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      List<String> comPrefixo(String documento, bool Function(String) cabe) =>
          linhasComTexto(documento).where(cabe).toList();

      final medidas = <String, bool Function(String)>{
        'seções': (l) => l.startsWith('## ') || l.startsWith('### '),
        'itens de lista': (l) => l.startsWith('- '),
      };

      for (final documento in {
        'da política de privacidade': politicas,
        'dos termos de uso': termos,
      }.entries) {
        final blocosPt = linhasComTexto(documento.value['pt']!).length;
        for (final idioma in idiomas) {
          expect(linhasComTexto(documento.value[idioma]!).length, blocosPt,
              reason: 'A tradução em $idioma ${documento.key} tem número de '
                  'parágrafos diferente do português. Traduzir é traduzir '
                  'tudo: o que faltar, falta para quem só lê naquele idioma.');
          medidas.forEach((oQue, cabe) {
            expect(comPrefixo(documento.value[idioma]!, cabe).length,
                comPrefixo(documento.value['pt']!, cabe).length,
                reason: 'A tradução em $idioma ${documento.key} tem número de '
                    '$oQue diferente do português.');
          });
        }
      }
    });
  });

  group('o documento acompanha o idioma ativo', () {
    // Restaura o locale padrão para não vazar estado entre arquivos de teste.
    tearDown(() {
      ContentLocale.instance.setLocale(const Locale('pt', 'BR'));
    });

    const politicaEsperada = {
      'pt': 'assets/legal/politica_de_privacidade.md',
      'en': 'assets/legal/politica_de_privacidade_en.md',
      'es': 'assets/legal/politica_de_privacidade_es.md',
    };
    const termosEsperados = {
      'pt': 'assets/legal/termos_de_uso.md',
      'en': 'assets/legal/termos_de_uso_en.md',
      'es': 'assets/legal/termos_de_uso_es.md',
    };

    test('cada idioma abre o seu arquivo, e o arquivo existe', () {
      // A tradução existir no repositório e a tela abri-la são duas coisas:
      // a política estava em três idiomas e a tela abria a portuguesa.
      for (final caso in {
        const Locale('pt', 'BR'): 'pt',
        const Locale('en'): 'en',
        const Locale('es'): 'es',
      }.entries) {
        ContentLocale.instance.setLocale(caso.key);
        final idioma = caso.value;

        expect(LegalDocumentPage.caminhoDaPolitica(),
            politicaEsperada[idioma],
            reason: 'Em $idioma a tela abriria a política errada.');
        expect(LegalDocumentPage.caminhoDosTermos(), termosEsperados[idioma],
            reason: 'Em $idioma a tela abriria os termos errados.');

        for (final caminho in [
          LegalDocumentPage.caminhoDaPolitica(),
          LegalDocumentPage.caminhoDosTermos(),
        ]) {
          expect(File(caminho).existsSync(), isTrue,
              reason: 'A tela aponta para $caminho, que não existe no '
                  'repositório.');
        }
      }
    });

    test('idioma sem tradução cai no português', () {
      // O português é a reserva: é dele que as traduções saem, e é ele que
      // vale enquanto um idioma novo não tiver a sua. Nenhuma tela legal
      // pode abrir vazia porque o app ganhou um idioma antes do tradutor.
      ContentLocale.instance.setLocale(const Locale('fr'));

      expect(LegalDocumentPage.caminhoDaPolitica(), politicaEsperada['pt']);
      expect(LegalDocumentPage.caminhoDosTermos(), termosEsperados['pt']);
    });

    test('a pasta dos documentos continua registrada no pubspec', () {
      // Escolher o arquivo certo não adianta se ele não for empacotado: a
      // pasta inteira é o registro, e trocá-la por uma lista arquivo a
      // arquivo é como as traduções ficariam de fora sem ninguém ver.
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec.contains('\n    - assets/legal/\n'), isTrue,
          reason: 'assets/legal/ deixou de ser registrada como pasta no '
              'pubspec. Se a lista virou arquivo a arquivo, acrescente as '
              'traduções — senão elas não entram no bundle.');
    });
  });
}
