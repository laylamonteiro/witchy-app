import 'package:flutter/foundation.dart';

import '../models/free_writing_model.dart';
import '../repositories/free_writing_repository.dart';
import 'reading_archive_composer.dart';

/// Escreve a página de uma leitura no acervo "Meus Registros" no instante em
/// que a leitura acontece.
///
/// Antes havia um botão "Salvar nos Registros" ao pé de cada tiragem. A
/// consulta já era gravada no histórico da própria ferramenta — é dele que
/// saem as Jornadas, o rito do dia e a Leitura do Ciclo —, mas só virava
/// página do acervo se a pessoa tocasse ali. Quem não tocasse ficava com um
/// acervo que não contava a própria prática, e não havia como voltar atrás:
/// meses depois, na hora de pedir a Leitura do Ciclo, o que ficou de fora
/// ficou de fora. Agora a página nasce junto com a tiragem — a Bruxa não tem
/// que se lembrar de guardar o que ela já fez.
///
/// O id da entrada é o MESMO id da leitura, e é isso que sustenta a
/// idempotência: o Conselheiro que chega depois reescreve a página em vez de
/// criar uma segunda, e reabrir uma mesa já tirada (o tarô é idempotente por
/// assinatura) cai na mesma linha.
class ReadingArchiveRecorder {
  ReadingArchiveRecorder({FreeWritingRepository? repository})
      : _repository = repository ?? FreeWritingRepository();

  final FreeWritingRepository _repository;

  /// Grava (ou reescreve) a página da leitura [readingId].
  ///
  /// Best-effort de propósito: a tiragem já aconteceu na tela e o histórico
  /// da ferramenta já a registrou — uma falha ao escrever o acervo não pode
  /// derrubar a leitura na cara da pessoa. Falhou, fica o debugPrint.
  Future<void> record({
    required String readingId,
    required String userId,
    required String source,
    required ArchiveEntry page,
  }) async {
    try {
      // A data de criação é a da TIRAGEM, não a da reescrita: o Conselheiro
      // muda o texto, nunca o momento. É por `created_at` que a Leitura do
      // Ciclo põe a leitura no dia certo da linha do tempo.
      final existing = await _repository.getById(readingId);
      await _repository.insert(
        FreeWritingModel(
          id: readingId,
          userId: userId,
          title: page.title,
          content: page.content,
          source: source,
          createdAt: existing?.createdAt,
        ),
      );
    } catch (e) {
      debugPrint('ReadingArchiveRecorder: falhou ao gravar $source: $e');
    }
  }
}
