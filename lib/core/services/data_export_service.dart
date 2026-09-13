import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/diary/data/models/free_writing_model.dart';
import '../database/database_helper.dart';
import '../database/tabelas_locais.dart';
import '../sharing/image_download_stub.dart'
    if (dart.library.js_interop) '../sharing/image_download_web.dart';

/// Exportação dos dados locais da usuária (direito de portabilidade, LGPD).
///
/// Existia DUPLICADA em duas telas (Privacidade e Editar Perfil), e as listas
/// de tabelas tinham divergido: a cópia do Editar Perfil não exportava
/// `free_writings`, então quem baixasse o backup por lá perdia a Escrita Livre
/// sem aviso. Com uma fonte única, incluir uma tabela nova passa a valer para
/// os dois lugares.
class DataExportService {
  DataExportService._();

  static final DataExportService instance = DataExportService._();

  /// Tabelas incluídas no backup: a lista canônica de [TabelasLocais.conteudo],
  /// a mesma que a limpeza local e a exclusão de conta consomem.
  ///
  /// Era escrita à mão aqui, e por isso podia divergir das outras três cópias —
  /// divergiu. Derivando da lista única, tabela nova nasce exportada, e o que a
  /// pessoa leva embora é exatamente o que os gestos de apagar alcançam: se um
  /// deles esquecesse algo, o outro esconderia o esquecimento.
  ///
  /// Fora ficam só as duas tabelas que não são registro dela: o catálogo de
  /// Códigos Premium e as lápides da sincronização (que guardam o id do que ela
  /// apagou, e não há o que levar embora num id de coisa apagada).
  static final List<String> tables = TabelasLocais.conteudo;

  /// Lê as tabelas da conta [userId] e devolve o JSON do backup.
  ///
  /// Tabela ausente (versão antiga do banco, recurso ainda não usado) entra
  /// vazia em vez de interromper a exportação inteira.
  ///
  /// O FILTRO POR CONTA não é detalhe: o banco local sobrevive à troca de
  /// conta — o `signOut` de quem tem e-mail preserva a base (auth_provider)
  /// e a adoção de dados anônimos só alcança linhas de `local_user`
  /// (`DatabaseHelper.claimLegacyData`) —, então num aparelho que já teve
  /// duas contas as linhas da primeira continuam ali. A leitura sem `where`
  /// entregava essas linhas a QUEM EXPORTA: diários, sonhos, tiragens e a
  /// tabela `menstrual_days` inteira, com sintomas e datas. O gesto que
  /// existe para cada uma levar o que é seu entregava o que era de outra.
  ///
  /// Sai junto o conteúdo que o app semeia (`is_preloaded = 1`): ele nasce
  /// sob `local_user` e não é registro dela — é o que vem com o app, e
  /// volta sozinho na abertura seguinte.
  Future<String> buildJson({
    required String userId,
    String appVersion = '1.0.0',
  }) async {
    final db = await DatabaseHelper.instance.database;
    final exportData = <String, dynamic>{};

    for (final table in tables) {
      try {
        // Toda tabela de conteúdo ganhou `user_id` na versão 7 do banco. A
        // pergunta é feita mesmo assim porque errar tem dois lados bem
        // diferentes: filtrar uma tabela SEM a coluna faria a consulta
        // estourar, o `catch` abaixo devolveria lista vazia e a tabela
        // sumiria do backup em silêncio. Sem a coluna também não há duas
        // contas para confundir — ali o certo continua sendo levar tudo.
        final colunas = await db.rawQuery('PRAGMA table_info($table)');
        final separaPorConta = colunas.any((c) => c['name'] == 'user_id');

        final rows = await db.query(
          table,
          where: separaPorConta ? 'user_id = ?' : null,
          whereArgs: separaPorConta ? [userId] : null,
        );
        exportData[table] = table == 'free_writings'
            ? rows.where(_naoEhEspelho).toList()
            : rows;
      } catch (_) {
        exportData[table] = [];
      }
    }

    exportData['export_date'] = DateTime.now().toIso8601String();
    exportData['app_version'] = appVersion;

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// As páginas-espelho ficam FORA do backup.
  ///
  /// O dia do ciclo vira uma página no Grimório, e o arquivo de "levar meus
  /// dados embora" já leva a tabela `menstrual_days` inteira — com sintomas,
  /// intensidade, revisão e lápides, que a prosa da página nem tem. Exportar
  /// as duas coisas escreveria o mesmo dia duas vezes no mesmo arquivo, e a
  /// segunda vez seria a pior: o relato do corpo em texto corrido, mais uma
  /// cópia para ela guardar sem ter pedido. A página é derivável da linha;
  /// a linha não é derivável da página.
  static bool _naoEhEspelho(Map<String, Object?> row) =>
      !FreeWritingSource.neverLeavesDevice.contains(row['source']);

  /// Nome de arquivo com carimbo de tempo, para backups não se sobrescreverem.
  String fileName() =>
      'grimorio_backup_${DateTime.now().millisecondsSinceEpoch}.json';

  /// Entrega o backup: download no navegador (não há pasta do app ali) e
  /// compartilhamento no celular.
  Future<void> deliver(String jsonString, {required String subject}) async {
    final nome = fileName();

    if (kIsWeb) {
      await downloadBytes(
        Uint8List.fromList(utf8.encode(jsonString)),
        nome,
        mimeType: 'application/json',
      );
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$nome');
    await file.writeAsString(jsonString);

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: subject),
    );
  }

  /// Monta e entrega em um passo — o que as telas precisam.
  Future<void> exportAndDeliver({
    required String userId,
    required String subject,
  }) async {
    await deliver(await buildJson(userId: userId), subject: subject);
  }
}
