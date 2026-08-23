import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/core/services/data_sync_service.dart';
import 'package:grimorio_de_bolso/features/auth/data/repositories/supabase_auth_repository.dart';

/// A exclusão de conta mantinha a própria lista de tabelas, escrita à mão.
/// Ela cobria 15 enquanto o app sincronizava 20 — e o que sobrava no servidor
/// depois de a pessoa pedir para sumir era justamente o mais íntimo: a escrita
/// livre, as leituras de ciclo, as tiragens de tarô, os check-ins, o progresso
/// da trilha e as anotações da enciclopédia.
///
/// Este teste trava a regra que substituiu a lista: a varredura é derivada de
/// [SyncEntity], então uma entidade nova nasce coberta. Ele falha na versão
/// anterior do código e passa na atual.
///
/// Não há dublê do método que apaga: o risco não mora na chamada ao Supabase,
/// mora em QUAIS tabelas entram na lista — e é essa lista que está sob teste.
void main() {
  group('varredura da exclusão de conta', () {
    test('cobre toda entidade sincronizável, sem exceção', () {
      final tabelas = SupabaseAuthRepository.tabelasDaExclusaoDeConta();

      for (final entity in SyncEntity.values) {
        final tabela = DataSyncService.supabaseTableFor(entity);
        expect(
          tabelas,
          contains(tabela),
          reason: '$entity sincroniza para $tabela e sobreviveria à exclusão',
        );
      }
    });

    test('inclui as seis que a lista escrita à mão esquecia', () {
      final tabelas = SupabaseAuthRepository.tabelasDaExclusaoDeConta();

      // Nomeadas uma a uma de propósito: se alguém voltar a escrever a lista
      // à mão, o teste diz exatamente o que ficou para trás da última vez.
      for (final tabela in const [
        'free_writings',
        'cycle_readings',
        'tarot_readings',
        'daily_checkins',
        'learning_progress',
        'user_encyclopedia_entries',
      ]) {
        expect(tabelas, contains(tabela),
            reason: '$tabela ficaria no servidor');
      }
    });

    test('inclui as lápides do sync', () {
      // `sync_tombstones` não é entidade, mas registra QUAIS ids existiram
      // e quando foram apagados — rastro da pessoa, some junto com ela.
      expect(SupabaseAuthRepository.tabelasDaExclusaoDeConta(),
          contains('sync_tombstones'));
    });

    test('apaga o perfil, e por último', () {
      final tabelas = SupabaseAuthRepository.tabelasDaExclusaoDeConta();

      // `profiles` guarda e-mail e data de nascimento. Ela não é entidade de
      // sync, então precisa entrar explicitamente — e no fim, porque enquanto
      // a linha existe um erro no meio da varredura ainda é recuperável.
      expect(tabelas, contains('profiles'));
      expect(tabelas.last, 'profiles');
    });

    test('não repete tabela nem inventa nome', () {
      final tabelas = SupabaseAuthRepository.tabelasDaExclusaoDeConta();

      expect(tabelas.toSet().length, tabelas.length,
          reason: 'tabela repetida vira DELETE duplicado');
      expect(tabelas.length, SyncEntity.values.length + 2,
          reason: 'as 20 entidades, as lápides do sync e profiles');
      expect(tabelas.every((t) => t.isNotEmpty), isTrue);
    });
  });
}
