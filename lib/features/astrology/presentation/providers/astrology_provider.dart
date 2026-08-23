import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../../../../core/ai/ai_service.dart';
import '../../data/models/birth_chart_model.dart';
import '../../data/models/magical_profile_report.dart';
import '../../data/models/magical_profile_model.dart';
import '../../data/repositories/astrology_repository.dart';
import '../../data/services/chart_calculator.dart';
import '../../data/services/magical_interpreter.dart';
import '../../../../core/content/content_locale.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// O texto de falha que chega à tela sai daqui, e não de string cravada: as
/// cinco mensagens deste provider eram português com o dump da exceção
/// dentro. Chegavam assim em inglês e espanhol, e o scanner de hardcoded não
/// as via porque nenhuma tinha acento.
AppLocalizations get _l10n =>
    lookupAppLocalizations(ContentLocale.instance.locale);

class AstrologyProvider with ChangeNotifier {
  final AstrologyRepository _repository = AstrologyRepository();
  final ChartCalculator _calculator = ChartCalculator.instance;
  final MagicalInterpreter _interpreter = MagicalInterpreter.instance;
  final AIService _aiService = AIService.instance;

  BirthChartModel? _birthChart;
  MagicalProfile? _magicalProfile;
  bool _isLoading = false;
  final Set<String> _tecendo = <String>{};

  /// Por que cada seção da Análise Personalizada não veio.
  ///
  /// Por SEÇÃO, e não uma falha só para todas. A trava de geração já era por
  /// seção — abrir um card enquanto outro termina é o normal de quem está
  /// explorando —, mas o erro continuava global: a seção que falhasse marcava
  /// falha em TODAS as outras abertas, inclusive nas que estavam indo bem.
  final Map<String, _FalhaDaSecao> _falhas = <String, _FalhaDaSecao>{};

  /// Dublê do tecelão de seção, nulo em produção.
  ///
  /// O teste de concorrência do acúmulo precisa mandar duas seções terminarem
  /// em ordens controladas. O risco que ele vigia mora na
  /// leitura-depois-da-chamada e na fila de gravação — que rodam de verdade —
  /// e não na chamada de rede da IA, que é só a borda. Mesmo racional do
  /// ServidorDeSync no DataSyncService.
  @visibleForTesting
  Future<String> Function({
    required BirthChartModel birthChart,
    required MagicalProfile profile,
    required String sectionKey,
  })? tecelaoDeTeste;

  /// Entrega mapa e perfil prontos ao teste, sem passar pelo cálculo do mapa.
  @visibleForTesting
  void adotarMapaParaTeste(BirthChartModel chart, MagicalProfile profile) {
    _birthChart = chart;
    _magicalProfile = profile;
  }

  String? _error;
  String _currentUserId = 'local_user';

  BirthChartModel? get birthChart => _birthChart;
  MagicalProfile? get magicalProfile => _magicalProfile;
  bool get isLoading => _isLoading;
  /// Esta seção da Análise Personalizada está sendo tecida agora?
  ///
  /// Por seção, e não uma de cada vez: abrir um card enquanto outro ainda
  /// termina é o comportamento normal de quem está explorando, e a trava
  /// global fazia o segundo card não começar nunca — ficava numa tela morta
  /// até tocar em "tentar novamente".
  bool isWeavingSection(String key) => _tecendo.contains(key);
  bool get isGeneratingAI => _tecendo.isNotEmpty;

  /// Uma gravação de perfil por vez.
  ///
  /// O acúmulo em memória já é atômico (o texto é lido DEPOIS da chamada de
  /// IA), mas cada gravação sobe um upsert próprio. Duas seções terminando
  /// juntas punham dois POST no ar sem alvo de conflito e sem guarda por
  /// `updated_at`: o servidor ficava com o que chegasse por último — que
  /// pode ser o mais VELHO. E o local ficava certo e marcado como
  /// sincronizado, então nada corrigia depois; a seção perdida só reaparecia
  /// quando alguém sujasse a linha de novo.
  ///
  /// A fila ordena as gravações DENTRO deste processo. Dois aparelhos ao
  /// mesmo tempo continuam se atropelando — isso é guarda no servidor, e
  /// está descrito em supabase/perfil_magico_upsert.sql.
  Future<void> _filaDePerfil = Future<void>.value();

