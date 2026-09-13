import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/core/database/tabelas_locais.dart';
import 'package:grimorio_de_bolso/core/services/data_export_service.dart';
import 'package:grimorio_de_bolso/core/services/data_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// A catraca das listas de tabelas.
///
/// Havia QUATRO cópias escritas à mão da mesma lista — a exportação, a limpeza
/// do Editar Perfil, a limpeza da Privacidade e o `clearAllTables` — e as
/// quatro divergiram. Duas telas com o mesmo rótulo e o mesmo texto de
/// confirmação apagavam conjuntos diferentes, e nenhuma apagava tudo.
///
/// Estes testes NÃO conferem uma lista contra outra lista escrita à mão: eles
/// partem das tabelas que o banco realmente cria (`sqlite_master`) e do
/// esquema de cada uma (`PRAGMA table_info`). Uma tabela nova que ninguém
/// nomear cai aqui, e o teste diz o nome dela.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const conta = 'cccccccc-dddd-eeee-ffff-000000000000';

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // Diretório próprio: os arquivos de teste rodam em paralelo e disputariam
    // o mesmo grimorio_de_bolso.db no caminho padrão.
    final dir = await Directory.systemTemp.createTemp('grimorio_tabelas');
    await databaseFactory.setDatabasesPath(dir.path);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // Banco vazio a cada teste: dois deles semeiam a mesma linha, e chave
    // repetida derrubaria o insert em vez de dizer algo sobre as listas.
    await DatabaseHelper.instance.clearAllTables();
  });

  /// As tabelas que o banco criou de verdade, sem as internas do SQLite.
  Future<Set<String>> tabelasDoSchema() async {
    final db = await DatabaseHelper.instance.database;
    final linhas = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' "
      "AND name NOT LIKE 'sqlite_%' AND name <> 'android_metadata'",
    );
    return {for (final linha in linhas) linha['name']! as String};
  }

  Set<String> tabelasSincronizadas() => {
        for (final entity in SyncEntity.values)
          DataSyncService.localTableFor(entity),
      };

  /// Uma linha em [tabela], montada a partir do PRÓPRIO esquema dela.
  ///
  /// Escrever 29 linhas à mão aqui seria criar a trigésima lista que pode
  /// divergir do banco — e é exatamente o defeito que estes testes travam. O
  /// PRAGMA diz quais colunas são obrigatórias; o valor não importa, só a
  /// existência da linha.
  Future<void> semear(
    String tabela, {
    String texto = 'x',
    String? dono,
    Map<String, Object?> extras = const {},
  }) async {
    final db = await DatabaseHelper.instance.database;
    final colunas = await db.rawQuery('PRAGMA table_info($tabela)');
    final linha = <String, Object?>{};
    for (final coluna in colunas) {
      final nome = coluna['name']! as String;
      final tipo = (coluna['type']! as String).toUpperCase();
      final chave = (coluna['pk']! as int) > 0;
      final obrigatoria = (coluna['notnull']! as int) == 1;
      if (nome == 'user_id') {
        linha[nome] = dono ?? conta;
        continue;
      }
      // Coluna opcional, ou com valor padrão, fica de fora: o padrão do
      // esquema é melhor que um palpite nosso (é ele que põe 'free' na
      // `source` de `free_writings`).
      if (!chave && (!obrigatoria || coluna['dflt_value'] != null)) continue;
      // Os CHECK que existem hoje pedem >= 0 e > 0; 1 serve aos dois.
      linha[nome] = tipo.contains('INT') || tipo.contains('REAL') ? 1 : texto;
    }
    // Por último, para vencer o palpite acima: é com [extras] que o teste
    // escolhe de que lado de uma ressalva a linha nasce.
    linha.addAll(extras);
    await db.insert(tabela, linha);
  }

  Future<int> quantasLinhas(String tabela) async {
    final db = await DatabaseHelper.instance.database;
    final linhas = await db.rawQuery('SELECT COUNT(*) AS n FROM $tabela');
    return linhas.first['n']! as int;
  }

  test('a lista canônica cobre todas as tabelas que o banco cria', () async {
    final doSchema = await tabelasDoSchema();

    expect(
      doSchema.difference(TabelasLocais.foraDoConteudo),
      TabelasLocais.conteudo.toSet(),
      reason: 'tabela do banco que ninguém nomeou: ela fica de fora da '
          'exportação, da limpeza local e da exclusão de conta ao mesmo tempo. '
          'Ou ela é conteúdo dela (entra no SyncEntity ou em '
          'TabelasLocais.soNesteAparelho), ou não é (entra em '
          'TabelasLocais.foraDoConteudo, com o porquê escrito).',
    );
    // A comparação acima é de conjuntos, e um nome repetido passaria por ela:
    // a limpeza apagaria a mesma tabela duas vezes e ninguém veria.
    expect(
      TabelasLocais.conteudo.length,
      TabelasLocais.conteudo.toSet().length,
      reason: 'tabela nomeada duas vezes na lista canônica — provável '
          'sobreposição entre o SyncEntity e uma das listas de aparelho',
    );
  });

  test('toda tabela de conteúdo ou sobe, ou está declarada como de aparelho',
      () async {
    // A catraca que faltava: o test/sync_coverage_test.dart parte do enum e
    // confere que toda entidade tem par de tabelas — nunca que toda tabela de
    // conteúdo tem entidade. Foi por essa fresta que `guided_ritual_logs` e as
    // coleções passaram: gravam conteúdo dela, têm coluna `synced`, e somem na
    // reinstalação inclusive para quem tem a nuvem ligada.
    final sincronizadas = tabelasSincronizadas();
    for (final tabela in TabelasLocais.conteudo) {
      expect(
        sincronizadas.contains(tabela) ||
            TabelasLocais.soNesteAparelho.contains(tabela) ||
            TabelasLocais.contadoresDeCota.contains(tabela),
        isTrue,
        reason: '$tabela guarda conteúdo dela e não está no SyncEntity: ou '
            'ganha entidade e tabela remota, ou entra em '
            'TabelasLocais.soNesteAparelho com a frase do que se perde na '
            'reinstalação. (A terceira saída, TabelasLocais.contadoresDeCota, '
            'é só para o que não é registro de nada — o contador de cota do '
            'dia.) Some sem aviso não é opção.',
      );
    }
  });

  test('a declaração "fica no aparelho" não mente sobre quem sobe', () {
    expect(
      TabelasLocais.soNesteAparelho.intersection(tabelasSincronizadas()),
      isEmpty,
      reason: 'tabela declarada como de aparelho que na verdade sincroniza — a '
          'declaração seria uma promessa falsa sobre onde o dado está',
    );
    // A lista que a dona lê para decidir o que vale uma tabela nova no
    // servidor precisa ter só perdas de verdade: contador de cota do dia ali
    // dentro engrossaria a conta com duas linhas que ninguém sente falta.
    expect(
      TabelasLocais.soNesteAparelho.intersection(
        TabelasLocais.contadoresDeCota,
      ),
      isEmpty,
      reason: 'contador de cota declarado como perda na reinstalação',
    );
  });

  test('a exportação leva as mesmas tabelas que a limpeza apaga', () async {
    // Se a exportação e os gestos de apagar olhassem listas diferentes, um
    // esconderia o esquecimento do outro: o backup traria o que a limpeza não
    // alcança, ou a limpeza apagaria o que o backup não leva.
    //
    // A conferência é feita sobre o ARQUIVO que ela recebe, e não sobre
    // `DataExportService.tables`: aquele campo HOJE é a própria lista
    // canônica, então compará-lo com ela seria comparar um objeto consigo
    // mesmo — um teste que não pode falhar, nem quando alguém reintroduzir
    // uma lista à mão ao lado dele. O que não pode divergir é o resultado.
    final backup = jsonDecode(await DataExportService.instance.buildJson())
        as Map<String, dynamic>;
    final noArquivo = backup.keys.toSet()
      ..remove('export_date')
      ..remove('app_version');

    expect(
      noArquivo,
      (await tabelasDoSchema()).difference(TabelasLocais.foraDoConteudo),
      reason: 'o arquivo de "levar meus dados embora" não traz as mesmas '
          'tabelas que os gestos de apagar alcançam',
    );
  });

  // Uma linha que TEM de sair, em cada tabela onde existe ressalva. Sem isto
  // a semeadura cairia no padrão do esquema — que em `cycle_readings` é
  // justamente `status = 'pending'`, o lado que FICA — e o teste passaria a
  // conferir a ressalva em vez do apagar.
  const doLadoQueSai = <String, Map<String, Object?>>{
    'spells': {'is_preloaded': 0},
    'affirmations': {'is_preloaded': 0},
    'cycle_readings': {'status': 'generated'},
    'menstrual_days': {'deleted': 0},
  };

  /// Uma linha de cada lado, em cada tabela: a que qualquer apagar tem de
  /// levar e, onde existe ressalva, a que só a limpeza local poupa.
  Future<void> semearOsDoisLados() async {
    for (final tabela in TabelasLocais.conteudo) {
      await semear(tabela, extras: doLadoQueSai[tabela] ?? const {});
    }
    // Cada sobrevivente com chave própria, para conviver com a linha de cima
    // na mesma tabela.
    await semear('spells', texto: 'ancestral', extras: {'is_preloaded': 1});
    await semear('affirmations', texto: 'do-dia', extras: {'is_preloaded': 1});
    await semear('cycle_readings',
        extras: {'id': 'credito-pago', 'status': 'pending'});
    await semear('menstrual_days',
        extras: {'day_key': 'dia-apagado', 'deleted': 1});
    await semear(TabelasLocais.lapides);
  }

  test('limpar os dados deste aparelho não deixa tabela para trás', () async {
    await semearOsDoisLados();

    // A catraca das ressalvas: ressalva nova no código sem linha semeada aqui
    // é ressalva que ninguém confere.
    expect(
      TabelasLocais.limpezaParcial.keys.toSet(),
      doLadoQueSai.keys.toSet(),
      reason: 'ressalva da limpeza local sem caso neste teste — escreva as '
          'duas linhas (a que sai e a que fica) antes de confiar nela',
    );

    await DatabaseHelper.instance.limparConteudoDesteAparelho();

    for (final tabela in TabelasLocais.conteudo) {
      final temRessalva = TabelasLocais.limpezaParcial.containsKey(tabela);
      expect(
        await quantasLinhas(tabela),
        temRessalva ? 1 : 0,
        reason: temRessalva
            ? '$tabela: a linha que a ressalva poupa tinha de ficar — o '
                'conteúdo que vem com o app, o crédito de leitura já pago e '
                'ainda não usado, a lápide do dia que ela apagou'
            : '$tabela sobreviveu a "limpar todos os dados deste aparelho" — '
                'é isso que as duas telas faziam, cada uma com uma tabela '
                'diferente, depois de mostrar a mensagem de sucesso',
      );
    }
    expect(
      await quantasLinhas(TabelasLocais.lapides),
      1,
      reason: 'as lápides ficam: apagá-las traria de volta, no download '
          'seguinte, exatamente o que ela mandou sumir',
    );
  });

  test('a exclusão de conta não tem ressalva nenhuma', () async {
    // As mesmas linhas de antes, inclusive as que a limpeza local poupa:
    // aqui nenhuma fica.
    await semearOsDoisLados();

    await DatabaseHelper.instance.clearAllTables();

    for (final tabela in [...TabelasLocais.conteudo, TabelasLocais.lapides]) {
      expect(
        await quantasLinhas(tabela),
        0,
        reason: '$tabela sobreviveu ao gesto mais forte do app. Aqui a base '
            'local inteira deixa de valer, e o id anônimo é sempre '
            "'local_user': o que sobra, a próxima pessoa a abrir o app neste "
            'aparelho vê.',
      );
    }
  });

  test('a adoção do primeiro login atravessa o banco cheio', () async {
    // A adoção varre a lista canônica DENTRO DE UMA TRANSAÇÃO e carimba
    // `synced` em cada tabela que toca. Uma tabela sem essa coluna não dá erro
    // só nela: derruba a transação inteira do primeiro login e leva junto tudo
    // o que já tinha sido adotado. Os contadores de cota são exatamente esse
    // caso, e é por isso que saem da lista da adoção (e só dela).
    for (final tabela in TabelasLocais.conteudo) {
      await semear(tabela, dono: 'local_user');
    }

    await DatabaseHelper.instance.claimLegacyData(conta);

    final db = await DatabaseHelper.instance.database;
    for (final tabela in DatabaseHelper.tabelasDaAdocaoAnonima()) {
      final adotadas = await db.query(
        tabela,
        where: 'user_id = ?',
        whereArgs: [conta],
      );
      expect(
        adotadas,
        hasLength(1),
        reason: '$tabela ficaria presa em local_user depois do login — e se a '
            'transação tiver caído, nenhuma tabela chegou',
      );
    }
    // Os contadores de cota ficam onde estavam, e de propósito: a conta nova
    // não herda a cota do dia já gasta.
    for (final tabela in TabelasLocais.contadoresDeCota) {
      expect(
        await db.query(tabela, where: 'user_id = ?', whereArgs: [conta]),
        isEmpty,
        reason: '$tabela foi adotada: ou a coluna `synced` apareceu nela, ou '
            'alguém a devolveu para a lista da adoção',
      );
    }
  });

  test('toda entidade de sync tem tabela criada em algum .sql do servidor',
      () async {
    // O cabeçalho do restore_database.sql anunciava 16 tabelas e o app
    // sincroniza 21: um projeto restaurado à risca fazia `syncAll` devolver
    // erro em três entidades a cada varredura, e sem `sync_tombstones` as
    // exclusões ressuscitavam. Entidade nova sem SQL de servidor cai aqui.
    final criadas = <String>{};
    final padrao = RegExp(
      r'CREATE TABLE (?:IF NOT EXISTS )?(?:public\.)?([a-z_]+)',
      caseSensitive: false,
    );
    for (final arquivo in Directory('supabase').listSync()) {
      if (arquivo is! File) continue;
      if (!arquivo.path.endsWith('.sql')) continue;
      for (final achado in padrao.allMatches(arquivo.readAsStringSync())) {
        criadas.add(achado.group(1)!);
      }
    }

    for (final entity in SyncEntity.values) {
      expect(
        criadas,
        contains(DataSyncService.supabaseTableFor(entity)),
        reason: 'nenhum .sql de supabase/ cria a tabela de $entity — quem '
            'restaurar o projeto fica com essa entidade em erro a cada '
            'varredura, e o dado se perde na reinstalação',
      );
    }
  });
}
