import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';

import '../../../../core/content/content_locale.dart';
import '../../../diary/data/models/free_writing_model.dart';
import '../../../diary/data/repositories/free_writing_repository.dart';
import '../../domain/menstrual_day.dart';

/// Strings do idioma atual sem BuildContext, como no ReadingArchiveComposer:
/// a página é "assada" no momento da gravação, igual às páginas das leituras.
AppLocalizations get _l10n =>
    lookupAppLocalizations(ContentLocale.instance.locale);

/// Escreve no Grimório a página do dia que a pessoa registrou no ciclo.
///
/// O pedido é "todos os registros devem ser registrados no Grimório": o dia
/// do ciclo é um registro como o sonho e a gratidão, e ficar só num calendário
/// que só a roda abre era guardá-lo num lugar que o resto do app não enxerga.
///
/// É ESPELHO, e o espelho segue o padrão que o acervo já usa para as leituras
/// (ReadingArchiveRecorder): a página nasce com um id DERIVADO do registro de
/// origem, e por isso gravar de novo reescreve a mesma página em vez de criar
/// uma segunda. A identidade do dia é (conta, dia) — não há uuid em
/// `menstrual_days` —, então é dela que o id sai.
///
/// Três coisas que este gravador NÃO faz, e o porquê de cada uma:
///
/// - não sobe para a nuvem. O id carrega a data em que ela sangrou, e a frase
///   que ela leu para dizer sim diz que o registro fica neste aparelho. Quem
///   cumpre isso é o FreeWritingRepository (`neverLeavesDevice`), nas três
///   portas — upload, lápide da exclusão e varredura. Com UMA brecha ainda
///   aberta, e fora desta frente: a adoção dos dados anônimos no primeiro
///   login recarimba a linha como pendente e o sync do login corre antes da
///   releitura do acervo — ver `FreeWritingRepository._recarimbarEspelhos`,
///   que nomeia a única linha que fecha isso de verdade;
/// - não conta. A página é um segundo rosto do mesmo dia, e somá-la aos
///   Números do Ciclo inflaria `activeDays`, `longestStreak` e a fase "mais
///   presente" com dias que ela registrou uma vez só. O corte está na
///   definição de `writings` e em `_fontesQueNaoContam`
///   (cycle_reading_composer.dart);
/// - não escreve sozinho. Ele só roda dentro do MenstrualCycleRepository, nos
///   verbos que mexem na linha (gravar, apagar, apagar tudo e receber a versão
///   de outro aparelho). Fechar a folha do dia no "Cancelar" não grava linha
///   nenhuma, e portanto não cria página nenhuma.
class MenstrualArchiveRecorder {
  MenstrualArchiveRecorder({FreeWritingRepository? repository})
      : _repository = repository ?? FreeWritingRepository();

  final FreeWritingRepository _repository;

  /// O id da página do dia. Determinístico: é o que torna a gravação
  /// idempotente. A conta entra porque o acervo é uma tabela só para o
  /// aparelho inteiro — o `local_user` de antes do login e a conta real
  /// convivem nela, e dois donos não podem disputar a mesma chave primária.
  static String pageId({required String userId, required String dayKey}) =>
      'menstrual-$userId-$dayKey';

