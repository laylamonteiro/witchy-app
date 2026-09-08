import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// `claimLegacyData` roda a CADA login e reescreve a chave primária de
// `magical_profiles` (o id passa a ser o do mapa). Essa reescrita não tolerava
// conflito, e ela é feita dentro de UMA transação: dois perfis que colidissem
// derrubavam a adoção inteira — inclusive o que já tinha sido adotado antes
// deles. Na web, uma transação que aborta ainda leva junto o erro de
// IndexedDB, que é como isso aparecia no log logo depois de entrar na conta.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const conta = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // Diretório próprio: os arquivos de teste rodam em paralelo e disputariam
    // o mesmo grimorio_de_bolso.db.
    final dir = await Directory.systemTemp.createTemp('grimorio_adocao');
    await databaseFactory.setDatabasesPath(dir.path);
  });

  setUp(() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('magical_profiles');
    await db.delete('birth_charts');
    await db.delete('dreams');
  });

  Future<void> perfil({
    required String id,
    required String mapa,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final agora = DateTime.now().millisecondsSinceEpoch;
    await db.insert('magical_profiles', {
      'id': id,
      'user_id': conta,
      'birth_chart_id': mapa,
      'profile_data': jsonEncode({'userId': 'local_user'}),
      'generated_at': agora,
      'updated_at': agora,
      'synced': 0,
    });
  }

  test('perfis que colidem na chave não derrubam a adoção do resto', () async {
    final db = await DatabaseHelper.instance.database;
    final agora = DateTime.now().millisecondsSinceEpoch;

    // O sonho anônimo é o que a adoção precisa trazer para a conta.
    await db.insert('dreams', {
      'id': 'sonho-1',
      'user_id': 'local_user',
      'title': 'Corvo',
      'content': 'Um corvo pousou na janela',
      'date': agora,
      'created_at': agora,
      'updated_at': agora,
      'synced': 0,
    });

    // A colisão: o primeiro perfil quer virar 'mapa-1', que já é o id do
    // segundo.
    await perfil(id: 'perfil-1', mapa: 'mapa-1');
    await perfil(id: 'mapa-1', mapa: 'mapa-2');

    await DatabaseHelper.instance.claimLegacyData(conta);

    final sonho = await db.query('dreams', where: 'id = ?', whereArgs: ['sonho-1']);
    expect(sonho.single['user_id'], conta,
        reason: 'a adoção não pode ser desfeita por um perfil que colide');

    // Nada se perde: a linha que colidiu continua lá, com o id antigo.
    final perfis = await db.query('magical_profiles');
    expect(perfis.map((p) => p['id']).toSet(), {'perfil-1', 'mapa-1'});
  });

  test('sem colisão, o id do perfil vira o do mapa', () async {
    final db = await DatabaseHelper.instance.database;
    await perfil(id: 'perfil-9', mapa: 'mapa-9');

    await DatabaseHelper.instance.claimLegacyData(conta);

    final perfis = await db.query('magical_profiles');
    expect(perfis.single['id'], 'mapa-9');
    // E o dono dentro do JSON acompanha.
    final dados = jsonDecode(perfis.single['profile_data'] as String) as Map;
    expect(dados['userId'], conta);
  });

  test('conta anônima não dispara adoção nenhuma', () async {
    final db = await DatabaseHelper.instance.database;
    await perfil(id: 'perfil-x', mapa: 'mapa-x');

    await DatabaseHelper.instance.claimLegacyData('local_user');

    final perfis = await db.query('magical_profiles');
    expect(perfis.single['id'], 'perfil-x');
  });
}
