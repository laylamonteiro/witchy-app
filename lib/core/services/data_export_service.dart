import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/database_helper.dart';
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

  /// Tabelas incluídas no backup. Ao criar uma tabela de conteúdo da usuária,
  /// acrescente aqui — senão ela fica de fora da exportação.
  static const List<String> tables = [
    'spells',
    'dreams',
    'desires',
    'gratitudes',
    'affirmations',
    'daily_rituals',
    'ritual_logs',
    'sigils',
    'birth_charts',
    'magical_profiles',
    'rune_readings',
    'pendulum_consultations',
    'oracle_readings',
    'tarot_readings',
    'daily_magical_weather',
    'learning_progress',
    'guided_ritual_logs',
    'user_encyclopedia_entries',
    'free_writings',
    'daily_checkins',
    // O relatório em si sai em free_writings; aqui vai o registro da compra
    // e do período coberto — exportar os dados dela é exportar tudo.
    'cycle_readings',
  ];

  /// Lê todas as tabelas e devolve o JSON do backup.
  ///
  /// Tabela ausente (versão antiga do banco, recurso ainda não usado) entra
  /// vazia em vez de interromper a exportação inteira.
  Future<String> buildJson({String appVersion = '1.0.0'}) async {
    final db = await DatabaseHelper.instance.database;
    final exportData = <String, dynamic>{};

    for (final table in tables) {
      try {
        exportData[table] = await db.query(table);
      } catch (_) {
        exportData[table] = [];
      }
    }

    exportData['export_date'] = DateTime.now().toIso8601String();
    exportData['app_version'] = appVersion;

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

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
  Future<void> exportAndDeliver({required String subject}) async {
    await deliver(await buildJson(), subject: subject);
  }
}
