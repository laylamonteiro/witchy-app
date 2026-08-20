import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../../../../core/ai/ai_service.dart';
import '../../data/models/birth_chart_model.dart';
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
  bool _isGeneratingAI = false;
  String? _error;
  String _currentUserId = 'local_user';

  BirthChartModel? get birthChart => _birthChart;
  MagicalProfile? get magicalProfile => _magicalProfile;
  bool get isLoading => _isLoading;
  bool get isGeneratingAI => _isGeneratingAI;
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
  ///
  /// [hasFullAccess] decide se a análise personalizada (produto Premium)
  /// entra junto: sem acesso, ela nem é pedida à IA.
  Future<BirthChartModel?> calculateAndSaveBirthChart({
    required DateTime birthDate,
    required TimeOfDay birthTime,
    required String birthPlace,
    required double latitude,
    required double longitude,
    required bool hasFullAccess,
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

      // Gerar texto personalizado com Conselheiro Místico automaticamente
      _isLoading = false;
      notifyListeners();

      // Iniciar geração do texto IA em background
      generateAIMagicalProfile(hasFullAccess: hasFullAccess);

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
  Future<void> updateBirthChart(
    BirthChartModel chart, {
    required bool hasFullAccess,
  }) async {
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

      // Regenerar texto personalizado com Conselheiro Místico
      _isLoading = false;
      notifyListeners();

      // Iniciar geração do texto em background
      generateAIMagicalProfile(hasFullAccess: hasFullAccess);

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

  /// Gera texto personalizado do perfil mágico com IA
  Future<void> generateAIMagicalProfile({required bool hasFullAccess}) async {
    if (_birthChart == null || _magicalProfile == null) return;

    // A análise personalizada é produto Premium: sem acesso, não se gera nem
    // se guarda (fail-closed — esconder na tela o que já está no aparelho
    // nunca foi proteção). A degustação é gerada à parte, do tamanho dela.
    if (!hasFullAccess) return;

    // Verificar se já existe texto gerado para o mesmo mapa
    final currentHash = _generateChartHash(_birthChart!);
    if (_magicalProfile!.aiGeneratedText != null &&
        _magicalProfile!.chartHash == currentHash) {
      return;
    }

    _isGeneratingAI = true;
    _error = null;
    notifyListeners();

    try {
      final aiText = await _aiService.generateMagicalProfileText(
        birthChart: _birthChart!,
        profile: _magicalProfile!,
      );

      // Atualizar perfil com texto IA
      _magicalProfile = _magicalProfile!.copyWith(
        aiGeneratedText: aiText,
        chartHash: currentHash,
      );

      // Salvar perfil atualizado
      await _repository.saveMagicalProfile(_magicalProfile!);
    } catch (e) {
      _error = 'Erro ao gerar perfil personalizado: $e';
    } finally {
      _isGeneratingAI = false;
      notifyListeners();
    }
  }

  /// Força regeneração do texto IA (mesmo que já exista)
  Future<void> regenerateAIMagicalProfile({required bool hasFullAccess}) async {
    if (_birthChart == null || _magicalProfile == null) return;
    if (!hasFullAccess) return;

    _isGeneratingAI = true;
    _error = null;
    notifyListeners();

    try {
      final aiText = await _aiService.generateMagicalProfileText(
        birthChart: _birthChart!,
        profile: _magicalProfile!,
      );

      final currentHash = _generateChartHash(_birthChart!);

      _magicalProfile = _magicalProfile!.copyWith(
        aiGeneratedText: aiText,
        chartHash: currentHash,
      );

      await _repository.saveMagicalProfile(_magicalProfile!);
    } catch (e) {
      _error = 'Erro ao regenerar perfil: $e';
    } finally {
      _isGeneratingAI = false;
      notifyListeners();
    }
  }
}
