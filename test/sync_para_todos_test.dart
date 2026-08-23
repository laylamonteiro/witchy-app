import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/services/data_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sincronizar deixou de ser exclusivo do Premium.
///
/// O motivo é o iOS: no navegador, o armazenamento gravável por script é
/// apagado depois de 7 dias sem a pessoa abrir o site — e o banco do app é
/// sqlite no IndexedDB. Sem cópia na nuvem, uma semana ociosa apagava o
/// grimório inteiro, inclusive a Leitura do Ciclo, que é vendida justamente
/// a quem NÃO é Premium.
///
/// Abrir a torneira multiplica o alcance de dois defeitos que já existiam, e
/// é deles que estes testes tratam: a detecção de conflito, que dizia "mudou"
/// para toda linha das tabelas com blob JSON, e a adoção de dados anônimos no
/// login, que tinha perdido uma tabela.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('detecção de conflito nas tabelas de blob JSON', () {
    // O lado local é o texto que o SQLite guardou; o remoto veio de um jsonb
    // do Postgres, decodificado e reserializado. Mesmo conteúdo, ordem de
    // chave diferente.
    const doLocal = '{"signo":"Escorpião","casa":7,"aspectos":["trígono"]}';
    const doServidor = '{"casa":7,"aspectos":["trígono"],"signo":"Escorpião"}';

    Map<String, dynamic> linha(String chartData) => {
          'id': 'abc',
          'chart_data': chartData,
          'synced': 0,
          'updated_at': 1700000000000,
        };

    test('mesmo conteúdo em outra ordem NÃO é conflito', () {
      // Este é o teste que falha na versão anterior: a comparação de texto
      // dizia que mudou, todo upload virava "conflito", e o mostRecent
      // resolve empate de milissegundo a favor do servidor — edição local
      // perdida em silêncio.
      expect(
        DataSyncService.temMudancas(
          'birth_charts',
          linha(doLocal),
          linha(doServidor),
        ),
        isFalse,
      );
    });

    test('espaçamento diferente também não é conflito', () {
      expect(
        DataSyncService.temMudancas(
          'birth_charts',
          linha('{"casa":7}'),
          linha('{ "casa" : 7 }'),
        ),
        isFalse,
      );
    });

    test('aceita o lado remoto já decodificado', () {
      // Nem todo caminho passa pelo _toLocal antes de comparar.
      final remoto = linha('')
        ..['chart_data'] = <String, dynamic>{'casa': 7, 'signo': 'Escorpião'};
      expect(
        DataSyncService.temMudancas(
          'birth_charts',
          linha('{"signo":"Escorpião","casa":7}'),
          remoto,
        ),
        isFalse,
      );
    });

    test('conteúdo REALMENTE diferente continua sendo conflito', () {
      expect(
        DataSyncService.temMudancas(
          'birth_charts',
          linha('{"casa":7}'),
          linha('{"casa":8}'),
        ),
        isTrue,
        reason: 'perder a diferença de verdade seria pior que o defeito',
      );
    });

    test('ordem de lista é conteúdo, não formatação', () {
      // [a, b] não é [b, a]: uma tiragem de tarô em outra ordem é outra
      // tiragem.
      expect(
        DataSyncService.temMudancas(
          'tarot_readings',
          linha('')..['reading_data'] = '{"cartas":["A","B"]}',
          linha('')..['reading_data'] = '{"cartas":["B","A"]}',
        ),
        isTrue,
      );
    });

    test('texto que não é JSON é comparado como texto', () {
      expect(
        DataSyncService.temMudancas(
          'birth_charts',
          linha('nao e json'),
          linha('nao e json'),
        ),
        isFalse,
      );
      expect(
        DataSyncService.temMudancas(
          'birth_charts',
          linha('nao e json'),
          linha('outra coisa'),
        ),
        isTrue,
      );
    });

    test('campo comum de tabela sem blob segue na comparação direta', () {
      expect(
        DataSyncService.temMudancas(
          'dreams',
          {'id': '1', 'title': 'Cobra'},
          {'id': '1', 'title': 'Coruja'},
        ),
        isTrue,
      );
      expect(
        DataSyncService.temMudancas(
          'dreams',
          {'id': '1', 'title': 'Cobra'},
          {'id': '1', 'title': 'Cobra'},
        ),
        isFalse,
      );
    });

    test('updated_at e created_at continuam fora da comparação', () {
      expect(
        DataSyncService.temMudancas(
          'dreams',
          {'id': '1', 'title': 'Cobra', 'updated_at': 1, 'created_at': 1},
          {'id': '1', 'title': 'Cobra', 'updated_at': 2, 'created_at': 2},
        ),
        isFalse,
      );
    });
  });

  group('adoção do que foi criado antes do login', () {
    test('cobre toda entidade sincronizável, menos os feitiços', () {
      final tabelas = DatabaseHelper.tabelasDaAdocaoAnonima();

      for (final entity in SyncEntity.values) {
        final tabela = DataSyncService.localTableFor(entity);
        if (tabela == 'spells') continue;
        expect(
          tabelas,
          contains(tabela),
          reason: '$tabela ficaria presa em local_user depois do login',
        );
      }
    });

    test('inclui tarot_readings, que a lista escrita à mão perdia', () {
      // Uma tiragem feita antes do login sumia da tela ao entrar na conta e
      // nunca subia para a nuvem.
      expect(DatabaseHelper.tabelasDaAdocaoAnonima(),
          contains('tarot_readings'));
    });

    test('não adota os feitiços pré-carregados do app', () {
      // `spells` é tratada à parte, com AND is_preloaded = 0: o acervo que
      // vem com o app não é de ninguém.
      expect(DatabaseHelper.tabelasDaAdocaoAnonima(), isNot(contains('spells')));
    });

    test('mantém os registros de ritual guiado, que não sincronizam', () {
      expect(DatabaseHelper.tabelasDaAdocaoAnonima(),
          contains('guided_ritual_logs'));
    });
  });

  group('preferência de sincronização sem paywall', () {
    Future<SharedPreferences> comValores(Map<String, Object> valores) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      for (final e in valores.entries) {
        if (e.value is bool) await prefs.setBool(e.key, e.value as bool);
      }
      return prefs;
    }

    test('quem nunca escolheu nada nasce sincronizando', () async {
      final prefs = await comValores({});
      expect(DataSyncService.resolveCloudSyncPreference(prefs), isTrue);
    });

    test('o desligado que o paywall gravava não vale como escolha', () async {
      // Versões anteriores persistiam false automaticamente para quem era
      // Free. Isso era o paywall, não a vontade da pessoa — e não pode virar
      // "ela escolheu não sincronizar" agora que o recurso é de todo mundo.
      final prefs = await comValores({
        DataSyncService.cloudSyncPreferenceKey: false,
      });
      expect(DataSyncService.resolveCloudSyncPreference(prefs), isTrue);
    });

    test('o desligado que a pessoa escolheu é respeitado', () async {
      final prefs = await comValores({
        DataSyncService.cloudSyncPreferenceKey: false,
        DataSyncService.cloudSyncUserConfiguredKey: true,
      });
      expect(DataSyncService.resolveCloudSyncPreference(prefs), isFalse);
    });

    test('ligado continua ligado', () async {
      final prefs = await comValores({
        DataSyncService.cloudSyncPreferenceKey: true,
        DataSyncService.cloudSyncUserConfiguredKey: true,
      });
      expect(DataSyncService.resolveCloudSyncPreference(prefs), isTrue);
    });
  });

  group('o que o servidor devolve volta igual ao que subiu', () {
    test('um blob JSON sobrevive à ida e à volta', () {
      // Guarda a premissa da comparação acima: o campo é texto no SQLite e
      // estrutura no Postgres, e o par _toRemote/_toLocal é quem traduz.
      final service = DataSyncService();
      const original = '{"casa":7,"signo":"Escorpião"}';

      final remoto = service.toRemoteForTest(
        'birth_charts',
        {'id': 'abc', 'chart_data': original, 'synced': 0},
        '00000000-0000-4000-8000-000000000001',
      );
      expect(remoto['chart_data'], isA<Map<String, dynamic>>());

      final volta = service.toLocalForTest('birth_charts', remoto);
      expect(volta['chart_data'], isA<String>());
      expect(
        jsonDecode(volta['chart_data'] as String),
        jsonDecode(original),
      );
    });
  });
}
