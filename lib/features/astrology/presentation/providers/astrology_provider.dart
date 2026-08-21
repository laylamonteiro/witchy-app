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

class AstrologyProvider with ChangeNotifier {
  final AstrologyRepository _repository = AstrologyRepository();
  final ChartCalculator _calculator = ChartCalculator.instance;
  final MagicalInterpreter _interpreter = MagicalInterpreter.instance;
  final AIService _aiService = AIService.instance;

  BirthChartModel? _birthChart;
  MagicalProfile? _magicalProfile;
  bool _isLoading = false;
  String? _generatingSection;
  String? _error;
  String _currentUserId = 'local_user';

  BirthChartModel? get birthChart => _birthChart;
  MagicalProfile? get magicalProfile => _magicalProfile;
  bool get isLoading => _isLoading;
  /// A seção da Análise Personalizada sendo tecida agora (nula em repouso).
  String? get generatingSection => _generatingSection;
  bool get isGeneratingAI => _generatingSection != null;

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
      _error = 'Erro ao carregar mapa natal: $e';
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

      // Salvar no banco
      await _repository.saveBirthChart(chart);

      // Gerar perfil mágico
      final profile = _interpreter.interpretChart(chart);
      await _repository.saveMagicalProfile(profile);

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
      _error = 'Erro ao calcular mapa natal: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
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
      await _repository.saveMagicalProfile(profile);

      _birthChart = chart;
      _magicalProfile = profile;

      _isLoading = false;
      notifyListeners();

      return;
    } catch (e) {
      _error = 'Erro ao atualizar mapa natal: $e';
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
      _error = 'Erro ao deletar mapa natal: $e';
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
      await _repository.saveMagicalProfile(profile);
      _magicalProfile = profile;
    } catch (e) {
      _error = 'Erro ao regenerar perfil: $e';
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
    if (_generatingSection != null) return;

    _generatingSection = sectionKey;
    _error = null;
    notifyListeners();

    try {
      final hashAtual = _generateChartHash(_birthChart!);
      final mesmoMapa = _magicalProfile!.chartHash == hashAtual;
      final acumulado = mesmoMapa ? _magicalProfile!.aiGeneratedText : null;

      final corpo = await _aiService.generateMagicalProfileSection(
        birthChart: _birthChart!,
        profile: _magicalProfile!,
        sectionKey: sectionKey,
      );
      if (corpo.trim().isEmpty) {
        _error = 'Erro ao gerar perfil personalizado';
        return;
      }

      final secao = '${MagicalProfileSections.header(sectionKey)}\n\n$corpo';
      final texto = (acumulado == null || acumulado.trim().isEmpty)
          ? secao
          : '$acumulado\n\n$secao';

      _magicalProfile = _magicalProfile!.copyWith(
        aiGeneratedText: texto,
        chartHash: hashAtual,
      );
      await _repository.saveMagicalProfile(_magicalProfile!);
    } catch (e) {
      _error = 'Erro ao gerar perfil personalizado: $e';
    } finally {
      _generatingSection = null;
      notifyListeners();
    }
  }

  /// Tece de novo uma seção que já existe, no lugar da anterior.
  Future<void> regenerateProfileSection(
    String sectionKey, {
    required bool hasFullAccess,
  }) async {
    if (_magicalProfile == null || !hasFullAccess) return;
    final texto = _magicalProfile!.aiGeneratedText;
    if (texto != null) {
      _magicalProfile = _magicalProfile!.copyWith(
        aiGeneratedText: removeMagicalProfileSection(texto, sectionKey),
      );
    }
    await generateProfileSection(sectionKey, hasFullAccess: hasFullAccess);
  }
}
