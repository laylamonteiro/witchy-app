import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/services/data_export_service.dart';
import 'package:grimorio_de_bolso/core/services/data_sync_service.dart';

/// Uma tabela que o app grava e o sync não conhece some na reinstalação —
/// e a pessoa descobre isso quando já é tarde. Foi o que aconteceu com o
/// tarô: ganhou tabela local para alimentar a Leitura do Ciclo, mas ficou
/// fora do sync (e do restore da nuvem, que existe justamente para isso).
///
/// Estes testes travam a regra: toda entidade sincronizada precisa estar
/// inteira nos mapas, e a exportação de dados precisa cobrir o que a pessoa
/// registra.
void main() {
  test('toda SyncEntity tem tabela local e remota', () {
    final service = DataSyncService();
    for (final entity in SyncEntity.values) {
      final local = service.localTableForTest(entity);
      final remote = service.remoteTableForTest(entity);
      expect(local, isNotEmpty, reason: 'sem tabela local: $entity');
      expect(remote, isNotEmpty, reason: 'sem tabela remota: $entity');
    }
  });

  test('as tiragens de tarô sincronizam como as outras', () {
    final service = DataSyncService();
    expect(
      SyncEntity.values.contains(SyncEntity.tarotReadings),
      isTrue,
      reason: 'runas, pêndulo e oráculo sincronizam; o tarô também precisa',
    );
    expect(service.localTableForTest(SyncEntity.tarotReadings),
        'tarot_readings');
  });

  test('a exportação cobre o que a pessoa registra', () {
    // Fontes que a Leitura do Ciclo lê: se entram na análise, são dados
    // dela e precisam sair na exportação.
    for (final table in const [
      'dreams',
      'gratitudes',
      'desires',
      'sigils',
      'free_writings',
      'rune_readings',
      'pendulum_consultations',
      'oracle_readings',
      'tarot_readings',
      'cycle_readings',
    ]) {
      expect(
        DataExportService.tables.contains(table),
        isTrue,
        reason: 'fora da exportação: $table',
      );
    }
  });
}