  Future<void> _gravarPerfil(MagicalProfile perfil) {
    final proxima =
        _filaDePerfil.then((_) => _repository.saveMagicalProfile(perfil));
    // A fila não pode morrer numa falha: a próxima seção ainda precisa
    // gravar. O erro continua indo para quem chamou.
    _filaDePerfil = proxima.catchError((_) {});
    return proxima;
  }

  /// O motivo pelo qual ESTA seção não veio — null se ela não falhou.
  String? erroDaSecao(String key) => _falhas[key]?.mensagem;

  /// ESTA seção falhou por limite de requisições do provedor de IA?
  ///
  /// A tela troca isso por uma frase que orienta ("aguarde e tente de novo"),
  /// em vez do nome de uma classe de exceção.
  bool falhaDeLimiteNaSecao(String key) =>
      _falhas[key]?.foiLimiteDoProvedor ?? false;

  /// As seções já tecidas, na ordem em que foram guardadas.
  ///
  /// O parse é memorizado pelo próprio texto: a tela pergunta isto a cada
  /// build, e reparsear um markdown de milhares de caracteres a 60 quadros
  /// por segundo seria desperdício puro.
  List<ProfileSection> get profileSections {
    final texto = _magicalProfile?.aiGeneratedText;
    if (texto != _secoesDe) {
      _secoesDe = texto;
      _secoes = texto == null ? const [] : parseMagicalProfile(texto);
    }
    return _secoes;
  }

  /// A seção guardada para esta chave, se já tiver sido tecida.
  ProfileSection? profileSection(String key) {
    for (final secao in profileSections) {
      if (secao.key == key) return secao;
    }
    return null;
  }

  List<ProfileSection> _secoes = const [];
  String? _secoesDe;
  String? get error => _error;
  bool get hasBirthChart => _birthChart != null;
  bool get hasMagicalProfile => _magicalProfile != null;
  bool get hasAIGeneratedProfile => _magicalProfile?.aiGeneratedText != null;

  Future<void> setUserId(String userId) async {
    if (_currentUserId == userId) return;
    _currentUserId = userId;
    await loadBirthChart();
  }

  /// Carrega o mapa natal do usuário (se existir)
  Future<void> loadBirthChart([String? userId]) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final effectiveUserId = userId ?? _currentUserId;
      _birthChart = await _repository.getBirthChart(effectiveUserId);

