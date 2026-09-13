// Editar uma afirmação própria NUNCA gravava.
//
// `_saveAffirmation` montava o modelo com o id existente e, logo abaixo,
// TODO o caminho de persistência estava dentro de
// `if (widget.affirmation == null) { ... }`. Havendo afirmação, a função
// caía direto no `Navigator.pop`. E o `AffirmationProvider` sequer tinha um
// `updateAffirmation` para o formulário chamar.
//
// O que a pessoa via: abria a afirmação na lista (ou na página do Grimório
// Vivo, que abre o formulário já em modo edição), reescrevia o texto,
// trocava a categoria, tocava no botão que diz "Atualizar" — e a tela
// fechava sem erro nenhum. A alteração se perdia, sem aviso e sem como
// perceber antes de reabrir.
//
// O segundo teste guarda a armadilha do conserto: o modelo TEM de sair de
// `copyWith`. Remontá-lo pelo construtor cheio devolveria
// `isFavorite: false` e `createdAt: DateTime.now()` — a edição
// desfavoritaria a afirmação e a jogaria para o topo da lista, que ordena
// por `created_at DESC`. Seria trocar um defeito por dois.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/database/database_helper.dart';
import 'package:grimorio_de_bolso/features/diary/data/models/affirmation_model.dart';
import 'package:grimorio_de_bolso/features/diary/data/repositories/affirmation_repository.dart';
import 'package:grimorio_de_bolso/features/diary/presentation/providers/affirmation_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'support/short_test_timeout.dart';

void main() {
  useShortTestTimeout();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  const conta = 'afirmacao-editada-user';
  final repositorio = AffirmationRepository();

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('afirmacao_editada');
    await databaseFactory.setDatabasesPath(dir.path);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = await DatabaseHelper.instance.database;
    await db.delete('affirmations');
  });

  /// Provider já apontado para a conta do teste, com a lista carregada.
  Future<AffirmationProvider> providerDaConta() async {
    final provider = AffirmationProvider();
    await provider.setUserId(conta);
    return provider;
  }

  Future<AffirmationModel> linhaCrua(String id) async {
    final db = await DatabaseHelper.instance.database;
    final linhas =
        await db.query('affirmations', where: 'id = ?', whereArgs: [id]);
    return AffirmationModel.fromMap(linhas.single);
  }

  test('a edição chega ao banco — texto e categoria', () async {
    final provider = await providerDaConta();
    final original = AffirmationModel(
      userId: conta,
      text: 'Eu mereço o que estou construindo',
      category: AffirmationCategory.abundance,
    );
    expect(await provider.addAffirmation(original), isTrue);

    final editada = original.copyWith(
      text: 'Eu mereço o que já construí',
      category: AffirmationCategory.wisdom,
    );
    expect(await provider.updateAffirmation(editada), isTrue);

    final noBanco = await linhaCrua(original.id);
    expect(noBanco.text, 'Eu mereço o que já construí',
        reason: 'o texto reescrito não chegou ao banco');
    expect(noBanco.category, AffirmationCategory.wisdom,
        reason: 'a categoria trocada não chegou ao banco');
  });

  test('editar não cria uma segunda afirmação', () async {
    final provider = await providerDaConta();
    final original = AffirmationModel(
      userId: conta,
      text: 'Primeira versão',
      category: AffirmationCategory.healing,
    );
    await provider.addAffirmation(original);
    await provider.updateAffirmation(original.copyWith(text: 'Segunda versão'));

    final db = await DatabaseHelper.instance.database;
    final todas = await db.query('affirmations',
        where: 'user_id = ?', whereArgs: [conta]);
    expect(todas, hasLength(1),
        reason: 'a edição virou uma linha nova em vez de reescrever a dela');
  });

  test('editar não desfavorita nem joga a afirmação para o topo da lista',
      () async {
    final provider = await providerDaConta();
    // Nasce favoritada e com data própria: é o que a remontagem pelo
    // construtor destruiria.
    final nascimento = DateTime(2026, 3, 9, 7, 30);
    final original = AffirmationModel(
      userId: conta,
      text: 'Guardo o que é meu',
      category: AffirmationCategory.protection,
      isFavorite: true,
      createdAt: nascimento,
    );
    await repositorio.insert(original);

    await provider.updateAffirmation(
      original.copyWith(text: 'Guardo o que sempre foi meu'),
    );

    final noBanco = await linhaCrua(original.id);
    expect(noBanco.isFavorite, isTrue,
        reason: 'a edição desfavoritou uma afirmação que ela tinha guardado');
    expect(noBanco.createdAt, nascimento,
        reason: 'a edição trocou a data de nascimento e a lista, que ordena '
            'por created_at, mudaria de ordem sozinha');
    expect(noBanco.text, 'Guardo o que sempre foi meu');
  });
}
