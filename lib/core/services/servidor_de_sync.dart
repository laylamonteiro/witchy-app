import 'package:supabase_flutter/supabase_flutter.dart';

/// A borda de rede da sincronização.
///
/// O [DataSyncService] decide o que sobe, o que desce e o que se apaga; esta
/// porta só executa a chamada. A separação existe porque o risco dos defeitos
/// de sincronização mora na decisão, não no fio — e a decisão precisa rodar
/// em teste contra um banco sqlite de verdade, com um servidor de mentira do
/// outro lado. É o mesmo racional do gateway de sync do SpellRepository.
abstract class ServidorDeSync {
  /// Todas as linhas da pessoa numa tabela.
  Future<List<Map<String, dynamic>>> linhasDoUsuario(
    String tabela,
    String userId,
  );

  /// Grava (insere ou atualiza) uma linha.
  Future<void> upsert(
    String tabela,
    Map<String, dynamic> linha, {
    String? onConflict,
  });

  /// Os ritos já gravados no dia, para a união do upload de daily_checkins.
  Future<String?> ritesDoDia(String tabela, String userId, String date);

  /// Apaga a linha da pessoa com este id.
  Future<void> apagarLinha(String tabela, String userId, dynamic id);

  /// Apaga as linhas da pessoa que não são do dia informado.
  Future<void> apagarOutrosDias(String tabela, String userId, String date);
}

/// A implementação de produção, sobre o cliente Supabase.
class ServidorSupabase implements ServidorDeSync {
  ServidorSupabase(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> linhasDoUsuario(
    String tabela,
    String userId,
  ) async {
    final response = await _client.from(tabela).select().eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> upsert(
    String tabela,
    Map<String, dynamic> linha, {
    String? onConflict,
  }) async {
    await _client.from(tabela).upsert(linha, onConflict: onConflict);
  }

  @override
  Future<String?> ritesDoDia(
    String tabela,
    String userId,
    String date,
  ) async {
    final linha = await _client
        .from(tabela)
        .select('rites')
        .eq('user_id', userId)
        .eq('date', date)
        .maybeSingle();
    return linha?['rites'] as String?;
  }

  @override
  Future<void> apagarLinha(String tabela, String userId, dynamic id) async {
    await _client.from(tabela).delete().eq('id', id).eq('user_id', userId);
  }

  @override
  Future<void> apagarOutrosDias(
    String tabela,
    String userId,
    String date,
  ) async {
    await _client
        .from(tabela)
        .delete()
        .eq('user_id', userId)
        .neq('date', date);
  }
}