      if (_birthChart != null) {
        // Recalcula silenciosamente se o mapa foi gerado por uma versão antiga
        // do algoritmo (ex.: antes dos novos pontos místicos).
        await _recalculateIfOutdated();
        // Carregar perfil mágico também
        _magicalProfile = await _repository.getMagicalProfile(effectiveUserId);
      }
    } catch (e) {
      debugPrint('Mapa natal: falha ao carregar: $e');
      _error = _l10n.errorsGeneric;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Recalcula um mapa salvo cuja versão de cálculo esteja desatualizada,
  /// reaproveitando os dados de nascimento originais. Preserva o id (mesma
  /// linha no banco) e não mexe no perfil mágico/IA. Falha em silêncio,
  /// mantendo o mapa antigo se o recálculo não for possível.
  Future<void> _recalculateIfOutdated() async {
    final chart = _birthChart;
    if (chart == null || chart.calcVersion >= kChartCalcVersion) return;

    try {
      final recalculated = await _calculator.calculateBirthChart(
        userId: chart.userId,
        birthDate: chart.birthDate,
        birthTime: chart.birthTime,
        birthPlace: chart.birthPlace,
        latitude: chart.latitude,
        longitude: chart.longitude,
        unknownBirthTime: chart.unknownBirthTime,
      );
      final updated = recalculated.copyWith(id: chart.id, userId: chart.userId);
      await _repository.updateBirthChart(updated);
      _birthChart = updated;
    } catch (e) {
      debugPrint('Falha ao recalcular mapa desatualizado: $e');
    }
  }

  /// Calcula e salva um novo mapa natal
  Future<BirthChartModel?> calculateAndSaveBirthChart({
    required DateTime birthDate,
    required TimeOfDay birthTime,
    required String birthPlace,
    required double latitude,
    required double longitude,
    bool unknownBirthTime = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Calcular mapa natal
      final chart = await _calculator.calculateBirthChart(
        userId: _currentUserId,
        birthDate: birthDate,
        birthTime: birthTime,
        birthPlace: birthPlace,
        latitude: latitude,
        longitude: longitude,
        unknownBirthTime: unknownBirthTime,
      );

      // O mapa que existia antes desta correção, para poder limpá-lo depois.
      final anterior = _birthChart;

      // Salvar no banco
      await _repository.saveBirthChart(chart);

      // Gerar perfil mágico
      final profile = _interpreter.interpretChart(chart);
      await _gravarPerfil(profile);

      // O mapa anterior vira lixo apontando para nada.
      //
      // O perfil é carimbado pelo id do MAPA. Corrigir a data ou a hora de
      // nascimento faz nascer um mapa com id novo, e o perfil antigo ficava
      // pendurado no id velho: as dez seções que a pessoa mandou tecer
      // simplesmente não estavam mais lá, e nada oferecia trazê-las de volta
      // nem apagava o registro órfão. Some depois de o novo estar gravado —
      // uma falha no meio não pode deixar a pessoa sem mapa nenhum.
      if (anterior != null && anterior.id != chart.id) {
        try {
          await _repository.deleteMagicalProfile(anterior.id);
          await _repository.deleteBirthChart(anterior.id);
        } catch (e) {
          // Lixo que sobrou não justifica falhar o recálculo, que é o que a
          // pessoa pediu. Fica registrado para quem for olhar.
          debugPrint('Mapa natal: falha ao limpar o mapa anterior: $e');
        }
      }

      // Atualizar estado
      _birthChart = chart;
      _magicalProfile = profile;

      _isLoading = false;
      notifyListeners();

      // A Análise Personalizada NÃO é gerada aqui: cada seção é tecida
      // quando a pessoa abre o card dela. Gerar as dez de uma vez torrava
      // chamadas de IA que quase ninguém lia inteiras.
      return chart;
    } catch (e) {
      debugPrint('Mapa natal: falha ao calcular: $e');
      _error = _l10n.errorsGeneric;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Descarta a Análise Personalizada já gravada, para ela ser tecida de novo
  /// no formato de dez cards.
  ///
  /// Só o texto de IA sai — o mapa e o Perfil Mágico continuam inteiros.
  ///
  /// A pedido da pessoa, NUNCA sozinho: quinze dos dezesseis perfis em
  /// produção estão no formato antigo, e migrar em silêncio gastaria dez
  /// chamadas de IA por perfil sem ninguém pedir. Quem decide é ela.
  Future<bool> descartarAnalisePersonalizada() async {
    final perfil = _magicalProfile;
    if (perfil == null || perfil.aiGeneratedText == null) return false;

    try {
      final limpo = perfil.copyWith(limparTextoDeIa: true);
      await _gravarPerfil(limpo);
      _magicalProfile = limpo;
      _secoes = const [];
      _secoesDe = null;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Perfil mágico: falha ao descartar a análise antiga: $e');
      _error = _l10n.errorsGeneric;
      notifyListeners();
      return false;
    }
  }

  /// Atualiza o mapa natal existente
  Future<void> updateBirthChart(BirthChartModel chart) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateBirthChart(chart);

      // Regenerar perfil mágico
      final profile = _interpreter.interpretChart(chart);
      await _gravarPerfil(profile);

      _birthChart = chart;
      _magicalProfile = profile;

      _isLoading = false;
      notifyListeners();

      return;
    } catch (e) {
      debugPrint('Mapa natal: falha ao atualizar: $e');
      _error = _l10n.errorsGeneric;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Deleta o mapa natal
  Future<void> deleteBirthChart() async {
    if (_birthChart == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteBirthChart(_birthChart!.id);
      _birthChart = null;
      _magicalProfile = null;
    } catch (e) {
      debugPrint('Mapa natal: falha ao apagar: $e');
      _error = _l10n.errorsGeneric;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Regenera o perfil mágico
  Future<void> regenerateMagicalProfile() async {
    if (_birthChart == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final profile = _interpreter.interpretChart(_birthChart!);
      await _gravarPerfil(profile);
      _magicalProfile = profile;
    } catch (e) {
      debugPrint('Perfil mágico: falha ao regerar: $e');
      _error = _l10n.errorsGeneric;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Gera hash único do mapa astral para comparação
  String _generateChartHash(BirthChartModel chart) {
    final data =
        '${chart.birthDate.toIso8601String()}_${chart.birthTime.hour}_${chart.birthTime.minute}_${chart.latitude}_${chart.longitude}';
    return md5.convert(utf8.encode(data)).toString();
  }

  /// Tece UMA seção da Análise Personalizada — a que a pessoa acabou de
  /// abrir.
  ///
  /// Sob demanda por dois motivos. O primeiro é custo: tecer as dez de uma
  /// vez gastava dez chamadas de IA para uma pessoa que talvez lesse duas.
  /// O segundo é a integridade do texto: cada seção tem a chamada inteira
  /// para si, então nenhuma sai cortada pelo teto de tokens de um relatório
  /// gerado de uma vez só.
  ///
  /// O texto guardado é o mesmo markdown de sempre — as seções vão sendo
  /// acrescentadas nele, e cada acréscimo é salvo (e sincronizado) na hora.
  /// Se o mapa mudou desde a última seção, o que havia é descartado: seria
  /// um relatório costurado de dois mapas diferentes.
  Future<void> generateProfileSection(
    String sectionKey, {
    required bool hasFullAccess,
  }) async {
    if (_birthChart == null || _magicalProfile == null) return;
    // A análise é produto Premium: sem acesso, não se gera nem se guarda
    // (fail-closed — esconder na tela o que já está no aparelho nunca foi
    // proteção).
    if (!hasFullAccess) return;
    if (_tecendo.contains(sectionKey)) return;

    _tecendo.add(sectionKey);
    // A falha ANTERIOR desta seção sai agora: quem manda tecer de novo não
    // pode ver o erro da tentativa passada enquanto a nova roda.
    _falhas.remove(sectionKey);
    notifyListeners();

    try {
      final tecelao =
          tecelaoDeTeste ?? _aiService.generateMagicalProfileSection;
      final corpo = await tecelao(
        birthChart: _birthChart!,
        profile: _magicalProfile!,
        sectionKey: sectionKey,
      );
      if (corpo.trim().isEmpty) {
        // Sem motivo a exibir: a tela mostra a falha genérica, que é o que
        // dá para dizer com honestidade quando a resposta volta vazia.
        debugPrint('Perfil mágico: seção $sectionKey voltou vazia');
        _falhas[sectionKey] = const _FalhaDaSecao();
        return;
      }

      // O acumulado é lido DEPOIS da chamada, nunca antes: duas seções
      // tecendo ao mesmo tempo liam o mesmo texto no começo e a segunda a
      // terminar apagava a primeira.
      final hashAtual = _generateChartHash(_birthChart!);
      final mesmoMapa = _magicalProfile!.chartHash == hashAtual;
      // Mapa trocado desde a última seção: o que havia é descartado, senão
      // o relatório ficaria costurado de dois mapas diferentes.
      final guardado = mesmoMapa ? _magicalProfile!.aiGeneratedText : null;
      // Tirar a versão anterior desta seção antes de acrescentar a nova é o
      // que faz "tecer de novo" ser só tecer: sem isto sobrariam duas
      // seções com a mesma chave, e a tela abriria a velha. E a antiga só
      // sai depois que a nova chega — uma falha não apaga o que existia.
      final acumulado = guardado == null
          ? null
          : removeMagicalProfileSection(guardado, sectionKey);

      final secao = '${MagicalProfileSections.header(sectionKey)}\n\n$corpo';
      final texto = (acumulado == null || acumulado.trim().isEmpty)
          ? secao
          : '$acumulado\n\n$secao';

      _magicalProfile = _magicalProfile!.copyWith(
        aiGeneratedText: texto,
        chartHash: hashAtual,
      );
      await _gravarPerfil(_magicalProfile!);
    } on AiRateLimitException {
      _falhas[sectionKey] = const _FalhaDaSecao(foiLimiteDoProvedor: true);
    } catch (e) {
      // As exceções que a camada de IA lança já vêm com texto pronto para a
      // tela — e agora sem o detalhe do Dio dentro, que trazia a URL do
      // provedor. O que sobra aqui é tirar o prefixo `Exception: `, que é
      // ruído do Dart, e deixar o texto original no log.
      debugPrint('Perfil mágico: seção $sectionKey falhou: $e');
      _falhas[sectionKey] = _FalhaDaSecao(
        mensagem: '$e'.replaceAll('Exception: ', ''),
      );
    } finally {
      _tecendo.remove(sectionKey);
      notifyListeners();
    }
  }
}

/// Por que uma seção da Análise Personalizada não veio.
///
/// Sem mensagem, a tela mostra a falha genérica — é o que dá para dizer com
/// honestidade quando a resposta volta vazia.
class _FalhaDaSecao {
  const _FalhaDaSecao({
    this.mensagem,
    this.foiLimiteDoProvedor = false,
  });

  final String? mensagem;
  final bool foiLimiteDoProvedor;
}