  /// Grava (ou reescreve) a página do dia.
  ///
  /// Erros SOBEM, ao contrário do gravador das leituras. Lá a tiragem já
  /// aconteceu na tela e a página é um extra; aqui a página é a metade
  /// visível de um registro que a tela acabou de prometer que guardou — e
  /// quem chama já trata a falha: a folha do dia mostra
  /// `menstrualSaveError` e mantém o que ela escreveu.
  Future<void> record(MenstrualDay day) async {
    final l10n = _l10n;
    final blocos = <String>[
      '✦ ${l10n.menstrualArchiveMark}\n${_markOf(l10n, day.mark)}',
      if (day.flow != null)
        '✦ ${l10n.menstrualArchiveFlow}\n${_flowOf(l10n, day.flow!)}',
      if (day.symptoms.isNotEmpty)
        '✦ ${l10n.menstrualArchiveSymptoms}\n'
            '${day.symptoms.map((id) => _symptomOf(l10n, id)).join(', ')}',
      if ((day.mood ?? '').trim().isNotEmpty)
        '✦ ${l10n.menstrualArchiveMood}\n${day.mood!.trim()}',
      if (day.note.trim().isNotEmpty)
        '✦ ${l10n.menstrualArchiveNote}\n${day.note.trim()}',
    ];

    // Tira primeiro qualquer página que este dia já tenha, mesmo com chave
    // antiga: a adoção dos dados anônimos troca o dono da linha e mantém o
    // `id`, então um dia registrado antes do login tem a página com a chave
    // de `local_user`. Sem esta limpeza, a gravação seguinte criaria uma
    // SEGUNDA página do mesmo dia — e o apagar do dia só alcançaria uma.
    await _repository.deleteDeviceOnly(
      userId: day.userId,
      source: FreeWritingSource.menstrual,
      idEndsWith: '-${day.dayKey}',
    );
    await _repository.insert(
      FreeWritingModel(
        id: pageId(userId: day.userId, dayKey: day.dayKey),
        userId: day.userId,
        title: l10n.menstrualArchiveTitle,
        content: blocos.join('\n\n'),
        source: FreeWritingSource.menstrual,
        // As DUAS datas são o dia OBSERVADO, nunca o instante da digitação.
        // O cartão do acervo mostra `updatedAt` e a lista ordena por
        // `updated_at DESC`: com o instante da digitação, um dia de março
        // preenchido em abril apareceria como abril e subiria ao topo da
        // lista — e corrigir um sintoma meses depois republicaria o dia no
        // alto do Grimório, que é o contrário de discrição.
        createdAt: day.day,
        updatedAt: day.day,
        // Carimbo de "não sobe". O repositório o repõe de qualquer forma;
        // está aqui para que a linha já nasça fora do alcance da varredura,
        // mesmo que alguém um dia insira por outro caminho.
        synced: true,
      ),
    );
  }

  /// Tira a página do dia do Grimório.
  ///
  /// Também sobe erro: uma página que sobrevive ao dia apagado é um fantasma
  /// que continua contando o que ela pediu para esquecer — falhar em voz alta
  /// é melhor do que deixá-lo lá em silêncio.
  Future<void> erase({required String userId, required DateTime day}) async {
    // Pelo FIM do id (o dia), e não pelo id inteiro: ver a nota da adoção em
    // `deleteDeviceOnly`. Uma página com a chave velha é do mesmo dia e da
    // mesma pessoa, e tem de sair junto.
    await _repository.deleteDeviceOnly(
      userId: userId,
      source: FreeWritingSource.menstrual,
      idEndsWith: '-${MenstrualDay.keyOf(day)}',
    );
  }

  /// Tira do Grimório todas as páginas do ciclo desta conta — o gesto do
  /// "apagar meus registros do ciclo".
  Future<void> eraseAll(String userId) async {
    await _repository.deleteDeviceOnly(
      userId: userId,
      source: FreeWritingSource.menstrual,
    );
  }

  static String _markOf(AppLocalizations l10n, MenstrualMark mark) =>
      switch (mark) {
        MenstrualMark.start => l10n.menstrualMarkStart,
        MenstrualMark.flow => l10n.menstrualMarkFlow,
        MenstrualMark.spotting => l10n.menstrualMarkSpotting,
        MenstrualMark.end => l10n.menstrualMarkEnd,
        MenstrualMark.note => l10n.menstrualMarkNote,
      };

  static String _flowOf(AppLocalizations l10n, MenstrualFlowLevel flow) =>
      switch (flow) {
        MenstrualFlowLevel.light => l10n.menstrualFlowLight,
        MenstrualFlowLevel.medium => l10n.menstrualFlowMedium,
        MenstrualFlowLevel.heavy => l10n.menstrualFlowHeavy,
      };

  /// Os mesmos rótulos da folha do dia (MenstrualRecordForm.symptoms): a
  /// página tem de dizer "Cólica", e não o código `cramps`.
  static String _symptomOf(AppLocalizations l10n, String id) => switch (id) {
        'cramps' => l10n.menstrualSymptomCramps,
        'headache' => l10n.menstrualSymptomHeadache,
        'tired' => l10n.menstrualSymptomTired,
        'nausea' => l10n.menstrualSymptomNausea,
        'back' => l10n.menstrualSymptomBack,
        _ => l10n.menstrualSymptomMood,
      };
}
